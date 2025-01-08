//
//  ErrorEntity.swift
//  InstntSDK
//
//  Created by Jagruti Patel CW on 12/10/21.
//

import Foundation
public enum ErrorConstants: Int {
    case error_DOCUMENT_CAPTURE
    case error_DOCUMENT_CAPTURE_CANCELLED
    case error_BARCODE_UNDETECTED
    case error_MRZ_UNDETECTED
    case error_FACE_UNDETECTED
    case error_SELFIE_CAPTURE
    case error_SETUP
    case error_FORM_SUBMIT    
    case error_UPLOAD
    case error_EXTERNAL
    case error_NO_CONNECTIVITY
    case error_NETWORK_TIMEOUT
    case error_PARSER
    case error_INVALID_OTP
    case error_INVALID_PHONE
    case error_INVALID_DATA
    case error_INVALID_TRANSACTION_ID
}

open class InstntError: Error {
    public var errorConstant: ErrorConstants
    public var message: String?
    public var statusCode: Int = 999
    public var api: String?

    public init(errorConstant: ErrorConstants, message: String? = nil, statusCode: Int = 999) {
        self.errorConstant = errorConstant
        self.message = message ?? self.getErrorMessage(errorConstant)
        self.statusCode = statusCode
    }
    func getErrorMessage(_ constant: ErrorConstants) -> String {
        var message: String = "We are experiencing technical issues, please try again later"

        switch constant {
        case .error_DOCUMENT_CAPTURE:
            message = NSLocalizedString("Error capturing document, Please try again", comment: "")
        case .error_DOCUMENT_CAPTURE_CANCELLED:
            message = NSLocalizedString("Cancelled capturing document, Please try again", comment: "")
        case .error_BARCODE_UNDETECTED:
            message = NSLocalizedString("Barcode is not detected, Please try again", comment: "")
        case .error_FACE_UNDETECTED:
            message = NSLocalizedString("Face is not detected, Please try again", comment: "")
        case .error_MRZ_UNDETECTED:
            message = NSLocalizedString("Passport MRZ is not detected, Please try again", comment: "")
        case .error_SELFIE_CAPTURE:
            message = NSLocalizedString("Error capturing selfie, please try again", comment: "")
        case .error_FORM_SUBMIT:
            message = NSLocalizedString("Error submitting form, please try again", comment: "")
        case .error_NETWORK_TIMEOUT:
            message = NSLocalizedString("Network time out", comment: "")
        case .error_EXTERNAL:
            message = NSLocalizedString("We are experiencing technical issues, please try again later", comment: "")
        case .error_PARSER:
            message = NSLocalizedString("ERROR_PARSER", comment: "")
        case .error_NO_CONNECTIVITY:
            message = NSLocalizedString("ERROR_NO_CONNECTIVITY", comment: "")
        case .error_INVALID_OTP:
            message = NSLocalizedString("The OTP is invalid, please try again", comment: "")
        case .error_INVALID_PHONE:
            message = NSLocalizedString("The Phone number is invalid, please try again", comment: "")
        case .error_UPLOAD:
            message = NSLocalizedString("Error Uploading document, please try again later.", comment: "")
        case .error_INVALID_DATA:
            message = NSLocalizedString("Invalid data, please try again later.", comment: "")
        case .error_INVALID_TRANSACTION_ID:
            message = NSLocalizedString("Invalid transactionId, please try again later.", comment: "")
        case .error_SETUP:
            message = NSLocalizedString("Invalid data.", comment: "")
            
        }

        return NSLocalizedString(message, comment: "Error Message")
    }
    
    static func parse(_ response: ConnectionResponse?, errorConstant: ErrorConstants) -> InstntError {
          var errorEntity: InstntError

          if let response = response,
              let jsonData = try? JSONSerialization.jsonObject(with: response.data as Data, options: []),
           let _ = jsonData as? NSDictionary {

              errorEntity = InstntError(errorConstant: .error_EXTERNAL)
              errorEntity.api = response.request.requestURL
          } else {
              errorEntity = InstntError(errorConstant: errorConstant)
          }

          return errorEntity
      }
}

