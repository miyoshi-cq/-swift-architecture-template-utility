@propertyWrapper
public struct NullCodable<Wrapped> {
    public var wrappedValue: Wrapped?

    public init(wrappedValue: Wrapped?) {
        self.wrappedValue = wrappedValue
    }
}

extension NullCodable: Encodable where Wrapped: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self.wrappedValue {
        case let .some(value): try container.encode(value)
        case .none: try container.encodeNil()
        }
    }
}

extension NullCodable: Decodable where Wrapped: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            self.wrappedValue = try container.decode(Wrapped.self)
        }
    }
}

extension NullCodable: Equatable where Wrapped: Equatable {}

public extension KeyedDecodingContainer {
    func decode<Wrapped>(
        _ type: NullCodable<Wrapped>.Type,
        forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> NullCodable<Wrapped> where Wrapped: Decodable {
        try decodeIfPresent(NullCodable<Wrapped>.self, forKey: key) ??
            NullCodable<Wrapped>(wrappedValue: nil)
    }
}
