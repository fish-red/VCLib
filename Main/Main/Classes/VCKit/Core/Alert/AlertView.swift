
//
//  AlertView.swift
//  Test
//
//  Created by 陈文强 on 16/9/12.
//  Copyright © 2016年 CWQ. All rights reserved.
//
import UIKit

open class AlertView: PopUpView {
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        style = .alert
        config = AlertConfig.sharedConfig()
        configPop()
    }
    
    override init(title: String?, detail: String?, actions: [PopUpAction]?) {
        super.init(title: title, detail: detail, actions: actions)
        style = .alert
        config = AlertConfig.sharedConfig()
        configPop()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


open class AlertConfig: PopConfig {
    open class func sharedConfig() -> AlertConfig {
        return _config
    }

    open override var titleInset: UIEdgeInsets {
        get {
            return UIEdgeInsetsMake(20, 15, 0, 15)
        }
        set {}
    }
    
    open override var detailInset: UIEdgeInsets {
        get {
            return UIEdgeInsetsMake(5, 25, 10, 25)
        }
        set {}
    }
    
    open var alertWidth: CGFloat    = 275
    open var cornerRadius: CGFloat  = 8
    
    fileprivate static let _config: AlertConfig = AlertConfig()
    fileprivate override init() {}
    
    open override var showAnimation: PopUpViewAnimation? {
        set {}
        get {
            let block: PopUpViewAnimation = { (v, complete) in
                
                let bounds = PopWindow.defaultWindow().attachView().bounds
                v.center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
                
                v.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2)
                v.alpha = 0.0
                UIView.animate(withDuration: self.showDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
                    v.layer.transform = CATransform3DIdentity
                    v.alpha = 1
                }) { (finish) in
                    complete?(v, finish)
                }
            }
            return block
        }
    }
    
    open override var hideAnimation: PopUpViewAnimation? {
        set {}
        get {
            let block: PopUpViewAnimation = { (v, complete) in
                UIView.animate(withDuration: self.hideDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
                    v.alpha = 0
                }) { (finish) in
                    v.removeFromSuperview()
                    complete?(v, finish)
                }
            }
            return block
        }
    }
}


