//
//  SignInViewController.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 23/11/16.
//  Copyright © 2016 BeaconTree. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import RNActivityView
import EasyToast
import QRCodeReader
import AVFoundation

class SignInViewController: ViewController {

    @IBOutlet weak var txtUserID: UITextField!
    
    lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
    })
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let list = Inspection.query().fetch()
        print("list = \(list?.count)")
        
        if DevelopmentMode {
            doSignIn()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "homeSegue" {
            let homeTableViewController = segue.destination as! HomeTableViewController
            homeTableViewController.inspection = sender as! Inspection!
        }
    }
 

    
    // MARK: - Actions

    @IBAction func btnSignInTapped(_ sender: Any) {
        doSignIn()
    }
    
    @IBAction func btnQRCodeTapped(_ sender: Any) {
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.view.showToast("Camera not detected.", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            return
        }
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            if let value = result?.value {
                self.txtUserID.text = value
            }
            self.readerVC.dismiss(animated: true, completion: nil)
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    // MARK: - WebCalls

    func doSignIn() {
        
        if txtUserID.text == nil || txtUserID.text?.characters.count == 0 {
            self.view.showToast("Please Enter InspectionID.", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            return
        }
        self.view.endEditing(true)
        self.view.showActivityView(withLabel: "Logging in...")

        if Utils.isInternetAvailable() {
            
            let parameters: Parameters = ["inspectorID": txtUserID.text!]
            
            Alamofire.request(otiSignInURL, method: .post, parameters: parameters, encoding: JSONEncoding.default , headers: nil)
                .responseObject { (response: DataResponse<LoginResponse>) in
                    
                    if let loginResponse = response.result.value {
                        
                        print(loginResponse.status)
                        print(loginResponse.message ?? "No msg!")
                        
                        if (loginResponse.SUCCESS) {
                            self.view.showActivityView(withLabel: "Success")
                            self.view.hideActivityViewWith(afterDelay: 1)
                            _ = loginResponse.inspection.commit()
                            self.performSegue(withIdentifier: "homeSegue", sender: loginResponse.inspection)
                        } else {
                            self.view.showActivityView(withLabel: "Failed")
                            self.view.hideActivityViewWith(afterDelay: 1)
                        }
                    } else {
                        self.view.showActivityView(withLabel: "Something went wrong!")
                        self.view.hideActivityViewWith(afterDelay: 1)
                    }
            }
            
        } else {
            
            let inspectorID = NSNumber(value: Int(txtUserID.text!)!)
            
            let inspection = Inspection.find(inspectorID: inspectorID)
                
            if inspection != nil {
                self.view.showActivityView(withLabel: "Success")
                self.view.hideActivityViewWith(afterDelay: 1)
                self.performSegue(withIdentifier: "homeSegue", sender: inspection)
            } else {
                self.view.showToast("User not sync yet!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
                self.view.hideActivityViewWith(afterDelay: 0)
            }
        }
    }
}
