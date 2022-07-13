import Foundation

public enum DateStringType: String {
    case yyyyMMdd = "YYYYMMdd"
    case yyyyMMddSlash = "YYYY/MM/dd"
    case YYYY年M月
    case M月d日HHii = "M月d日 HH:ii"
    case yearMonthDayJp = "YYYY年M月d日"
    case yearMonthDayDateJp = "YYYY年M月d日(EEE)"
    case startAt = "ah:mm〜"
    case startAtYearMonthDateJp24 = "YYYY年M月d日 H:mm〜"
    case timeOnly = "H:mm"
}

public extension String {
    func messageEnterJson() -> String {
        replacingOccurrences(of: "\n", with: "\\n")
    }

    func calendarString() -> (年: String, 月: String, 日: String, 週: String) {
        let yearRange = range(of: "年")
        let monthRange = range(of: "月")
        let dayRange = range(of: "日")
        let startWeekRange = range(of: "(")
        let endWeekRange = range(of: ")")
        let year: String = self[startIndex ... yearRange!.lowerBound].description
        let month: String = self[yearRange!.upperBound ... monthRange!.lowerBound].description
        let day: String = self[monthRange!.upperBound ..< dayRange!.lowerBound].description
        let week: String = self[startWeekRange!.upperBound ..< endWeekRange!.lowerBound].description

        return (year, month, day, week)
    }
}

public extension String {
    var iso8601withSeconds: Date? { Formatter.iso8601withSeconds.date(from: self) }

    func dateFromISO8601String() -> Date? {
        iso8601withSeconds
    }

    func adaptorISO8601(to conversionType: DateStringType) -> String {
        adaptorISO8601(to: conversionType.rawValue)
    }

    func adaptorISO8601(to conversionType: String) -> String {
        let formatter = DateFormatter.japanFormatter
        formatter.dateFormat = conversionType

        if let dateSecond = iso8601withSeconds {
            return formatter.string(from: dateSecond)
        }

        return self
    }

    func adaptorISO8601(from originallyType: DateStringType) -> String {
        adaptorISO8601(from: originallyType.rawValue)
    }

    func adaptorISO8601(from originallyType: String) -> String {
        let formatter = DateFormatter.japanFormatter
        formatter.dateFormat = originallyType

        guard let date = formatter.date(from: self) else { return self }

        return date.iso8601withSeconds
    }

    func date(from originallyType: DateStringType) -> Date? {
        date(from: originallyType.rawValue)
    }

    func date(from originallyType: String) -> Date? {
        let formatter = DateFormatter.japanFormatter
        formatter.dateFormat = originallyType

        guard let date = formatter.date(from: self) else { return nil }

        return date
    }
}
