//
//  SheetView.swift
//  Test
//
//  Created by 陈文强 on 16/9/12.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit

open class SheetView: PopUpView {
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        style = .sheet
        config = SheetConfig.sharedConfig()
        configPop()
    }
    
    override init(title: String?, detail: String?, actions: [PopUpAction]?) {
        super.init(title: title, detail: detail, actions: actions)
        style = .sheet
        config = SheetConfig.sharedConfig()
        configPop()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


open class SheetConfig: PopConfig {
    
    open class func sharedConfig() -> SheetConfig {
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
            return UIEdgeInsetsMake(5, 25, 20, 25)
        }
        set {}
    }
    
    
    fileprivate static let _config: SheetConfig = SheetConfig()
    fileprivate override init() {}
    
    open override var showAnimation: PopUpViewAnimation? {
        set {}
        get {
            let block: PopUpViewAnimation = { (v, complete) in
                
                var f = v.frame
                f.origin.y = PopWindow.defaultWindow().attachView().bounds.size.height
                v.frame = f
                
                UIView.animate(withDuration: self.showDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
                    f.origin.y -= f.size.height
                    v.frame = f
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
                var f = v.frame
                let attachView = PopWindow.defaultWindow().attachView()
                
                UIView.animate(withDuration: self.hideDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
                    f.origin.y = attachView.bounds.size.height
                    v.frame = f
                }) { (finish) in
                    complete?(v, finish)
                }
            }
            return block
        }
    }
}



