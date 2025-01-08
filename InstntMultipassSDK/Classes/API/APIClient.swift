//
//  APIClient.swift
//  InstntSDK
//
//  Created by Nate Eckerson on 5/25/21.
//

import UIKit
import AVFoundation

public protocol ScanDelegate: NSObjectProtocol {
    func onScanFinish(captureResult: String)
    func onScanCancelled(error: InstntError)
    func onScanFailed(error: InstntError)
    func onScanError(error: InstntError)
}

class APIClient: NSObject {
    static let shared = APIClient()
    var baseEndpoint: String = ""
    var isSandbox: Bool = false
    var formKey = ""
    
    weak var delegate: ScanDelegate? = nil
    
    weak var delegateVC: UIViewController? = nil
    
    let session = AVCaptureSession()
    
    private override init() {
        super.init()
    }
    

    // MARK: - init
    func initialize() {
        
        print("initialize method called on SDK APIClient class")
        
    }
    
    func GetCredentialById(cID: String) {
        
        // TODO
        
    }
    
    func ProposeCredentialOffer() {
        
        // TODO
        
    }
    
    func AcceptCredentialOffer(myData: [String : Any]) {
        
        let myVCModel = MultipassVCModel.init(VCData: myData)
        
        var myVCModelList: [MultipassVCModel] = []
        
        if let contentData = UserDefaults.standard.object(forKey: "myVCModelList") as? Data {
            myVCModelList = try! JSONDecoder().decode([MultipassVCModel].self, from: contentData)
        }
        
        myVCModelList.append(myVCModel)
        
        if let contentData = try? JSONEncoder().encode(myVCModelList) {
            UserDefaults.standard.set(contentData, forKey: "myVCModelList")
        }
        
    }
    
    func getCredentials() -> [MultipassVCModel] {
        
        var myVCModelList: [MultipassVCModel] = []
        
        if let contentData = UserDefaults.standard.object(forKey: "myVCModelList") as? Data {
            myVCModelList = try! JSONDecoder().decode([MultipassVCModel].self, from: contentData)
        }
        
        return myVCModelList
        
    }
    
    func DeleteCredentialById(VCtoDelete: MultipassVCModel) {
        
        var myVCModelList: [MultipassVCModel] = []
        
        if let contentData = UserDefaults.standard.object(forKey: "myVCModelList") as? Data {
            myVCModelList = try! JSONDecoder().decode([MultipassVCModel].self, from: contentData)
            print(myVCModelList)
        }
        
        var indx = 0
        for eachVC in myVCModelList {
            if eachVC.firstName == VCtoDelete.firstName && eachVC.VCID == VCtoDelete.VCID {
                myVCModelList.remove(at: indx)
            }
            indx = indx + 1
        }
        
        if let contentData = try? JSONEncoder().encode(myVCModelList) {
            print(myVCModelList)
            UserDefaults.standard.set(contentData, forKey: "myVCModelList")
        }
        
    }
    
    func ScanCredentials(from vc: UIViewController, delegate:ScanDelegate) {
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            let output = AVCaptureMetadataOutput()

            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            session.addInput(input)
            session.addOutput(output)
            
            output.metadataObjectTypes = [.qr]
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = vc.view.bounds
            previewLayer.accessibilityLabel = "scanLayer"
            
            vc.view.layer.addSublayer(previewLayer)
            
            let cancelView = UILabel.init(frame: CGRect(x: 0, y: vc.view.frame.height-100, width: vc.view.frame.width, height: 55))
            
            cancelView.text = "Cancel"
            cancelView.backgroundColor = UIColor.init(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 0.5))
            cancelView.textAlignment = .center
            cancelView.textColor = .white
            
            let cancelBtnTap = UITapGestureRecognizer(target: self, action: "cancelBtnTapped:")
            
            cancelView.isUserInteractionEnabled = true
            cancelView.addGestureRecognizer(cancelBtnTap)
            
            cancelView.accessibilityLabel = "scanLayerCancel"
            vc.view.addSubview(cancelView)
            
            delegateVC = vc
            
            self.delegate = delegate
            
            session.startRunning()
        } catch {

            //showAlert()
            print(error)
        }
        
    }
    
    @objc func cancelBtnTapped(_ sender:UITapGestureRecognizer) {
                
        if let inputs = session.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                session.removeInput(input)
            }
        }
        
        if let outputs = session.outputs as? [AVCaptureOutput] {
            for output in outputs {
                session.removeOutput(output)
            }
        }
        
        delegateVC?.view.layer.sublayers?.forEach {
            if $0.accessibilityLabel == "scanLayer" {
                $0.removeFromSuperlayer()
            }
        }
        
        delegateVC?.view.subviews.forEach {
            if $0.accessibilityLabel == "scanLayerCancel" {
                $0.removeFromSuperview()
            }
        }
        
    }
    
    // MARK: - set up camera

    /*
    func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            let output = AVCaptureMetadataOutput()

            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            session.addInput(input)
            session.addOutput(output)
            
            output.metadataObjectTypes = [.qr]
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = delegate.view.bounds
            
            view.layer.addSublayer(previewLayer)
            
            session.startRunning()
        } catch {

            showAlert()
            print(error)
        }
    }*/

    // MARK: - Alert

    /*
    func showAlert() {
            let alert = UIAlertController(title: Constants.alertTitle,
                                          message: Constants.alertMessage,
                                          preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.alertButtonTitle,
                                      style: .default))
        present(//alert, animated: true)
            }
     */
    
    private enum Constants {
        static let alertTitle = "Scanning is not supported"
        static let alertMessage = "Your device does not support scanning a code from an item. Please use a device with a camera."
        static let alertButtonTitle = "OK"
    }
    
}

extension APIClient: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let stringValue = metadataObject.stringValue else { return }
        
        //print(stringValue)
        
        self.cancelBtnTapped(UITapGestureRecognizer.init())

        /*
        delegateVC?.view.layer.sublayers?.forEach {
            if $0.accessibilityLabel == "scanLayer" {
                print("cancelBtnTapped4")
                $0.removeFromSuperlayer()
            }
        }*/
        
        delegate?.onScanFinish(captureResult: stringValue)
        
    }
}

extension APIClient: ScanDelegate {
    
    public func onScanFinish(captureResult: String) {
        
        print("step 2")
        
        delegate?.onScanFinish(captureResult: captureResult)
        
        /*
        delegateVC?.view.layer.sublayers?.forEach {
            print("cancelBtnTapped5")
            $0.removeFromSuperlayer()
        }*/

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
