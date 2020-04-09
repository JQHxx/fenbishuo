//
//  Logger .swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/30.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

fileprivate enum LoggerLevel: String {
    
    case verbose
    case debug
    case info
    case warning
    case error
    
    var title: String { rawValue.uppercased() }
}

@objc(CTLogger)
class Logger: NSObject {
    
    static let queue = DispatchQueue(label: "com.fenbishuo.ios.logger")
    
    static func verbose(_ content: String,
                      _ file: String = #file,
                      _ function: String = #function,
                      _ line: Int = #line) {
        log(type: .verbose, content, file, function, line)
    }
    
    @inline(__always)
    static func debug(_ content: String,
                      _ file: String = #file,
                      _ function: String = #function,
                      _ line: Int = #line) {
        #if DEBUG
        print(
            "\(Date().gmtFormat) [DEBUG] \(content)"//" (\(function) - line:\(line))."
        )
        #endif
    }
    
    static func info(_ content: String,
                      _ file: String = #file,
                      _ function: String = #function,
                      _ line: Int = #line) {
        log(type: .info, content, file, function, line)
    }
    
    static func warning(_ content: String,
                      _ file: String = #file,
                      _ function: String = #function,
                      _ line: Int = #line) {
        log(type: .warning, content, file, function, line)
    }
    
    @objc static func error(log: String) {
        error(log)
    }
    
    static func error(_ content: String,
                      _ file: String = #file,
                      _ function: String = #function,
                      _ line: Int = #line) {
        log(type: .error, content, file, function, line)
    }
    
    fileprivate static func log(type: LoggerLevel,
                    _ content: String,
                    _ file: String,
                    _ function: String,
                    _ line: Int) {
        #if DEBUG
        print(
            "\(Date().gmtFormat) [\(type.title)] \(content)"
        )
        #endif
        if [.error, .warning, .info].contains(type) {
            queue.async {
                self.writeToFile("\(Date().gmtFormat) [\(type.title)] \(content)\n")
            }
        }
    }
    
    // MARK: - write to file
    
    fileprivate static var cacheLogs: [String] = []
    
    @objc static func flush() {
        queue.async {
            guard !self.cacheLogs.isEmpty else { return }
            
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: self.filePath)
                let fileSize = (attr as NSDictionary).fileSize()
                // 大于1MB清理一半旧日志
                if fileSize > 1024 * 1024 {
                    let handle = FileHandle(forUpdatingAtPath: self.filePath)
                    if let data = handle?.readDataToEndOfFile(), let text = String(data: data, encoding: .unicode) {
                        let start = text.index(text.startIndex, offsetBy: text.count / 2)
                        let sub = text[start...]
                        handle?.truncateFile(atOffset: 0)
                        handle?.write(sub.data(using: .unicode) ?? "".data(using: .unicode)!)
                    }
                    handle?.closeFile()
                }
            } catch {
                self.error("获取文件大小失败:\(error)")
            }
            
            if self.fileHandle == nil {
                self.fileHandle = FileHandle(forUpdatingAtPath: self.filePath)
            }
            
            let text = self.cacheLogs.joined()
            if let data = text.data(using: .unicode) {
                self.fileHandle?.seekToEndOfFile()
                self.fileHandle?.write(data)
                self.cacheLogs = []
            }
            self.fileHandle?.closeFile()
            self.fileHandle = nil
        }
    }
    
    fileprivate static func writeToFile(_ log: String) {
        cacheLogs.append(log)
    }
    
    fileprivate static var fileHandle: FileHandle?
    
    static let filePath: String = {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let directory = documentsPath + "/com.fenbishuo.logs"
        if !FileManager.default.fileExists(atPath: directory) {
            try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        }
        let logPath = directory + "/logs"
        if !FileManager.default.fileExists(atPath: logPath) {
            FileManager.default.createFile(atPath: logPath, contents: nil, attributes: nil)
        }
        debug("Logger file path: \(logPath)")
        return logPath
    }()
}
