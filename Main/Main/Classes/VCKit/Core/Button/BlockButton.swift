//
//  BlockButton.swift
//  Main
//
//  Created by 陈文强 on 16/9/30.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit

public typealias BlockButtonCallBack = (BlockButton) -> ()

open class BlockButton: UIButton {
    fileprivate var callBack: BlockButtonCallBack?
    open func addTouchUpInsideBlock(_ callBack: BlockButtonCallBack?) {
        addTarget(self, action: #selector(BlockButton.btnClick(_:)), for: .touchUpInside)
    }
    
    internal func btnClick(_ btn: BlockButton) {
        callBack?(self)
    }
}
