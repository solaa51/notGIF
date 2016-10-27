//
//  ATUtility.swift
//  notGIF
//
//  Created by Atuooo on 10/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

public let kScreenSize = ATScreenSize.shared.size
public let kScreenWidth = ATScreenSize.shared.size.width
public let kScreenHeight = ATScreenSize.shared.size.height

class ATScreenSize {
    static let shared = ATScreenSize()
    
    let size: CGSize = {
        var ss = UIScreen.main.bounds.size
        if ss.height < ss.width {
            let tmp = ss.width
            ss.width = ss.height
            ss.height = tmp
        }
        return ss
    }()
    
    private init() {}
}

extension UIColor {

    @nonobjc static let tintRed   = UIColor.hex(0xF4511E)
    @nonobjc static let tintBlue  = UIColor.hex(0x039BE5)
    @nonobjc static let tintBar   = UIColor.hex(0x1C1C1C, alpha: 0.5)
    @nonobjc static let bgColor   = UIColor.hex(0x222222)
    @nonobjc static let tintColor = UIColor.hex(0xFBFBFB, alpha: 0.95)

    
    public class func hex(_ hex: NSInteger, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16))/255.0,
                       green: ((CGFloat)((hex & 0xFF00) >> 8))/255.0,
                       blue: ((CGFloat)(hex & 0xFF))/255.0, alpha: alpha)
    }
}

extension Int {
    var byteString: String {
        let kb = self / 1024
        let _ = Int.max
        return kb >= 1024 ? String(format: "%.1f MB", Float(kb) / 1024) : "\(kb) kB"
    }
}


extension String {
    func singleLineWidth(with font: UIFont) -> CGFloat {
        return (self as NSString).boundingRect(with: CGSize(width: .max, height: .max),
                                               options: [.usesFontLeading, .usesLineFragmentOrigin],
                                               attributes: [NSFontAttributeName: font],
                                               context: nil).size.width
    }
}

extension IndexSet {
    subscript(index: Int) -> Int {
        return self[self.index(startIndex, offsetBy: index)]
    }
}

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

extension UIImage {
    public func aspectFill(toSize: CGSize) -> UIImage {
        var cropArea = CGRect.zero
        var scale = CGFloat(0)
        
        if size.height > size.width {
            cropArea = CGRect(x: 0, y: (size.height-size.width) / 2, width: size.width, height: size.width)
            scale = size.width / toSize.width
        } else {
            cropArea = CGRect(x: (size.width - size.height)/2, y: 0, width: size.height, height: size.height)
            scale = size.height / toSize.width
        }
        
        let cropImageRef = cgImage!.cropping(to: cropArea)
        return UIImage(cgImage: cropImageRef!, scale: scale, orientation: .up)
    }
}
