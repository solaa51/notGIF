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
