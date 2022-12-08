import os

public class LogService {
    static var logger: Logger!

    public static func log(
        _ message: String,
        function: String = #function
    ) {
        #if DEBUG
        self.logger.log(
            level: .default,
            "❗️[Default] \(function, privacy: .public) \(message, privacy: .public)"
        )
        #endif
    }

    public static func info(
        _ message: String,
        function: String = #function
    ) {
        #if DEBUG
        self.logger.log(
            level: .info,
            "❗️[Info] \(function, privacy: .public) \(message, privacy: .public)"
        )
        #endif
    }

    public static func debug(
        _ message: String,
        function: String = #function
    ) {
        #if DEBUG
        self.logger.log(
            level: .debug,
            "❗️[Debug] \(function, privacy: .public) \(message, privacy: .public)"
        )
        #endif
    }

    public static func error(
        _ message: String,
        function: String = #function
    ) {
        #if DEBUG
        self.logger.log(
            level: .error,
            "❗️[Error] \(function, privacy: .public) \(message, privacy: .public)"
        )
        #endif
    }

    public static func fault(
        _ message: String,
        function: String = #function
    ) {
        #if DEBUG
        self.logger.log(
            level: .fault,
            "❗️[Fault] \(function, privacy: .public) \(message, privacy: .public)"
        )
        #endif
    }
}
