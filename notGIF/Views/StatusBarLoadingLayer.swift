//
//  StatusBarLoadingLayer.swift
//  notGIF
//
//  Created by Atuooo on 17/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

private let numOfCircle = 3

class StatusBarLoadingLayer: CALayer {

    init(radius: Int, center: CGPoint, color: UIColor = .white) {
        super.init()
        
        frame.size = CGSize(width: radius * numOfCircle, height: radius)
        position = center
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1, 0.6, 1]
        scaleAnimation.keyTimes = [0, 0.5, 1]

        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [1, 0.2, 1]
        opacityAnimation.keyTimes = [0, 0.5, 1]
        
        let animations = CAAnimationGroup()
        animations.duration = 1
        animations.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animations.animations = [scaleAnimation, opacityAnimation]
        animations.isRemovedOnCompletion = false
        animations.repeatCount = .infinity // HUGE
        
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.3, 0, 0.3]
        
        for i in 0 ..< numOfCircle {
            let rect = CGRect(x: i * radius, y: 0, width: radius, height: radius)
            
            let circleLayer = CAShapeLayer()
            circleLayer.frame = rect
            circleLayer.path = UIBezierPath(ovalIn: circleLayer.bounds).cgPath
            circleLayer.fillColor = color.cgColor
            circleLayer.backgroundColor = UIColor.clear.cgColor
            
            animations.beginTime = beginTime + beginTimes[i]
            circleLayer.add(animations, forKey: "animations")
            addSublayer(circleLayer)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
