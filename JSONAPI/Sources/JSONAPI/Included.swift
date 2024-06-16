/// https://jsonapi.org/format/#document-compound-documents

/// A marker protocol to constrain types that can be used as `Document`'s `Included` member.
/// `Document<_, _, _, Included>` ("Document.Included") can be either
/// + `EncodableIncluded` when building a compound document for encoding.
/// + `DecodableIncluded` when decoding a received compound document.
/// + `Never` for not a compound document (a document without `included` member).
public protocol _Included {}

extension Never: _Included {}

// MARK: - Encoding

public typealias EncodableIncluded = [_AnyEncodableResourceObject]
extension EncodableIncluded: _Included {}

/// An element of `EncodableIncluded`.
public struct _AnyEncodableResourceObject: Encodable {

    let resourceObject: any _ResourceObject

    public func encode(to encoder: any Encoder) throws {
        try resourceObject.encode(to: encoder)
    }
}

/// An accumulation node for a resource object and its included resource objects.
/// It is used to build an encodable compound (with `included` member) document.
/// https://jsonapi.org/format/#document-compound-documents
public struct _CompoundResourceObject<ResourceObjects> where ResourceObjects: Sequence, ResourceObjects.Element: _ResourceObject {

    public typealias ResourceObject = ResourceObjects.Element

    @usableFromInline
    internal init<T>(resourceObject: T, accumulatingIncluded: [CompositeKey : any _ResourceObject]) where T: _ResourceObject, ResourceObjects == CollectionOfOne<T> {
        self.resourceObjects = CollectionOfOne(resourceObject)
        self.accumulatingIncluded = accumulatingIncluded
    }

    @usableFromInline
    internal init(resourceObjects: ResourceObjects, accumulatingIncluded: [CompositeKey : any _ResourceObject]) {
        self.resourceObjects = resourceObjects
        self.accumulatingIncluded = accumulatingIncluded
    }

    /// Is `CollectionOfOne` for a single resource object representation.
    @usableFromInline
    let resourceObjects: ResourceObjects

    @usableFromInline
    let accumulatingIncluded: [CompositeKey: any _ResourceObject]

    @inlinable
    public consuming func including<RelationshipObject, ReferencedObject>(
        _ relationshipKeyPath: KeyPath<ResourceObject.Relationships, RelationshipObject>,
        if condition: Bool = true,
        include: (RelationshipObject.ResourceRepresentable.ID) throws -> ReferencedObject
    ) throws -> Self
    where RelationshipObject: _RelationshipObject,
          ReferencedObject: _ResourceObjectConvertible,
          RelationshipObject.ResourceRepresentable == ReferencedObject.ResourceObject.ResourceRepresentable
    {
        guard condition else {
            return self
        }
        var accumulatingIncluded = accumulatingIncluded
        for resourceObject in resourceObjects {
            for resourceIdentifierObject in resourceObject.relationships[keyPath: relationshipKeyPath].resourceIdentifierObjects {
                guard accumulatingIncluded[resourceIdentifierObject.compositeKey] == nil else {
                    continue // already included
                }
                let referencedResourceObject = try include(resourceIdentifierObject.id).resourceObject
                accumulatingIncluded[referencedResourceObject.compositeKey] = referencedResourceObject
            }
        }
        return Self(resourceObjects: resourceObjects, accumulatingIncluded: accumulatingIncluded)
    }

    @inlinable
    public consuming func including<RelationshipObject, ReferencedObject>(
        _ relationshipKeyPath: KeyPath<ResourceObject.Relationships, RelationshipObject>,
        if condition: Bool = true,
        include: (RelationshipObject.ResourceRepresentable.ID) throws -> _CompoundResourceObject<some Sequence<ReferencedObject>>
    ) rethrows -> Self
    where RelationshipObject: _RelationshipObject,
          ReferencedObject: _ResourceObject,
          RelationshipObject.ResourceRepresentable == ReferencedObject.ResourceRepresentable
    {
        guard condition else {
            return self
        }
        var accumulatingIncluded = accumulatingIncluded
        for resourceObject in resourceObjects {
            for resourceIdentifierObject in resourceObject.relationships[keyPath: relationshipKeyPath].resourceIdentifierObjects {
                guard accumulatingIncluded[resourceIdentifierObject.compositeKey] == nil else {
                    continue // already included
                }
                let referencedCompoundResourceObject = try include(resourceIdentifierObject.id)
                for resourceObject in referencedCompoundResourceObject.resourceObjects {
                    accumulatingIncluded[resourceObject.compositeKey] = resourceObject
                }
                for accumulatedResourceObject in referencedCompoundResourceObject.accumulatingIncluded {
                    accumulatingIncluded[accumulatedResourceObject.key] = accumulatedResourceObject.value
                }
            }
        }
        return Self(resourceObjects: resourceObjects, accumulatingIncluded: accumulatingIncluded)
    }
}

