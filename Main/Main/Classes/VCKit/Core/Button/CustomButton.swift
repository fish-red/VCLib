//
//  CustomButton.swift
//
//  Created by 陈文强 on 16/9/30.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit


public enum LayoutStyle {
    case leftTitleRightImage
    case leftImageRightTitle
    case upImageDownTitle
    case upTitleDownImage
}

open class CustomButton: UIButton {
    open var layoutStyle: LayoutStyle = .upTitleDownImage
    
    // 间隙(水平\垂直通用)
    open var midSpacing: CGFloat = 4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // 是否要自适应内容大小 默认是false
    open var shouldAutoAdjustSize: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    // 重写父类方法 调用layout
    override open func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
        setNeedsLayout()
    }
    
    override open func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title , for: state)
        setNeedsLayout()
    }
    
    open var debug: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    // 四个间隙view 当debug的时候显示
    fileprivate lazy var left: UILabel = {
        let left = UILabel()
        left.text = "\(self.contentEdgeInsets.left)"
        left.textAlignment = .center
        self.addSubview(left)
        return left
    }()
    
    fileprivate lazy var right: UILabel = {
        let right = UILabel()
        right.textAlignment = .center
        right.text = "\(self.contentEdgeInsets.right)"
        self.addSubview(right)
        return right
    }()
    
    fileprivate lazy var top: UILabel = {
        let top = UILabel()
        top.textAlignment = .center
        top.text = "\(self.contentEdgeInsets.top)"
        self.addSubview(top)
        return top
    }()
    
    fileprivate lazy var bottom: UILabel = {
        let bottom = UILabel()
        bottom.textAlignment = .center
        bottom.text = "\(self.contentEdgeInsets.bottom)"
        self.addSubview(bottom)
        return bottom
    }()
}

extension CustomButton {
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        clipsToBounds = true
        
        guard titleLabel != nil && imageView != nil else {
            return
        }
        
        imageView?.sizeToFit()
        titleLabel?.sizeToFit()
        
        // layout titleLabel and imageView
        switch layoutStyle {
        case .leftImageRightTitle:
            layoutHoriz(imageView, rightView: titleLabel)
        case .leftTitleRightImage:
            layoutHoriz(titleLabel, rightView: imageView)
        case .upImageDownTitle:
            layoutVertical(imageView, downView: titleLabel)
        case .upTitleDownImage:
            layoutVertical(titleLabel, downView: imageView)
        }
        
        showInset()
    }
    
    fileprivate func showInset() {
        guard debug == true else {
            return
        }
        
        titleLabel?.backgroundColor = UIColor.lightGray
        imageView?.backgroundColor = UIColor.yellow
        
        top.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: contentEdgeInsets.top)
        left.frame = CGRect(x: 0, y: 0, width: contentEdgeInsets.left, height: bounds.size.height)
        bottom.frame = CGRect(x: 0, y: bounds.size.height-contentEdgeInsets.bottom, width: bounds.size.width, height: contentEdgeInsets.bottom)
        right.frame = CGRect(x: bounds.size.width - contentEdgeInsets.right, y: 0, width: contentEdgeInsets.right, height: bounds.size.height)
    }
    
    
    fileprivate func layoutHoriz(_ leftView: UIView?, rightView: UIView?) {
        guard leftView != nil && rightView != nil else {
            return
        }
        
        let inset = currentImage != nil && currentTitle?.characters.count > 0 ? midSpacing : 0
        
        let totalWidth = titleLabel!.frame.size.width + inset + imageView!.frame.size.width + contentEdgeInsets.left + contentEdgeInsets.right
        let totalHeight = max(titleLabel!.frame.size.height, imageView!.frame.size.height) + contentEdgeInsets.top + contentEdgeInsets.bottom
        adjustSizeToFit(CGSize(width: totalWidth, height: totalHeight))
        
        
        var leftViewFrame = leftView!.frame
        var rightViewFrame = rightView!.frame
        
        let contentHeight = bounds.size.height - contentEdgeInsets.top - contentEdgeInsets.bottom
        leftViewFrame.origin.x = max((bounds.size.width - totalWidth) / 2.0, 0) + contentEdgeInsets.left
        leftViewFrame.origin.y = max((contentHeight - leftViewFrame.size.height) / 2.0, 0) + contentEdgeInsets.top
        rightViewFrame.origin.x = leftViewFrame.maxX + inset
        rightViewFrame.origin.y = max((contentHeight - rightViewFrame.size.height) / 2.0, 0) + contentEdgeInsets.top
        
        leftView?.frame = leftViewFrame
        rightView?.frame = rightViewFrame
        
    }
    
    fileprivate func layoutVertical(_ upView: UIView?, downView: UIView?) {
        guard upView != nil && downView != nil else {
            return
        }
        
        let inset = currentImage != nil && currentTitle?.characters.count > 0 ? midSpacing : 0
        
        let totalHeight = titleLabel!.frame.size.height + inset + imageView!.frame.size.height + contentEdgeInsets.top + contentEdgeInsets.bottom
        let totalWidth =  max(titleLabel!.frame.size.width, imageView!.frame.size.width) + contentEdgeInsets.left + contentEdgeInsets.right
        adjustSizeToFit(CGSize(width: totalWidth, height: totalHeight))
        
        
        var upViewFrame = upView!.frame
        var downViewFrame = downView!.frame
        
        let contentWidth = bounds.size.width - contentEdgeInsets.left - contentEdgeInsets.right
        upViewFrame.origin.y = max((bounds.size.height - totalHeight) / 2.0, 0) + contentEdgeInsets.top
        upViewFrame.origin.x = max((contentWidth - upViewFrame.size.width) / 2.0, 0) + contentEdgeInsets.left
        downViewFrame.origin.x = max((contentWidth - downViewFrame.size.width) / 2.0, 0) + contentEdgeInsets.left
        downViewFrame.origin.y = upViewFrame.maxY + inset
        
        upView?.frame = upViewFrame
        downView?.frame = downViewFrame
        
    }
    
    fileprivate func adjustSizeToFit(_ size: CGSize) {
        
        if shouldAutoAdjustSize == true {
            var rect = bounds
            rect.size = size
            if !rect.equalTo(bounds) {
                self.bounds = rect;
            }
        }else {
            if size.width > bounds.size.width {
                var titleFrame = titleLabel!.bounds
                titleFrame.size.width = bounds.size.width - size.width + titleLabel!.frame.size.width
                titleLabel?.bounds = titleFrame
            }
            
            if size.height > bounds.size.height {
                var imageFrame = imageView!.bounds
                imageFrame.size.height = bounds.size.height - size.height + imageView!.frame.size.height
                imageView?.bounds = imageFrame
            }
        }
    }
}

