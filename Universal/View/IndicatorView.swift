//
//  IndicatorView.swift
//  notGIF
//
//  Created by Atuooo on 26/10/2016.
//  Copyright © 2016 xyz. All rights reserved.
//

import UIKit

public enum IndicatorType {
    case noGIF
    case denied
    
    var info: String {
        switch self {
        case .noGIF:
            return "No GIFs Found"
        case .denied:
            return "Photos Access Rejected"
        }
    }
}

class IndicatorView: UIView {
    var urlString = ""
    
    init(for view: UIView, type: IndicatorType, isHostApp: Bool = true) {
        super.init(frame: CGRect.zero)
        
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Sad"))
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = type.info
        label.font = UIFont(name: "Shojumaru-Regular", size: 20)
        label.textColor = .gray
        label.textAlignment = .center
        label.sizeToFit()
        addSubview(label)
        
        if type == .denied {
            urlString = isHostApp ? UIApplicationOpenSettingsURLString : "notGIF://"
            
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Allow Access", for: .normal)
            button.setTitleColor(.tintBlue, for: .normal)
            button.titleLabel?.font = UIFont(name: "Shojumaru-Regular", size: 16)
            button.addTarget(self, action: #selector(IndicatorView.openSystemSettings), for: .touchUpInside)
            
            addSubview(button)
            
            button.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 200, height: 40))
                make.top.equalTo(label.snp.bottom).offset(10)
                make.centerX.equalTo(label)
            }
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.top.centerX.equalTo(self)
        }
        
        label.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }
        
        view.addSubview(self)
        snp.makeConstraints { make in
            make.right.left.equalTo(view)
            make.top.equalTo(view).offset(40)
            make.height.equalTo(200)
        }
    }
    
    func openSystemSettings() {

        if let url = URL(string: urlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

