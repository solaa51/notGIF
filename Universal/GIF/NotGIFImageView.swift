//
//  NotGIFImageView.swift
//  GIFEnginTest
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

class NotGIFImageView: UIImageView {
    private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(NotGIFImageView.changeFrame(dpLink:)))
    
    private var accumulator: TimeInterval = 0.0
    private var currentFrameIndex: Int = 0
    private var currentFrame: CGImage? = nil
    private var loopCountdown: Int = Int.max
    private var animatedImage: NotGIFImage? = nil
    
    override var image: UIImage? {
        get {
            if let animatedImg = animatedImage {
                return animatedImg
            } else {
                return super.image
            }
        }
        
        set {
            if image === newValue {
                return
            } else {
                stopAnimating()
                currentFrameIndex = 0
                accumulator = 0.0
                
                if let animatedImg = newValue as? NotGIFImage {
                    animatedImage = animatedImg
                    if let frame = animatedImg.getFrame(at: 0) {
                        super.image = UIImage(cgImage: frame)
                        currentFrame = frame
                    }
                    
                    startAnimating()
                } else {
                    super.image = newValue
                    animatedImage = nil
                }
            }
            
            layer.setNeedsDisplay()
        }
    }
    
    override func startAnimating() {
        if let _ = animatedImage {
            displayLink.isPaused = false
        } else {
            super.startAnimating()
        }
    }
    
    override func stopAnimating()  {
        displayLink.isPaused = true

//        if let _ = animatedImage {
//            displayLink.isPaused = true
//        } else {
//            super.stopAnimating()
//        }
    }
    
    override var isHighlighted: Bool {
        get{
            return super.isHighlighted
        }
        set {
            if let _ = animatedImage {
                return
            } else {
                return super.isHighlighted = newValue
            }
        }
    }
    
    override var isAnimating: Bool {
        get {
            if let _ = animatedImage {
                return !displayLink.isPaused
            } else {
                return super.isAnimating
            }
        }
    }

    override func display(_ layer: CALayer) {
        if let _ = animatedImage {
            layer.contents = currentFrame
        }
    }
    
    func changeFrame(dpLink: CADisplayLink) {
        if let animatedImg = animatedImage {
            if currentFrameIndex < animatedImg.frames.count {
                accumulator += dpLink.duration
                var frameDuration = animatedImg.frameDurations[currentFrameIndex]
                while accumulator >= frameDuration
                {
                    accumulator = 0
                    currentFrameIndex += 1
                    if currentFrameIndex >= animatedImg.frames.count {
                        currentFrameIndex = 0
                    }
                    
                    currentFrame = animatedImg.getFrame(at: currentFrameIndex)
                    
                    self.layer.setNeedsDisplay()
                    frameDuration = animatedImg.frameDurations[currentFrameIndex]
                }
            }
        } else {
            stopAnimating()
        }
    }
    
    func prepareToReuse() {
        displayLink.isPaused = true
        super.image = nil
        currentFrameIndex = 0
        accumulator = 0.0
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        layer.masksToBounds = true
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        displayLink.isPaused = true
    }
    
    deinit {
        displayLink.invalidate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        displayLink.isPaused = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
