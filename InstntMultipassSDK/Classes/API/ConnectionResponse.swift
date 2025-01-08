//
//  ConnectionResponse.swift
//  taxiapp
//
//  Created by Jagruti on 10/13/19.
//  Copyright © 2019 ROBAB. All rights reserved.
//

import Foundation
class ConnectionResponse: NSObject {
    private (set) public var request: ConnectionRequest
    private (set) public var status: Int
    private (set) public var data: Data
    private (set) public var headers: [String: AnyObject?]
    var requestId: String?

    public init(request: ConnectionRequest, status: Int, response: Data, headers: [String: AnyObject?]) {
        self.request = request
        self.status = status
        data = response
        self.headers = headers
        if let id = request.id {
            requestId = id
        }
    }
}
