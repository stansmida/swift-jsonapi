/// A type that represents JSON:API resource object.
/// https://jsonapi.org/format/#document-resource-objects
///
/// - Note: On `Attributes`, `Relationships`, `Links` and `Meta` generic parameters.
/// We could constrain them to be respective `T` associated types. Due to dynamic nature
/// of APIs, though, this would require to define a new `ResourceRepresentable` type for any
/// situation where an API can alter the resource members or their members (e.g. API can omit some `Attributes` members
/// based on user permissons, sparse fieldsets; or `Meta` structure can be different for `data` and `included` document
/// members, etc.). Likewise, a document comsumer might not be interested in some members at certain
/// situations and choose not to decode them, e.g. `ResourceObject<Article, Article.Attributes, Never, Never, Never>`
/// when they need just an article attributes (without defining new `ArticleAttributes: ResourceRepresentable`
/// where all but `Attributes` associated types would be `Never`). This way, you can choose whether to define
/// a `ResourceRepresentable` type that exactly matches `ResourceObject`, or, when appropriate, "inject" a custom
/// resource object member representation.
/// Another good example of this being used is `ResourceIdentifierObject`, which is just `ResourceObject`
/// with all the members being `Never`, and allows to create a resource identifier object from any `ResourceObject`.
/// That said, the only constrained type relationshis between `ResourceObject` and its `ResourceRepresentable`
/// are type and id types, which are constant types in any transaction regardless of resource object position
/// in the document or query parameters.
///
/// - SeeAlso: ``ResourceIdentifierObject`` is a typealias for this type that represents
/// a resource identifier object.
/// - SeeAlso: ``ResourceRepresentable``
public struct ResourceObject<T, Attributes, Relationships, Links, Meta>: _ResourceObject where T: ResourceRepresentable,
                                                                                               Attributes: Codable,
                                                                                               Relationships: Codable,
                                                                                               Links: Codable,
                                                                                               Meta: Codable {

    public typealias ResourceRepresentable = T

    public init(_ resource: T) where Attributes == T.Attributes, Relationships == T.Relationships, Links == T.Links, Meta == T.Meta {
        self.id = resource.id
        if T.Attributes.self != Never.self {
            self._attributes = resource.attributes
        }
        if T.Relationships.self != Never.self {
            self._relationships = resource.relationships
        }
        if T.Links.self != Never.self {
            self._links = resource.links
        }
        if T.Meta.self != Never.self {
            self._meta = resource.meta
        }
    }

    public init(
        type: T.Type,
        id: T.ID,
        attributes: @autoclosure () -> Attributes = fatalError(),
        relationships: @autoclosure () -> Relationships = fatalError(),
        links: @autoclosure () -> Links = fatalError(),
        meta: @autoclosure () -> Meta = fatalError()
    ) {
        self.id = id
        if Attributes.self != Never.self { self._attributes = attributes() } else { self._attributes = Attributes?.none }
        if Relationships.self != Never.self { self._relationships = relationships() } else { self._relationships = Relationships?.none }
        if Links.self != Never.self { self._links = links() } else { self._links = Links?.none }
        if Meta.self != Never.self { self._meta = meta() } else { self._meta = Meta?.none }
    }

    private var _attributes: Attributes!
    private var _relationships: Relationships!
    private var _links: Links!
    private var _meta: Meta!

    public let id: T.ID
    public var attributes: Attributes { _attributes }
    public var relationships: Relationships { _relationships }
    public var links: Links { _links }
    public var meta: Meta { _meta }
}

/// A type that represents JSON:API resource identifier object.
/// https://jsonapi.org/format/#document-resource-identifier-objects
public typealias ResourceIdentifierObject<T, Meta> = ResourceObject<T, Never, Never, Never, Meta> where T: ResourceRepresentable, Meta: Codable

extension ResourceIdentifierObject {

    public init(_ id: T.ID) {
        self.id = id
    }

    public init(_ resource: T) {
        self.init(resource.id)
    }
}

/// A helper protocol to work with ``ResourceObject`` generics until Swift gains parametrized generics.
public protocol _ResourceObject: _PrimaryData, _ResourceObjectConvertible where Self: Codable, ResourceObject == Self, ResourceObjectType == Self {
    associatedtype ResourceRepresentable: JSONAPI.ResourceRepresentable
    associatedtype Attributes: Codable
    associatedtype Relationships: Codable
    associatedtype Links: Codable
    associatedtype Meta: Codable
    init(from container: KeyedDecodingContainer<ResourceObjectCodingKey>) throws
    var id: ResourceRepresentable.ID { get }
    var attributes: Attributes { get }
    var relationships: Relationships { get }
    var links: Links { get }
    var meta: Meta { get }
}

