// MARK: Codable

/// https://developer.apple.com/documentation/swift/never/init(from:)
/// https://developer.apple.com/documentation/swift/never/encode(to:)
@available(iOS, obsoleted: 17.0, message: "This API is available directly in the language since this obsoletion.")
@available(macOS, obsoleted: 14.0, message: "This API is available directly in the language since this obsoletion.")
@available(macCatalyst, obsoleted: 17.0, message: "This API is available directly in the language since this obsoletion.")
@available(tvOS, obsoleted: 17.0, message: "This API is available directly in the language since this obsoletion.")
@available(watchOS, obsoleted: 10.0, message: "This API is available directly in the language since this obsoletion.")
extension Never: Codable {

    public init(from decoder: any Decoder) throws {
        fatalError()
    }

    public func encode(to encoder: any Encoder) throws {}
}

@available(iOS, obsoleted: 15.0, message: "This API is available directly in the language since this obsoletion.")
@available(macOS, obsoleted: 12.0, message: "This API is available directly in the language since this obsoletion.")
@available(macCatalyst, obsoleted: 15.0, message: "This API is available directly in the language since this obsoletion.")
@available(tvOS, obsoleted: 15.0, message: "This API is available directly in the language since this obsoletion.")
@available(watchOS, obsoleted: 8.0, message: "This API is available directly in the language since this obsoletion.")
extension Never: @retroactive Identifiable {
    public var id: Never { fatalError() }
}

// MARK: LosslessStringConvertible
// The below allows to pass `Never?.none` to a generic parameter constrained to `LosslessStringConvertible`.

extension Optional: @retroactive CustomStringConvertible where Wrapped == Never {
    public var description: String {
        switch self {
            case .none: "nil"
            case .some(let wrapped): wrapped.description
        }
    }
}

extension Optional: @retroactive LosslessStringConvertible where Wrapped == Never {
    public init?(_ description: String) { nil }
}

extension Never: @retroactive CustomStringConvertible {}
extension Never: @retroactive LosslessStringConvertible {
    public init?(_ description: String) { nil }
    public var description: String { fatalError() }
}

// MARK: Sequence
// The below allows to iterate over Document.Errors
extension Never: @retroactive Sequence {
    public func makeIterator() -> NeverIterator { .init() }
}

public struct NeverIterator: IteratorProtocol {
    public mutating func next() -> Never? { nil }
}
