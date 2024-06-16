/// A constraint for `Document.Data` (also referred as primary data) generic parameter.
///
/// A primary data in a document is one of:
/// + `Optional<some _ResourceObject>`
/// + `some _ResourceObject`
/// + `[some _ResourceObject]`
///
/// https://jsonapi.org/format/#document-top-level
public protocol _PrimaryData {
    associatedtype ResourceObjectType: _ResourceObject
}

extension Array: _PrimaryData where Element: _ResourceObject {
    public typealias ResourceObjectType = Element
}

extension Never: _PrimaryData {}

extension Optional: _PrimaryData where Wrapped: _ResourceObject {
    public typealias ResourceObjectType = Wrapped
}

/// Allows `Never` to be primary data type when creating an error document.
extension Never: _ResourceObject {
    public typealias ResourceRepresentable = Never
    public init(from container: KeyedDecodingContainer<ResourceObjectCodingKey>) throws { fatalError() }
    public var resourceObject: Never { fatalError() }
    public var attributes: Never { fatalError() }
    public var relationships: Never { fatalError() }
}

/// Allows `Never: _ResourceObject` so `Never` can be primary data type when creating an error document.
extension Never: ResourceRepresentable {
    public static var type: Never? { nil }
}
