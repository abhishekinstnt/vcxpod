//
//  NetworkActivityIndicator.swift
//  taxiapp
//
//  Created by Jagruti on 10/13/19.
//  Copyright © 2019 ROBAB. All rights reserved.
//

import Foundation
import UIKit
class NetworkActivityIndicator: NSObject {
    /**
     The shared instance.
     */
    static let sharedIndicator = NetworkActivityIndicator()
    /**
     The number of activities in progress.
     */
    private (set) public var activitiesCount = 0

    /**
     A Boolean value that turns an indicator of network activity on or off.

     Specify true if the app should show network activity and false if it should not. The default value is false. A spinning indicator in the status bar shows network activity.
     */
    var visible: Bool = false {
        didSet {
            if visible {
                self.activitiesCount += 1
            } else {
                self.activitiesCount -= 1
            }

            if self.activitiesCount < 0 {
                self.activitiesCount = 0
            }

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                let shouldShow = NetworkActivityIndicator.sharedIndicator.activitiesCount > 0
                UIApplication.shared.isNetworkActivityIndicatorVisible = shouldShow
            }
        }
    }
}
