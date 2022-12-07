import os

public class LogService {
    static var logger: Logger!

    public static func log(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        self.logger.log(level: .default, "❗️[Default] \(message) \(file) L:\(line) \(function)")
        #endif
    }
}
