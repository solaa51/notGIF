//
//  DebugLog.swift
//  notGIF
//
//  Created by Atuooo on 12/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import Foundation

func println(_ item: @autoclosure () -> Any) {
    #if DEBUG
        print("\n^ \(item())")
    #endif
}
