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
}
