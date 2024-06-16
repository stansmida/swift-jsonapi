# Swift JSON:API

This package aims to provide a typed API for working with JSON:API documents in Swift.

Currently for my personal use, incomplete, perhaps incorrect, and to be finalized gradually
according to my needs but anyone is welcomed to use it as is or get inspired and fork their
implementation.

# Document

Represented by `Document`.

- [x] `data`
- [x] `errors`
- [x] `meta`
- [ ] a member defined by an applied extension
- [x] `jsonapi`
- [x] `links` (⚠️ not typed yet)
- [x] `included`

## `data`

Represented by `Document.Data` generic parameter.

- a single resource object: `ResourceObject` or `ResourceRepresentable`.
- a single resource identifier object: `ResourceIdentifierObject` (`ResourceObject<T, Never, Never, Never, Never>`).
- null: `ResourceObject?` or `ResourceRepresentable?`.
- an array of resource objects: `[ResourceObject]` or `[ResourceRepresentable]`, can be empty.
- an array of resource identifier objects: `[ResourceIdentifierObject]`, can be empty.

### Resource objects

Represented by `ResourceObject<T, Attributes, Relationships, Links, Meta>`. So the resource identifier object is the same type with just the identity member: `ResourceObject<T, Never, Never, Never, Never>`. `ResourceRepresentable` is a protocol for resource object models that allows for convenient conversion into `ResourceObject`.

- [x] `id`
- [x] `type`
- [ ] `lid`
- [x] `attributes`
- [x] `relationships`
- [x] `links` (⚠️ not typed yet)
- [x] `meta`

Object structure for `attributes`, `relationships`, `links` and `meta` is not statically enforced.

## `included`

Represented by `Document.Included` generic parameter.

### Writing (encoding)

Include resource objects via `include` methods on the primary data.
The example below shows how to include resource objects identified by both a direct and an indirect relationships. `user.avatarID` is a direct relationship, and it is possible to include resource objects also by an indirect relationship, including user resource objects that created the included images. By chaining and nested chaining, you can include an arbitrary graph of resource objects.
```swift
let primaryData = User(id: 0, avatarID: 0, name: "John Doe")
    .including(\.avatarID) { imageID in
        try DB.image(for: imageID)
            .including(\.creatorID) { creatorID in
                try DB.user(for: creatorID)
            }
    }
let document = try Document(data: primaryData)
```

### Reading (decoding)

Define the document `Included` generic parameter as `DecodableIncluded`, which will allow you to access included resource objects via some of `Document.included` methods.

```swift
typealias MyDocument<Data> = Document<Data, Never, Never, Never, Never, Never, Never> where Data: _PrimaryData, Data: Decodable

let document = try JSONDecoder().decode(MyDocument<User.ResourceObject>.self, from: encoded)
let user = document.data
let userAvatar = try document.included(via: \.avatarID)
let userAvatarCreator = try document.included(for: userAvatar, via: \.creatorID)
```
