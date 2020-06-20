# recommender-vapor
A recommender service for Vapor, using the [gorse](https://gorse.io) recommender system

#Getting started

Added Recommender to your `Package.swift`

```swift
.package(url: "https://github.com/mborsten/recommender-vapor.git", from: "0.0.1-alpha"),
```

# Usage

Recommender uses `gorse` to recommend items based on `User`s ratings. The default config expects the gorse service to be available at
http://0.0.0.0:5050.

You can use the example `docker-compose.yml` file:

```bash
cd docker
docker-compose build
docker-compose up
```

Extend you Item's model:

```swift
extension Item: RecommendableItem { }
```

Now you can add ratings (in the context of an authenticated user)

```swift
let protected = routes.grouped(User.authenticator())
protected.post("items", ":itemId", "like") {
  let user = try request.auth.require(User.self)
          return request
              .recommend
              .insertFeedback(userId: try user.requireID().uuidString, itemId: request.parameters.get("itemId")!, rating: 5)
              .map { .ok }
}
```

To retrieve a list of recommended items

```swift
let protected = routes.grouped(User.authenticator())
protected.post("items", "recommended") {
  let user = try request.auth.require(User.self)
  return Item.recommended(req: request, userId: try user.requireID())
}
```
