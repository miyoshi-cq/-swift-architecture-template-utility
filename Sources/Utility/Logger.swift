import os

public class LogService {
    static var logger: Logger?

    public static func log(
        _ message: String,
        _ logType: OSLogType = .default,
        function: String = #function
    ) {
        #if DEBUG
        self.logger?.log(
            level: logType,
            "\(function, privacy: .public) \(message, privacy: .public)"
        )
        #endif
    }
}
