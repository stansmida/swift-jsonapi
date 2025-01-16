// https://jsonapi.org/format/#document-structure
import Foundation

/// A helper protocol to work with ``Document`` generics until Swift gains parametrized generics.
public protocol DocumentType: Sendable {
    associatedtype Data: _PrimaryData
    associatedtype Errors: _Errors
    associatedtype Meta: Sendable
    associatedtype JSONAPI: Sendable
    associatedtype Links: _Links
    associatedtype Included: _Included
}

/// - Todo: Extensions don't have their generic parameter yet. These could perhaps get a variadic parameter `each Extension`?
public struct Document<Data, Errors, Meta, JSONAPI, Links, Included>: DocumentType
where Data: _PrimaryData,
      Errors: _Errors,
      Meta: Sendable,
      JSONAPI: Sendable,
      Links: _Links,
      Included: _Included {

    /// Create an encodable document where primary data is a single resource object.
    public init<T>(
        data: T,
        meta: @autoclosure () -> Meta = fatalError(),
        jsonAPI: @autoclosure () -> JSONAPI = fatalError(),
        links: @autoclosure () -> Links = fatalError()
    ) where T: _ResourceObjectConvertible, Data == T.ResourceObject,
            Errors == Never,
            Meta: Swift.Encodable,
            JSONAPI: Swift.Encodable,
            Links: _Links,
            Included == Never {
        self._data = data.resourceObject
        if Meta.self != Never.self { _meta = meta() }
        if JSONAPI.self != Never.self { _jsonAPI = jsonAPI() }
        if Links.self != Never.self { _links = links() }
    }

    /// Create an encodable document where primary data is a single resource object, and has `included` member.
    ///
    /// `_CompoundResourceObject` isn't supposed to be initialized directly but via
    /// ``_ResourceObjectConvertible.including(_:if:include:)`` method.
    /// - Parameters:
    ///   - sorted: Whether to sort included objects alphabetically (by type and id).
    public init(
        data: _CompoundResourceObject<CollectionOfOne<Data>>,
        sorted: Bool = false,
        meta: @autoclosure () -> Meta = fatalError(),
        jsonAPI: @autoclosure () -> JSONAPI = fatalError(),
        links: @autoclosure () -> Links = fatalError()
    ) where Errors == Never,
            Meta: Swift.Encodable,
            JSONAPI: Swift.Encodable,
            Links: _Links,
            Included == EncodableIncluded {
        self._data = data.resourceObjects.first
        if Meta.self != Never.self { _meta = meta() }
        if JSONAPI.self != Never.self { _jsonAPI = jsonAPI() }
        if Links.self != Never.self { _links = links() }
        if sorted {
            self._included = data.accumulatingIncluded.values
                .sorted(by: areInIncreasingOrder)
                .map(_AnyEncodableResourceObject.init)
        } else {
            self._included = data.accumulatingIncluded.values.map(_AnyEncodableResourceObject.init)
        }
    }

    /// Create an encodable document where primary data is a nullable single resource object.
    public init<T>(
        data: T?,
        meta: @autoclosure () -> Meta = fatalError(),
        jsonAPI: @autoclosure () -> JSONAPI = fatalError(),
        links: @autoclosure () -> Links = fatalError()
    ) where T: _ResourceObjectConvertible, Data == T.ResourceObject?,
            Errors == Never,
            Meta: Swift.Encodable,
            JSONAPI: Swift.Encodable,
            Links: Swift.Encodable,
            Included == Never {
        self._data = Data?.some(data?.resourceObject)
        if Meta.self != Never.self { _meta = meta() }
        if JSONAPI.self != Never.self { _jsonAPI = jsonAPI() }
        if Links.self != Never.self { _links = links() }
    }

    /// Create an encodable document where primary data is a nullable single resource object, and has `included` member.
    ///
    /// `_CompoundResourceObject` isn't supposed to be initialized directly but via
    /// ``_ResourceObjectConvertible.including(_:if:include:)`` method.
    /// - Parameters:
    ///   - sorted: Whether to sort included objects alphabetically (by type and id).
    public init<T>(
        data: _CompoundResourceObject<CollectionOfOne<T>>?,
        sorted: Bool = false,
        meta: @autoclosure () -> Meta = fatalError(),
        jsonAPI: @autoclosure () -> JSONAPI = fatalError(),
        links: @autoclosure () -> Links = fatalError()
    ) where T: _ResourceObjectConvertible, Data == T.ResourceObject?,
            Errors == Never,
            Meta: Swift.Encodable,
            JSONAPI: Swift.Encodable,
            Links: Swift.Encodable,
            Included == EncodableIncluded {
        self._data = Data?.some(data?.resourceObjects.first)
        if Meta.self != Never.self { _meta = meta() }
        if JSONAPI.self != Never.self { _jsonAPI = jsonAPI() }
        if Links.self != Never.self { _links = links() }
        if sorted {
            self._included = data?.accumulatingIncluded.values
                .sorted(by: areInIncreasingOrder)
                .map(_AnyEncodableResourceObject.init) ?? []
        } else {
            self._included = data?.accumulatingIncluded.values.map(_AnyEncodableResourceObject.init) ?? []
        }
    }

    /// Create an encodable document where primary data is an array of resource objects.
    public init<T>(
        data: [T],
        meta: @autoclosure () -> Meta = fatalError(),
        jsonAPI: @autoclosure () -> JSONAPI = fatalError(),
        links: @autoclosure () -> Links = fatalError()
    ) where T: _ResourceObjectConvertible, Data == [T.ResourceObject],
            Errors == Never,
            Meta: Swift.Encodable,
            JSONAPI: Swift.Encodable,
            Links: Swift.Encodable,
            Included == Never {
        self._data = data.map(\.resourceObject)
        if Meta.self != Never.self { _meta = meta() }
        if JSONAPI.self != Never.self { _jsonAPI = jsonAPI() }
        if Links.self != Never.self { _links = links() }
    }

    /// Create an encodable document where primary data is an array of resource objects, and has `included` member.
    ///
    /// `_CompoundResourceObject` isn't supposed to be initialized directly but via
    /// ``Sequence.including(_:if:include:)`` method.
    /// - Parameters:
    ///   - sorted: Whether to sort included objects alphabetically (by type and id).
    public init<T>(
        data: _CompoundResourceObject<Array<T>>,
        sorted: Bool = false,
        meta: @autoclosure () -> Meta = fatalError(),
        jsonAPI: @autoclosure () -> JSONAPI = fatalError(),
        links: @autoclosure () -> Links = fatalError()
    ) where Data == Array<T>,
            Errors == Never,
            Meta: Swift.Encodable,
            JSONAPI: Swift.Encodable,
            Links: Swift.Encodable,
            Included == EncodableIncluded {
        self._data = data.resourceObjects
        if Meta.self != Never.self { _meta = meta() }
        if JSONAPI.self != Never.self { _jsonAPI = jsonAPI() }
        if Links.self != Never.self { _links = links() }
        if sorted {
            self._included = data.accumulatingIncluded.values
                .sorted(by: areInIncreasingOrder)
                .map(_AnyEncodableResourceObject.init)
        } else {
            self._included = data.accumulatingIncluded.values.map(_AnyEncodableResourceObject.init)
        }
    }

    /// Create an encodable document with errors.
    public init<E>(
        error: E,
        meta: @autoclosure () -> Meta = fatalError(),
        jsonAPI: @autoclosure () -> JSONAPI = fatalError()
    ) where Data == Never,
            E: _ErrorObject, Errors == [E],
            Meta: Swift.Encodable,
            JSONAPI: Swift.Encodable,
            Links == Never,
            Included == Never {
        self._errors = [error]
        if Meta.self != Never.self { _meta = meta() }
        if JSONAPI.self != Never.self { _jsonAPI = jsonAPI() }
    }

    /// Create an encodable document with errors.
    public init<E>(
        errors: [E],
        meta: @autoclosure () -> Meta = fatalError(),
        jsonAPI: @autoclosure () -> JSONAPI = fatalError()
    ) where Data == Never,
            E: _ErrorObject, Errors == [E],
            Meta: Swift.Encodable,
            JSONAPI: Swift.Encodable,
            Links == Never,
            Included == Never {
        self._errors = errors
        if Meta.self != Never.self { _meta = meta() }
        if JSONAPI.self != Never.self { _jsonAPI = jsonAPI() }
    }

    private var _data: Data!
    private var _errors: Errors!
    private var _meta: Meta!
    private var _jsonAPI: JSONAPI!
    private var _links: Links!
    private var _included: Included!

    public var data: Data { _data }
    public var errors: Errors  { _errors }
    public var meta: Meta  { _meta }
    public var jsonAPI: JSONAPI { _jsonAPI }
    public var links: Links { _links }
    public var included: Included { _included }
}

