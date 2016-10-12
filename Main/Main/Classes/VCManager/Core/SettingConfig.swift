//
//  Theme.swift
//  Main
//
//  Created by 陈文强 on 16/8/23.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import Foundation


// Setting item 默认的协议
//public protocol SettingItemProtocol {
//    static func defaultSize() -> SettingItemProtocol
//    func getName() -> String?
//}
//
//// 默认的font size 大小类型枚举
//public enum DefaultFontSize: CGFloat, SettingItemProtocol {
//    case min = 14
//    case mid = 18
//    case max = 22
//    
//    public static func defaultSize() -> SettingItemProtocol {
//        return DefaultFontSize.mid
//    }
//    
//    public func getName() -> String? {
//        switch self {
//        case .min:
//            return NSLocalizedString("text_size_min", comment: "")
//        case .mid:
//            return NSLocalizedString("text_size_mid", comment: "")
//        case .max:
//            return NSLocalizedString("text_size_max", comment: "")
//        }
//    }
//}
//
//// 加锁等级枚举
//public enum LockLevel: Int, SettingItemProtocol {
//    case none   = 0
//    case finger = 1
//    
//    public static func defaultSize() -> SettingItemProtocol {
//        return LockLevel.none
//    }
//    
//    public func getName() -> String? {
//        switch self {
//        case .none:
//            return NSLocalizedString("summary_protect_none", comment: "")
//        case .finger:
//            return NSLocalizedString("title_protect_fingerprint", comment: "")
//        }
//    }
//}
//
//// 加锁的状态
//public enum LockState {
//    case lock
//    case unlock
//    
//    mutating func toggle() {
//        switch self {
//        case .lock:
//            self = .unlock
//        case .unlock:
//            self = .lock
//        }
//    }
//}
//
//
//public enum SettingKey: String {
//    case LockLevel = "Lock_Level"
//    case FontSize  = "Default_FontSize"
//    case FirstInstall = "FirstInstall"
//}
//
//open class SettingHelper {
//    // Single
//    class func sharedHelper() -> SettingHelper {
//        return _sharedHelper
//    }
//    fileprivate static let _sharedHelper = SettingHelper()
//    
//    // font 字体大小
//    open var fontSize: DefaultFontSize = DefaultFontSize.defaultSize() as! DefaultFontSize {
//        didSet {
//            if fontSize.rawValue != oldValue.rawValue {
//                UserDefaultHelper.write(SettingKey.FontSize.rawValue, obj: fontSize.rawValue)
//            }
//        }
//    }
//    
//    // lock level   隐私加锁等级
//    open var lockLevel: LockLevel = LockLevel.defaultSize() as! LockLevel {
//        didSet {
//            if lockLevel.rawValue != oldValue.rawValue {
//                UserDefaultHelper.write(SettingKey.LockLevel.rawValue, obj: lockLevel.rawValue)
//            }
//        }
//    }
//    
//    // lock state  加锁状态
//    open var lockState: LockState = LockState.lock
//    open var showAllNotes: Bool {
//        return lockState == .unlock ? true : false
//    }
//    
//    
//    
//    // first install 第一次安装打开
//    open var firstInstall: Bool = true
//    
//    fileprivate init() {
//        // 如果没有font 则写入UserDefault
//        let f = UserDefaultHelper.read(SettingKey.FontSize.rawValue)?.floatValue
//        if f == nil {
//            UserDefaultHelper.write(SettingKey.FontSize.rawValue, obj: fontSize.rawValue)
//        } else {
//            if let size = DefaultFontSize(rawValue: CGFloat(f!)) {
//                fontSize = size
//            }
//        }
//        
//        let l = UserDefaultHelper.read(SettingKey.LockLevel.rawValue)?.intValue
//        if l == nil {
//            UserDefaultHelper.write(SettingKey.FontSize.rawValue, obj: lockLevel.rawValue)
//        } else {
//            if var level = LockLevel(rawValue:l!) {
//                if level == .finger {
//                    if LocalAuthorityHelper.isAuthorityEnable().enable == true {
//                        level = LockLevel.finger
//                    }else {
//                        level = LockLevel.none
////                        UserDefaultHelper.write(.LockLevel, obj: level.rawValue)
//                    }
//                }
//                lockLevel = level
//            }
//        }
//        
//        
//        let install = UserDefaultHelper.read(SettingKey.FirstInstall.rawValue) as? String
//        let version = ApplicationManager.defaultMgr().appVersion
//        if install == nil {
//            UserDefaultHelper.write(SettingKey.FirstInstall.rawValue, obj: version)
//        } else {
//            if install == version {
//                firstInstall = false
//            }else {
//                UserDefaultHelper.write(SettingKey.FirstInstall.rawValue, obj: version)
//                firstInstall = true
//            }
//        }
//    }
//}

