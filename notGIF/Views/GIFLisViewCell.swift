//
//  GIFListCollectionViewCell.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

class GIFListViewCell: UICollectionViewCell {
    var imageView: NotGIFImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = NotGIFImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        let hC = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: ["imageView": imageView])
        let vC = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: ["imageView": imageView])
        contentView.addConstraints(hC + vC)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.stopAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