// MARK: - Hashable

extension Document: Equatable where Data: Equatable, Errors: Equatable, Meta: Equatable, JSONAPI: Equatable, Links: Equatable, Included: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        (Data.self == Never.self || lhs.data == rhs.data)
        && (Errors.self == Never.self || lhs.errors == rhs.errors)
        && (Meta.self == Never.self || lhs.meta == rhs.meta)
        && (JSONAPI.self == Never.self || lhs.jsonAPI == rhs.jsonAPI)
        && (Links.self == Never.self || lhs.links == rhs.links)
        && (Included.self == Never.self || lhs.included == rhs.included)
    }
}

extension Document: Hashable where Data: Hashable, Errors: Hashable, Meta: Hashable, JSONAPI: Hashable, Links: Hashable, Included: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        if Data.self != Never.self { hasher.combine(data) }
        if Errors.self != Never.self { hasher.combine(errors) }
        if Meta.self != Never.self { hasher.combine(meta) }
        if JSONAPI.self != Never.self { hasher.combine(jsonAPI) }
        if Links.self != Never.self { hasher.combine(links) }
        if Included.self != Never.self { hasher.combine(included) }
    }
}

// MARK: - Codable

private extension Document {

    enum CodingKey: String, Swift.CodingKey {
        case data, errors, meta, jsonAPI = "jsonapi", links, included
    }
}

