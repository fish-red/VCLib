//
//  Alert.swift
//  Test
//
//  Created by 陈文强 on 16/8/19.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit


//#MARK: - ---PopUpAction---
/// Action Did Click
public typealias PopUpActionHandle = (PopUpAction) -> ()

/// PopUpActionStyle
public enum PopUpActionStyle {
    case `default`
    case cancel
    case destructive
    case custom
    
    fileprivate var color: UIColor? {
        switch self {
        case .default:
            return UIColor(red: 39.0/255.0, green: 124.0/255.0, blue: 255.0/255.0, alpha: 1)
        case .cancel:
            return UIColor(red: 0/255.0, green: 91.0/255.0, blue: 255.0/255.0, alpha: 1)
        case .destructive:
            return UIColor(red: 255.0/255.0, green: 30.0/255.0, blue: 29.0/255.0, alpha: 1)
        case .custom:
            return nil
        }
    }
}

/// Pop Action
open class PopUpAction {
    open var title: String? {
        didSet {
            btn.setTitle(title, for: UIControlState())
        }
    }
    
    open var titleColor: UIColor? {
        didSet {
            btn.setTitleColor(titleColor, for: UIControlState())
        }
    }
    
    open var selBackgroundColor: UIColor? {
        didSet {
            let image = UIImage.imageWithColor(selBackgroundColor)
            btn.setBackgroundImage(image, for: .highlighted)
        }
    }
    
    open var style: PopUpActionStyle = .default {
        didSet {
            guard style != oldValue && style != .custom else {
                return
            }
            btn.setTitleColor(style.color, for: UIControlState())
        }
    }
    
    open var handle: PopUpActionHandle?
    
    public convenience init(title: String, style: PopUpActionStyle = .default, handle: PopUpActionHandle? = nil) {
        self.init()
        self.title = title
        self.style = style
        self.handle = handle
        
        btn.setTitleColor(style.color, for: UIControlState())
        btn.setTitle(title, for: UIControlState())
    }
    
    open class func action(_ title: String, style: PopUpActionStyle = .default, handle: PopUpActionHandle? = nil) -> PopUpAction {
        return PopUpAction(title: title, style: style, handle: handle)
    }
    
    fileprivate lazy var btn: UIButton = {
        let btn = UIButton(type: .custom)
        RANDOMCOLOR(btn)
        let image = UIImage.imageWithColor(UIColor.lightGray)
        btn.setBackgroundImage(image, for: .highlighted)
        btn.addTarget(self, action: #selector(PopUpAction.btnClick), for: .touchUpInside)
        return btn
    }()
}

private extension PopUpAction {
    @objc func btnClick() {
        handle?(self)
        PopWindow.defaultWindow().tapBackgroundBlock?()
    }
}




//MARK: - ---PopUp---
/// PopComplete
public typealias PopUpViewComplete = (_ pop: PopUpView, _ finish: Bool) -> ()
public typealias PopUpViewAnimation = (PopUpView, PopUpViewComplete?) -> Void

/// Style
public enum PopUpViewStyle {
    case alert
    case sheet
    case custom
}

//#MARK: - Public
public extension PopUpView {
    
    public func show(_ complete: PopUpViewComplete? = nil) {
        if config.shouldUseWindow == true {
            let popWindow = PopWindow.defaultWindow()
            popWindow.shouldBlur = config.shouldBlur
            popWindow.shouldTouchBackgroundToHide = config.shouldTapHidden
            popWindow.shouldShowBackgroundColor = config.shouldShowBackground
            
            if superview == nil {
                let attachView = popWindow.attachView()
                attachView.addSubview(self)
            }
            popWindow.show()
        }else {
            if let window = UIApplication.shared.keyWindow {
                let coverView = PopCoverView()
                coverView.shouldBlur = config.shouldBlur
                coverView.shouldTouchBackgroundToHide = config.shouldTapHidden
                coverView.shouldShowBackgroundColor = config.shouldShowBackground
                coverView.tapBackgroundBlock = {
                    self.hide()
                }
                
                window.addSubview(coverView)
                coverView.frame = window.bounds
                coverView.addSubview(self)
                coverView.show()
                self.coverView = coverView
            }
        }
        
        showAnimation?(self) { (pop, finish) in
            self.showComplete?(self, finish)
            
            complete?(self, finish)
        }
    }
    
