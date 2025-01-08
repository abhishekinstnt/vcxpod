//
//  Utils.swift
//  InstntSDK
//
//  Created by Jagruti Patel CW on 2/6/22.
//

import Foundation
class Utils {
    class func getViewHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    class func getViewWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    class func getDeviceModel() -> String {
        return UIDevice.current.model
    }
    class func getOSVersion() -> String {
        return UIDevice.current.systemVersion
    }
    class func getSerialNumber() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    class func getDPI() -> String {
        let scale = UIScreen.main.nativeScale
        let ppi = scale * ((UIDevice.current.userInterfaceIdiom == .pad) ? 132 : 163)
        return "\(ppi)"
    }
    class func diagonalScreenSize() -> String {
        let scale = UIScreen.main.nativeScale
        let ppi = scale * ((UIDevice.current.userInterfaceIdiom == .pad) ? 132 : 163)
        let width = getViewWidth() * scale
        let hegith = getViewHeight() * scale
        let horizontal = width/ppi
        let vertical = hegith/ppi
        let diagonal = sqrt(pow(horizontal, 2) + pow(vertical, 2))
        return "\(diagonal)"
    }
}
