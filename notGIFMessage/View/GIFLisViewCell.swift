//
//  GIFListCollectionViewCell.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit
import SnapKit

class GIFListViewCell: UICollectionViewCell {
    var imageView: NotGIFImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = NotGIFImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.stopAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
