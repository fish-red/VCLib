//
//  NSDate+Extension.swift
//  IMTodo
//
//  Created by 陈文强 on 16/3/4.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import Foundation

// MARK: - EqualTable
// MARK: 比较两个NSDate对象
// MARK: ↓↓↓↓↓
extension Date {}
/// EZSE: Returns if dates are equal to each other
public func == (lhs: Date, rhs: Date) -> Bool {
    return (lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970)
}
/// EZSE: Returns if one date is smaller than the other
public func < (lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

public func > (lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedDescending
}



// MARK: - Date to String with format
// MARK: 通过NSDate去创建描述日期的字符串
// MARK: ↓↓↓↓↓

// MARK: DateFormatManager
// MARK: 单例管理 NSDateFormat对象
/// 多次使用NSDateFormat会导致性能下降
/// 使用单例保存format
private class DateFormatManager {
    fileprivate init() {}
    fileprivate static let _manager = DateFormatManager()
    fileprivate class func defaultManager() -> DateFormatManager {
        return _manager
    }
    
    fileprivate var formatList: [String: DateFormatter] = [String: DateFormatter]()
    
    fileprivate func getNSFormat(_ f_name: String) -> DateFormatter {
        if let f = formatList[f_name] {
            return f
        }else {
            let format = DateFormatter()
            format.dateFormat = f_name
            formatList[f_name] = format
            return format
        }
    }
}


// MARK: DateFormat
// MARK: 格式描述枚举值
public enum DateFormat: String {
    case YMD_With_Line       = "yyyy-MM-dd"
    case MD_And_HM_With_Line = "yyyy-MM-dd HH:mm"
    case MD_With_Line        = "MM-dd"
    
    case YMD_With_Split      = "yyyy/MM/dd"
    
    case MD_With_Dot         = "MM.dd"
    
    #if os(iOS)
    case YMD_With_Dot        = "yy.MM.dd"
    case YMD_And_HM_With_CH  = "yyyy年MM月dd日 HH:mm"
    #elseif os(OSX)
    case YMD_With_Dot        = "yyyy.MM.dd"
    case YMD_And_HMS_With_CH = "yyyy年MM月dd日 HH:mm:ss"
    #endif
    
    case Full_Format         = "yyyyMMddHHmmssSSS"
    
    case All_Format         = "公元前/后: G,\n\t  年份: u=yyyy=yy,\n\t  季度: q=qqq=qqqq,\n\t  月份: M=MMM=MMMM,\n\t  今天是今年第几周: w,\n\t  今天是本月第几周: W,\n\t  今天是今天第几天: D,\n\t  今天是本月第几天: d,\n\t  星期: c=ccc=cccc,\n\t  上午/下午: a,\n\t  小时: h=H,\n\t  分钟: m,\n\t  秒: s,\n\t  毫秒: SSS,\n\t  这一天已过多少毫秒: A,\n\t  时区名称: zzzz=vvvv,\n\t  时区编号: Z "
}


/// 通过DateFormat\String 获得String对象
extension Date {
    /// 通过格式枚举值(可根据需求定制) 将日期转换成String输出
    public func toString(dateFormat format: DateFormat) -> String {
        return toString(format: format.rawValue)
    }
    
    /// 通过输入的格式 将日期转换成String输出
    public func toString(format: String) -> String {
        let fmt = DateFormatManager.defaultManager().getNSFormat(format)
        let str: String = fmt.string(from: self)
        return str
    }
}





// MARK: - Calendar
// MARK: 针对日历(Calendar)的类拓展
// MARK: ↓↓↓↓↓

// MARK: To Int Value
// MARK: 获取NSDate中对应的参数
extension Date {
    public var year: Int {
        return (Calendar.current as NSCalendar).component(NSCalendar.Unit.year, from: self)
    }
    
    public var quarter: Int {
        return (Calendar.current as NSCalendar).component(NSCalendar.Unit.quarter, from: self)
    }
    
    public var month: Int {
        return (Calendar.current as NSCalendar).component(NSCalendar.Unit.month, from: self)
    }
    
    public var weekOfYear: Int {
        return (Calendar.current as NSCalendar).component(NSCalendar.Unit.weekOfYear, from: self)
    }
    
    public var weekOfMonth: Int {
        return (Calendar.current as NSCalendar).component(NSCalendar.Unit.weekOfMonth, from: self)
    }
    
    public var day: Int {
        return (Calendar.current as NSCalendar).component(NSCalendar.Unit.day, from: self)
    }
    
    public var hour: Int {
        return (Calendar.current as NSCalendar).component(NSCalendar.Unit.hour, from: self)
    }
    
    public var minute: Int {
        return (Calendar.current as NSCalendar).component(NSCalendar.Unit.minute, from: self)
    }
    
    public var second: Int {
        return (Calendar.current as NSCalendar).component(NSCalendar.Unit.second, from: self)
    }
    
    /// 获取当前星期数字
    public var dayOfWeek: Int? {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale(identifier: "zh_CN")
        
        let cmps = (calendar as NSCalendar?)?.component(NSCalendar.Unit.weekday, from: self)
        return cmps
    }
    
    /// 获取当前星期文本
    public var dayNameOfWeek: String {
        let day = dayOfWeek
        
        guard day != nil else {
            return "Null of day"
        }
        
        switch day! {
        case 1:
            return "星期日"
        case 2:
            return "星期一"
        case 3:
            return "星期二"
        case 4:
            return "星期三"
        case 5:
            return "星期四"
        case 6:
            return "星期五"
        case 7:
            return "星期六"
        default:
            return "I don't know"
        }
    }
}


// MARK: To String For Time Passed
// MARK: 获得时间戳
extension Date {
    
    /// 获取时间描述
    public func toStringForTimePassed(_ useCH: Bool = false) -> String {
        let now = Date()
        guard self <= now else {
            return "the format was wrong! ..."
        }
        
        let unit = NSCalendar.Unit.year.union(NSCalendar.Unit.month).union(NSCalendar.Unit.day).union(NSCalendar.Unit.hour).union(NSCalendar.Unit.minute).union(NSCalendar.Unit.second)
        let components = Date.dateCmp(self, toDate: now, unit: unit)
        
        let year    = useCH ? "年" : " year"
        let years   = useCH ? "年" : " years"
        let month   = useCH ? "月" : " month"
        let months  = useCH ? "月" : " months"
        let day     = useCH ? "天" : " day"
        let days    = useCH ? "天" : " days"
        let hour    = useCH ? "小时" : " hour"
        let hours   = useCH ? "小时" : " hours"
        let minute  = useCH ? "分钟" : " minute"
        let minutes = useCH ? "分钟" : " minutes"
        let second  = useCH ? "秒" : " second"
        let seconds = useCH ? "秒" : " seconds"
        let ago     = useCH ? "前" : " ago"
        let justNow = useCH ? "刚刚" : "Just now"
        
        var str: String
        if components.year! >= 1 {
            
            components.year == 1 ? (str = year) : (str = years)
            return "\(components.year)\(str)\(ago)"
            
        } else if components.month! >= 1 {
            
            components.month == 1 ? (str = month) : (str = months)
            return "\(components.month)\(str)\(ago)"
            
        } else if components.day! >= 1 {
            
            components.day == 1 ? (str = day) : (str = days)
            return "\(components.day)\(str)\(ago)"
            
        } else if components.hour! >= 1 {
            
            components.hour == 1 ? (str = hour) : (str = hours)
            return "\(components.hour)\(str)\(ago)"
            
        } else if components.minute! >= 1 {
            
            components.minute == 1 ? (str = minute) : (str = minutes)
            return "\(components.minute)\(str)\(ago)"
            
        } else if components.second! >= 1 {
            
            components.second == 1 ? (str = second) : (str = seconds)
            return "\(components.second)\(str)\(ago)"
            
        }else if components.second == 0 {
            
            return justNow
            
        } else {
            return "i don't know the currect time..."
        }
    }
    
    
    
    // 国际化
    public func toStringForTimePassedWithLocal() -> String {
        let now = Date()
        guard self <= now else {
            return "the format was wrong! ..."
        }
        
//        let unit = NSCalendar.Unit.year.union(NSCalendar.Unit.month).union(NSCalendar.Unit.day).union(NSCalendar.Unit.hour).union(NSCalendar.Unit.minute).union(NSCalendar.Unit.second)
//        let components = Date.dateCmp(self, toDate: now, unit: unit)
        
//        let mgr = LanguageManager.defaultMgr()
//        
//        if components.year! >= 1 {
//            
//            return mgr.yearForTimePassed(components.year)
//            
//        } else if components.month! >= 1 {
//            
//            return mgr.monthForTimePassed(components.month)
//            
//        } else if components.day! >= 1 {
//            
//            return mgr.dayForTimePassed(components.day)
//            
//        } else if components.hour! >= 1 {
//            
//            return mgr.hourForTimePassed(components.hour)
//            
//        } else if components.minute! >= 1 {
//            
//            return mgr.minuteForTimePassed(components.minute)
//            
//        } else {
//            
//            return mgr.justNowTimePassed()
//            
//        }
        return ""
    }
}


// MARK: DateParameter
// MARK: 日期参数对象
open class DateParameter: NSObject {
    open var year: Int?
    open var month: Int?
    open var day: Int?
    
    open var hour: Int?
    open var minute: Int?
    open var second: Int?
    
    /// 将所有值取反
    fileprivate func negativeValue() {
        if let y = year {
            year = -Int(abs(Int32(y)))
        }
        if let M = month {
            month = -Int(abs(Int32(M)))
        }
        if let d = day {
            day = -Int(abs(Int32(d)))
        }
        if let h = hour {
            hour = -Int(abs(Int32(h)))
        }
        if let m = minute {
            minute = -Int(abs(Int32(m)))
        }
        if let s = second {
            second = -Int(abs(Int32(s)))
        }
    }
    
    /// 将值复制到NSDateComponents中
    open func copyParamToComponents(_ cmps: DateComponents) {
//        if let y = year {
//            cmps.year = y
//        }
//        if let M = month {
//            cmps.month = M
//        }
//        if let d = day {
//            cmps.day = d
//        }
//        if let h = hour {
//            cmps.hour = h
//        }
//        if let m = minute {
//            cmps.minute = m
//        }
//        if let s = second {
//            cmps.second = s
//        }
    }
}


// MARK: Counting
// MARK: 计算时间差
extension Date {
    /// Counting Date (Instance Method)
    /// 计算时间差值
    public func countingToNow() -> DateComponents {
        return Date.countingTwoDate(self, date2: Date())
    }
    
    /// Counting Date (Class Method)
    /// 计算两个日期差值(day)
    public static func countingTwoDate(_ date1: Date, date2: Date) -> DateComponents {
        let unit = NSCalendar.Unit.year.union(NSCalendar.Unit.month).union(NSCalendar.Unit.day).union(NSCalendar.Unit.hour).union(NSCalendar.Unit.minute).union(NSCalendar.Unit.second)
        
        let fromDate: Date = min(date1, date2)
        let toDate: Date = max(date1, date2)
        return dateCmp(fromDate, toDate: toDate, unit: unit)
    }
}


// MARK: Judge Date
// MARK: 判断Date属性
extension Date {
    /// 判断是否为今年
    public func isThisYear() -> Bool {
        let cmps = Date.dateCmp(self, toDate: Date(), unit: NSCalendar.Unit.year)
        return cmps.year == 0
    }
    
    /// 判断是否为本月
    public func isThisMonth() -> Bool {
        let unit = NSCalendar.Unit.year.union(NSCalendar.Unit.month)
        let cmps = Date.dateCmp(self, toDate: Date(), unit: unit)
        return cmps.year == 0 && cmps.month == 0
    }
    
    /// 判断是否为本周
    public func isThisWeek() -> Bool {
        let unit = NSCalendar.Unit.year.union(NSCalendar.Unit.weekOfYear)
        let cmps = Date.dateCmp(self, toDate: Date(), unit: unit)
        return cmps.year == 0 && cmps.weekOfYear == 0
    }
    
    /// 判断是否为今天
    public func isThisDay() -> Bool {
        let unit = NSCalendar.Unit.year.union(NSCalendar.Unit.month).union(NSCalendar.Unit.day)
        let cmps = Date.dateCmp(self, toDate: Date(), unit: unit)
        return cmps.year == 0 && cmps.month == 0 && cmps.day == 0
    }
    
    /// 判断某个时间是否为明天
    public func isTomorrow() -> Bool {
        let unit = NSCalendar.Unit.year.union(NSCalendar.Unit.month).union(NSCalendar.Unit.day)
        let cmps = Date.dateCmp(self, toDate: Date(), unit: unit)
        return cmps.year == 0 && cmps.month == 0 && cmps.day == -1
    }
    
    /// 判断某个时间是否为昨天
    public func isYesterday() -> Bool {
        let unit = NSCalendar.Unit.year.union(NSCalendar.Unit.month).union(NSCalendar.Unit.day)
        let cmps = Date.dateCmp(self, toDate: Date(), unit: unit)
        return cmps.year == 0 && cmps.month == 0 && cmps.day == 1
    }
}


// MARK: Update NSDate
// MARK: 改变日期
extension Date {
    /// Create NSDate with param 
    /// 通过一个param对象创建一个NSDate
    init(param: DateParameter) {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let cmps = DateComponents()
        param.copyParamToComponents(cmps)
        
        let d = calendar.date(from: cmps)
        
        if d != nil {
            self.init(timeInterval: 0, since: d!)
        }else {
            self.init()
        }
    }
    
    /// 手动创建日期对象
    public static func createDate(parameter: DateParameter) -> Date? {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let cmps = DateComponents()
        
        parameter.copyParamToComponents(cmps)
        
        // 根据设置的dateComponentsForDate获取历法中与之对应的时间点
        // 这里的时分秒会使用NSDateComponents中规定的默认数值，一般为0或1。
        return calendar.date(from: cmps)
    }
    
    /// 设置日期
    public func setDate(parameter: DateParameter) -> Date? {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let options = NSCalendar.Options()
        
        var date: Date = self
        
        if let y = parameter.year {
            let d = (calendar as NSCalendar?)?.date(bySettingUnit: .year, value: y, of: date, options: options)
            guard d != nil else {
                return nil
            }
            date = d!
        }
        
        if let M = parameter.month {
            let d = (calendar as NSCalendar?)?.date(bySettingUnit: .month, value: M, of: date, options: options)
            guard d != nil else {
                return nil
            }
            date = d!
        }
        
        if let d = parameter.day {
            let d = (calendar as NSCalendar?)?.date(bySettingUnit: .day, value: d, of: date, options: options)
            guard d != nil else {
                return nil
            }
            date = d!
        }
        
        if let h = parameter.hour {
            let d = (calendar as NSCalendar?)?.date(bySettingUnit: .hour, value: h, of: date, options: options)
            guard d != nil else {
                return nil
            }
            date = d!
        }
        
        if let m = parameter.minute {
            let d = (calendar as NSCalendar?)?.date(bySettingUnit: .minute, value: m, of: date, options: options)
            guard d != nil else {
                return nil
            }
            date = d!
        }
        
        if let s = parameter.second {
            let d = (calendar as NSCalendar?)?.date(bySettingUnit: .second, value: s, of: date, options: options)
            guard d != nil else {
                return nil
            }
            date = d!
        }
        
        return date
    }
    
    /// 添加日期值
    public func addingValue(_ param: DateParameter) -> Date? {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        let cmps = DateComponents()
        param.copyParamToComponents(cmps)
        
        // 根据设置的dateComponentsForDate获取历法中与之对应的时间点
        // 这里的时分秒会使用NSDateComponents中规定的默认数值，一般为0或1。
        return (calendar as NSCalendar?)?.date(byAdding: cmps, to: self, options: NSCalendar.Options())
    }
    
    /// 减少日期值
    public func reduceValue(_ param: DateParameter) -> Date? {
        param.negativeValue()
        return addingValue(param)
    }
    
    /// Get compoments
    /// 获取一个NSDateCompoments对象
    fileprivate static func dateCmp(_ fromDate: Date, toDate: Date, unit: NSCalendar.Unit) -> DateComponents {
        return (Calendar.current as NSCalendar).components(unit, from: fromDate, to: toDate, options: NSCalendar.Options())
    }
}


