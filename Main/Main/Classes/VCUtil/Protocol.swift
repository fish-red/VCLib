//
//  Protocol.swift
//  MainProject
//
//  Created by 陈文强 on 16/8/4.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import UIKit

//#MARK: - Able
//#MARK: ViewSelectAble
public enum SelectListState {
    case normal
    case selection
    case other
}

public protocol SelectListAble: NSObjectProtocol {
    var selectState: SelectListState {set get}
    var selectionList: NSMutableArray {set get}
}

@objc public protocol CheckedAble: NSObjectProtocol {
    weak var checkBtn: UIButton? {set get}
    func showCheckBox()
    func hideCheckBox()
}



//#MARK: ViewLongPressAble
public protocol ViewLongPressDelegate: NSObjectProtocol {
    func viewDidLongPress(_ v: UIView)
}

public protocol LongPressAble: NSObjectProtocol {
    weak var delegate: ViewLongPressDelegate? {get set}
    func addLongGes()
    func longHandle(_ ges: UILongPressGestureRecognizer)
}

extension LongPressAble where Self: UIView {
    func addLongGes() {
        let long = UILongPressGestureRecognizer(target: self, action: Selector(("longHandle:")))
        self.addGestureRecognizer(long)
    }
}


//#MARK: - Init
public protocol SetUpSubviewProtocol {
    func setUpSubviews()
}











