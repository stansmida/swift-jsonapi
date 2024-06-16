// https://jsonapi.org/format/#document-structure
import Foundation

public typealias DecodableDocument<Data, FailureResponse, Meta, JSONAPI, Links, Included>
= Document<Data, Never, Meta, JSONAPI, Links, Included, FailureResponse>
where Data: _PrimaryData, Data: Decodable,
Meta: Decodable,
JSONAPI: Decodable,
Links: Decodable,
Included: _Included, Included: Decodable,
FailureResponse: _FailureResponse

/// - Todo: Extensions don't have their generic parameter yet. These could perhaps get a variadic parameter `each Extension`?
public struct Document<Data, Errors, Meta, JSONAPI, Links, Included, FailureResponse> where Data: _PrimaryData,
                                                                                            Errors: _Errors,
                                                                                            Included: _Included,
                                                                                            FailureResponse: _FailureResponse {

    /// Create an encodable document where primary data is a single resource object.
    public init<T>(
        data: T?,
        meta: @autoclosure () -> Meta = fatalError(),
        jsonAPI: @autoclosure () -> JSONAPI = fatalError(),
        links: @autoclosure () -> Links = fatalError()
    ) where T: _ResourceObjectConvertible, Data == T.ResourceObject?,
            Errors == Never,
            Meta: Encodable,
            JSONAPI: Encodable,
            Links: Encodable,
            Included == Never,
            FailureResponse == Never {
        self._data = data?.resourceObject
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
        data: _CompoundResourceObject<CollectionOfOne<Data>>?,
        sorted: Bool = false,
        meta: @autoclosure () -> Meta = fatalError(),
        jsonAPI: @autoclosure () -> JSONAPI = fatalError(),
        links: @autoclosure () -> Links = fatalError()
    ) where Errors == Never,
            Meta: Encodable,
            JSONAPI: Encodable,
            Links: Encodable,
            Included == EncodableIncluded,
            FailureResponse == Never {
        self._data = data?.resourceObjects.first
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
            Meta: Encodable,
            JSONAPI: Encodable,
            Links: Encodable,
            Included == Never,
            FailureResponse == Never {
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
            Meta: Encodable,
            JSONAPI: Encodable,
            Links: Encodable,
            Included == EncodableIncluded,
            FailureResponse == Never {
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
            Meta: Encodable,
            JSONAPI: Encodable,
            Links == Never,
            Included == Never,
            FailureResponse == Never {
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
            Meta: Encodable,
            JSONAPI: Encodable,
            Links == Never,
            Included == Never,
            FailureResponse == Never {
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

// MARK: - Codable

private extension Document {

    enum CodingKey: String, Swift.CodingKey {
        case data, errors, meta, jsonAPI = "jsonapi", links, included
    }
}

extension Document: Encodable where Data: Encodable, Meta: Encodable, JSONAPI: Encodable, Links: Encodable, Included: Encodable {

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

extension DecodableDocument: Decodable where Data: Decodable, Meta: Decodable, JSONAPI: Decodable, Links: Decodable, Included: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        guard !container.contains(.errors) else {
            // "The members data and errors MUST NOT coexist in the same document." So when `errors` is detected,
            // the type is transformed into a failure document where:
            // + `Data` is transformed to `Never`, and data related types `Links` and `Included` are `Never` too.
            // + `Errors` is transformed to `[FailureResponse.ErrorObject], and `FailureResponse` is "consumed" to `Never`.
            // + `Meta` becomes `FailureResponse.Meta` as the types can be different for success and failure document.
            // + `JSONAPI` remains the same.
            throw try Document<Never, [FailureResponse.ErrorObject], FailureResponse.Meta, JSONAPI, Never, Never, Never>(decoder)
        }
        try self.init(decoder)
    }
}

private extension DecodableDocument where Data: Decodable, Meta: Decodable, JSONAPI: Decodable, Links: Decodable, Included: Decodable {

    init(_ decoder: any Decoder) throws {
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

// MARK: - Utils

private func areInIncreasingOrder(lhs: any _ResourceObject, rhs: any _ResourceObject) -> Bool {
    func rawType(_ resourceObject: some _ResourceObject) -> String { String(type(of: resourceObject).ResourceRepresentable.type) }
    return rawType(lhs) == rawType(rhs) ? String(lhs.id) < String(rhs.id) : rawType(lhs) < rawType(rhs)
}
