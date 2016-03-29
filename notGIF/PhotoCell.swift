//
//  PhotoCell.swift
//  GifViewer
//
//  Created by Atuooo on 9/10/15.
//  Copyright © 2015 atuooo. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: FLAnimatedImageView!
    var shouldPlay = true
    var data = NSData()
}
