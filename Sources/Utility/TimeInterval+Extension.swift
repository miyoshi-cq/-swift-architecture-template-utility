import Foundation

public extension TimeInterval {
    func timeFormatted() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = self >= 60 * 60 ? [.hour, .minute, .second] : [.minute, .second]
        return formatter.string(from: self) ?? ""
    }
}
