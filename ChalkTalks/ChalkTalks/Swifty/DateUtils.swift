//
//  DateUtils.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import Foundation

@objc(CTDateUtils)
class DateUtils: NSObject {
    
    @objc class func formatTimeAgoWith(timestamp: TimeInterval) -> String {
        let now = Date().timeIntervalSince1970
        let interval = now - timestamp
        
        if interval <= 60 {
            return "刚刚"
        } else if interval < 60 * 60 {
            let minute = Int(interval / 60)
            return "\(minute)分钟前"
        } else if interval < 60 * 60 * 24 {
            let hour = Int(interval / (60 * 60))
            return "\(hour)小时前"
        } else if interval < 60 * 60 * 24 * 30 {
            let day = Int(interval / (60 * 60 * 24))
            return "\(day)天前"
        } else if interval < 60 * 60 * 24 * 365 {
            let month = Calendar.current.dateComponents([.month], from: Date(timeIntervalSince1970: timestamp), to: Date()).month ?? 1
            return "\(max(month, 1))个月前"
        } else {
            let year = Calendar.current.dateComponents([.year], from: Date(timeIntervalSince1970: timestamp), to: Date()).year ?? 1
            return "\(max(year, 1))年前"
        }
    }
    
    @objc class func formatTimeAgoWith(date: Date) -> String {
        return formatTimeAgoWith(timestamp: date.timeIntervalSince1970)
    }
}

// MARK: - Date

extension Date {
    
    public static func staticFormatter(format: String, offset: String? = nil) -> DateFormatter {

        let threadDictionary = Thread.current.threadDictionary
        var formatter: DateFormatter

        if let fmt = threadDictionary[format] as? DateFormatter {
            formatter = fmt
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = format
            fmt.locale = Locale(identifier: "en_US_POSIX")

            threadDictionary[format] = fmt

            formatter = fmt
        }

        if let offset = offset, let tz = TimeZone(identifier: offset) {
            formatter.timeZone = tz
        } else {
            formatter.timeZone = TimeZone.autoupdatingCurrent
        }

        return formatter
    }
    
    public var gmtFormat: String {
        return Date.staticFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ").ss.prepare({ (fmt) in
            fmt.timeZone = TimeZone(secondsFromGMT: 0)
        }).string(from: self)
    }
}
