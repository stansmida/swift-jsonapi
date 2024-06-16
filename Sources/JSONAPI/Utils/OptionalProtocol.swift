// Allows method overloading where only difference is optional vs. non-optional type,
// otherwise having both results in ambiguity failure when calling with non-optional type.
public protocol _Optional<Wrapped> {
    associatedtype Wrapped
    var value: Optional<Wrapped> { get }
}

extension Optional: _Optional {
    public var value: Optional<Wrapped> { self }
}
