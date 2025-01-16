/// A type that represents a relationship object.
/// Every ``ResourceRepresentable/Relationships`` member must be a ``_RelationshipObject``
/// in order for the document to be a valid JSON:API document.
/// https://jsonapi.org/format/#document-resource-object-relationships
/// 
/// By the specification, we have:
/// + ``RelationshipObject/ToOne`` for to-one relationship, or ``RelationshipObject/ToOne?`` for a
///   nullable to-one relationship to allow an empty value.
/// + ``RelationshipObject/ToMany`` to to-many relationship. Here, `null` value is not allowed,
///   but only an empty array.
public protocol _RelationshipObject: Sendable {
    associatedtype ResourceRepresentable: JSONAPI.ResourceRepresentable
    var resourceIdentifierObjects: [ResourceIdentifierObject<ResourceRepresentable, ResourceRepresentable.Meta>] { get }
}

public protocol _ToOne: _RelationshipObject {
    var data: ResourceIdentifierObject<ResourceRepresentable, ResourceRepresentable.Meta> { get }
}

extension _ToOne {
    public var resourceIdentifierObjects: [ResourceIdentifierObject<ResourceRepresentable, ResourceRepresentable.Meta>] { [data] }
}

public protocol _ToMany: _RelationshipObject {
    var data: [ResourceIdentifierObject<ResourceRepresentable, ResourceRepresentable.Meta>] { get }
}

extension _ToMany {
    public var resourceIdentifierObjects: [ResourceIdentifierObject<ResourceRepresentable, ResourceRepresentable.Meta>] { data }
}

public extension _RelationshipObject {
    typealias ResourceObject = ResourceRepresentable.ResourceObject
}

public enum RelationshipObject {

    public struct ToMany<ResourceRepresentable>: _ToMany, Codable where ResourceRepresentable: JSONAPI.ResourceRepresentable {

        public init(_ ids: [ResourceRepresentable.ID]) {
            self.data = ids.map(ResourceIdentifierObject.init)
        }

        public init(_ resources: [ResourceRepresentable]) {
            self.data = resources.map(ResourceIdentifierObject.init)
        }

        public let data: [ResourceIdentifierObject<ResourceRepresentable, ResourceRepresentable.Meta>]
    }

    public struct ToOne<ResourceRepresentable>: _ToOne, Codable where ResourceRepresentable: JSONAPI.ResourceRepresentable {

        public init?(_ id: ResourceRepresentable.ID?) {
            guard let id else {
                return nil
            }
            self.data = ResourceIdentifierObject(id)
        }

        public init(_ id: ResourceRepresentable.ID) {
            self.data = ResourceIdentifierObject(id)
        }

        public init(_ resource: ResourceRepresentable) {
            self.data = ResourceIdentifierObject(resource)
        }

        public let data: ResourceIdentifierObject<ResourceRepresentable, ResourceRepresentable.Meta>
    }
}

extension Optional: _RelationshipObject where Wrapped: _ToOne {
    public typealias ResourceRepresentable = Wrapped.ResourceRepresentable
    public var resourceIdentifierObjects: [ResourceIdentifierObject<Wrapped.ResourceRepresentable, Wrapped.ResourceRepresentable.Meta>] {
        switch self {
            case .none: []
            case .some(let wrapped): wrapped.resourceIdentifierObjects
        }
    }
}

extension RelationshipObject.ToMany: Equatable where ResourceRepresentable.Type_: Equatable, ResourceRepresentable.Meta: Equatable {}
extension RelationshipObject.ToMany: Hashable where ResourceRepresentable.Type_: Hashable, ResourceRepresentable.ID: Hashable, ResourceRepresentable.Meta: Hashable {}
extension RelationshipObject.ToOne: Equatable where ResourceRepresentable.Type_: Equatable, ResourceRepresentable.Meta: Equatable {}
extension RelationshipObject.ToOne: Hashable where ResourceRepresentable.Type_: Hashable, ResourceRepresentable.ID: Hashable, ResourceRepresentable.Meta: Hashable {}