public extension _ResourceObject {
    var resourceObject: Self { self }
}

/// Allows to pass either ``ResourceRepresentable`` or ``ResourceObject`` where ``ResourceObject`` is needed.
/// This protocol is supposed to be closed, with `ResourceRepresentable` and `ResourceObject` being exclusive
/// conformers.
public protocol _ResourceObjectConvertible {
    associatedtype ResourceObject: _ResourceObject
    var resourceObject: ResourceObject { get }
}

// MARK: - Coding

public enum ResourceObjectCodingKey: CodingKey {
    case type, id, lid, attributes, relationships, links, meta
}

extension ResourceObject: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: ResourceObjectCodingKey.self)
        try self.init(from: container)
    }

    public init(from container: KeyedDecodingContainer<ResourceObjectCodingKey>) throws {
        let rawType = try container.decode(String.self, forKey: .type)
        guard let type = T.Type_(rawType), String(type) == String(T.type) else {
            throw DecodingError.typeMismatch(T.Type_.self, .init(codingPath: container.codingPath, debugDescription: "Couldn't instantiate \(T.`Type`.self) from '\(rawType)'."))
        }
        let rawID = try container.decode(String.self, forKey: .id)
        guard let id = T.ID(rawID) else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Couldn't instantiate \(T.ID.self) from '\(rawID)'."))
        }
        self.id = id
        if Attributes.self != Never.self {
            self._attributes = try container.decode(Attributes.self, forKey: .attributes)
        }
        if Relationships.self != Never.self {
            self._relationships = try container.decode(Relationships.self, forKey: .relationships)
        }
        if Links.self != Never.self {
            self._links = try container.decode(Links.self, forKey: .links)
        }
        if Meta.self != Never.self {
            self._meta = try container.decode(Meta.self, forKey: .meta)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: ResourceObjectCodingKey.self)
        try container.encode(String(T.type), forKey: .type)
        try container.encode(String(id), forKey: .id)
        if Attributes.self != Never.self {
            try container.encode(attributes, forKey: .attributes)
        }
        if Relationships.self != Never.self {
            try container.encode(relationships, forKey: .relationships)
        }
        if Links.self != Never.self {
            try container.encode(links, forKey: .links)
        }
        if Meta.self != Never.self {
            try container.encode(meta, forKey: .meta)
        }
    }
}

// MARK: - Hashable

extension ResourceObject: Equatable where T.ID: Equatable, Attributes: Equatable, Relationships: Equatable, Links: Equatable, Meta: Equatable {
    public static func == (lhs: JSONAPI.ResourceObject<T, Attributes, Relationships, Links, Meta>, rhs: JSONAPI.ResourceObject<T, Attributes, Relationships, Links, Meta>) -> Bool {
        lhs.id == rhs.id
        && (Attributes.self == Never.self || lhs.attributes == rhs.attributes)
        && (Relationships.self == Never.self || lhs.relationships == lhs.relationships)
        && (Links.self == Never.self || lhs.links == rhs.links)
        && (Meta.self == Never.self || lhs.meta == rhs.meta)
    }
}

extension ResourceObject: Hashable where T.Type_: Hashable, T.ID: Hashable, Attributes: Hashable, Relationships: Hashable, Links: Hashable, Meta: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(T.type)
        hasher.combine(id)
        if Attributes.self != Never.self { hasher.combine(attributes) }
        if Relationships.self != Never.self { hasher.combine(relationships) }
        if Links.self != Never.self { hasher.combine(links) }
        if Meta.self != Never.self { hasher.combine(meta) }
    }
}

// MARK: - Composite Key

/// A unique reference to a resource object in another part of the document.
/// https://jsonapi.org/format/#document-compound-documents
public struct CompositeKey: Hashable {

    public init<T, U>(_ resourceIdentifierObject: ResourceIdentifierObject<T, U>) {
        self.init(type: String(T.type), id: String(resourceIdentifierObject.id))
    }

    public init<T>(_ resource: T) where T: ResourceRepresentable {
        self.init(type: String(T.type), id: String(resource.id))
    }

    public init(type: String, id: String) {
        self.type = type
        self.id = id
    }

    let type: String
    let id: String
}

public extension _ResourceObject {
    var compositeKey: CompositeKey { .init(type: String(ResourceRepresentable.type), id: String(id)) }
}
