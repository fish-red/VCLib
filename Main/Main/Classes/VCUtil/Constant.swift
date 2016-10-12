//
//  Constant.swift
//  MainProject
//
//  Created by 陈文强 on 16/8/3.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit
//
//  --------------------------------
// |                                |
// |            Custom              |
// |                                |
//  --------------------------------
// MARK: - Custom

// MARK: String
public let DOMOBILE_URL               = "www.domobile.com"
public let SUPPORT_DM_URL             = "support@domobile.com"
public let APP_ID                     = "//TODO 从appstore查找"


// note 水平侧边间隙
public let NOTE_HORIZ_MARGIN: CGFloat = 15
// 主页导航栏高度
public let MAIN_BAR_HEIGHT: CGFloat   = 120


// MARK: Text 相关

// MARK: Color
public let GLOBAL_COLOR_BLACK         = UIColor(0x262626)
public let GLOBAL_COLOR_LIGHT_GRAY    = UIColor(0xf8f8f8)






//
//  --------------------------------
// |                                |
// |            Standard            |
// |                                |
//  --------------------------------
// MARK: - Standard

// MARK: Constant
public let DEVICE_SCREEN_WIDTH        = UIScreen.main.bounds.size.width
public let DEVICE_SCREEN_HEIGHT       = UIScreen.main.bounds.size.height
public let DEVICE_SCREEN_SCALE        = UIScreen.main.scale


// 设置1pix线 宽度
public let SINGLE_LINE_WIDTH          = SINGLE_LINE_ADJUST_OFFSET + SINGLE_LINE_ADJUST_WIDTH
// 偏移量
public let SINGLE_LINE_ADJUST_OFFSET  = (1 / UIScreen.main.scale) * 0.5
// 线宽
public let SINGLE_LINE_ADJUST_WIDTH   = (1 / UIScreen.main.scale)


// MARK: Define 
public typealias EmptyBlock = () -> ()

// MARK: Debug
private let Debug: Bool = true
public func DebugLog(_ obj: Any?) {
    
    if Debug == true {
        print(obj ?? "")
    }
}



// MARK: ExecutingTime

public func inTime(_ info: String?, f: EmptyBlock?) {
    let now = Date()
    
    f?()
    
    let time = now.timeIntervalSinceNow
    let i = info ?? ""
    DebugLog("执行 '\(i)' 用时: \(-time)")
}



// MARK: Queue

public func inMain(_ block: EmptyBlock?) {
    DispatchQueue.main.async {
        block?()
    }
}

public func inAsyn(_ block: EmptyBlock?) {
    DispatchQueue.global().async {
        block?()
    }
}

public func inAfter(_ time: Double ,block: EmptyBlock?) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(UInt64(time) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
        block?()
    }
}


// MARK: 判断真机还是模拟器
public struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}




