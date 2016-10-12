//
//  PopCoverView.swift
//  Main
//
//  Created by 陈文强 on 16/9/23.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit

open class PopCoverView: UIView {
    open func show() {
        alpha = 0
        UIView.animate(withDuration: self.showDuration, animations: {
            self.alpha = 1
        }) 
    }
    
    open func hide() {
        UIView.animate(withDuration: self.hideDuration, animations: {
            
            self.alpha = 0
            
        }, completion: { (suc) in
            self.isHidden = true
            
            // 释放子view
            _ = self.subviews.map { (v) -> Void in
                v.removeFromSuperview()
                DispatchQueue.main.async(execute: {
                    v.isHidden = true
                })
            }
        }) 
    }
    
    open var shouldTouchBackgroundToHide: Bool = true
    open var shouldTapDownRespon: Bool = true
    open var tapBackgroundBlock: PopWindowTapOperation?
    
    open var showDuration: TimeInterval = 0.25
    open var hideDuration: TimeInterval = 0.1
    
    open var shouldShowBackgroundColor: Bool = true {
        didSet {
            if shouldShowBackgroundColor == true {
                backgroundColor = shadowColor
            }else {
                backgroundColor = nil
            }
        }
    }
    
    open var shouldBlur: Bool = false {
        didSet {
            if shouldBlur == true {
                resetBlur()
                
                backgroundColor = UIColor.clear
                blurView?.frame = bounds
                addSubview(blurView!)
            }else {
                blurView?.removeFromSuperview()
                
                backgroundColor = shadowColor
            }
        }
    }
    
    fileprivate func resetBlur() {
        blurView?.removeFromSuperview()
        blurView = nil
        
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        blurView = effectView
    }
    fileprivate var blurView: UIVisualEffectView?
    
    fileprivate var shadowColor: UIColor? = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = shadowColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PopWindow.tapHandle(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first?.view == self else {
            return
        }
        if shouldTapDownRespon == true && self.shouldTouchBackgroundToHide == true {
            tapBackgroundBlock?()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// MARK: - Private
// MARK: Event
extension PopCoverView {
    
    func tapHandle(_ ges: UITapGestureRecognizer) {
        guard shouldTouchBackgroundToHide == true && shouldTapDownRespon == false else {
            return
        }
        
        let state = ges.state
        switch state {
        case .ended:
            tapBackgroundBlock?()
        default:
            break
        }
    }
}



// MARK: - Delegate
extension PopCoverView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == (shouldBlur == false ? self : blurView)
    }
}
