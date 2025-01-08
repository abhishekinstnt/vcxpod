//
//  ApiRequestDelegate.swift
//  taxiapp
//
//  Created by Jagruti on 10/13/19.
//  Copyright © 2019 ROBAB. All rights reserved.
//

import Foundation
class ApiRequestDelegate: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }

}