    public func hide(_ complete: PopUpViewComplete? = nil) {
        
        // tap background
        hideAnimation?(self) { (pop, finish) in
            
            if self.config.shouldUseWindow == true {
                PopWindow.defaultWindow().hide()
            }else {
                self.coverView?.hide()
            }
            
            self.hideComplete?(self, finish)
            
            complete?(self, finish)
        }
    }
    
    public func addActions(_ actions: [PopUpAction]) {
        // remove all actions
        _ = self.actions?.map({ (a) -> Void in
            a.btn.removeFromSuperview()
        })
        self.actions?.removeAll()
        
        _ = lines.map({ (line) -> Void in
            line.removeFromSuperview()
        })
        lines.removeAll()
        
        // update
        self.actions = actions
        
        configActions()
        configPop()
        
        // style
        guard style != .custom else {
            return
        }
    }
}


/// View to show in window
open class PopUpView: UIView {
    
    open var style: PopUpViewStyle = .custom
    open var customView: UIView? {
        didSet {
            guard customView != nil else {
                return
            }
            
            clipsToBounds = true
            addSubview(customView!)
            frame = customView!.bounds
        }
    }
    
    
    open var config: PopConfig = PopConfig()
    
    open var showComplete: PopUpViewComplete?
    open var hideComplete: PopUpViewComplete?
    
    open var showAnimation: PopUpViewAnimation? {
        return config.showAnimation
    }
    open var hideAnimation: PopUpViewAnimation? {
        return config.hideAnimation
    }
    
    // containView
    open lazy var containView: UIView? = {
        let v = UIView()
        RANDOMCOLOR(v)
        self.addSubview(v)
        return v
    }()
    
    open var title: String? {
        didSet {
            configTitleLabel()
            configPop()
        }
    }
    
    fileprivate var coverView: PopCoverView?
    fileprivate var titleLabel: UILabel?
    
    open var message: String? {
        didSet {
            configDetailLabel()
            configPop()
        }
    }
    fileprivate var messageLabel: UILabel?
    
    fileprivate var actions: [PopUpAction]?
    fileprivate var lines: [UIView] = [UIView]()
    
    fileprivate var titleH: CGFloat = 0
    fileprivate var messageH: CGFloat = 0
    fileprivate var containH: CGFloat = 0
    
    fileprivate var maxWidth: CGFloat {
        let attView = PopWindow.defaultWindow().attachView()
        var max: CGFloat = 0
        
        switch style {
        case .alert:
            layer.cornerRadius = AlertConfig.sharedConfig().cornerRadius
            layer.masksToBounds = true
            max = AlertConfig.sharedConfig().alertWidth
        default:
            max = attView.bounds.size.width
        }
        return max
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        RANDOMCOLOR(self)
        
        addNoti()
        
        autoresizesSubviews = true
        
        let window = PopWindow.defaultWindow()
        window.tapBackgroundBlock = {
            self.hide()
        }
        
        configPop()
    }
    
    init(title: String?, detail: String?, actions: [PopUpAction]?) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        self.title = title
        configTitleLabel()
        
        self.message = detail
        configDetailLabel()
        
        self.actions = actions
        configActions()
        
        RANDOMCOLOR(self)

        addNoti()
        
        autoresizesSubviews = true
        
        let window = PopWindow.defaultWindow()
        window.tapBackgroundBlock = {
            self.hide()
        }
        
        configPop()
    }
    
