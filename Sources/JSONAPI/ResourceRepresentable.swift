/// A type that represents a resource object.
///
/// ``ID`` value (`Self` is `Identifiable`) is represented as ``ResourceObject/id``.
///
/// This type can be represented as:
/// + Resource object via ``ResourceObject/init(_:)``, or ``ResourceRepresentable/resourceObject``.
/// + Resource identifier object via ``ResourceIdentifierObject/init(_:)``, or ``ResourceRepresentable/resourceIdentifierObject``.
public protocol ResourceRepresentable: _ResourceObjectConvertible
where Self: Identifiable,
      Type_: LosslessStringConvertible,
      ID: LosslessStringConvertible, ID: Sendable,
      Attributes: Codable, Attributes: Sendable,
      Relationships: Codable, Relationships: Sendable,
      Links: _Links,
      Meta: Codable, Meta: Sendable {

    // Ideally backticked `Type` but [it is broken](https://github.com/apple/swift/issues/52303)
    associatedtype Type_
    associatedtype Attributes
    associatedtype Relationships
    associatedtype Links
    associatedtype Meta

    /// Represented as ``ResourceObject/type``.
    static var type: Type_ { get }

    /// MUST be an object in order for the resource to be a valid JSON:API resource object. Or `Never`.
    /// Represented as ``ResourceObject/attributes``.
    var attributes: Attributes { get }
    /// MUST be an object whose members are of ``_RelationshipObject`` in order for the resource
    /// to be a valid JSON:API resource object. Or `Never`.
    /// Represented as ``ResourceObject/relationships``.
    var relationships: Relationships { get }
    var links: Links { get }
    /// MUST be an object in order for the resource to be a valid JSON:API resource object. Or `Never`.
    /// Represented as ``ResourceObject/meta``.
    var meta: Meta { get }
}

public extension ResourceRepresentable where Attributes == Never {
    var attributes: Never { fatalError() }
}

public extension ResourceRepresentable where Relationships == Never {
    var relationships: Never { fatalError() }
}

public extension ResourceRepresentable where Links == Never {
    var links: Never { fatalError() }
}

public extension ResourceRepresentable where Meta == Never {
    var meta: Never { fatalError() }
}

public extension ResourceRepresentable {

    var resourceIdentifierObject: JSONAPI.ResourceIdentifierObject<Self, Meta> { JSONAPI.ResourceIdentifierObject(self) }
    var resourceObject: JSONAPI.ResourceObject<Self, Attributes, Relationships, Links, Meta> { JSONAPI.ResourceObject(self) }
}
