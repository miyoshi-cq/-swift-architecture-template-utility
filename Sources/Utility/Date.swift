import Foundation

public extension DateFormatter {
    static func create(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = format

        var calender = Calendar(identifier: .gregorian)
        calender.locale = .current
        formatter.calendar = calender
        return formatter
    }

    static var iso8601: ISO8601DateFormatter {
        ISO8601DateFormatter()
    }

    static var iso8601WithSeconds: ISO8601DateFormatter {
        let f = ISO8601DateFormatter()
        f.formatOptions = [
            .withFullDate,
            .withTime,
            .withTimeZone,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
        ]
        return f
    }

    static var iso8601withFractionalSeconds: ISO8601DateFormatter {
        let f = ISO8601DateFormatter()
        f.formatOptions = [
            .withFullDate,
            .withTime,
            .withTimeZone,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
            .withFractionalSeconds,
        ]
        return f
    }
}

public extension String {
    var iso8601: Date? {
        DateFormatter.iso8601.date(from: self)
    }

    var iso8601WithSeconds: Date? {
        DateFormatter.iso8601WithSeconds.date(from: self)
    }

    var iso8601withFractionalSeconds: Date? {
        DateFormatter.iso8601withFractionalSeconds.date(from: self)
    }
}

public extension Date {
    var iso8601: String {
        DateFormatter.iso8601.string(from: self)
    }

    var iso8601WithSeconds: String {
        DateFormatter.iso8601WithSeconds.string(from: self)
    }

    var iso8601withFractionalSeconds: String {
        DateFormatter.iso8601withFractionalSeconds.string(from: self)
    }
}
