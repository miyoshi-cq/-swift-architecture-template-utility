import Foundation

public extension String {
    enum Regex: String {
        case phone = "^[0-9]+$"
        case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        case password = "^[A-Za-z0-9]{8,}$"
    }

    func isValid(regex: Regex) -> Bool {
        let test = NSPredicate(format: "SELF MATCHES %@", regex.rawValue)
        return test.evaluate(with: self)
    }
}
