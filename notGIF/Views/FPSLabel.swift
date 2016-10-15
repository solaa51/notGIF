//
//  FPSLabel.swift
//  notGIF
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

class FPSLabel: UILabel {
    
    // override https://gist.github.com/ibireme/8398714c741fc2097604
    
    private var displayLink: CADisplayLink?
    private var lastTime: TimeInterval = 0
    private var count: Int = 0
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superView = superview else { return }
        frame = CGRect(x: 20, y: superView.bounds.height - 40, width: 55, height: 20)
        
        layer.cornerRadius = 5
        clipsToBounds = true
        textAlignment = .center
        isUserInteractionEnabled = false
        textColor = UIColor.white
        backgroundColor = UIColor(white: 0, alpha: 0.7)
        font = UIFont(name: "Menlo", size: 14)
        
        displayLink = CADisplayLink(target: self, selector: #selector(FPSLabel.tick(dpLink:)))
        displayLink?.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    func tick(dpLink: CADisplayLink) {
        
        if lastTime == 0  {
            lastTime = dpLink.timestamp
            return
        }
        
        count += 1
        let timeDelta = dpLink.timestamp - lastTime
        if timeDelta < 0.25 {
            return
        }
        
        lastTime = dpLink.timestamp
        let fps = Double(count) / timeDelta
        count = 0
        
        let progress = fps / 60.0;
        self.textColor = UIColor(hue: CGFloat(0.27 * ( progress - 0.2 )) , saturation: 1, brightness: 0.9, alpha: 1)
        self.text = "\(Int(fps+0.5))FPS"
    }
}
