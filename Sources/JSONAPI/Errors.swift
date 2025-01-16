// https://jsonapi.org/format/#error-objects

/// A constraint for `Document.Erros` generic parameter to be either:
/// + `Never`
/// + `[ErrorObject]`
public protocol _Errors where Self: Sequence, Self: Sendable, Element: _ErrorObject {}

extension Never: _Errors {}
extension Array: _Errors where Element: _ErrorObject {}

/// A helper protocol to work with ``ResourceObject`` generics until Swift gains parametrized generics.
public protocol _ErrorObject: Error, Identifiable, Sendable where ID: Codable {

    // TODO: https://jsonapi.org/format/#error-objects
    associatedtype Links: _Links
    associatedtype Status: LosslessStringConvertible
    associatedtype Code: LosslessStringConvertible
    associatedtype Title: LosslessStringConvertible
    associatedtype Detail: LosslessStringConvertible
    associatedtype Source: Codable
    associatedtype Meta: Codable, Sendable

    init(
        id: () -> ID,
        links: () -> Links,
        status: () -> Status,
        code: () -> Code,
        title: () -> Title,
        detail: () -> Detail,
        source: () -> Source,
        meta: () -> Meta
    )

    var id: ID { get }
    var links: Links { get }
    var status: Status { get }
    var code: Code { get }
    var title: Title { get }
    var detail: Detail { get }
    var source: Source { get }
    var meta: Meta { get }
}

// MARK: - Codable

enum ErrorObjectCodingKey: CodingKey {
    case id, links, status, code, title, detail, source, meta
}

/// A type that represents an error object element in the document's `errors` member.
/// - Note: [`id` not restricted to `String`?](https://jsonapi.org/format/#error-objects)
public struct ErrorObject<ID, Links, Status, Code, Title, Detail, Source, Meta>: _ErrorObject where
ID: Codable, ID: Hashable, ID: Sendable,
Links: _Links,
Status: LosslessStringConvertible, Status: Sendable,
Code: LosslessStringConvertible, Code: Sendable,
Title: LosslessStringConvertible, Title: Sendable,
Detail: LosslessStringConvertible, Detail: Sendable,
Source: Codable, Source: Sendable,
Meta: Codable, Meta: Sendable
{
    public init(
        id: @autoclosure () -> ID = fatalError(),
        links: @autoclosure () -> Links = fatalError(),
        status: @autoclosure () -> Status = fatalError(),
        code: @autoclosure () -> Code = fatalError(),
        title: @autoclosure () -> Title = fatalError(),
        detail: @autoclosure () -> Detail = fatalError(),
        source: @autoclosure () -> Source = fatalError(),
        meta: @autoclosure () -> Meta = fatalError()
    ) {
        if ID.self != Never.self { self._id = id() } else { self._id = ID?.none }
        if Links.self != Never.self { self._links = links() } else { self._links = Links?.none }
        if Status.self != Never.self { self._status = status() } else { self._status = Status?.none }
        if Code.self != Never.self { self._code = code() } else { self._code = Code?.none }
        if Title.self != Never.self { self._title = title() } else { self._title = Title?.none }
        if Detail.self != Never.self { self._detail = detail() } else { self._detail = Detail?.none }
        if Source.self != Never.self { self._source = source() } else { self._source = Source?.none }
        if Meta.self != Never.self { self._meta = meta() } else { self._meta = Meta?.none }
    }

    private let _id: ID!
    private let _links: Links!
    private let _status: Status!
    private let _code: Code!
    private let _title: Title!
    private let _detail: Detail!
    private let _source: Source!
    private let _meta: Meta!

    public var id: ID { _id }
    public var links: Links { _links }
    public var status: Status { _status }
    public var code: Code { _code }
    public var title: Title { _title }
    public var detail: Detail { _detail }
    public var source: Source { _source }
    public var meta: Meta { _meta }
}

extension ErrorObject: Equatable where Links: Equatable, Status: Equatable, Code: Equatable, Title: Equatable, Detail: Equatable, Source: Equatable, Meta: Equatable {}

extension ErrorObject: Hashable where Links: Hashable, Status: Hashable, Code: Hashable, Title: Hashable, Detail: Hashable, Source: Hashable, Meta: Hashable {}

extension Never: _ErrorObject {

    public init(id: () -> Never, links: () -> Never, status: () -> Never, code: () -> Never, title: () -> Never, detail: () -> Never, source: () -> Never, meta: () -> Never) {
        fatalError()
    }
    
    public var links: Never { fatalError() }
    public var status: Never { fatalError() }
    public var code: Never { fatalError() }
    public var title: Never { fatalError() }
    public var detail: Never { fatalError() }
    public var source: Never { fatalError() }
    public var meta: Never { fatalError() }
}

/// Allows to throw an `ErrorDocument` if `errors` member is detected during decoding a document.
extension Document: Error where Errors.Element: _ErrorObject {}

// MARK: Failure Response

/// A constraint for `Document.FailureResponse` generic parameter to be either:
/// + `FailureResponse`
/// + `Never`
public protocol _FailureResponse: Sendable {
    associatedtype ErrorObject: _ErrorObject
    associatedtype Meta: Decodable, Sendable
}

/// A type that defines the document's `Errors.Element` and `Meta` types for failure response.
public enum FailureResponse<ErrorObject, Meta>: _FailureResponse where ErrorObject: _ErrorObject, Meta: Decodable, Meta: Sendable {}

extension Never: _FailureResponse {
    public typealias ErrorObject = Never
}
