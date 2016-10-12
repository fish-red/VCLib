//
//  LocalAuthorityHelper.swift
//
//  Created by 陈文强 on 16/8/31.
//  Copyright © 2016年 CWQ. All rights reserved.
//


import LocalAuthentication
import Foundation

/**
 *  LocalAuthorityHelperComplete
 *  完成回调
 *
 *  当Authority调用完成的时候返回结果
 *  
 *  @param success      执行结果
 *  @param info         执行信息
 */
public typealias LocalAuthorityHelperComplete = (_ success: Bool, _ info: String?) -> Void


/**
 *  LocalAuthorityHelper
 *  用来调用指纹解锁的工具类
 * 
 *  快速调用指纹解锁API
 */
open class LocalAuthorityHelper {
    /**
     *  获取设备指纹解锁功能是否可用
     *
     *  @return (enable: 指纹解锁是否可用, info: 错误信息)
     */
    open class func isAuthorityEnable() -> (enable: Bool, info: String?){
        let auth = LAContext()
        var error: NSError? = nil
        var info: String = ""
        let enable = auth.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if enable == true {
            return (enable: true, info: nil)
        }else {
            switch error!.code {
            case LAError.Code.touchIDNotEnrolled.rawValue:
                info = "TouchIDNotEnrolled"
            case LAError.Code.passcodeNotSet.rawValue:
                info = "PasscodeNotSet"
            default:
                info = "some other error"
            }
            return (enable: false, info: info)
        }
    }
    
    
    /**
     *  调用系统指纹解锁API
     *
     *  @param complete     结果回调
     */
    open class func showAuth(_ complete: LocalAuthorityHelperComplete?) {
        
        let auth = LAContext()
//        auth.localizedFallbackTitle = "继续?"  // 设置失败重试的按钮
        
        var info: String = ""
        let enable = isAuthorityEnable()
        if enable.0 == true  {
            let key = "lib_protect_alert_please_scan_fingerprint"
            var reason = NSLocalizedString(key, comment: "")
            if key == reason {
                reason = key
            }
            
            auth.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (suc, er) in
                if suc == true {
                    info = "unlock success"
                }
                else {
                    if let error = er as? NSError {
                        // 解析错误信息
                        switch error.code {
                        case LAError.Code.systemCancel.rawValue:
                            info = "SystemCancel"
                        case LAError.Code.userCancel.rawValue:
                            info = "UserCancel"
                        case LAError.Code.authenticationFailed.rawValue:
                            info = "AuthenticationFailed"
                        case LAError.Code.passcodeNotSet.rawValue:
                            info = "PasscodeNotSet"
                        case LAError.Code.touchIDNotAvailable.rawValue:
                            info = "TouchIDNotAvailable"
                        case LAError.Code.touchIDNotEnrolled.rawValue:
                            info = "TouchIDNotEnrolled"
                        case LAError.Code.userFallback.rawValue:
                            info = "UserFallback"
                        default:
                            info = "some other error"
                        }
                    }
                }
                
                // 回调
                complete?(suc, info)
            })
        }else {
            
            // 该设备无指纹解锁功能
            complete?(false, info)
        }
    }
}
