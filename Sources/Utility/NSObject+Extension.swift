import Foundation

public protocol NameDescribable {
    var className: String { get }
    static var className: String { get }
}

public extension NameDescribable {
    var className: String {
        String(describing: type(of: self))
    }

    static var className: String {
        String(describing: type(of: self))
    }
}

extension NSObject: NameDescribable {}
