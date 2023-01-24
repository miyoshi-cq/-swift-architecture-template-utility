import os

@available(iOS 14, *)
public class LogService {
    static var logger: Logger?

    public static func log(
        _ message: String,
        _ logType: OSLogType = .default,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        #if DEBUG
        let filename = file.components(separatedBy: "/").last ?? ""

        self.logger?.log(
            level: logType,
            "\(filename, privacy: .public) \(function, privacy: .public) L:\(String(line), privacy: .public) \(message, privacy: .public)"
        )
        #endif
    }
}
