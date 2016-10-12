//
//  UIColor+Extension.swift
//  MTodo
//
//  Created by 陈文强 on 16/3/2.
//  Copyright © 2016年 CWQ. All rights reserved.
//


#if os(iOS)
// iOS 系统下
import Foundation
import UIKit
public typealias Color = UIColor
    
#elseif os(OSX)
// OSX 系统下
import Cocoa
public typealias Color = NSColor
    
#endif


/**
 *  RANDOMCOLOR
 *  快速对UIView设置随机背景色
 *
 *  @param view     需要设置背景色的view
 */
public func RANDOMCOLOR(_ view: UIView?) {
//    view?.backgroundColor = UIColor.randomColor()
}





// MARK: - RandomColor
extension Color {
    /// Create a random color
    /// 获得一个随机UIColor\NSColor对象
    ///
    /// -return:        A new UIColor\NSColor instance
    public class func randomColor() -> Color {
        let r : CGFloat = CGFloat(arc4random() % 256) / 255.0
        let g : CGFloat = CGFloat(arc4random() % 256) / 255.0
        let b : CGFloat = CGFloat(arc4random() % 256) / 255.0
        return Color(red: r, green: g, blue: b, alpha: 1)
    }
}





// MARK: - HexColor
/// Color
/// UIColor\NSColor 的类拓展
///
/// 快速创建UIColor\NSColor对象
extension Color {
    /// Initializes UIColor\NSColor with an integer.
    /// 通过16进制数获取一个UIColor\NSColor对象
    ///
    /// -parameter value        The integer value of the color. E.g. 0xFF0000 is red, 0x0000FF is blue.
    public convenience init(_ value: Int) {
        let components = getColorComponents(value)
        self.init(red: components.red, green: components.green, blue: components.blue, alpha: 1.0)
    }
    
    ///  Initializes UIColor\NSColor with an integer and alpha value.
    ///  通过16进制数和透明度(alpha)获取一个UIColor\NSColor对象
    ///
    ///  -parameter value        The integer value of the color
    ///  -parameter alpha        The integer alpha of the color
    public convenience init(_ value: Int, alpha: CGFloat) {
        let components = getColorComponents(value)
        self.init(red: components.red, green: components.green, blue: components.blue, alpha: alpha)
    }
    
    /// Creates a new color with the given alpha value
    /// 通过透明度(alpha)获取一个新的UIColor\NSColor对象
    /// 
    /// -parameter value        The integer value of the color
    public func alpha(_ value:CGFloat) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(red: red, green: green, blue: blue, alpha: value)
    }
    
    /// Mixes the color with another color
    /// 混合两个color
    ///
    /// - parameter color:      The color to mix with
    /// - parameter amount:     The amount (0-1) to mix the new color in.
    /// - returns:              A new UIColor instance representing the resulting color
    public func mixWithColor(_ color:Color, amount:Float) -> Color {
        var comp1: [CGFloat] = Array(repeating: 0, count: 4);
        self.getRed(&comp1[0], green: &comp1[1], blue: &comp1[2], alpha: &comp1[3])
        
        var comp2: [CGFloat] = Array(repeating: 0, count: 4);
        color.getRed(&comp2[0], green: &comp2[1], blue: &comp2[2], alpha: &comp2[3])
        
        var comp: [CGFloat] = Array(repeating: 0, count: 4);
        for i in 0...3 {
            comp[i] = comp1[i] + (comp2[i] - comp1[i]) * CGFloat(amount)
        }
        return Color(red:comp[0], green: comp[1], blue: comp[2], alpha: comp[3])
    }
}





// MARK: - ComponmentColor
extension Color {
    
    var red: CGFloat {
        get {
            let components = self.cgColor.components
            return components![0]
        }
    }
    
    var green: CGFloat {
        get {
            let components = self.cgColor.components
            return components![1]
        }
    }
    
    var blue: CGFloat {
        get {
            let components = self.cgColor.components
            return components![2]
        }
    }
    
    var alpha: CGFloat {
        get {
            return self.cgColor.alpha
        }
    }
    
    func white(_ scale: CGFloat) -> Color {
        return Color(
            red: self.red + (1.0 - self.red) * scale,
            green: self.green + (1.0 - self.green) * scale,
            blue: self.blue + (1.0 - self.blue) * scale,
            alpha: 1.0
        )
    }
}




// MARK: - Description
extension Color {
    /// Hex string of a UIColor instance.
    ///
    /// -parameter rgba:    Whether the alpha should be included.
    /// -return:            The hex string of the color
    public func hexString(_ includeAlpha: Bool) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        if (includeAlpha) {
            return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
    }
    
    open override var description: String {
        return self.hexString(true)
    }
    
    open override var debugDescription: String {
        return self.hexString(true)
    }
}



/// MARK: - Private
/// Get (r,g,b) value from color
private func getColorComponents(_ value: Int) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
    let r = CGFloat(value >> 16 & 0xFF) / 255.0
    let g = CGFloat(value >> 8 & 0xFF) / 255.0
    let b = CGFloat(value & 0xFF) / 255.0
    return (r, g, b)
}
