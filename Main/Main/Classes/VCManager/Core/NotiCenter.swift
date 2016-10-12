//
//  NotiCenter.swift
//  Main
//
//  Created by 陈文强 on 16/9/8.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import Foundation

/**
 *  NotiCenterKey
 *  本地通知枚举
 *
 *  对通知的key键封装
 */
public enum NotiKey: String {
    case TAGS_CHANGE_NOTI     = "TAGS_CHANGE_NOTI"
    case NOTE_CHANGE_NOTI     = "NOTE_CHANGE_NOTI"
}

/**
 *  NotiCenterHelper
 *  本地通知的工具类
 *
 *  用来快速调用通知中心
 */
extension NotiCenter {
    /**
     *  通过Key发送通知
     *
     *  @param key      发送通知的key(NotiCenterKey)
     */
    public class func post(_ key: NotiKey) {
        post(key.rawValue)
    }
}


open class NotiCenter: NSObject {
    /**
     *  通过Key发送通知
     *
     *  @param key      发送通知的key(NotiKey)
     */
    open class func post(_ name: String) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil)
    }
    
    /**
     *  快速获取通知中心
     *
     *  @return center  通知中心对象
     */
    open class func center() -> NotificationCenter {
        return NotificationCenter.default
    }
    
    open class func removeObserver(_ obj: AnyObject) {
        NotificationCenter.default.removeObserver(obj)
    }
}