// MARK: Adding included objects

extension _ResourceObjectConvertible {

    @inlinable
    public func including<RelationshipObject, ReferencedObject>(
        _ relationshipKeyPath: KeyPath<ResourceObject.Relationships, RelationshipObject>,
        if condition: Bool = true,
        include: (RelationshipObject.ResourceRepresentable.ID) throws -> ReferencedObject
    ) throws -> _CompoundResourceObject<CollectionOfOne<ResourceObject>>
    where RelationshipObject: _RelationshipObject,
          ReferencedObject: _ResourceObjectConvertible,
          RelationshipObject.ResourceRepresentable == ReferencedObject.ResourceObject.ResourceRepresentable
    {
        try _CompoundResourceObject(resourceObject: resourceObject, accumulatingIncluded: [:])
            .including(relationshipKeyPath, if: condition, include: include)
    }

    @inlinable
    public func including<RelationshipObject, ReferencedObject>(
        _ relationshipKeyPath: KeyPath<ResourceObject.Relationships, RelationshipObject>,
        if condition: Bool = true,
        include: (RelationshipObject.ResourceRepresentable.ID) throws -> _CompoundResourceObject<some Sequence<ReferencedObject>>
    ) throws -> _CompoundResourceObject<CollectionOfOne<ResourceObject>>
    where RelationshipObject: _RelationshipObject,
          ReferencedObject: _ResourceObject,
          RelationshipObject.ResourceRepresentable == ReferencedObject.ResourceRepresentable
    {
        try _CompoundResourceObject(resourceObject: resourceObject, accumulatingIncluded: [:])
            .including(relationshipKeyPath, if: condition, include: include)
    }
}

extension Sequence where Element: _ResourceObjectConvertible {

    @inlinable
    public func including<RelationshipObject, ReferencedObject>(
        _ relationshipKeyPath: KeyPath<Element.ResourceObject.Relationships, RelationshipObject>,
        if condition: Bool = true,
        include: (RelationshipObject.ResourceRepresentable.ID) throws -> ReferencedObject
    ) throws -> _CompoundResourceObject<Array<Element.ResourceObject>>
    where RelationshipObject: _RelationshipObject,
          ReferencedObject: _ResourceObjectConvertible,
          RelationshipObject.ResourceRepresentable == ReferencedObject.ResourceObject.ResourceRepresentable
    {
        try _CompoundResourceObject(resourceObjects: map(\.resourceObject), accumulatingIncluded: [:])
            .including(relationshipKeyPath, if: condition, include: include)
    }

    @inlinable
    public func including<RelationshipObject, ReferencedObject>(
        _ relationshipKeyPath: KeyPath<Element.ResourceObject.Relationships, RelationshipObject>,
        if condition: Bool = true,
        include: (RelationshipObject.ResourceRepresentable.ID) throws -> _CompoundResourceObject<some Sequence<ReferencedObject>>
    ) throws -> _CompoundResourceObject<Array<Element.ResourceObject>>
    where RelationshipObject: _RelationshipObject,
          ReferencedObject: _ResourceObject,
          RelationshipObject.ResourceRepresentable == ReferencedObject.ResourceRepresentable
    {
        try _CompoundResourceObject(resourceObjects: map(\.resourceObject), accumulatingIncluded: [:])
            .including(relationshipKeyPath, if: condition, include: include)
    }
}

// MARK: - Decoding

