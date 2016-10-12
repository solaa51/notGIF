//
//  NotGIFImage.swift
//  GIFEnginTest
//
//  Created by Atuooo on 09/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

private let kGIFFrameDelayThreshold = 0.02
private let prefetchNum = 5

class NotGIFImage: UIImage {
    
    var totalDelay = 0.0
    var imgSource: CGImageSource!
    var gifInfo: String = ""
    
    lazy var frames = [CGImage?]()
    lazy var frameDurations = [TimeInterval]()
    
    private lazy var getFrameQueue: DispatchQueue = DispatchQueue(label: "com.atuo.getgifframe", attributes: [])
    
    func getFrame(at index: Int) -> CGImage? {
        if index >= frames.count {
            return nil
        }
        
        if frames.count <= prefetchNum {
            return frames[index]
        }
        
        if let frame = frames[index] {
            if index != 0 {
                frames[index] = nil
            }
            
            for i in index+1 ... index+prefetchNum {
                let idx = i % frames.count
                
                if frames[idx] == nil {
                    getFrameQueue.async {
                        self.frames[idx] = CGImageSourceCreateImageAtIndex(self.imgSource, idx, nil)
                    }
                }
            }

            return frame
            
        } else {
            
            let frame = CGImageSourceCreateImageAtIndex(imgSource, index, nil)
            frames[index] = frame
            return frame
        }
    }
    
    private func getGIFInfo(imgSource: CGImageSource) {
        let imgCount = CGImageSourceGetCount(imgSource)
        
        for index in 0 ..< imgCount {
            let delayTime = getGIFFrameDuration(imgSource: imgSource, index: index)
            frameDurations.append(delayTime)
            totalDelay += delayTime

            let frame = index < prefetchNum ? CGImageSourceCreateImageAtIndex(imgSource, index, nil) : nil
            frames.append(frame)
        }
        
        gifInfo += "\(imgCount) Frames" + "\n"
        gifInfo += String(format: "%.2fs", totalDelay) + " / "
        if let properties = CGImageSourceCopyProperties(imgSource, nil) as? NSDictionary,
            let fileSize = properties[kCGImagePropertyFileSize] as? Int {
            gifInfo += fileSize.byteString
        }
    }
    
    private func getGIFFrameDuration(imgSource: CGImageSource, index: Int) -> TimeInterval {
        guard let frameProperties = CGImageSourceCopyPropertiesAtIndex(imgSource, index, nil) as? NSDictionary,
            let gifProperties = frameProperties[kCGImagePropertyGIFDictionary] as? NSDictionary,
            let unclampedDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
        else { return 0.02 }
        
        var frameDuration = TimeInterval(0)
        
        if unclampedDelay < 0 {
            frameDuration = gifProperties[kCGImagePropertyGIFDelayTime] as? TimeInterval ?? 0.0
        } else {
            frameDuration = unclampedDelay
        }
        
        /* Implement as Browsers do: Supports frame delays as low as 0.02 s, with anything below that being rounded up to 0.10 s.
         http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility */
        
        if (frameDuration < kGIFFrameDelayThreshold - DBL_EPSILON) {
            frameDuration = 0.1;
        }
        
        return frameDuration
    }
    
    convenience override init?(data: Data) {
        self.init(data: data, scale: 1.0)
    }
    
    override init?(data: Data, scale: CGFloat) {
        
        guard let imgSource = CGImageSourceCreateWithData(data as CFData, nil),
              let imgType = CGImageSourceGetType(imgSource)
        else { return nil }
        
        if UTTypeConformsTo(imgType, kUTTypeGIF) {
            super.init()
            
            self.imgSource = imgSource
            getGIFInfo(imgSource: imgSource)
            
        } else {
            
            super.init(data: data, scale: scale)
        }
    }
    
    override var size: CGSize {
        get {
            if let firstObject = frames.first, let frame = firstObject {
                return CGSize(width: frame.width, height: frame.height)
            } else {
                return super.size
            }
        }
    }
    
    var ratio: CGFloat {
        if let firstObject = frames.first, let frame = firstObject {
            return CGFloat(frame.width) / CGFloat(frame.height)
        } else {
            return 0.618
        }
    }
    
    required convenience init(imageLiteralResourceName name: String) {
        fatalError("init(imageLiteralResourceName:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
