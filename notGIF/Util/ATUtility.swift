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

public let kTextColor = UIColor.hex(0xFBFBFB, alpha: 0.95)

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

extension Int {
    var byteString: String {
        let kb = self / 1024
        return kb >= 1024 ? String(format: "%.1f MB", Float(kb) / 1024) : "\(kb) kB"
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

extension UIColor {
    public class func hex(_ hex: NSInteger, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16))/255.0,
                       green: ((CGFloat)((hex & 0xFF00) >> 8))/255.0,
                       blue: ((CGFloat)(hex & 0xFF))/255.0, alpha: alpha)
    }
}