extension Document: Encodable where Data: Swift.Encodable, Meta: Swift.Encodable, JSONAPI: Swift.Encodable, Links: Swift.Encodable, Included: Swift.Encodable {

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        if Data.self != Never.self {
            if let data = _data {
                try container.encode(data, forKey: .data)
            } else {
                try container.encodeNil(forKey: .data)
            }
        }
        if Errors.Element.self != Never.self {
            var errorsContainer = container.nestedUnkeyedContainer(forKey: .errors)
            for error in errors {
                var errorContainer = errorsContainer.nestedContainer(keyedBy: ErrorObjectCodingKey.self)
                if Errors.Element.ID.self != Never.self {
                    try errorContainer.encode(error.id, forKey: .id)
                }
                if Errors.Element.Links.self != Never.self {
                    try errorContainer.encode(error.links, forKey: .links)
                }
                if Errors.Element.Status.self != Never.self {
                    try errorContainer.encode(String(error.status), forKey: .status)
                }
                if Errors.Element.Code.self != Never.self {
                    try errorContainer.encode(String(error.code), forKey: .code)
                }
                if Errors.Element.Title.self != Never.self {
                    try errorContainer.encode(String(error.title), forKey: .title)
                }
                if Errors.Element.Detail.self != Never.self {
                    try errorContainer.encode(String(error.detail), forKey: .detail)
                }
                if Errors.Element.Source.self != Never.self {
                    try errorContainer.encode(error.source, forKey: .source)
                }
                if Errors.Element.Meta.self != Never.self {
                    try errorContainer.encode(error.meta, forKey: .meta)
                }
            }
        }
        if Meta.self != Never.self {
            try container.encode(meta, forKey: .meta)
        }
        if JSONAPI.self != Never.self {
            try container.encode(jsonAPI, forKey: .jsonAPI)
        }
        if Links.self != Never.self {
            try container.encode(links, forKey: .links)
        }
        if Included.self != Never.self {
            try container.encode(included, forKey: .included)
        }
    }
}

extension FailableDocument: Decodable where Success: Swift.Decodable, Failure: Swift.Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Document<Never, Never, Never, Never, Never, Never>.CodingKey.self)
        if !container.contains(.errors) {
            self = .success(try Success(from: decoder))
        } else {
            self = .failure(try Failure(from: decoder))
        }
    }
}

