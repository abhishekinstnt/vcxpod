//
//  FormSubmitResponse.swift
//  InstntSDK
//
//  Created by Nate Eckerson on 6/3/21.
//

import Foundation

public struct FormSubmitResponse {
    public var status: String?
    public var url: String?
    public var success: Bool?
    public var jwt: String?
    public var decision: String?
    public var message: String?
    public var rawJSON: [String: Any]?
    
    init?(JSON: [String: Any]) {
        
        rawJSON = JSON
        
        let dataJSON = JSON["data"] as? [String: Any]
        let status = dataJSON?["status"] as? String
        let url = dataJSON?["url"] as? String
        let success = dataJSON?["success"] as? Bool
        let jwt = dataJSON?["instntjwt"] as? String
        let decision = dataJSON?["decision"] as? String
        let message = dataJSON?["message"] as? String
        
        self.status = status
        self.url = url
        self.success = success
        self.jwt = jwt
        self.decision = decision
        self.message = message
    }
}
