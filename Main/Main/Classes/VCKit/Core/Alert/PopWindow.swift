//
//  PopWindow.swift
//  Test
//
//  Created by 陈文强 on 16/9/9.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit


//MARK: - Public
extension PopWindow {
    public class func defaultWindow() -> PopWindow {
        return _popWindow
    }
    
    public func attachView() -> UIView {
        return rootViewController!.view
    }
    
    public func show() {
        makeKeyAndVisible()
        attachView().alpha = 0
        UIView.animate(withDuration: self.showDuration, animations: {
            self.attachView().alpha = 1
        }) 
    }
    
    public func hide() {
        UIView.animate(withDuration: self.hideDuration, animations: {
            
            self.attachView().alpha = 0
            
        }, completion: { (suc) in
            self.resignKey()
            self.isHidden = true
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
            
            // 释放子view
            _ = self.attachView().subviews.map { (v) -> Void in
                v.removeFromSuperview()
                DispatchQueue.main.async(execute: {
                    v.isHidden = true
                })
            }
        }) 
    }
}


public typealias PopWindowTapOperation = () -> ()

open class PopWindow: UIWindow {
    open var shouldTouchBackgroundToHide: Bool = true
    open var shouldTapDownRespon: Bool = false
    open var tapBackgroundBlock: PopWindowTapOperation?
    
    open var showDuration: TimeInterval = 0.25
    open var hideDuration: TimeInterval = 0.1
    
    open var shouldShowBackgroundColor: Bool = true {
        didSet {
            if shouldShowBackgroundColor == true {
                rootViewController?.view.backgroundColor = shadowColor
            }else {
                rootViewController?.view.backgroundColor = nil
            }
        }
    }
    
    open var shouldBlur: Bool = false {
        didSet {
            if shouldBlur == true {
                resetBlur()
                
                rootViewController?.view.backgroundColor = UIColor.clear
                blurView?.frame = rootViewController!.view.bounds
                rootViewController?.view.addSubview(blurView!)
            }else {
                blurView?.removeFromSuperview()
                
                rootViewController?.view.backgroundColor = shadowColor
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
    
    // single
    fileprivate static let _popWindow: PopWindow = PopWindow(frame: UIScreen.main.bounds)
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        windowLevel = UIWindowLevelAlert+1
        
        let vc = UIViewController()
        rootViewController = vc
        vc.view.backgroundColor = shadowColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PopWindow.tapHandle(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first?.view == (shouldBlur == false ? attachView() : blurView) else {
            return
        }
        if shouldTapDownRespon == true && self.shouldTouchBackgroundToHide == true {
            tapBackgroundBlock?()
        }
    }
}



// MARK: - Private
// MARK: Event
extension PopWindow {
    
    func tapHandle(_ ges: UITapGestureRecognizer) {
        guard shouldTouchBackgroundToHide == true else {
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
extension PopWindow: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == (shouldBlur == false ? attachView() : blurView)
    }
}

