//
//  UITableView+Extension.swift
//  Main
//
//  Created by 陈文强 on 16/8/24.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit
import ObjectiveC


extension NSObject {
//    public static func swizzling(oldSel: Selector, newSel: Selector) {
//        
//        struct Static {
//            static var token: dispatch_once_t = 0
//        }
//        
//        dispatch_once(&Static.token) {
//            let originalSelector = oldSel
//            let swizzledSelector = newSel
//            
//            let originalMethod = class_getInstanceMethod(self, originalSelector)
//            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
//            
//            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
//            
//            if didAddMethod {
//                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
//            } else {
//                method_exchangeImplementations(originalMethod, swizzledMethod);
//            }
//        }
//    }
}

extension UITableView {
//    public override static func initialize() {
//        guard self == UITableView.self else {
//            return
//        }
//        
//        let originalSelector = #selector(UITableView.reloadData)
//        let swizzledSelector = #selector(UITableView.xq_reloadData)
//        swizzling(originalSelector, newSel: swizzledSelector)
//    }
//    
//    func xq_reloadData() {
//        // 判断个数
//        var isEmpty = false
//        if numberOfSections == 0 {
//            isEmpty = true
//        }else {
//            var totalCount = 0
//            for i in 0 ..< numberOfSections {
//                totalCount += numberOfRowsInSection(i)
//            }
//            
//            if totalCount == 0 {
//                isEmpty = true
//            }
//        }
//        
//        backgroundView?.hidden = !isEmpty
//        
//        xq_reloadData()
//    }
//    
//    public func addEmptyViewWithType(type: XQEmptyType) {
//        let v = XQEmptyHelper.emptyViewWithType(type)
//        backgroundView = v
//    }
}


extension UICollectionView {
//    public override static func initialize() {
//        // 确保不是子类
//        guard self == UICollectionView.self else {
//            return
//        }
//        
//        let originalSelector = #selector(UITableView.reloadData)
//        let swizzledSelector = #selector(UITableView.xq_reloadData)
//        swizzling(originalSelector, newSel: swizzledSelector)
//    }
//    
//    func xq_reloadData() {
//        // 判断个数
//        var isEmpty = false
//        if numberOfSections() == 0 {
//            isEmpty = true
//        }else {
//            var totalCount = 0
//            for i in 0 ..< numberOfSections() {
//                totalCount += numberOfItemsInSection(i)
//            }
//            
//            if totalCount == 0 {
//                isEmpty = true
//            }
//        }
//        
//        backgroundView?.hidden = !isEmpty
//        
//        xq_reloadData()
//    }
//    
//    public func addEmptyViewWithType(type: XQEmptyType) {
//        let v = XQEmptyHelper.emptyViewWithType(type)
//        backgroundView = v
//    }
}

