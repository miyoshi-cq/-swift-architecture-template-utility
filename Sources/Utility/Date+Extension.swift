import Foundation

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = .japan
    formatter.locale = .japan
    formatter.calendar = Calendar(identifier: .gregorian)
    return formatter
}()

public extension Date {
    var calender: Calendar {
        var calender = Calendar(identifier: .gregorian)
        calender.timeZone = .japan
        calender.locale = .japan
        return calender
    }

    var year: Int {
        formatter.dateFormat = "YYYY"
        return Int(formatter.string(from: self))!
    }

    var month: Int {
        formatter.dateFormat = "MM"
        return Int(formatter.string(from: self))!
    }

    var day: Int {
        formatter.dateFormat = "dd"
        return Int(formatter.string(from: self))!
    }

    var minute: Int {
        formatter.dateFormat = "mm"
        return Int(formatter.string(from: self))!
    }

    var second: Int {
        formatter.dateFormat = "ss"
        return Int(formatter.string(from: self))!
    }

    var dayOfWeek: String {
        formatter.dateFormat = "EE"
        return formatter.string(from: self)
    }

    var dateJp: String {
        formatter.dateFormat = DateStringType.yearMonthDayJp.rawValue
        return formatter.string(from: self)
    }

    var dateYYYYMMdd: String {
        formatter.dateFormat = DateStringType.yyyyMMdd.rawValue
        return formatter.string(from: self)
    }

    var timeHHmmss: String {
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }

    var timeOnlyShort: String {
        formatter.dateFormat = DateStringType.timeOnly.rawValue
        return formatter.string(from: self)
    }

    var dateTime: String {
        formatter.dateFormat = "YYYY/MM/dd HH:mm"
        return formatter.string(from: self)
    }

    var weekEndDate: Date {
        var date: Date = .init()
        if let weekend = Calendar.current.date(byAdding: .day, value: 6, to: self) {
            date = weekend
        }
        return date
    }

    var iso8601withSeconds: String { Formatter.iso8601withSeconds.string(from: self) }

    var add15Min: Date {
        Calendar.current.date(byAdding: .minute, value: 15, to: self)!
    }

    var add10Min: Date {
        Calendar.current.date(byAdding: .minute, value: 10, to: self)!
    }

    var minus10Min: Date {
        Calendar.current.date(byAdding: .minute, value: -10, to: self)!
    }

    var nextDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
}

extension DateFormatter {
    static var japanFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = .japan
        formatter.locale = .japan
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }
}

extension TimeZone {
    static let japan = TimeZone(identifier: "Asia/Tokyo")!
}

extension Locale {
    static let japan = Locale(identifier: "ja_jp")
}

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
        timeZone = .japan
    }
}

extension Formatter {
    static let iso8601withSeconds = ISO8601DateFormatter([.withInternetDateTime])
}
