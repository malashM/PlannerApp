//
//  Logger.swift
//  PlannerApp
//
//  Created by Mikhail Malaschenko on 31.07.23.
//

import Foundation

enum LogEvent: String {
    case error = "[‼️]"
    case info = "[ℹ️]"
    case debug = "[💬]"
    case verbose = "[🔬]"
    case warning = "[⚠️]"
    case severe = "[🔥]"
}

class Logger {
    
    static func log(_ event: LogEvent, message: String, fileName: String = #file, line: Int = #line, funcName: String = #function) {
        print("Logging->\(date) \(event.rawValue)[\(sourceFileName(filePath: fileName))]:\(line) \(funcName) -> \(message)")
    }
}

private extension Logger {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }()

    static var date: String {
        return dateFormatter.string(from: Date())
    }
    
    static func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.last ?? ""
    }

}
