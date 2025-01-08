//
//  ConnectionErrorResponse.swift
//  taxiapp
//
//  Created by Jagruti on 10/13/19.
//  Copyright © 2019 ROBAB. All rights reserved.
//

import Foundation
class ConnectionErrorResponse: NSObject, Error {
    var request: ConnectionRequest
    private (set) public var errorConstants: ErrorConstants
    internal (set) public var connectionResponse: ConnectionResponse?
    var requestId: String?

    public init(request: ConnectionRequest, errorConstants: ErrorConstants, connectionResponse: ConnectionResponse? = nil) {
        self.request = request
        self.errorConstants = errorConstants
        self.connectionResponse = connectionResponse
        if let id = request.id {
            requestId = id
        }
    }

    public static func getConnectioErrorResponse(_ errorDescStr: String) -> ConnectionErrorResponse {
        _ = NSError(domain: NSURLErrorDomain,
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: errorDescStr])
        // TODO: - Need to return proper Connection Error Response
        return ConnectionErrorResponse(request: ConnectionRequest(urlString: "", method: .GET), errorConstants: .error_EXTERNAL)
    }
}
