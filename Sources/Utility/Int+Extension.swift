import Foundation

public extension Int {
    var withCommaString: String {
        let commaFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            formatter.groupingSize = 3
            return formatter
        }()

        return commaFormatter.string(from: NSNumber(integerLiteral: self)) ?? "\(self)"
    }
}
