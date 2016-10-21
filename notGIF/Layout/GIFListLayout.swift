//
//  GIFListLayout.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

protocol GIFListLayoutDelegate: NSObjectProtocol {
    func ratioForImageAtIndexPath(indexPath: IndexPath) -> CGFloat
}

class GIFListLayout: UICollectionViewLayout {
    
    weak var delegate: GIFListLayoutDelegate!
    private let cellPadding = CGFloat(1.0)
    private var contentSize = CGSize.zero
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    init(delegate: GIFListLayoutDelegate) {
        super.init()
        
        self.delegate = delegate 
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        cacheAttributes()
    }
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.filter{ $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    fileprivate func cacheAttributes() {
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()
        
        let itemCount = collectionView.numberOfItems(inSection: 0)
        let contentWidth = UIScreen.main.bounds.size.width - 3 * cellPadding
        
        var yOffset = CGFloat(1)
        
        for index in 0 ..< itemCount / 2 {
            let leftIndexPath  = IndexPath(item: index * 2, section: 0)
            let rightIndexPath = IndexPath(item: index * 2 + 1, section: 0)
            let leftItemRatio  = delegate.ratioForImageAtIndexPath(indexPath: leftIndexPath)
            let rightItemRatio = delegate.ratioForImageAtIndexPath(indexPath: rightIndexPath)
            
            let itemHeight = contentWidth / (rightItemRatio + leftItemRatio)
            let leftItemAtt = UICollectionViewLayoutAttributes(forCellWith: leftIndexPath)
            let leftItemWidth = itemHeight * leftItemRatio
            leftItemAtt.frame = CGRect(x: 1, y: yOffset, width: leftItemWidth, height: itemHeight)
            cachedAttributes.append(leftItemAtt)
            
            let rightItemAtt = UICollectionViewLayoutAttributes(forCellWith: rightIndexPath)
            rightItemAtt.frame = CGRect(x: 2 + leftItemWidth, y: yOffset, width: itemHeight * rightItemRatio, height: itemHeight)
            cachedAttributes.append(rightItemAtt)
            
            yOffset += itemHeight + 1
        }
        
        if itemCount % 2 == 1 {
            let lastSingleItemIndexPath = IndexPath(item: itemCount - 1, section: 0)
            let itemRatio = delegate.ratioForImageAtIndexPath(indexPath: lastSingleItemIndexPath)
            let itemAtt = UICollectionViewLayoutAttributes(forCellWith: lastSingleItemIndexPath)
            let itemWidth = contentWidth * 0.618, itemHeight = itemWidth / itemRatio
            itemAtt.frame = CGRect(x: 1, y: yOffset, width: itemWidth, height: itemHeight)
            cachedAttributes.append(itemAtt)
            
            yOffset += itemHeight
        }
        
        contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: yOffset)
    }
}
