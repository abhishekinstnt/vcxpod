//
//  HttpUtils.swift
//  taxiapp
//
//  Created by Jagruti on 10/13/19.
//  Copyright © 2019 ROBAB. All rights reserved.
//

import Foundation
let baseUrl = "http://api.qafilah.sa/mobile/CustomerAppServices.svc/"
public enum HttpMethod: String {
    case GET, POST, PUT
}
public enum ConfigurationType {
    case `default`, ephemeral, background
}
public enum ContentType {
    case json
    case pdf
    case form
    case xml_UTF8
    case jsonV1

    public var type: String {
        switch self {
        case .json:
            return "application/json"
        case .pdf:
            return "application/pdf"
        case .xml_UTF8:
            return "text/xml; charset=utf-8"
        case .form:
            return "application/x-www-form-urlencoded"
        case .jsonV1:
            return "application/v1.0+json"
        }
    }
}

public enum HttpHeaderString: String {
    case CONTENT_TYPE = "Content-Type"
    case CONTENT_LENGTH = "Content-Length"
    case AUTHORIZATION = "Authorization"
}

public enum HttpStatusCode: Int {
    case badRequest = 400
    case authorizationFailed = 401
    case forbidden = 403
    case notFound = 404
    case unprocessableEntity = 422
    case temporaryRedirect = 302
    case permanentRedirect = 301
    case partialSuccess = 207
}

class HttpUtils: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    var configurationType: ConfigurationType

    private let baseURL: String
    var cache: NSCache<AnyObject, AnyObject>
    var rawPOSTData: Data?
    var requestHeaders = [String: AnyObject?]()
    var timeoutSeconds: TimeInterval?
    var connectionRequest: ConnectionRequest
    init(request: ConnectionRequest) {
        connectionRequest = request
        baseURL = request.requestURL
        configurationType = request.configurationType
        cache = NSCache()
        if request.postData != nil {
            rawPOSTData = request.postData! as Data
        }
        requestHeaders = request.requestCustomHeaders
    }
    lazy var session: URLSession = {
        [weak self] in
        URLSession(
            configuration: self?.sessionConfiguration() ?? .default,
            delegate: ApiRequestDelegate(),
            delegateQueue: OperationQueue.current)
    }()

    public enum ResponseStatusCodeType {
        case successful, redirection, clientError, serverError, unknown
    }

    func sessionConfiguration() -> URLSessionConfiguration {
        switch configurationType {
        case .default:
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
            configuration.urlCache = nil
            configuration.httpShouldSetCookies = false
            return configuration
        case .ephemeral:
            return URLSessionConfiguration.ephemeral
        case .background:
            return URLSessionConfiguration.background(withIdentifier: "NetworkingBackgroundConfiguration")
        }
    }
    func createRequest(_ connectionRequest: ConnectionRequest) -> NSMutableURLRequest? {
        guard let encoded = connectionRequest.requestURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) else {
            return nil
        }
        let urlRequest = NSMutableURLRequest(url: url)
        // setHttp Method
        urlRequest.httpMethod = connectionRequest.httpMethod.rawValue

        if let timeoutInterval = timeoutSeconds {
            urlRequest.timeoutInterval = timeoutInterval
        }

        // Set custom headers for the request
        for (key, value) in connectionRequest.requestCustomHeaders {
            urlRequest.addValue(value as! String, forHTTPHeaderField: key)
        }

        // Adding Post Data
        if let postData = rawPOSTData {
            urlRequest.addValue(NSString(format: "%u", postData.count) as String, forHTTPHeaderField: HttpHeaderString.CONTENT_LENGTH.rawValue)
            
            urlRequest.httpBody = postData
        }

        // Adding Post dictionary if available
        if connectionRequest.postDictionary.count > 0 {
            if let finalDict = connectionRequest.postDictionary.removeBackSpaceString() {
                connectionRequest.postDictionary = finalDict
            }

            // TODO: change encoding based on backend api's
            if connectionRequest.requestContentType == .json {
                do {
                    let formattedParameters = try JSONSerialization.data(withJSONObject: connectionRequest.postDictionary, options: .prettyPrinted)
                    urlRequest.httpBody = formattedParameters
                } catch {
                    urlRequest.httpBody = nil
                }
            } else { // DATA
                let formattedParameters = connectionRequest.postDictionary.formURLEncodedFormat()
                urlRequest.httpBody = formattedParameters.data(using: String.Encoding.utf8)
            }
        }
        return urlRequest
    }
    func startRequest(_ success: @escaping (_ connectionResponse: ConnectionResponse) -> Void, failure: @escaping (_ connectionErrorReponse: ConnectionErrorResponse) -> Void) -> String {
           let requestID = UUID().uuidString

           guard let request = createRequest(connectionRequest) else {
               failure(ConnectionErrorResponse(request: connectionRequest, errorConstants: ErrorConstants.error_EXTERNAL))
               return ""
           }


           logConnectionRequest(request)

           showNetworkActivityIndicator(true)

           let session = self.session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

               self.showNetworkActivityIndicator(false)

               if let connectionError = error {
                   var errConst = ErrorConstants.error_EXTERNAL
                   if connectionError._code == NSURLErrorTimedOut {
                       errConst = ErrorConstants.error_NETWORK_TIMEOUT
                   }

                   failure(ConnectionErrorResponse(request: self.connectionRequest, errorConstants: errConst))

                   self.logError(request as URLRequest, error: connectionError as NSError?)
                   return
               }

               if let httpResponse = response as? HTTPURLResponse {
                   var responseData: Data = Data()
                   var responseHeaders = [String: AnyObject]()

                   if let headers = httpResponse.allHeaderFields as? [String: AnyObject] {
                       responseHeaders = headers
                   }

                   if let data = data, data.count > 0 {
                       responseData = data
                   }

                   self.logConnectionResponse(data, response: response)

                   if httpResponse.statusCode.statusCodeType() == .successful {
                       success(ConnectionResponse(request: self.connectionRequest, status: httpResponse.statusCode, response: responseData, headers: responseHeaders))
                   } else {
                       let response = ConnectionResponse(request: self.connectionRequest, status: httpResponse.statusCode, response: responseData, headers: responseHeaders)
                       let errorConstant: ErrorConstants = ErrorConstants.error_EXTERNAL

                       failure(ConnectionErrorResponse(request: self.connectionRequest, errorConstants: errorConstant, connectionResponse: response))
                   }
               }
           })
           session.taskDescription = requestID
           session.resume()
           return requestID
    }
    private func logConnectionRequest(_ request: NSMutableURLRequest) {
        var url: String = "none"
        let method: String = request.httpMethod
        var headers: String = ""
        var requestBody: String = "none"

        if let postData = request.httpBody,
            let requestBodyString = String(data: postData, encoding: String.Encoding.utf8) {
            requestBody = requestBodyString
        }

        if let urlObject = request.url {
            url = urlObject.absoluteString
        }

        if let headerDictionary = request.allHTTPHeaderFields {
            for header in headerDictionary {
                headers += "\(header)\n"
            }
        } else {
            headers = "none\n"
        }

        let requestString = "\n==========================\nHTTP Request:\nURL: " + url + "\n" +
            "Method: " + method + "\n" +
            "Headers: " + "\n" +
            headers +
            "Body: " +
            requestBody + "\n==========================\n"

        print(requestString)
    }

    func logConnectionResponse(_ data: Data?, response: URLResponse?) {
        var url: String = "none"
        var code: Int = 0
        var responseStr: String = ""
        var headers: String = ""
        var httpTitle: String = "HTTP Success"

        if let response = response as? HTTPURLResponse {
            if let urlObject = response.url {
                url = urlObject.absoluteString
            }

            code = response.statusCode

            if code.statusCodeType() != .successful {
                httpTitle = "HTTP Failure"
            }

            if let headerDictionary = response.allHeaderFields as? [String: AnyObject] {
                for header in headerDictionary where header.0 != "Accept-Charset" {
                    headers += "\(header)\n"
                }
            } else {
                headers = "none\n"
            }
        }

        if let data = data, data.count > 0 {
            if let encodedString = String(data: data, encoding: String.Encoding.utf8) {
                responseStr = encodedString
            }
        }

        let responseString = "\n==========================\n" +
            httpTitle +
            "\nURL: " + url + "\n" +
            "StatusCode: " + "\(code)" + "\n" +
            "Headers: " + "\n" +
            headers +
            "Body: " +
            responseStr + "\n==========================\n"

        print(responseString)
    }
    func logError(_ request: URLRequest?, error: NSError?) {
        guard let error = error else { return }

        var url: String = "none"

        if let request = request, let urlObject = request.url {
            url = urlObject.absoluteString
        }

        let isCancelled = error.code == -999
        if isCancelled {
            if let request = request, let url = request.url {
                print("Cancelled request: \(url)")
            }
        } else {
            print("Request: \(url)\n Error Code: \(error.code)\n Error message: \(error.localizedDescription)\n")
        }
    }
    
    private func showNetworkActivityIndicator(_ show: Bool) {
        DispatchQueue.main.async {
            NetworkActivityIndicator.sharedIndicator.visible = show
        }
    }

}

