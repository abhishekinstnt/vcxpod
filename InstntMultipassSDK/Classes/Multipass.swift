//
//  Instnt.swift
//  InstntSDK
//
//  Created by Nate Eckerson on 5/25/21.
//

import UIKit
import SVProgressHUD

public protocol MultipassScanDelegate: NSObjectProtocol {
    func onScanFinish(captureResult: String)
    func onScanCancelled(error: InstntError)
    func onScanFailed(error: InstntError)
    func onScanError(error: InstntError)
}

public class Multipass: NSObject {
    
    public static let shared = Multipass()
    
    public weak var delegate: MultipassScanDelegate? = nil
    
    private (set) var userID: String = ""
    
    public func InitializeMultipass(with userID: String) {
                
        print("initialize method called on SDK public class")
        
        APIClient.shared.initialize()
        
    }
    
    public func GetCredentialById(cID: String) {
        
        APIClient.shared.GetCredentialById(cID: cID)
        
    }
    
    public func ProposeCredentialOffer() {
        
        APIClient.shared.ProposeCredentialOffer()
        
    }
    
    public func AcceptCredentialOffer(myData: [String : Any]) {
        
        APIClient.shared.AcceptCredentialOffer(myData: myData)
        
    }
    
    public func getCredentials() -> [MultipassVCModel] {
        
       return APIClient.shared.getCredentials()
        
    }
    
    public func DeleteCredentialById(VC: MultipassVCModel) {
        
        APIClient.shared.DeleteCredentialById(VCtoDelete: VC)
        
    }
    
    public func ScanCredentials(multipassID: String, from vc: UIViewController) {
                
        APIClient.shared.ScanCredentials(from: vc, delegate: self)
        
    }

}

extension Multipass: ScanDelegate {
    
    public func onScanFinish(captureResult: String) {
                
        delegate?.onScanFinish(captureResult: captureResult)
        
    }
    
    public func onScanCancelled(error: InstntError) {
        self.delegate?.onScanCancelled(error: error)
        print("scan error \(String(describing: error.message))")
        print(error)
    }
    
    public func onScanFailed(error: InstntError) {
        self.delegate?.onScanFailed(error: error)
    }
    
    public func onScanError(error: InstntError) {
        self.delegate?.onScanError(error: error)
    }
    
}
