# lec8-code

Welcome to the Lecture 8 demo, iOstagram! In this, we will be making a small social media platform. It will let users create channels, and then post messages in those channels. The main focus of this is the network requests, and as such, we have already given you all views needed for this. You will only need to work on `NetworkManager.swift` and `ChatViewModel.swift`.

# Step 1

Open up `ChatModel.swift` and get familiar with it. Note that there is a decent amount of stuff going on here. We have already declared some initializers, including the ones necessary for decoding. Note the `init(from decoder: Decoder) throws {` initializer for `Channel`, which doesn't actually decode the `lastUpdatedAt` but instead sets in manually.

What you have to do here is add the conformances to the `Channel` and `Post` structs. We want them both to be `Identifiable` (we have already discussed what this does previously) and `Hashable`. Now you will also have to make `Channel` and `Post` conform to one of `Decodable`, `Encodable`, or both, so `Codable`, but we won't tell you which yet. Put this off for now and complete the `NetworkManager.swift` and `ChatViewModel.swift` first. We will come back to it later.

# Step 2

Now that you're familiar with the structs of data, checkout the `NetworkManager.swift` file. First, change the `baseURL` to the one we tell you in class. Then, you will see 4 functions that you should complete; you DO NOT need to modify the function signatures. The routes you will need to use are

- GET `"\(baseUrl)/channels"` to get all the channels
- POST `"\(baseUrl)/channels?channel={channelName}"` to make a channel (where `channelName` is the name of the channel)
- GET `"\(baseUrl)/posts?channel={channelName}"` to get all the posts of channel with name `channelName`
- POST `"\(baseUrl)/posts?channel={channelName}"` to make a post in channel with name `channelName` (where the body is a JSON encoded post)

We will walk you through `makePost`, but try to figure out the others yourself! For `makePost`, we will first make the url for the request like so:

```swift
func makePost(post: Post, channelName: String) async throws {
    var components = URLComponents(string: "\(baseUrl)/posts")!
    components.queryItems = [
        URLQueryItem(name: "channel", value: channelName)
    ]
    
    guard let url = components.url else {
        throw NetworkError.invalidURL
    }
}
```

Note that we are setting the query components through `URLComponents`. You can try to manually encode them into the string, but you should not do this as then special characters (like spaces) wont be encoded properly. Now we make the url request, encode the data, and set the request body like so:

```swift
func makePost(post: Post, channelName: String) async throws {
    var components = URLComponents(string: "\(baseUrl)/posts")!
    components.queryItems = [
        URLQueryItem(name: "channel", value: channelName)
    ]
    
    guard let url = components.url else {
        throw NetworkError.invalidURL
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(post)
}
```

Finally we check the response to make sure there wasn't an error, and throw otherwise:

```swift
func makePost(post: Post, channelName: String) async throws {
    var components = URLComponents(string: "\(baseUrl)/posts")!
    components.queryItems = [
        URLQueryItem(name: "channel", value: channelName)
    ]
    
    guard let url = components.url else {
        throw NetworkError.invalidURL
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(post)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode <= 299 else {
        throw NetworkError.networkError
    }
}
```

To complete the other 4 functions, you might not need to even set the body, and make sure the change the `httpMethod` appropriately. You also might need to decode the data from the response, like so for `getPosts`:

```swift
return try JSONDecoder().decode([Post].self, from: data)
```

We'll let you figure out the rest!

# Step 3

Now in `ChatViewModel.swift`, first complete the `makeChannel` function like so:

```swift
func makeChannel(channelName: String) async {
    if let newChannel = try? await NetworkManager.instance.makeChannel(channelName: channelName) {
        self.channels[newChannel.channelId] = newChannel
    }
}
```

This is calling the network request, and if it's successful, it updates the dictionary of channels in the view model (which will then update the views). Note the use of `try?` for the request, and the optional binding to check success (and no error thrown). Now for make post, we will instead use a do-catch:

```swift
func makePost(content: String, channelId: UUID) async {
    let post = Post(author: username, content: content, createdAt: Date())
    guard let channel = channels[channelId] else { return }
    do {
        try await NetworkManager.instance.makePost(post: post, channelName: channel.name)
        self.channels[channelId]!.posts.append(post)
        self.channels[channelId]!.lastUpdatedAt = Date()
    } catch let error {
        print(error)
    }
}
```

Now complete the other two functions in a similar manner:

```swift
func refreshChannels() async {
    do {
        let newChannels = try await NetworkManager.instance.getChannels()
        self.channels = newChannels.reduce(into: [:]) { $0[$1.channelId] = $1 }
    } catch let error {
        print("Error refreshing channels \(error)")
    }
}
```

```swift
func refreshPosts(channelId: UUID) async {
    guard let channel = channels[channelId] else { return }
    if let newPosts = try? await NetworkManager.instance.getPosts(channelName: channel.name) {
        self.channels[channelId]!.posts = newPosts
        self.channels[channelId]!.lastUpdatedAt = Date()
    }
}
```

# Step 4

Now go back in and add the minimum conformances necessary for `Channel` and `Post` if you haven't already. Also, add an initializer for the view model that refreshes the channels, like so:

```swift
init() {
    Task {
        await refreshChannels()
    }
}
```

Now what is this `Task`? It is ensuring that the nested code is being called in an async manner, in a separate thread.

# Step 5

You're done!