extension Int {
    func statusCodeType() -> HttpUtils.ResponseStatusCodeType {
        if self >= 200 && self < 300 {
            return .successful
        } else if self >= 300 && self < 400 {
            return .redirection
        } else if self >= 400 && self < 500 {
            return .clientError
        } else if self >= 500 && self < 600 {
            return .serverError
        } else {
            return .unknown
        }
    }
}

extension Dictionary {
    public func toString() -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self)
            guard let string = String(data: data, encoding: String.Encoding.utf8) else {
                return nil
            }
            return string
        } catch let error {
            print("Converting Dictionary to String Failed \(error.localizedDescription)")
        }
        return nil
    }

    func removeBackSpaceString() -> [String: AnyObject]? {
        guard var string = self.toString() else {
            return nil
        }

        let noBrakeSpaceString: String = "\u{00a0}"
        string = string.replacingOccurrences(of: noBrakeSpaceString, with: " ")

        guard let finalDictionary = string.toDictionary() else {
            return nil
        }

        return finalDictionary
    }
    public func formURLEncodedFormat() -> String {
        var converted = ""
        for (index, entry) in enumerated() {
            if index > 0 {
                converted.append("&")
            }
            converted.append("\(entry.0)=\(entry.1)")
        }

        guard let encodedParameters = converted.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { fatalError("Couldn't convert parameters to form url: \(converted)") }
        return encodedParameters
    }
}

extension String {
    func toDictionary() -> [String: AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch let error {
                print("Converting String to Dictionary Failed \(error.localizedDescription)")
            }
        }
        return nil
    }
}