extension Document: Decodable where Data: Swift.Decodable, Meta: Swift.Decodable, JSONAPI: Swift.Decodable, Links: Swift.Decodable, Included: Swift.Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        if Data.self != Never.self {
            self._data = try container.decode(Data.self, forKey: .data)
        }
        if Errors.Element.self != Never.self {
            var arrayContainer = try container.nestedUnkeyedContainer(forKey: .errors)
            var errors = [Errors.Element]()
            if let count = arrayContainer.count {
                errors.reserveCapacity(count)
            }
            while !arrayContainer.isAtEnd {
                let errorContainer = try arrayContainer.nestedContainer(keyedBy: ErrorObjectCodingKey.self)
                let id: () -> Errors.Element.ID
                if Errors.Element.ID.self != Never.self {
                    let value = try errorContainer.decode(Errors.Element.ID.self, forKey: .id)
                    id = { value }
                } else {
                    id = { fatalError() }
                }
                let links: () -> Errors.Element.Links
                if Errors.Element.Links.self != Never.self {
                    let value = try errorContainer.decode(Errors.Element.Links.self, forKey: .links)
                    links = { value }
                } else {
                    links = { fatalError() }
                }
                let status: () -> Errors.Element.Status
                if Errors.Element.Status.self != Never.self {
                    let stringValue = try errorContainer.decode(String.self, forKey: .status)
                    guard let value = Errors.Element.Status(stringValue) else {
                        throw Swift.DecodingError.dataCorrupted(.init(codingPath: errorContainer.codingPath, debugDescription: "Couldn't instantiate \(Errors.Element.Status.self) from '\(stringValue)'."))
                    }
                    status = { value }
                } else {
                    status = { fatalError() }
                }
                let code: () -> Errors.Element.Code
                if Errors.Element.Code.self != Never.self {
                    let stringValue = try errorContainer.decode(String.self, forKey: .code)
                    guard let value = Errors.Element.Code(stringValue) else {
                        throw Swift.DecodingError.dataCorrupted(.init(codingPath: errorContainer.codingPath, debugDescription: "Couldn't instantiate \(Errors.Element.Code.self) from '\(stringValue)'."))
                    }
                    code = { value }
                } else {
                    code = { fatalError() }
                }
                let title: () -> Errors.Element.Title
                if Errors.Element.Title.self != Never.self {
                    let stringValue = try errorContainer.decode(String.self, forKey: .title)
                    guard let value = Errors.Element.Title(stringValue) else {
                        throw Swift.DecodingError.dataCorrupted(.init(codingPath: errorContainer.codingPath, debugDescription: "Couldn't instantiate \(Errors.Element.Title.self) from '\(stringValue)'."))
                    }
                    title = { value }
                } else {
                    title = { fatalError() }
                }
                let detail: () -> Errors.Element.Detail
                if Errors.Element.Detail.self != Never.self {
                    let stringValue = try errorContainer.decode(String.self, forKey: .detail)
                    guard let value = Errors.Element.Detail(stringValue) else {
                        throw Swift.DecodingError.dataCorrupted(.init(codingPath: errorContainer.codingPath, debugDescription: "Couldn't instantiate \(Errors.Element.Detail.self) from '\(stringValue)'."))
                    }
                    detail = { value }
                } else {
                    detail = { fatalError() }
                }
                let source: () -> Errors.Element.Source
                if Errors.Element.Source.self != Never.self {
                    let value = try errorContainer.decode(Errors.Element.Source.self, forKey: .source)
                    source = { value }
                } else {
                    source = { fatalError() }
                }
                let meta: () -> Errors.Element.Meta
                if Errors.Element.Meta.self != Never.self {
                    let value = try errorContainer.decode(Errors.Element.Meta.self, forKey: .meta)
                    meta = { value }
                } else {
                    meta = { fatalError() }
                }
                let error = Errors.Element(id: id, links: links, status: status, code: code, title: title, detail: detail, source: source, meta: meta)
                errors.append(error)
            }
            self._errors = errors as? Errors
        }
        if Meta.self != Never.self {
            self._meta = try container.decode(Meta.self, forKey: .meta)
        }
        if JSONAPI.self != Never.self {
            self._jsonAPI = try container.decode(JSONAPI.self, forKey: .jsonAPI)
        }
        if Links.self != Never.self {
            self._links = try container.decode(Links.self, forKey: .links)
        }
        if Included.self != Never.self {
            self._included = try container.decode(Included.self, forKey: .included)
        }
    }
}

// MARK: - Document variant types

