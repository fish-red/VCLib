//
//  MotionManager.swift
//  Test
//
//  Created by 陈文强 on 16/9/20.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import Foundation
import CoreMotion

public typealias MotionComplete = () -> ()

// MARK: Public
extension MotionManager {
    /// Public
    public func start() {
        motionMgr.startAccelerometerUpdates(to: OperationQueue()) { (data, error) in
            self.outputAccelertionData(data?.acceleration)
            if error != nil {
                DebugLog("motion error: \(error)")
            }
        }
    }
    
    public func stop() {
        motionMgr.stopAccelerometerUpdates()
    }
    
    public func setComplete(_ complete: MotionComplete?) {
        motionComplete = complete
    }
}

open class MotionManager: NSObject {
    
    /// Property
    open var motionComplete: MotionComplete?
    
    
    /// Single
    fileprivate static let _defaultInstance: MotionManager = MotionManager()
    fileprivate override init() {}
    open class func defaultMgr() -> MotionManager {
        return _defaultInstance
    }
    
    fileprivate lazy var motionMgr: CMMotionManager = {
        let mgr = CMMotionManager()
        mgr.accelerometerUpdateInterval = 0.1
        return mgr
    }()
    
    
    fileprivate func outputAccelertionData(_ acceleration: CMAcceleration?) {
        guard acceleration != nil else {
            return
        }
        
        let meter = sqrt(pow(acceleration!.x, 2) + pow(acceleration!.y, 2)
            + pow(acceleration!.z, 2))
        
        //当综合加速度大于2.3时，就激活效果（此数值根据需求可以调整，数据越小，用户摇动的动作就越小，越容易激活，反之加大难度，但不容易误触发）
        if meter > 2.3 {
            //立即停止更新加速仪（很重要！）
            self.motionMgr.stopAccelerometerUpdates()
            
            DispatchQueue.main.async(execute: {
                self.motionComplete?()
            })
        }
    }
}


