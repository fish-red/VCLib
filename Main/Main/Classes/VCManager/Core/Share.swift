//
//  Share.swift
//
//  Created by 陈文强 on 16/8/31.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit

/**
 *
 *  ShareComplete
 *  当执行分享完毕之后回调
 *
 *  @param suc      执行结果
 *  @param info     执行信息
 */
public typealias ShareComplete = (_ suc: Bool, _ info: String?) -> ()

/**
 *
 *  ShareHelper
 *  调用系统分享功能工具类
 *
 *  快速调用系统分享API
 */
open class Share {
    /**
     *  从某一控制器中弹出分享界面
     *
     *  @param items        分享的items
     *  @param v            从某一UIView中弹出(当设备为ipad时候需要)
     *  @param vc           从某一UIViewController中弹出
     *
     */
    open class func shareWithViewController(_ items: [AnyObject], v: UIView?, vc: UIViewController, complete: ShareComplete?) {
        
        let active = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // 当设备为ipad时调用pop
        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let pop = active.popoverPresentationController {
                pop.sourceView = v
                pop.permittedArrowDirections = .up
            }
        }
        
        // 完成回调
        active.completionWithItemsHandler = { (info, finish, obj, error) in
            complete?(finish, info.map { $0.rawValue })
            active.dismiss(animated: true, completion: nil)
        }
        vc.present(active, animated: true) {}
    }
}
