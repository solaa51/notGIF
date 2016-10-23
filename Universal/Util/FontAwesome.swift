//
//  FontAwesome.swift
//  notGIF
//
//  Created by Atuooo on 11/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

public enum FontUnicode: String {
    // http://fontawesome.io/cheatsheet/
    
    case twitter = "\u{f099}"
    case wechat  = "\u{f1d7}"
    case weibo   = "\u{f18a}"
    case message = "\u{f086}"   // f0e6 f27a
    case copy    = "\u{f0c5}"
    case share   = "\u{f1e0}"
    
    var string: String {
        return rawValue.substring(to: rawValue.characters.index(rawValue.startIndex, offsetBy: 1))
    }
}

extension UIFont {
    public static func awesomeFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "FontAwesome", size: fontSize)!
    }
}

extension UILabel {
    
    public convenience init(iconCode: FontUnicode, color: UIColor, fontSize: CGFloat) {
        self.init()
        textAlignment = .center
        font = UIFont.awesomeFont(ofSize: fontSize)
        text = iconCode.string
        textColor = color
    }
}

extension UIButton {
    public convenience init(iconCode: FontUnicode, color: UIColor, fontSize: CGFloat) {
        self.init()
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.awesomeFont(ofSize: fontSize)
        
        setTitle(iconCode.string, for: .normal)
        setTitleColor(color, for: .normal)
    }
}

extension UIImage {
    public class func iCon(ofCode code: FontUnicode, size: CGSize, color: UIColor) -> UIImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attributedString = NSAttributedString(string: code.string,
                                                  attributes: [
                                                    NSFontAttributeName: UIFont.awesomeFont(ofSize: min(size.width, size.height)),
                                                    NSForegroundColorAttributeName: color,
                                                    NSParagraphStyleAttributeName: paragraph])
        
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        attributedString.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
