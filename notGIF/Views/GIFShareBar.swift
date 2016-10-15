//
//  GIFShareBar.swift
//  notGIF
//
//  Created by Atuooo on 10/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

public enum ShareType: Int {
    case more    = 23
    case twitter
    case weibo
    case wechat
    case message
    
    var iconCode: FontUnicode {
        switch self {
            case .more:     return .share
            case .twitter:  return .twitter
            case .weibo:    return .weibo
            case .wechat:   return .wechat
            case .message:  return .message
        }
    }
}

private let itemSize = CGFloat(58)

class GIFShareBar: UIView {
    var shareHandler: ((ShareType) -> Void)?
    
    private let shareTypes: [ShareType] = [.more, .twitter, .weibo, .wechat, .message]
    private var shareButtons = [UIButton]()
    private var showedIndex = 0
    
    override var isHidden: Bool {
        didSet {
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin.y = self.isHidden ? kScreenHeight : kScreenHeight - itemSize
            })
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: kScreenHeight - itemSize, width: kScreenWidth, height: itemSize))
        isUserInteractionEnabled = false
        
        for i in 0 ..< shareTypes.count {
            let button = UIButton(iconCode: shareTypes[i].iconCode, color: kTextColor, fontSize: 28)
            button.addTarget(self, action: #selector(shareButtonClicked(sender:)), for: .touchUpInside)
            button.frame.size = CGSize(width: itemSize, height: itemSize)
            button.tag = shareTypes[i].rawValue
            
            if i == 0 {
                button.layer.position = CGPoint(x: 0, y: itemSize)
                button.layer.anchorPoint = CGPoint(x: 0, y: 1)
                button.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 1, 0, 0)
            } else {
                button.layer.position = CGPoint(x: CGFloat(i) * (itemSize + 1), y: 0)
                button.layer.anchorPoint = CGPoint(x: 0, y: 0)
                button.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 1, 0)
            }
            
            shareButtons.append(button)
            addSubview(button)
        }
    }
    
    func shareButtonClicked(sender: UIButton) {
        guard let shareType = ShareType(rawValue: sender.tag) else { return }
        shareHandler?(shareType)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        showButtons()
    }
    
    private func showButtons() {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 100
        
        if showedIndex == shareTypes.count {
            isUserInteractionEnabled = true
            return
        }
        
        UIView.animate(withDuration: 0.13, animations: {
            self.shareButtons[self.showedIndex].layer.transform = transform
            self.showedIndex += 1
        }) { done in
            self.showButtons()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
