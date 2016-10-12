
//
//  AlertConfig.swift
//  Test
//
//  Created by 陈文强 on 16/9/13.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit

open class PopConfig: NSObject {
    open var shouldShowBackground: Bool   = true
    open var shouldTapHidden: Bool        = true
    open var shouldBlur: Bool             = false
    open var shouldUseWindow: Bool        = false

    open var titleInset: UIEdgeInsets     = UIEdgeInsetsMake(20, 15, 0, 15)
    open var titleFontSize: CGFloat       = 20
    open var titleColor: UIColor          = UIColor.black
    
    open var detailInset: UIEdgeInsets    = UIEdgeInsetsMake(5, 25, 10, 25)
    open var detailFontSize: CGFloat      = 14
    open var detailColor: UIColor         = UIColor.black

    open var buttonHeight: CGFloat        = 44

    open var showDuration: TimeInterval = 0.2
    open var hideDuration: TimeInterval = 0.15

    open var splitColor: UIColor          = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)

    
    open var showAnimation: PopUpViewAnimation? = { (v, complete) in
        let bounds = PopWindow.defaultWindow().attachView().bounds
        v.center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        
        v.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.2)
        v.alpha = 0.0
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
            v.layer.transform = CATransform3DIdentity
            v.alpha = 1
        }) { (finish) in
            complete?(v, finish)
        }
    }
    
    open var hideAnimation: PopUpViewAnimation? = { (v, complete) in
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
            v.alpha = 0
        }) { (finish) in
            v.removeFromSuperview()
            complete?(v, finish)
        }
    }
}
