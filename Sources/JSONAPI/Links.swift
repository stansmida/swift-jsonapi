// TODO: For now it just declares codability and sendability.
public protocol _Links: Codable, Sendable {}

extension Never: _Links {}
