//
//  Empty.swift
//  Main
//
//  Created by 陈文强 on 16/8/24.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit

public enum EmptyType {
    case normal(title: String, image: String)
}

open class EmptyHelper: NSObject {
    open class func emptyViewWithType(_ type: EmptyType) -> UIView {
        let empty: UIView
        
        switch type {
        case .normal(title: let t, image: let i):
            let v = NormalEmptyView()
            v.titleLabel?.text = t
            v.imageView?.setImage(UIImage(named: i), for: UIControlState())
            empty = v
            break
        }
        return empty
    }
}


open class NormalEmptyView: UIView {
    open var imageView: UIButton?
    open var titleLabel: UILabel?
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


//#MARK: - SetUpSubviews
private extension NormalEmptyView {
    func setUpSubviews() {
        backgroundColor = UIColor.white
        
        let imgView = UIButton()
        imgView.contentMode = .center
        addSubview(imgView)
//        imgView.snp_makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview().offset(-50)
//        }
        imageView = imgView
        
        let tLabel = UILabel()
        tLabel.font = UIFont.boldSystemFont(ofSize: 16)
        tLabel.textColor = UIColor.lightGray
        addSubview(tLabel)
//        tLabel.snp_makeConstraints { (make) in
//            make.top.equalTo(imgView.snp_bottom).offset(20)
//            make.centerX.equalToSuperview()
//        }
        titleLabel = tLabel
    }
}