    fileprivate func addNoti() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(PopUpView.orientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    open func configPop() {
        if style != .custom {
            configTitleLabel()
            configDetailLabel()
            configActions()
        }
        frame = CGRect(x: 0, y: 0, width: maxWidth, height: titleH+messageH+containH)
    }
    
    fileprivate func configTitleLabel() {
        
        guard title?.characters.count > 0 else {
            titleLabel = nil
            titleH = 0
            return
        }
        
        if titleLabel == nil {
            let titleLabel = UILabel()
            titleLabel.textColor = config.titleColor
            titleLabel.font = UIFont.systemFont(ofSize: config.titleFontSize)
            titleLabel.textAlignment = .center
            RANDOMCOLOR(titleLabel)
            addSubview(titleLabel)
            self.titleLabel = titleLabel
        }
        
        titleLabel?.text = title
        
        // 计算高度
        let str = NSString(string: title!)
        let attr = [NSFontAttributeName: UIFont.systemFont(ofSize: config.titleFontSize)]
        
        let inset = config.titleInset
        let h: CGFloat = str.boundingRect(with: CGSize(width: maxWidth-2*(inset.left+inset.right), height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attr, context: nil).size.height
        
        titleH = h + inset.bottom + inset.top
    }
    
    
    fileprivate func configDetailLabel() {
        guard message?.characters.count > 0 else {
            messageLabel = nil
            messageH = 0
            return
        }
        
        if messageLabel == nil {
            let messageLabel = UILabel()
            messageLabel.textColor = config.detailColor
            messageLabel.font = UIFont.systemFont(ofSize: config.detailFontSize)
            messageLabel.textAlignment = .center
            RANDOMCOLOR(messageLabel)
            addSubview(messageLabel)
            self.messageLabel = messageLabel
        }
        
        messageLabel?.text = message
        
        // 计算高度
        let str = NSString(string: message!)
        let attr = [NSFontAttributeName: UIFont.systemFont(ofSize: config.detailFontSize)]
        
        let inset = config.detailInset
        let h: CGFloat = str.boundingRect(with: CGSize(width: maxWidth-2*(inset.left+inset.right), height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attr, context: nil).size.height
        messageH = h + inset.top + inset.bottom
    }
    
    fileprivate func configActions() {
        guard actions?.count > 0 else {
            containH = 0
            return
        }
        
        _ = actions?.map({ (a) -> Void in
            containView?.addSubview(a.btn)
            
            let line = UIView()
            line.backgroundColor = config.splitColor
            containView?.addSubview(line)
            lines.append(line)
        })
        
        let count = actions?.count ?? 0
        if style == .alert && count <= 2 {
            containH = config.buttonHeight
        }else {
            containH = config.buttonHeight * CGFloat(actions?.count ?? 0)
        }
    }
    
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        DebugLog("\(classForCoder) 销毁")
        NotificationCenter.default.removeObserver(self)
    }
    
    // 方向改变
    func orientationChanged(_ sender: NSObject) {
        let device = sender.value(forKey: "object") as? UIDevice
        DebugLog("方向是: \(device?.orientation)")
        
        let bounds = PopWindow.defaultWindow().attachView().bounds
        center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
    }
}


//MARK: - Private
//MARK: Layout
extension PopUpView {
    open override func layoutSubviews() {
        var lastView: UIView?
        var maxY: CGFloat = 0
        
        if titleLabel != nil {
            let inset = config.titleInset
            let t_H: CGFloat = titleH - inset.top - inset.bottom

            titleLabel?.frame = CGRect(x: inset.left, y: maxY+inset.top, width: bounds.size.width-(inset.left+inset.right), height: t_H)
            
            maxY += titleH
            lastView = titleLabel
        }
        
        if messageLabel != nil {
            let inset = config.detailInset
            let m_H: CGFloat = messageH - inset.top - inset.bottom

            messageLabel?.frame = CGRect(x: inset.left, y: maxY+inset.top, width: bounds.size.width-(inset.left+inset.right), height: m_H)
            
            maxY += messageH
            lastView = messageLabel
        }
        
        // 根据action个数去判断需要的高度
        var containH: CGFloat = 0
        let action_count = actions?.count ?? 0
        switch style {
        case .alert:
            if actions?.count > 2 {
                containH = config.buttonHeight * CGFloat(action_count)
            }else if actions?.count > 0 {
                containH = config.buttonHeight
            }
        case .sheet:
            if actions?.count > 0 {
                containH = config.buttonHeight*CGFloat(action_count)
            }
        default:
            break
        }
        containView?.frame = CGRect(x: 0, y: maxY, width: bounds.size.width, height: containH)
        
        
        // actions
        var x: CGFloat = 0
        var y: CGFloat = 0
        var w: CGFloat = bounds.size.width
        let h: CGFloat = config.buttonHeight
        _ = actions?.enumerated().map({ (idx, action) -> Void in
            let line = lines[idx]
            
            if style == .alert && action_count <= 2 {
                // 横排
                
                w = action_count > 1 ? bounds.size.width * 0.5 : bounds.size.width
                x = CGFloat(idx)*w
                
                // 第一条线横纹 第二条竖纹
                if idx == 0 {
                    line.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: POP_SINGLE_LINE_WIDTH)
                }else {
                    line.frame = CGRect(x: x, y: 0, width: POP_SINGLE_LINE_WIDTH, height: h)
                }
            }else {
                // 竖排
                y = CGFloat(idx)*config.buttonHeight
                
                // 横纹排列
                line.frame = CGRect(x: 0, y: CGFloat(idx)*h, width: w, height: POP_SINGLE_LINE_WIDTH)
            }
            action.btn.frame = CGRect(x: x, y: y, width: w, height: h)
        })
    }
}