/// A `Result` wrapper for a "success" document and its "failure" variant when decoding an expected document.
///
/// To allow fallback to the error variant of a document when decoding an expected success document, decode
/// it as this type, accessible via ``Document/FailableWith`` type.
///
/// `Failure` represents an error document variant of the expected document.
/// https://jsonapi.org/format/#document-top-level
/// https://jsonapi.org/format/#errors
/// "The members `data` and `errors` MUST NOT coexist in the same document." So when `errors` is detected
/// during decoding, the type is transformed into a failure document where:
/// + `Data` is transformed to `Never`, and `data` related types `Links` and `Included` are `Never` too.
/// + `Errors` is transformed to `[FailureResponse.ErrorObject].
/// + `Meta` becomes `FailureResponse.Meta` as the types can be different for success and failure document.
/// + `JSONAPI` remains the same.
public typealias FailableDocument<Document, FailureResponse>
= Result<
    Document,
    JSONAPI.Document<Never, [FailureResponse.ErrorObject], FailureResponse.Meta, Document.JSONAPI, Never, Never>
> where Document: DocumentType, Document: Swift.Decodable,
Document.Data: _PrimaryData, Document.Data: Swift.Decodable,
        Document.Errors.Element == Never,
        Document.Meta: Swift.Decodable,
        Document.JSONAPI: Swift.Decodable,
        Document.Links: Swift.Decodable,
        Document.Included: _Included, Document.Included: Swift.Decodable,
        FailureResponse: _FailureResponse

public extension Document where Self: Swift.Decodable, Errors.Element == Never {

    /// Returns a failable document type, that can result in an error variant of the document defined by `FailureResponse`.
    typealias FailableWith<FailureResponse> = FailableDocument<Self, FailureResponse> where FailureResponse: _FailureResponse
}

public extension Document where Data: Codable, Errors: Codable, Meta: Codable, JSONAPI: Codable, Links: Codable, Included == DecodableIncluded {

    /// Document with `included` member can't be `Encodable` and `Decodable` at the same time due to a dynamic nature
    /// of `EncodableDocument` and `DecodableIncluded`. This allows you for a quick conversion from a decodable
    /// document type with `included` member to its encodable variant.
    ///
    /// - Important: This type can shadow `Swift.Encodable` when working within the document which can result
    /// in a compile error. In such cases, refer to `Encodable` protocol with qualified symbol (`Swift.Encodable`), e.g.
    /// ```swift
    /// extension Document: @retroactive AsyncResponseEncodable where Self: Swift.Encodable {
    ///
    ///     public func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
    ///         let response = Response()
    ///         try response.content.encode(self, as: .jsonAPI)
    ///         return response
    ///     }
    /// }
    /// ```
    typealias Encodable = Document<Data, Errors, Meta, JSONAPI, Links, EncodableIncluded>
}

public extension Document where Data: Codable, Errors: Codable, Meta: Codable, JSONAPI: Codable, Links: Codable, Included == EncodableIncluded {

    /// Document with `included` member can't be `Encodable` and `Decodable` at the same time due to a dynamic nature
    /// of `EncodableDocument` and `DecodableIncluded`. This allows you for a quick conversion from an encodable
    /// document type with `included` member to its decodable variant.
    ///
    /// - Important: This type can shadow `Swift.Decodable` when working within the document which can result
    /// in a compile error. In such cases, refer to `Decodable` protocol with qualified symbol (`Swift.Decodable`), e.g.
    /// ```swift
    /// extension JSONAPI.Document: @retroactive AsyncRequestDecodable where Self: Swift.Decodable {
    ///
    ///     public static func decodeRequest(_ request: Vapor.Request) async throws -> Self {
    ///        try request.content.decode(Self.self, as: .jsonAPI)
    ///     }
    /// }
    /// ```
    typealias Decodable = Document<Data, Errors, Meta, JSONAPI, Links, DecodableIncluded>
}

// MARK: - Utils

private func areInIncreasingOrder(lhs: any _ResourceObject, rhs: any _ResourceObject) -> Bool {
    func rawType(_ resourceObject: some _ResourceObject) -> String { String(type(of: resourceObject).ResourceRepresentable.type) }
    return rawType(lhs) == rawType(rhs) ? String(lhs.id) < String(rhs.id) : rawType(lhs) < rawType(rhs)
}
