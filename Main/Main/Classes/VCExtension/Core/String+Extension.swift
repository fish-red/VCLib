//
//  NSString+Regex.swift
//  IMTodo
//
//  Created by 陈文强 on 16/4/5.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import Foundation


// MARK: - Regix
// MARK: 正则匹配字符串
// MARK: -

/// Match 对象使用的枚举值
public enum MatchType: String {
    
    //
    //  --------------------------------
    // |                                |
    // |            Custom              |
    // |                                |
    //  --------------------------------
    // MARK: - Custom
    
    // 用户名 3-16位数字字母下划线 (\\u4e00-\\u9fa5 中文...)
    case UserName      = "^[a-zA-Z0-9_\\u4e00-\\u9fa5]{3,16}+$"
    // 昵称
    case NickName      = "^[\\u4e00-\\u9fa5]{4,8}$"
    
    // 密码字母开头6-18位之间
    case Pwd6_18       = "^[a-zA-Z0-9]\\w{5,17}$"
    
    // 中文字符
    case Chinese       = "^[\\u4e00-\\u9fa5]{0,}$"
    
    // 纯数字
    case Number        = "^[1-9][0-9]{0,}$"
    
    // 图片格式
    case Image         = ".+(.JPEG|.jpeg|.JPG|.jpg|.GIF|.gif|.BMP|.bmp|.PNG|.png)$"
    // 视频格式
    case Video         = ".+(.swf|.flv|.mp4|.rmvb|.avi|.mpeg|.ra|.ram|.mov|.wmv)$"
    
    
    
    
    
    //
    //  --------------------------------
    // |                                |
    // |            Standard            |
    // |                                |
    //  --------------------------------
    // MARK: - Standard
    
    // 邮箱
    case Email         = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
    case Email_1       = "[\\w!#$%&'*+/=?^_`{|}~-]+(?:\\.[\\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\\w](?:[\\w-]*[\\w])?\\.)+[\\w](?:[\\w-]*[\\w])?"

    // 手机号
    case Phone         = "^((13[0-9])|(15[^4,\\D]) |(17[0,0-9])|(18[0,0-9]))\\d{8}$"
    case Phone_1       = "^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\\d{8}$"

    // URL
    case URL           = "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
    case URL_1         = "^(f|ht){1}(tp|tps):\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- ./?%&=]*)?"

    // 密码的强度必须是包含大小写字母和数字的组合，不能使用特殊字符，长度在8-10之间
    case Pwd8_10       = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{8,10}$"

    // 由数字、26个英文字母或下划线组成的字符串
    case Num_Char      = "^\\w+$"

    // 下面是身份证号码的正则校验。15或18位。
    case Identifier_15 = "^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$"
    case Identifier_18 = "^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X)$"

    // 校验日期
    case Calendar      = "^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)$"

    // 校验IP-v4\ IP-v6地址
    case IP_V4         = "\\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\b"
    case IP_V6         = "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"
    
    
    
    // 判断文件路径及扩展名校验
    // Txt
    case Txt           = "^([a-zA-Z]\\:|\\\\)\\\\([^\\\\]+\\\\)*[^\\/:*?'<>|]+\\.txt(l)?$"
}


// MARK: Match String
// MARK: 正则匹配字符串
extension String {
    func match(_ type: MatchType) -> Bool {
        let pattern: String = type.rawValue
        let predicate = NSPredicate(format: "SELF MATCHES %@" ,pattern)
        return predicate.evaluate(with: self)
    }
    
    func contain(_ type: MatchType) -> Bool {
        
        let pattern: String = type.rawValue
        
        do {
            // - 1、创建规则
            // - 2、创建正则表达式对象
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            // - 3、开始匹配
            let res = regex.matches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count))
            // 输出结果
            
            var contain = false
            for checkingRes in res {
                if checkingRes.range.location == 0 && checkingRes.range.length == self.characters.count {
                    DebugLog("匹配\(type)正确")
                    contain = true
                    break
                }else {
                    DebugLog("匹配\(type) 不正确")
                    contain = false
                    break
                }
            }
            return contain
        } catch {
            return false
        }
    }
}




// MARK: Time String
// MARK: 时间转换字符串
let maxCount = 10000
let dayTimeoutInterval: TimeInterval = 60*60*24

extension String {
    /// 通过时间来获取当前时间格式
//    static func getTimeDesc(date: NSDate?) -> String? {
//        guard date != nil else {
//            return nil
//        }
//    
//        let now = NSDate()
//        let createDate: NSDate = date!
//        let calendar = NSCalendar.currentCalendar()
//        let unit = NSCalendarUnit.Year.union(NSCalendarUnit.Month).union(NSCalendarUnit.Day).union(NSCalendarUnit.Hour).union(NSCalendarUnit.Minute)
//        let options = NSCalendarOptions()
//        let cmps = calendar.components(unit, fromDate: createDate, toDate: now, options: options)
//        
//        if createDate.isThisYear() == true {
//            // 今年
//            if createDate.isThisWeek() == true {
//                // 本周
//                if createDate.isThisDay() == true {
//                    // 今天
//                    let hour = cmps.hour
//                    if hour >= 1 {
//                        return "\(hour)小时前"
//                    }else {
//                        let minute = cmps.minute
//                        if minute >= 1 {
//                            return "\(minute)分钟前"
//                        }else {
//                            return "刚刚"
//                        }
//                    }
//                }else {
//                    let day = createDate.countingToNow().day
//                    return "\(day)天前"
//                }
//            }else {
//                // 今年其他时间 MM-dd
//                return createDate.toString(dateFormat: .MD_With_Line)
//            }
//        }else {
//            // 非今年
//            return createDate.toString(dateFormat: .YMD_With_Line)
//        }
//    }
//    
//    static func getTimeDesc(interval: NSTimeInterval) -> String? {
//        guard interval > 0 else {
//            return nil
//        }
//        
//        let date = NSDate(timeIntervalSince1970: interval)
//        return getTimeDesc(date)
//    }
    
    /// 通过数量来获取数值格式
    static func getCount(_ count: Int) -> String? {
        guard count > 0 else {
            return "0"
        }
        
        // 小于10000的
        if (count < maxCount)
        {
            return "\(count)"
        }
        
        // 不是整数
        let multiple = Double(count / maxCount)
        return "\(multiple)万"
    }
    
    /// 通过时间长度来获取音乐时间描述
    static func getDurationTime(_ duration: TimeInterval) -> String {
        let time = Int(duration)
        let minute = time / 60
        let sec = time % 60
        return "\(minute):\(sec)"
    }
    
    /// 通过时间来获取声音长度描述
    static func getVoiceDurationTime(_ duration : TimeInterval) -> String {
        let time = Int(duration)
        let minute = time / 60
        let sec = max(time % 60, 1)
        
        return String(format: "%02d: %02d", arguments: [minute, sec])
    }
}
