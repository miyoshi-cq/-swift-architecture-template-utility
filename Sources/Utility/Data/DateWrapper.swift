import Foundation

public protocol DateValueCodableStrategy {
    associatedtype RawValue: Codable & Equatable

    static func decode(_ value: RawValue) throws -> Date
    static func encode(_ date: Date) -> RawValue
}

@propertyWrapper
public struct DateValue<Formatter: DateValueCodableStrategy>: Codable, Equatable {
    private let value: Formatter.RawValue
    public var wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
        value = Formatter.encode(wrappedValue)
    }

    public init(from decoder: Decoder) throws {
        value = try Formatter.RawValue(from: decoder)
        wrappedValue = try Formatter.decode(value)
    }

    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

public struct ISO8601FullStrategy: DateValueCodableStrategy {
    public static func decode(_ value: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFractionalSeconds
        return formatter.date(from: value)!
    }

    public static func encode(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFractionalSeconds
        return formatter.string(from: date)
    }
}

public struct ISO8601Strategy: DateValueCodableStrategy {
    public static func decode(_ value: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: value)!
    }

    public static func encode(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: date)
    }
}
