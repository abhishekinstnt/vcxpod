//
//  ConnectionRequest.swift
//  taxiapp
//
//  Created by Jagruti on 10/13/19.
//  Copyright © 2019 ROBAB. All rights reserved.
//

import Foundation
class ConnectionRequest {
    var requestURL: String
    var postData: Data?
    var postDictionary: [String: AnyObject] = [:]
    var requestCustomHeaders: [String: AnyObject] = [:]
    var httpMethod: HttpMethod
    var configurationType: ConfigurationType
    public var requestContentType: ContentType
    var id: String?
    public init(urlString: String, method: HttpMethod, contentType: ContentType = .json, id: String? = nil, enableAuthSecurity: Bool = false, enableBOTSensor: Bool = false) {
        requestURL = urlString
        httpMethod = method
        requestContentType = contentType
        configurationType = .default // Standard Defaults
        if let requestId = id {
            self.id = requestId
        }
    }

}
