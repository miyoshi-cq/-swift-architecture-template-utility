import Foundation

public extension String {
    func match(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        guard
            let regularExpression: NSRegularExpression = try? NSRegularExpression(
                pattern: pattern,
                options: options
            )
        else {
            return false
        }
        let matches: [NSTextCheckingResult] = regularExpression.matches(
            in: self,
            options: [],
            range: NSMakeRange(0, self.count)
        )
        return !matches.isEmpty
    }
}
