//
//  BaseEntity.swift
//  taxiapp
//
//  Created by Jagruti on 10/14/19.
//  Copyright © 2019 ROBAB. All rights reserved.
//

import Foundation
public protocol BaseEntityProtocol {
    static func parseJSON(_ responseData: Data, options: JSONSerialization.ReadingOptions?) -> AnyObject?
    static func parse<T: Decodable>(data: Data) -> T?
    static func getJSONData<T: Encodable>(object: T) -> Data?
}
open class BaseEntity: NSObject, BaseEntityProtocol {}
extension BaseEntityProtocol {

    static func parseEscapedJson(data: Data) -> AnyObject? {
        if data.count > 0 {
            guard let encodedString = String(data: data, encoding: String.Encoding.utf8) else {
                return nil
            }
            let encodedData = Data(encodedString.utf8)

            let outerJson = try? JSONSerialization.jsonObject(with: encodedData, options: .allowFragments) as? String
            // for Order details
            guard let json = outerJson?.replacingOccurrences(of: "\t", with: "\\t") else {
                return nil
            }
            let innerEncodedData = Data(json.utf8)
            let innerJson = parseJSON(innerEncodedData, options: nil)
            return innerJson as AnyObject?
        } else {
            return nil
        }
    }

    static func parseEscapedString(string: String) -> AnyObject? {
        let encodedData = Data(string.utf8)
        let innerJson = try? JSONSerialization.jsonObject(with: encodedData, options: [])
        return innerJson as AnyObject?
    }

    public static func parseJSON(_ responseData: Data, options: JSONSerialization.ReadingOptions? = nil) -> AnyObject? {
        let jsonoptions = options ?? []
        do {
            return try JSONSerialization.jsonObject(with: responseData, options: jsonoptions) as AnyObject?
        } catch let error as NSError {
            print(error)
            return nil
        }
    }

    /// Returns an object of the type you specify, decoded from a JSON object.
    ///
    /// - Parameter data: JSON Data from an API response.
    /// - Returns: Object representation of the JSON response. Object conforms to the `Decodable` protocol.
    public static func parse<T: Decodable>(data: Data) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch DecodingError.dataCorrupted(let context) {
            print(context)

            return nil
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found: \(context.debugDescription)")
            print("codingPath:, \(context.codingPath)")
            return nil
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found: \(context.debugDescription)")
            print("codingPath: \(context.codingPath)")
            return nil
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch: \(context.debugDescription)")
            print("codingPath: \(context.codingPath)")
            return nil

        } catch {
            print("error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Returns a JSON-encoded representation of the value you supply.
    ///
    /// - Parameter object: Object which conforms to the `Encodable` protocol.
    /// - Returns: JSON data object.
    public static func getJSONData<T: Encodable>(object: T) -> Data? {
        do {
            return try JSONEncoder().encode(object)
        } catch {
            return nil
        }
    }
}
