//
//  MultipassVCModel.swift
//  ActionSheetPicker-3.0
//
//  Created by Abhishek Darak on 13/06/24.
//

import Foundation

public struct MultipassVCModel : Codable {
    
    public var VCID: String?
    public var VCImg: String?
    public var firstName: String?
    public var surName: String?
    public var mobileNumber: String?
    public var email: String?
    public var physicalAddress: String?
    public var city: String?
    public var state: String?
    public var country: String?
    public var zip: String?
    public var nationalId: String?
    
    enum CodingKeys: String, CodingKey {
        case VCID
        case VCImg
        case firstName
        case surName
        case mobileNumber
        case email
        case physicalAddress
        case city
        case state
        case country
        case zip
        case nationalId
    }

    init(VCData:  [String : Any]) {
        print(VCData)
        self.VCID = VCData["VCID"] as? String
        self.VCImg = VCData["VCImg"] as? String
        self.firstName = VCData["firstName"] as? String
        self.surName = VCData["surName"] as? String
        self.physicalAddress = VCData["physicalAddress"] as? String
        self.nationalId = VCData["nationalId"] as? String
        self.city = VCData["city"] as? String
        self.state = VCData["state"] as? String
        self.country = VCData["country"] as? String
        self.email = VCData["email"] as? String
        self.mobileNumber = VCData["mobileNumber"] as? String
        self.zip = VCData["zip"] as? String
        self.nationalId = VCData["nationalId"] as? String
    }
    
}

