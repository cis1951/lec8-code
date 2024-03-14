const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const WebSocket = require('ws');
const mongodb = require('mongodb');
const MongoClient = mongodb.MongoClient;

const app = express();
app.use(cors());

const port = process.env.PORT || 3000;
const wss = new WebSocket.Server({ noServer: true });
const mongoUrl = process.env.DB_URL;
const dbName = 'chatdb';
let db;

MongoClient.connect(mongoUrl, { useNewUrlParser: true, useUnifiedTopology: true }, (err, client) => {
  if (err) {
    return console.log(err);
  }
  db = client.db(dbName);
  db.createCollection('channels', (err, res) => {
    if (err) {
      console.log(err);
    } else {
      console.log("Created channels collection");
    }
  });

  app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}/`);
  });
});

app.get('/channels', async (req, res) => {
  try {
    const channels = await db.collection('channels').find().toArray();

    for (let channel of channels) {
      const posts = await db.collection(`${channel.name}_posts`).find().toArray();
      channel.posts = posts;
    }

    return res.json(channels);
  } catch (error) {
    return res.status(500).send(error.message);
  }
});

app.post('/channels', async (req, res) => {
  try {
    const channelName = req.query.channel;
    if (!channelName) {
      return res.status(400).send('Channel name is required');
    }

    const existingChannel = await db.collection('channels').findOne({ name: channelName });
    if (existingChannel) {
      return res.status(400).send('Channel already exists');
    }

    const newChannel = { id: uuidv4(), name: channelName, posts: [] };

    db.createCollection(`${channelName}_posts`, (err, res) => {
      if (err) {
        console.log(err);
        return res.status(500).send(err);
      } else {
        console.log(`Created ${channelName}_posts collection`);
      }
    });

    await db.collection('channels').insertOne(newChannel);
    return res.json(newChannel);
  } catch (error) {
    return res.status(500).send(error.message);
  }
});

app.delete('/channels', async (req, res) => {
  try {
    const channelName = req.query.channel;
    if (!channelName) {
      return res.status(400).send('Channel name is required');
    }

    const channel = await db.collection('channels').findOne({ name: channelName });
    if (!channel) {
      return res.status(404).send('Channel not found');
    }

    await db.collection('channels').deleteOne({ name: channelName });
    await db.collection(`${channelName}_posts`).drop();
    return res.status(204).send('Channel deleted');
  } catch (error) {
    return res.status(500).send(error.message);
  }
});

app.get('/posts', async (req, res) => {
  try {
    const channelName = req.query.channel;
    if (!channelName) {
      return res.status(400).send('Channel name is required');
    }

    const channel = await db.collection('channels').findOne({ name: channelName });
    if (!channel) {
      return res.status(404).send('Channel not found');
    }

    const limit = parseInt(req.query.limit, 10) || 10;
    const posts = await db.collection(`${channelName}_posts`).find().sort({ date: -1 }).limit(limit).toArray();
    return res.json(posts);
  } catch (error) {
    return res.status(500).send(error.message);
  }
});

app.post('/posts', express.json(), async (req, res) => {
  try {
    const channelName = req.query.channel;
    if (!channelName) {
      return res.status(400).send('Channel name is required');
    }

    const channel = await db.collection('channels').findOne({ name: channelName });
    if (!channel) {
      return res.status(404).send('Channel not found');
    }

    const post = req.body;
    if (!post) {
      return res.status(400).send('Post is required');
    }

    await db.collection(`${channelName}_posts`).insertOne(post);

    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify(post));
      }
    });

    return res.status(201).send('Post made');
  } catch (error) {
    return res.status(500).send(error.message);
  }
});



wss.on('connection', (ws) => {
  ws.on('post', async (content) => {
    try {
      const body = JSON.parse(content);
      let newPost = body.post;

      const channel = await db.collection('channels').findOne({ name: body.channel });
      if (!channel) {
        throw new Error('Channel does not exist');
      }

      await db.collection(`${body.channel}_posts`).insertOne(newPost);

      wss.clients.forEach((client) => {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(content);
        }
      });
    } catch (error) {
      console.error('Error processing post:', error);
    }
  });
});

app.on('upgrade', (request, socket, head) => {
  wss.handleUpgrade(request, socket, head, (ws) => {
    wss.emit('connection', ws, request);
  });
});
