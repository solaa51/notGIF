//
//  MBHUD.swift
//  notGIF
//
//  Created by Atuooo on 25/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import MBProgressHUD

extension MBProgressHUD {
    
    class func showAdded(to view: UIView, with text: String = "", progressHandler: @escaping () -> Void, completion: @escaping () -> Void) {
        
        let customHUD = MBProgressHUD(view: view)
        customHUD.removeFromSuperViewOnHide = true
        customHUD.mode = .indeterminate
        customHUD.animationType = .fade
        customHUD.contentColor = .tintColor
        customHUD.bezelView.color = .clear
        customHUD.bezelView.style = .solidColor
        customHUD.backgroundView.color = .clear
        
        customHUD.offset = CGPoint(x: 0, y: -40)
        customHUD.label.text = text
        customHUD.label.font = UIFont(name: "Menlo", size: 12)
        
        customHUD.completionBlock = {
            completion()
        }
        
        view.addSubview(customHUD)
        customHUD.show(animated: true)
        
        DispatchQueue.main.async {
            progressHandler()
            DispatchQueue.main.async {
                customHUD.hide(animated: true)
            }
        }
    }
    
    class func showAdded(to view: UIView, with text: String = "") {
        let customHUD = MBProgressHUD(view: view)
        customHUD.removeFromSuperViewOnHide = true
        customHUD.mode = .indeterminate
        customHUD.animationType = .fade
        customHUD.contentColor = .tintColor
        customHUD.bezelView.style = .solidColor
        customHUD.bezelView.color = .black
        customHUD.backgroundView.color = .clear
        
        customHUD.graceTime = 0.001
        customHUD.minShowTime = 0.1
        customHUD.label.text = text
        customHUD.label.font = UIFont(name: "Menlo", size: 12)

        customHUD.show(animated: true)
        view.addSubview(customHUD)
    }
}
