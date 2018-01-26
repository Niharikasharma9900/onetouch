//
//  ZoneViewController.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 13/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import RNActivityView
import EasyToast
import QRCodeReader
import AVFoundation

class ZoneViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SubmitReportHandlerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
    })
    
    var isDemoMode: Bool = false
    
    var vehicles:[Asset]!
    
    var zoneDetails : ZoneDetails! {
        didSet {
            submit.typeID = zoneDetails.id
        }
    }
    
    var inspection : Inspection! {
        didSet {
            submit.inspectorID = inspection.id
            submit.userEmail = inspection.userEmail
            submit.companyAddress = inspection.companyAddress
            submit.startTime = NSDate()
        }
    }
    
    var inspectionType : InspectionType! {
        didSet {
            sendRequestToGetReportLayout(validationType: inspectionType.validationType)
            submit.validationType = inspectionType.validationType
        }
    }
    
    var flag : Bool = true
    
    var submit: Submit = Submit()
    var timeStamps: [ZoneTimeStamp] = [ZoneTimeStamp]()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "HH:mm:ss"
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
        
        var enable: Bool = true
        for zone in zoneDetails.zones {
            if zone.updated.intValue != 1 {
                enable = false
                break;
            }
        }
        enableBtn(btn: btnSubmit, enable: enable)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (zoneDetails?.zones.count)!
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "zoneTableCellID", for: indexPath)
        let zone = zoneDetails.zones[indexPath.row]
        cell.textLabel?.text = zone.name
        
        if zone.updated.intValue == 1 {
            var foundMajor = false
            var foundMinor = false
            var foundNormal = false
            for step in zone.steps {
                for type in step.componentTypes {
                    if type.defectID.intValue > 0 && type.defectType == "major" {
                        foundMajor = true
                        break
                    }
                    if type.defectID.intValue > 0 && type.defectType == "minor" {
                        foundMinor = true
                    }
                    if type.defectID.intValue > 0 && type.defectType == "normal" {
                        foundNormal = true
                    }
                }
            }
            if foundMajor {
                cell.backgroundColor = .red
            } else if foundMinor {
                cell.backgroundColor = .yellow
            } else if foundNormal {
                cell.backgroundColor = .green
            } else {
                cell.backgroundColor = .green
            }
        } else {
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if inspection.appType == "PILOT" || inspection.appType == "DEMO" {
            if let tag = zoneDetails.zones[indexPath.row].zoneNFCTag {
                navigateToZone(value: tag)
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "stepSegue" {
            let stepViewController = segue.destination as! StepViewController
            stepViewController.selectedZone = sender as! Zone!
        } else if segue.identifier == "summarySegue" {
            let summaryVC = (segue.destination as? UINavigationController)?.viewControllers.first as? SummaryViewController
            summaryVC?.defects = sender as! [SubmitDefect]
            summaryVC?.completion = {
                _ = self.navigationController?.popViewController(animated: false)
            }
        }

    }
    
    
    // MARK: - Utils

    func checkDemoUser() {
        if self.inspection.appType == "DEMO" {
            isDemoMode = true
            if let demoTag = inspection.demoNFCTag {
                sendRequestToGetVehicleDetails(tag: demoTag, navigate: false)
            }
        }
    }
    
    func navigateToZone(value: String) {
       
//        let filtered = zoneDetails.zones.filter { $0.zoneNFCTag == value }
//
//        if filtered.count > 0 {
//            addTimeStamp(zone: filtered.first!)
//            self.performSegue(withIdentifier: "stepSegue", sender: filtered.first)
//        } else {
//            sendRequestToGetVehicleDetails(tag: value, navigate: true)
//        }
//        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
//            self.view.showToast("Camera not detected.", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
//            
//            return
//        }
        // Or by using the closure pattern
       readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            if
                let value = result?.value {
                self.view.showToast("QR Code: "+value, position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
                let filtered = self.zoneDetails.zones.filter { $0.zoneNFCTag == result?.value}
                
                if filtered.count > 0 {
                    self.addTimeStamp(zone: filtered.first!)
                    self.performSegue(withIdentifier: "stepSegue", sender: filtered.first)
                } else {
                    self.sendRequestToGetVehicleDetails(tag: value, navigate: true)
                }
                
                self.readerVC.dismiss(animated: true, completion: nil)
            }
        }
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    func updateVehicleDetails(asset: Asset, tag: String) -> Bool {
        
        let zoneSet = NSMutableSet()
        
        zoneSet.addObjects(from: zoneDetails.zones.flatMap{ $0.zoneNameID })

        for vehicleZone in asset.tagLocations {
            if tag.caseInsensitiveCompare(vehicleZone.nfcTagID) == .orderedSame {
                if !zoneSet.contains(vehicleZone.zoneNameID) {
                    return false
                }
            }
        }

        for zone in zoneDetails.zones {
            for vehicleZone in asset.tagLocations {
                if zone.zoneNameID ==  vehicleZone.zoneNameID {
                    zone.zoneNFCTag = vehicleZone.nfcTagID
                    zone.assetID = asset.id
                    break
                }
            }
        }
        
        
        asset.inspectionTypeID = zoneDetails.id
        
        if vehicles == nil {
            vehicles = [Asset]()
        }
        vehicles.append(asset)
        return true;
    }
    
    func enableBtn(btn: UIButton, enable: Bool) {
        btn.setTitleColor((enable ? UIColor.white : UIColor.gray), for: .normal)
        btn.isUserInteractionEnabled = enable
    }
    
    func submitRecord() {
        
        self.submit.time = NSDate()
        
        if let validationType = inspectionType.validationType {
            switch validationType {
            case "preinsp":
                sendRecord()
                break
            default:
                sendRecord()
                break
            }
        }
    }
    
    func sendRecord() {
     
        if isDemoMode && submit.demoEmail.characters.count == 0 {
            askForDemoEmail()
            return
        }
        
        self.view.endEditing(true)
        self.view.showActivityView(withLabel: "Submitting...")
        
        ZoneViewControllerHelper.prepareSubmit(submit: self.submit, assets: self.vehicles, inspection: self.inspection, inspectionType: self.inspectionType, zoneDetails: self.zoneDetails)
        
        if !Utils.isInternetAvailable() {
            if self.submit.commit() {
                self.view.showToast("Report saved offline!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
//                reportSubmitted()
                self.view.hideActivityViewWith(afterDelay: 0)
            } else {
                self.view.showToast("Report saved offline!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
                self.view.hideActivityViewWith(afterDelay: 0)
            }
            return
        }
        
        let submitReportHandler: SubmitReportHandler = SubmitReportHandler()
        submitReportHandler.delegate = self
        submitReportHandler.sendRecord(submit: self.submit, timeStamps: self.timeStamps)
        
    }
    
    func askForDemoEmail() {
        
        let alertController = UIAlertController(title: "Email?", message: "Please input your email:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                if let email = field.text {
                    self.submit.demoEmail = email
                    self.sendRecord()
                }
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Skip", style: .cancel) { (_) in
            self.submit.demoEmail = " "
            self.sendRecord()
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.keyboardType = UIKeyboardType.emailAddress
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addTimeStamp(zone: Zone) {
        let timeStamp: ZoneTimeStamp = ZoneTimeStamp()
        timeStamp.inspectionType = inspectionType.id
        timeStamp.time = NSDate()
        timeStamp.timeStamp = dateFormatter.string(for: timeStamp.time)
        timeStamp.zoneNameID = zone.zoneNameID
        timeStamp.assetID = zone.assetID
        timeStamps.append(timeStamp)
    }
    
    // MARK: - Actions
    
    @IBAction func btnSubmitTapped(_ sender: Any) {
        submitRecord()
    }
    
    @IBAction func btnQRCodeTapped(_ sender: Any) {
    
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.view.showToast("Camera not detected.", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
      
            return
        }
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            
            if let value = result?.value {
                self.view.showToast("QR Code: "+value, position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
                let filtered = self.zoneDetails.zones.filter { $0.zoneNFCTag == result?.value}
                
                if filtered.count > 0 {
                    self.addTimeStamp(zone: filtered.first!)
                    self.performSegue(withIdentifier: "stepSegue", sender: filtered.first)
                } else {
                    self.sendRequestToGetVehicleDetails(tag: value, navigate: true)
                }
            
            self.readerVC.dismiss(animated: true, completion: nil)
        }
    }
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    // MARK: - WebCalls
    
    func sendRequestToGetReportLayout(validationType : String) {
        
        self.view.endEditing(true)
        self.view.showActivityView(withLabel: "Fetching report layout...")
        
        if Utils.isInternetAvailable() {
            
            let parameters: Parameters = ["validationType": validationType]
            
            Alamofire.request(otiGetReportLayoutURL, method: .post, parameters: parameters, encoding: JSONEncoding.default , headers: nil)
                .responseObject { (response: DataResponse<ReportLayoutResponse>) in
                    
                    if let layoutResponse = response.result.value {
                        
                        print(layoutResponse.status)
                        print(layoutResponse.message ?? "No msg!")
                        print(layoutResponse.layout.toJSONString(prettyPrint: true) ?? "No layout details!")
                        
                        if (layoutResponse.SUCCESS) {
                            self.view.showActivityView(withLabel: "Success")
                            self.view.hideActivityViewWith(afterDelay: 1)
                            _ = layoutResponse.layout.commit()
                            self.submit.layout = layoutResponse.layout
                            self.checkDemoUser();
                        } else {
                            self.view.showActivityView(withLabel: "Failed to get layout details")
                            self.view.hideActivityViewWith(afterDelay: 1)
                        }
                    } else {
                        self.view.showActivityView(withLabel: "Something went wrong!")
                        self.view.hideActivityViewWith(afterDelay: 1)
                    }
                }
        } else {
            
//            let zoneDetails = ZoneDetails.find(inspectionTypeID: inspectionType.id)
//            
//            if zoneDetails != nil {
//                self.view.showActivityView(withLabel: "Success")
//                self.view.hideActivityViewWith(afterDelay: 0)
//                self.performSegue(withIdentifier: "zoneSegue", sender: zoneDetails)
//            } else {
//                self.view.showToast("Inspection type not sync yet!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
//                self.view.hideActivityViewWith(afterDelay: 0)
//            }
        }
    }
    
    func sendRequestToGetVehicleDetails(tag : String, navigate: Bool) {
        
        self.view.endEditing(true)
        self.view.showActivityView(withLabel: ZoneViewControllerHelper.getAssetDetailsFetchMessage(validationType: inspectionType.validationType))
        
        if Utils.isInternetAvailable() {
            
            let parameters: Parameters = ["nfcTag": tag, "inspectorID": inspection.id]
            
            Alamofire.request(otiGetVehicleURL, method: .post, parameters: parameters, encoding: JSONEncoding.default , headers: nil)
                .responseObject { (response: DataResponse<VehicleResponse>) in
                    
                    if let vehicleResponse = response.result.value {
                        
                        print(vehicleResponse.status)
                        print(vehicleResponse.message ?? "No msg!")
                        print(vehicleResponse.asset.toJSONString(prettyPrint: true) ?? "No asset details!")
                        
                        if (vehicleResponse.SUCCESS) {
//                            self.view.showActivityView(withLabel: "Success")
                            self.view.hideActivityViewWith(afterDelay: 1)
                            if self.updateVehicleDetails(asset: vehicleResponse.asset, tag: tag) {
                                
                                if DevelopmentMode {
                                    for zone in self.zoneDetails.zones {
                                        for step in zone.steps {
                                            for compType in step.componentTypes {
                                                compType.modelValue = String(compType.modelDataMax.doubleValue-1)
                                                compType.modelValueRecorded = true
                                            }
                                        }
                                        zone.updated = 1
                                    }
                                }
                                
                                if navigate {
                                  self.navigateToZone(value: tag)
                                 //   self.btnQRCodeTapped(AnyObject.self)
                                }

                            } else {
                                self.view.showToast("Tag not matching with zone.", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
//                                self.view.showActivityView(withLabel: "Tag not matching with zone.")
                                self.view.hideActivityViewWith(afterDelay: 1)
                            }
                        } else {
                            self.view.showActivityView(withLabel: "Failed to get asset details")
                            self.view.hideActivityViewWith(afterDelay: 1)
                        }
                    } else {
                        self.view.showActivityView(withLabel: "Something went wrong!")
                        self.view.hideActivityViewWith(afterDelay: 1)
                    }
            }
        } else {
            
            //            let zoneDetails = ZoneDetails.find(inspectionTypeID: inspectionType.id)
            //
            //            if zoneDetails != nil {
            //                self.view.showActivityView(withLabel: "Success")
            //                self.view.hideActivityViewWith(afterDelay: 0)
            //                self.performSegue(withIdentifier: "zoneSegue", sender: zoneDetails)
            //            } else {
//                            self.view.showToast("Inspection type not sync yet!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            //                self.view.hideActivityViewWith(afterDelay: 0)
            //            }
        }
    }
    
    
    // MARK: - SubmitReportHandlerDelegate

    func reportSubmitted(defects: [SubmitDefect]) {
        self.performSegue(withIdentifier: "summarySegue", sender: defects)
    }
    
    func reportSubmitError(message: String){
        self.view.showActivityView(withLabel: "Something went wrong!")
        self.view.hideActivityViewWith(afterDelay: 1)
    }
}
