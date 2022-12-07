import os

public class LogService {
    static var logger: Logger!

    public static func log(
        _ message: String,
        function: String = #function
    ) {
        #if DEBUG
        self.logger.log(level: .default, "❗️[Default] \(function) \(message, privacy: .public)")
        #endif
    }
}
