//
//  UserDefault.swift
//
//  Created by 陈文强 on 16/9/5.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import Foundation


/// UserDefaultType 用户偏好设置type
public enum UserDefaultType: String {
    case None = ""
}


/**
 *  UserDefaultHelper(Custom)
 *  用户偏好设置工具类
 * 
 *  方便持久化数据
 */
extension UserDefault {
    /**
     *  写入本地UserDefault
     *  本质是一个字典[key:Value]
     *
     *  @param type      写入的type(UserDefaultType)
     *  @param obj      写入的值(AnyObject)
     */
    public class func write(_ type: UserDefaultType, obj: AnyObject) {
        write(type.rawValue, obj: obj)
    }
    
    
    /**
     *  读取数据
     *  通过键值Key读取
     *
     *  @param type     读取的键type(UserDefaultType)
     *  @return         读取出的值(AnyObject?)
     */
    public class func read(_ type: UserDefaultType) -> AnyObject? {
        return read(type.rawValue)
    }
}


/// Standard
open class UserDefault {
    /**
     *  写入本地UserDefault
     *  本质是一个字典[key:Value]
     *
     *  @param key      写入的key(String)
     *  @param obj      写入的值(AnyObject)
     */
    open class func write(_ key: String, obj: AnyObject) {
        let ud = UserDefaults.standard
        ud.set(obj, forKey: key)
        
        // 立即同步写入
        ud.synchronize()
    }
    
    
    /**
     *  读取数据
     *  通过键值Key读取
     *
     *  @param key      读取的键key(String)
     *  @return         读取出的值(AnyObject?)
     */
    open class func read(_ key: String) -> AnyObject? {
        let ud = UserDefaults.standard
        let obj = ud.object(forKey: key)
        return obj as AnyObject?
    }
}









