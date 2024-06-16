import Foundation
import JSONAPI

// MARK: Model

struct Article: Hashable, Identifiable {

    let id: Int
    let authorID: User.ID
    let coverImageID: Image.ID?
    let title: String
    let body: String
    let attachmentIDs: [Image.ID]
    let commentIDs: [Comment.ID]
}

struct Comment: Hashable, Identifiable {

    let id: Int
    let text: String
    let userID: User.ID
}

struct Image: Hashable, Identifiable {

    let id: Int
    let creatorID: User.ID
}

struct User: Hashable, Identifiable {

    let id: Int
    let avatarID: Image.ID?
    let name: String
}

// MARK: ResourceRepresentable Model

enum Entity: String, LosslessStringConvertible {
    case article, comment, user, image
    var description: String { rawValue }
    init?(_ description: String) {
        self.init(rawValue: description)
    }
}

extension Article: ResourceRepresentable {

    static let type = Entity.article

    struct Attributes: Codable, Hashable {
        let title: String
        let body: String
    }

    struct Relationships: Codable, Hashable {
        let authorID: RelationshipObject.ToOne<User>
        let coverImageID: RelationshipObject.ToOne<Image>?
        let attachmentIDs: RelationshipObject.ToMany<Image>
        let commentIDs: RelationshipObject.ToMany<Comment>
    }

    init(_ resourceObject: Article.ResourceObject) {
        self.attachmentIDs = resourceObject.relationships.attachmentIDs.data.map(\.id)
        self.authorID = resourceObject.relationships.authorID.data.id
        self.body = resourceObject.attributes.body
        self.commentIDs = resourceObject.relationships.commentIDs.data.map(\.id)
        self.coverImageID = resourceObject.relationships.coverImageID?.data.id
        self.id = resourceObject.id
        self.title = resourceObject.attributes.title
    }

    var attributes: Attributes {
        .init(title: title, body: body)
    }

    var relationships: Relationships {
        .init(authorID: .init(authorID), coverImageID: .init(coverImageID), attachmentIDs: .init(attachmentIDs), commentIDs: .init(commentIDs))
    }
}

extension Comment: ResourceRepresentable {

    static let type = Entity.comment

    struct Attributes: Codable, Hashable {
        let text: String
    }

    struct Relationships: Codable, Hashable {
        let userID: RelationshipObject.ToOne<User>
    }

    init(_ resourceObject: Comment.ResourceObject) {
        self.id = resourceObject.id
        self.text = resourceObject.attributes.text
        self.userID = resourceObject.relationships.userID.data.id
    }

    var attributes: Attributes {
        .init(text: text)
    }

    var relationships: Relationships {
        .init(userID: .init(userID))
    }
}

extension Image: ResourceRepresentable {

    static let type = Entity.image

    typealias Attributes = Never

    struct Relationships: Codable, Hashable {
        let creatorID: RelationshipObject.ToOne<User>
    }

    init(_ resourceObject: Image.ResourceObject) {
        self.creatorID = resourceObject.relationships.creatorID.data.id
        self.id = resourceObject.id
    }

    var relationships: Relationships {
        .init(creatorID: .init(creatorID))
    }
}

extension User: ResourceRepresentable {

    static let type = Entity.user

    struct Attributes: Codable, Hashable {
        let name: String
    }

    struct Relationships: Codable, Hashable {
        let avatarID: RelationshipObject.ToOne<Image>?

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: User.Relationships.CodingKeys.self)
            try container.encode(self.avatarID, forKey: User.Relationships.CodingKeys.avatarID)
        }
    }

    init(_ resourceObject: User.ResourceObject) {
        self.avatarID = resourceObject.relationships.avatarID?.data.id
        self.id = resourceObject.id
        self.name = resourceObject.attributes.name
    }

    var attributes: Attributes {
        .init(name: name)
    }

    var relationships: Relationships {
        .init(avatarID: .init(avatarID))
    }
}

// MARK: - Pretty print and test coders

extension JSONEncoder {

    static let pretty: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
}

extension Data {

    var uft8String: String {
        String(data: self, encoding: .utf8)!
    }
}
