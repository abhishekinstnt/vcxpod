//
//  DocumentVerification.swift
//  InstntSDK
//
//  Created by Jagruti Patel CW on 12/21/21.
//

import Foundation

struct CreateTransaction: Encodable {
    let formKey: String
    let hideFormFields: Bool
    let idmetricsVersion, format: String
    let redirect: Bool
    

    enum CodingKeys: String, CodingKey {
        case formKey = "form_key"
        case hideFormFields = "hide_form_fields"
        case idmetricsVersion = "idmetrics_version"
        case format, redirect
    }
}


struct ReInitializeTransaction: Encodable {
    let formKey: String
    let hideFormFields: Bool
    let idmetricsVersion, format: String
    let redirect: Bool
    let instnttxnid: String
    

    enum CodingKeys: String, CodingKey {
        case formKey = "form_key"
        case hideFormFields = "hide_form_fields"
        case idmetricsVersion = "idmetrics_version"
        case format, redirect
        case instnttxnid
    }
}

struct ResultCreateTransaction: Decodable {
    let instnttxnid: String
    let otp_verification: Bool
    let fingerprintjs_browser_token: String
    let backend_service_url: String
    let signed_submit_form_url: String
    let document_verification: Bool
    let behaviosec_api_url: String?
    let behaviosec_tenant_id: String
    
    public init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        instnttxnid = try values.decode(String.self, forKey: .instnttxnid)
        otp_verification = try values.decode(Bool.self, forKey: .otp_verification)
        document_verification = try values.decode(Bool.self, forKey: .document_verification)
        fingerprintjs_browser_token = try values.decode(String.self, forKey: .fingerprintjs_browser_token)
        backend_service_url = try values.decode(String.self, forKey: .backend_service_url)
        signed_submit_form_url = try values.decode(String.self, forKey: .signed_submit_form_url)
        behaviosec_api_url = try values.decodeIfPresent(String.self, forKey: .behaviosec_api_url)
        behaviosec_tenant_id = try values.decode(String.self, forKey: .behaviosec_tenant_id)
    }
    
    enum CodingKeys: String, CodingKey {
        case instnttxnid
        case otp_verification
        case fingerprintjs_browser_token
        case backend_service_url
        case signed_submit_form_url
        case document_verification
        case behaviosec_api_url
        case behaviosec_tenant_id
    }
}

struct RequestGetUploadUrl: Encodable {
    let transactionType: String
    let documentType: String
    let docSuffix: String
    let transactionStatus: String    

    enum CodingKeys: String, CodingKey {
        case transactionType = "transaction_attachment_type"
        case documentType = "document_type"
        case docSuffix = "doc_suffix"
        case transactionStatus = "transaction_status"
    }
}

struct VerifyDocument: Encodable {
    let formKey, documentType, instnttxnid: String
}

struct ResultverifyDocument: Decodable {
    
}

struct RequestSendOTP: Encodable {
    let phone: String
}

struct ResultSendOTP: Decodable {
    let response: Response
    struct Response: Codable {
        let id: String
        let errors: [String]
        let valid: Bool
    }
}

struct RequestVerifyOTP: Encodable {
    let phone: String
    let is_verify: Bool
    let otp: String
   
}

struct ResultVerifyOTP: Decodable {
    let response: Response
    struct Response: Codable {
        let id: String
        let errors: [String]
        let valid: Bool
    }
    
}
