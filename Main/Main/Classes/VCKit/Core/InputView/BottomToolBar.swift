//
//  KeyBoardBottomToolBar.Swift
//
//  Created by 陈文强 on 16/9/22.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit
import SnapKit


/// UIView 的子类
/// 处于屏幕底部 自动监听键盘状态 会根据键盘状态自动收放

private let INPUT_VIEW_DEVICE_SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.size.height

open class KeyBoardBottomToolBar: UIView {
    
    // 当push(animation == true)
    // 1.调用一次 window == nil
    // 2.再调用一次 window != nil
    // 3.发送frameChange通知
    // 4.当动画执行完毕的时候 调用一次 window == nil
    
    // 当push(animation == true)
    // 1.调用一次 window == nil
    
    /// 判断是否在屏幕上方法
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        autoresizingMask = UIViewAutoresizing()
        
        // DebugLog("didMoveToWindow: \(window)")
        
        if window == nil {
            // remove from notification center
            NotificationCenter.default.removeObserver(self)
        }else {
            // add to notification center
            NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardBottomToolBar.keyBoardFrameChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        }
    }
}


// MARK: - NotificationCenterObserver
extension KeyBoardBottomToolBar {
    /// 当接收到键盘frame值变化的时候调用
    internal func keyBoardFrameChange(_ noti: Notification) {
        
        let dic = (noti as NSNotification).userInfo
        guard dic != nil else {
            return
        }
        
        let curve = 7<<16 //dic?[UIKeyboardAnimationCurveUserInfoKey]?.doubleValue ?? 0
        let duration = (dic?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue ?? 0.15
        
        let keyboardRect: CGRect? = (dic?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardY: CGFloat = keyboardRect?.origin.y ?? 0
        let keyboardH: CGFloat = keyboardRect?.size.height ?? 0
        
        DispatchQueue.main.async(execute: {
            // 使用了AutoLayout的标识
            var useAutoLayout = self.constraints.count > 0
            if useAutoLayout == false {
                // 遍历父类的constaint 查找是否添加了constaint
                let constraints = self.superview?.constraints
                let count = constraints?.count ?? 0
                for i in 0 ..< count {
                    let c = constraints?[i]
                    if c?.firstItem as? NSObject == self || c?.secondItem as? NSObject == self {
                        useAutoLayout = true
                        break
                    }
                }
            }
            
            guard useAutoLayout == true else {
                // Without AutoLayout
                // 没有使用 AutoLayout
                let translationY: CGFloat = keyboardY - self.frame.size.height
                
                var f = self.frame
                f.origin.y = translationY
                
                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(curve)), animations: {
                    self.frame = f
                    }, completion: { (finish) in
                })
                return
            }
            
            if keyboardY < INPUT_VIEW_DEVICE_SCREEN_HEIGHT {
                // 键盘将开启
//                DebugLog("键盘将展示")
                self.snp.updateConstraints({ (make) in
                    make.bottom.equalToSuperview().offset(-keyboardH)
                })
                
                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(curve)), animations: {
                    self.superview?.layoutIfNeeded()
                    }, completion: { (finish) in
                })
            }else {
                // 键盘将收起
//                DebugLog("键盘将收起")
                self.snp.updateConstraints({ (make) in
                    make.bottom.equalToSuperview()
                })
                
                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(curve)), animations: {
                    self.superview?.layoutIfNeeded()
                    }, completion: { (finish) in
                })
            }
        })
    }
}









