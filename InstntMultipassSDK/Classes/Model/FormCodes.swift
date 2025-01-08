//
//  FormCodes.swift
//  InstntSDK
//
//  Created by Nate Eckerson on 5/25/21.
//

import Foundation

//struct FormCodes {
//    private (set) var id: String
//    private (set) var title: String
//    private (set) var subtitle: String?
//    private (set) var fields: [FormField] = []
//    private (set) var submitLabel: String
//    
//    private (set) var serviceURL: String
//    private (set) var hostURL: String
//    private (set) var submitURL: String
//    private (set) var userId: Int
//    private (set) var fingerprint: String
//    private (set) var otpVerification: String
//    
//    init?(JSON: [String: Any]) {
//        guard let id = JSON["form_key_id"] as? String,
//              let title = JSON["form_title"] as? String,
//              let rows = JSON["form_json_rows"] as? [[String: Any]],
//              let submitBtnLabel = JSON["submit_btn_label"] as? String,
//              let serviceURL = JSON["backend_service_url"] as? String,
//              let hostURL = JSON["static_asset_root"] as? String,
//              let submitURL = JSON["signed_submit_form_url"] as? String,
//              let userId = JSON["user_id"] as? Int,
//              let fingerprint = JSON["fingerprintjs_browser_token"] as? String,
//              let otpVerification = JSON["otp_verification"] as? String else {
//            return nil
//        }
//        
//        self.id = id
//        self.title = title
//        self.subtitle = JSON["form_sub_title"] as? String
//        self.fields = rows.compactMap { FormField(JSON: $0) }
//        self.submitLabel = submitBtnLabel
//        
//        self.serviceURL = serviceURL
//        self.hostURL = hostURL
//        self.submitURL = submitURL
//        self.userId = userId
//        self.fingerprint = fingerprint
//        self.otpVerification = otpVerification
//    }
//}
