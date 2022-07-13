import Foundation

@propertyWrapper
public class UserDefaultsStorage<T: LosslessStringConvertible> {
    private let key: String

    public init(key: String) {
        self.key = key
    }

    public var wrappedValue: T? {
        get {
            UserDefaults.standard.object(forKey: key) as? T
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
