//
//  Encodable+Extension.swift
//  InstntSDK
//
//  Created by Jagruti Patel CW on 12/20/21.
//

import Foundation
extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}
