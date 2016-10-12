//
//  Application.Swift
//  Main
//
//  Created by 陈文强 on 16/9/8.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import Foundation

/**
 *  Application
 *  系统信息工具类(单例)
 *
 *  快速获取系统信息
 */
open class Application {
    // app 名称
    open var appName: String = ""
    
    // app 版本信息
    open var appVersion: String = ""
    
    // app build 版本
    open var appBuildVersion: String = ""
    
    
    fileprivate static let _defaultInstance = Application()
    open class var `default`: Application {
        return _defaultInstance
    }
    fileprivate init() {
        let info = Bundle.main.infoDictionary
        
        let key = "app_name"
        let name = NSLocalizedString("app_name", comment: "")
        appName = key == name ? info?["CFBundleDisplayName"] as? String ?? "" : name
        
        appVersion = info?["CFBundleShortVersionString"] as? String ?? ""
        appBuildVersion = info?["CFBundleVersion"] as? String ?? ""
    }
}