/// `Included` member of decoded `Document`.
/// It serves as a storage of included resource objects that you access via
/// + `Document/included(_:via:)` for objects directly related via a relationship of the primary data resource type
/// + `Document/included(_:for:via:)` for objects related via a relationship of (typically) already included resource
/// (indirectly related to the primary data).
public struct DecodableIncluded: _Included, Decodable {

    private struct AnyDecodableResourceObject: Decodable {

        let type: String
        let id: String
        let container: KeyedDecodingContainer<ResourceObjectCodingKey>

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: ResourceObjectCodingKey.self)
            self.type = try container.decode(String.self, forKey: .type)
            self.id = try container.decode(String.self, forKey: .id)
            self.container = container
        }
    }

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var array = [AnyDecodableResourceObject]()
        if let count = container.count {
            array.reserveCapacity(count)
        }
        while !container.isAtEnd {
            let element = try container.decode(AnyDecodableResourceObject.self)
            array.append(element)
        }
        self.elements = array.reduce(
            into: [CompositeKey: KeyedDecodingContainer<ResourceObjectCodingKey>](),
            { $0[CompositeKey(type: $1.type, id: $1.id)] = $1.container }
        )
    }

    @usableFromInline
    let elements: [CompositeKey: KeyedDecodingContainer<ResourceObjectCodingKey>]
}

// MARK: Accessing included resource objects

public extension Document where Included == DecodableIncluded {

