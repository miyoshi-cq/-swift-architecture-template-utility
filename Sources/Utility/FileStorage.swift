import Foundation

@propertyWrapper
public class FileStorage<T: Codable> {
    private var value: T?
    private let file: String

    public init(fileName: String) {
        self.file = fileName
        self.value = LocalStorageManager.getObjectFromFile(filename: fileName)
    }

    public var wrappedValue: T? {
        get { self.value }
        set {
            self.value = newValue

            let fileName = self.file

            if let data = newValue {
                LocalStorageManager.writeObjectToFile(filename: fileName, jsonEncodable: data)
            } else {
                /// setting value to nil will clear cache
                LocalStorageManager.deleteFile(filename: fileName)
            }
        }
    }
}

private enum LocalStorageManager {
    private enum PathSearchError: Error {
        case pathNotFound
    }

    private enum Constants {
        static let fileWritingDebounce = DispatchTimeInterval.milliseconds(200)
    }

    enum DispatchQueueLabel: String {
        case localStorageManager
    }

//    static func clearDiskCache(
//        dispatchQueue: DispatchQueue =
//            DispatchQueue(label: DispatchQueueLabel.localStorageManager.rawValue)
//    ) {
//        dispatchQueue.async {
//            FileName.allCases.forEach { filename in
//                Self.deleteFile(filename: filename)
//            }
//        }
//    }

    static func removeAll() {
        let manager = FileManager.default
        guard
            let docUrl = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first
        else {
            return
        }
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let dirURL = docUrl.appendingPathComponent(bundleId)

        manager.enumerator(at: dirURL, includingPropertiesForKeys: nil)?
            .forEach { url in
                if let url = url as? URL {
                    try? manager.removeItem(at: url)
                }
            }
    }

    static func getObjectFromFile<T: Decodable>(filename: String) -> T? {
        do {
            let fileURL = try retrieveConfiguredFileURL(filename: filename)
            let localData = try Data(contentsOf: fileURL, options: .alwaysMapped)
            let localItems = try JSONDecoder().decode(T.self, from: localData)
            return localItems
        } catch {
            logError(errorDescription: error.localizedDescription, functionName: #function)
            return nil
        }
    }

    static func writeObjectToFile(
        filename: String,
        jsonEncodable: some Encodable,
        dispatchQueue: DispatchQueue = DispatchQueue(
            label: DispatchQueueLabel.localStorageManager
                .rawValue
        )
    ) {
        dispatchQueue.async {
            let jsonEncoder = JSONEncoder()
            guard let jsonData = try? jsonEncoder.encode(jsonEncodable) else {
                return
            }
            do {
                let fileURL = try self.retrieveConfiguredFileURL(filename: filename)
                try jsonData.write(to: fileURL, options: Data.WritingOptions.atomic)
            } catch {
                self.logError(errorDescription: error.localizedDescription, functionName: #function)
            }
        }
    }

    static func deleteFile(
        filename: String,
        dispatchQueue: DispatchQueue = DispatchQueue(
            label: DispatchQueueLabel.localStorageManager
                .rawValue
        )
    ) {
        dispatchQueue.async {
            do {
                let fileURL = try self.retrieveConfiguredFileURL(filename: filename)
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                DispatchQueue.main.async {
                    self.logError(
                        errorDescription: error.localizedDescription,
                        functionName: #function
                    )
                }
            }
        }
    }
}

// MARK: - private method

private extension LocalStorageManager {
    static func retrieveConfiguredFileURL(
        filename: String,
        excludeFromBackup: Bool = true
    ) throws -> URL {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let appSupportDir = FileManager.SearchPathDirectory.applicationSupportDirectory
        let userMask = FileManager.SearchPathDomainMask.userDomainMask
        guard
            let appSupportDirURL: URL = FileManager.default.urls(for: appSupportDir, in: userMask)
                .first
        else {
            throw PathSearchError.pathNotFound
        }
        let dirURL = appSupportDirURL.appendingPathComponent(bundleId, isDirectory: true)
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: dirURL.path, isDirectory: &isDir) {
            try? FileManager.default.createDirectory(
                at: dirURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        var fullURL = dirURL.appendingPathComponent(filename, isDirectory: false)
        if excludeFromBackup {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try? fullURL.setResourceValues(resourceValues)
        }
        return fullURL
    }

    static func logError(errorDescription: String, functionName: String) {
        let log = String(describing: self) + " " + functionName + " error: " + errorDescription

        Task.detached {
            await AnalyticsService.shared.log(log)
        }
    }
}
