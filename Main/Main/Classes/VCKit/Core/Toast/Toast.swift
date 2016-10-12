//
//  Toast.swift
//  Toast
//
//  Created by cwq on 16/8/16.
//  Copyright © 2016年 cwq. All rights reserved.


import UIKit

/**
 *  Toast默认停留时间 */
private let ToastDispalyDuration: CGFloat = 1.5
/**
 *  Toast到顶端/底端默认距离 */
private let ToastDefaultOffset: CGFloat = 100.0
/**
 *  Toast背景色 */
private let ToastBackgroundColor = UIColor(red:0.2,green:0.2,blue:0.2,alpha:0.75)

/**
 Toast Type */
public enum ToastType {
    case top
    case center
    case bottom
}

public extension Toast {
    public class func show(_ text: String, type: ToastType = .bottom, duration: CGFloat = ToastDispalyDuration, offset: CGFloat = ToastDefaultOffset) {
        let toast = Toast(text: text)
        toast.type = type
        toast.offset = offset
        toast.duration = duration
        toast.show()
    }
}


open class Toast: NSObject {
    
    fileprivate var contentView: UIButton
    fileprivate var duration: CGFloat
    fileprivate var type: ToastType = .center
    fileprivate var offset: CGFloat?
    
    public init(text: String) {
        duration = ToastDispalyDuration
        
        // property
        let font = UIFont.boldSystemFont(ofSize: 16)
        let attributes = [NSFontAttributeName: font]
        
        let rect = text.boundingRect(with: CGSize(width: 250,height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes:attributes, context: nil)
        
        let textLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: rect.size.width+40, height: rect.size.height+20))
        textLabel.backgroundColor = UIColor.clear
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.font = font
        textLabel.text = text
        textLabel.numberOfLines = 0
        
        // contentView
        contentView = UIButton(frame: CGRect(x: 0, y: 0, width: textLabel.frame.size.width, height: textLabel.frame.size.height))
        contentView.alpha = 0.0
        contentView.layer.cornerRadius = 20.0
        contentView.backgroundColor = ToastBackgroundColor
        contentView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        contentView.addSubview(textLabel)
        
        super.init()
        
        contentView.addTarget(self, action:#selector(toastTaped(_:)), for: UIControlEvents.touchDown)
        
        NotificationCenter.default.addObserver(self, selector:#selector(deviceOrientationDidChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: UIDevice.current)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: UIDevice.current)
    }
}

//#MARK: - Animation
private extension Toast {
    func showAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.contentView.alpha = 1.0
        }) { (completion) in
        }
    }
    
    func hideAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.contentView.alpha = 0.0
        }) { (completion) in
        }
    }
}

//#MARK: Event
private extension Toast {
    @objc func deviceOrientationDidChanged(_ notify: Notification) {
        dismiss()
    }
    
    @objc func toastTaped(_ sender: UIButton) {
        dismiss()
    }
    
    func dismiss() {
        hideAnimation()
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow!
        window.addSubview(contentView)
        
        switch type {
        case .center:
            contentView.center = window.center
        case .top:
            if let top = offset {
                contentView.center = CGPoint(x: window.center.x, y: top+contentView.frame.size.height/2)
            }
        case .bottom:
            if let bottom = offset {
                contentView.center = CGPoint(x: window.center.x, y: window.frame.size.height-(bottom+contentView.frame.size.height/2))
            }
        }
        
        showAnimation()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(UInt64(duration) * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            self.hideAnimation()
        }
    }
}


