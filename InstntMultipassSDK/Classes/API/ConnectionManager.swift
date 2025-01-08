//
//  ConnectionManager.swift
//  taxiapp
//
//  Created by Jagruti on 10/14/19.
//  Copyright © 2019 ROBAB. All rights reserved.
//

import Foundation
class ConnectionManager: NSObject {

    var httpRequestTimeout: TimeInterval = 45

    typealias ConnectionSuccessBlock = (ConnectionResponse) -> Void
    typealias ConnectionFailureBlock = (ConnectionErrorResponse) -> Void
    typealias ConnectionBlocks = (successBlock: ConnectionSuccessBlock, failureBlock: ConnectionFailureBlock)
    static var ConnectionRequests: [String: [ConnectionBlocks]] = [String: [ConnectionBlocks]]()
    public func sendRequest(_ connectionRequest: ConnectionRequest, success: @escaping (ConnectionResponse) -> Void, failure: @escaping (ConnectionErrorResponse) -> Void) {


        let connectionString: String = connectionRequest.requestURL + connectionRequest.httpMethod.rawValue
        if isApiCallInProgress(connectionString, successBlock: success, failureBlock: failure) {
            return
        }

        addCustomHeaders(connectionRequest)
        let httpRequest = HttpUtils(request: connectionRequest)
        httpRequest.timeoutSeconds = httpRequestTimeout

        _ = httpRequest.startRequest({ (connectionResponse) -> Void in
            self.informSuccess(connectionString, connectionResponse: connectionResponse)
        },
        failure: { (connectionErrorResponse) -> Void in
            self.informFailure(connectionString, connectionErrorResponse: connectionErrorResponse)
        })
    }

    open func addCustomHeaders(_ request: ConnectionRequest) {

        request.requestCustomHeaders["Content-Type"] = request.requestContentType.type as AnyObject?

        // Override this call to add your custom headers.
    }

    private func isApiCallInProgress(
        _ url: String,
        successBlock: @escaping ConnectionSuccessBlock,
        failureBlock: @escaping ConnectionFailureBlock) -> Bool {
        guard var _ = ConnectionManager.ConnectionRequests[url] else {
            var connectionBlocks: [ConnectionBlocks] = [ConnectionBlocks]()
            connectionBlocks.append((successBlock, failureBlock))
            ConnectionManager.ConnectionRequests[url] = connectionBlocks

            return false
        }

        ConnectionManager.ConnectionRequests[url]!.append((successBlock, failureBlock))

        return true
    }

    private func informSuccess(_ url: String, connectionResponse: ConnectionResponse) {
        guard let apiRequests = ConnectionManager.ConnectionRequests[url] else {
            return
        }

        for request in apiRequests {
            DispatchQueue.main.async {
                request.successBlock(connectionResponse)
            }
        }

        ConnectionManager.ConnectionRequests[url] = nil
    }

    private func informFailure(_ url: String, connectionErrorResponse: ConnectionErrorResponse) {
        guard let apiRequests = ConnectionManager.ConnectionRequests[url] else {
            return
        }

        for request in apiRequests {
            DispatchQueue.main.async {
                request.failureBlock(connectionErrorResponse)
            }
        }

        ConnectionManager.ConnectionRequests[url] = nil
    }
}