    /// nullable resource object primary data, to-one
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        via keyPath: KeyPath<Referencing.Relationships, Relationship>
    ) throws -> Referenced? where Data == Optional<Referencing>, Referencing: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        try included(type, for: data, via: keyPath)
    }

    /// nullable resource object, to-one
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        for resourceObject: some _Optional<Referencing>,
        via keyPath: KeyPath<Referencing.Relationships, Relationship>
    ) throws -> Referenced? where Referencing: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        guard let resourceObject = resourceObject.value else {
            return nil
        }
        return try included(type, for: resourceObject, via: keyPath)
    }

    /// nullable resource object primary data, nullable to-one
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        via keyPath: KeyPath<Referencing.Relationships, some _Optional<Relationship>>
    ) throws -> Referenced? where Data == Optional<Referencing>, Referencing: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        try included(type, for: data, via: keyPath)
    }

    /// nullable resource object, nullable to-one
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        for resourceObject: some _Optional<Referencing>,
        via keyPath: KeyPath<Referencing.Relationships, some _Optional<Relationship>>
    ) throws -> Referenced? where Referencing: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        guard let resourceObject = resourceObject.value else {
            return nil
        }
        return try included(type, for: resourceObject, via: keyPath)
    }
    
    /// nullable resource object primary data, to-many
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        via keyPath: KeyPath<Referencing.Relationships, Relationship>
    ) throws -> [Referenced]? where Data == Optional<Referencing>, Referencing: _ResourceObject, Relationship: _ToMany, Referenced: _ResourceObject {
        try included(type, for: data, via: keyPath)
    }

    /// nullable resource object, to-many
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        for resourceObject: some _Optional<Referencing>,
        via keyPath: KeyPath<Referencing.Relationships, Relationship>
    ) throws -> [Referenced]? where Referencing: _ResourceObject, Relationship: _ToMany, Referenced: _ResourceObject {
        guard let resourceObject = resourceObject.value else {
            return nil
        }
        return try included(type, for: resourceObject, via: keyPath)
    }

    /// single resource object primary data, to-one
    @inlinable
    func included<Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        via keyPath: KeyPath<Data.Relationships, Relationship>
    ) throws -> Referenced where Data: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        try included(type, for: data, via: keyPath)
    }

    /// single resource object, to-one
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        for resourceObject: Referencing,
        via keyPath: KeyPath<Referencing.Relationships, Relationship>
    ) throws -> Referenced where Referencing: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        let relationship = resourceObject.relationships[keyPath: keyPath]
        guard let container = included.elements[relationship.data.compositeKey] else {
            throw IncludedResourceObjectNotFound(relationshipObject: relationship, relationshipPath: keyPath)
        }
        return try Referenced(from: container)
    }

    /// single resource object primary data, nullable to-one
    @inlinable
    func included<Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        via keyPath: KeyPath<Data.Relationships, some _Optional<Relationship>>
    ) throws -> Referenced? where Data: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        try included(type, for: data, via: keyPath)
    }

    /// single resource object, nullable to-one
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        for resourceObject: Referencing,
        via keyPath: KeyPath<Referencing.Relationships, some _Optional<Relationship>>
    ) throws -> Referenced? where Referencing: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        guard let relationship = resourceObject.relationships[keyPath: keyPath].value else {
            return nil
        }
        guard let container = included.elements[relationship.data.compositeKey] else {
            throw IncludedResourceObjectNotFound(relationshipObject: relationship, relationshipPath: keyPath)
        }
        return try Referenced(from: container)
    }

    /// single resource object primary data, to-many
    @inlinable
    func included<Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        via keyPath: KeyPath<Data.Relationships, Relationship>
    ) throws -> [Referenced] where Data: _ResourceObject, Relationship: _ToMany, Referenced: _ResourceObject {
        try included(type, for: data, via: keyPath)
    }

    /// single resource object, to-many
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        for resourceObject: Referencing,
        via keyPath: KeyPath<Referencing.Relationships, Relationship>
    ) throws -> [Referenced] where Referencing: _ResourceObject, Relationship: _ToMany, Referenced: _ResourceObject {
        let relationship = resourceObject.relationships[keyPath: keyPath]
        return try relationship.data.map { resourceObjectIdentifier in
            guard let container = included.elements[CompositeKey(resourceObjectIdentifier)] else {
                throw IncludedResourceObjectNotFound(relationshipObject: relationship, relationshipPath: keyPath)
            }
            return try Referenced(from: container)
        }
    }

    /// array of resource objects primary data, to-one
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        via keyPath: KeyPath<Referencing.Relationships, Relationship>
    ) throws -> [Referenced] where Data: Sequence<Referencing>, Referencing: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        try included(type, for: data, via: keyPath)
    }

    /// array of resource objects, to-one
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        for resourceObject: some Sequence<Referencing>,
        via keyPath: KeyPath<Referencing.Relationships, Relationship>
    ) throws -> [Referenced] where Referencing: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        try resourceObject.map({ try included(type, for: $0, via: keyPath) })
    }

    /// array of resource objects primary data, nullable to-one
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        via keyPath: KeyPath<Referencing.Relationships, some _Optional<Relationship>>
    ) throws -> [Referenced?] where Data: Sequence<Referencing>, Referencing: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        try included(type, for: data, via: keyPath)
    }

    /// array of resource objects, nullable to-one
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        for resourceObject: some Sequence<Referencing>,
        via keyPath: KeyPath<Referencing.Relationships, some _Optional<Relationship>>
    ) throws -> [Referenced?] where Referencing: _ResourceObject, Relationship: _ToOne, Referenced: _ResourceObject {
        try resourceObject.map({ try included(type, for: $0, via: keyPath) })
    }

    /// array of resource objects primary data, to-many
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        via keyPath: KeyPath<Referencing.Relationships, Relationship>
    ) throws -> [[Referenced]] where Data: Sequence<Referencing>, Referencing: _ResourceObject, Relationship: _ToMany, Referenced: _ResourceObject {
        try included(type, for: data, via: keyPath)
    }

    /// array of resource objects, to-many
    @inlinable
    func included<Referencing, Relationship, Referenced>(
        _ type: Referenced.Type = Relationship.ResourceRepresentable.ResourceObject.self,
        for resourceObject: some Sequence<Referencing>,
        via keyPath: KeyPath<Referencing.Relationships, Relationship>
    ) throws -> [[Referenced]] where Referencing: _ResourceObject, Relationship: _ToMany, Referenced: _ResourceObject {
        try resourceObject.map({ try included(type, for: $0, via: keyPath) })
    }
}

public struct IncludedResourceObjectNotFound: Error {

    public init(relationshipObject: any _RelationshipObject, relationshipPath: AnyKeyPath) {
        self.relationshipObject = relationshipObject
        self.relationshipPath = relationshipPath
    }

    let relationshipObject: any _RelationshipObject
    let relationshipPath: AnyKeyPath
}
