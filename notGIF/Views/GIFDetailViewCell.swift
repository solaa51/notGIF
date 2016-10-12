//
//  GIFDetailViewCell.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

private let maxHeight = kScreenHeight - 64 - 120

class GIFDetailViewCell: UICollectionViewCell {
    var imageView: NotGIFImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = NotGIFImageView()
        contentView.addSubview(imageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configureWithImage(image: NotGIFImage) {
        let imageH = kScreenWidth / image.ratio
        
        if imageH > maxHeight {
            imageView.frame.size = CGSize(width: imageH * image.ratio, height: maxHeight)
        } else {
            imageView.frame.size = CGSize(width: kScreenWidth, height: imageH)
        }
        
        imageView.center = contentView.center //CGPoint(x: kScreenWidth / 2, y: contentView.center.y - 32)
        imageView.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
