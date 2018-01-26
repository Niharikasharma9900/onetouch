//
//  HomeTableViewController.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 09/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import RNActivityView
import EasyToast
import QRCodeReader
import AVFoundation

class HomeTableViewController: UITableViewController {

    @IBOutlet weak var lblInspName: UILabel!
    @IBOutlet weak var lblJob: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    
    var inspection : Inspection! {
        didSet {
            inspection.inspectionTypes = inspection.inspectionTypes.sorted(by: { $0.name < $1.name })

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DevelopmentMode {
            fetchZones(inspectionType: inspection.inspectionTypes[1])
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lblInspName?.text = inspection.inspName
        lblJob?.text = inspection.inspPosition
        lblCompany?.text = inspection.companyName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (inspection?.inspectionTypes.count)!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeTableCellID", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = inspection.inspectionTypes[indexPath.section].name
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = themeTinColor.cgColor
        return cell
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        fetchZones(inspectionType: inspection.inspectionTypes[indexPath.section])
    }
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "zoneSegue" {
            let zoneViewController = segue.destination as! ZoneViewController
            let data : [String:AnyObject] = sender as! [String:AnyObject]
            zoneViewController.zoneDetails = data["zoneDetails"] as! ZoneDetails!
            zoneViewController.inspectionType = data["inspectionType"] as! InspectionType!
            zoneViewController.inspection = self.inspection
        }
    }
    
    // MARK: - WebCalls
    
    func fetchZones(inspectionType : InspectionType) {
        
        self.view.endEditing(true)
        self.view.showActivityView(withLabel: "Fetching...")
        
        if Utils.isInternetAvailable() {
            
            let parameters: Parameters = ["inspectorID": inspection.id,
                                          "userID": inspection.id,
                                          "inspectionTypeID": inspectionType.id]
            
            Alamofire.request(otiGetZonesURL, method: .post, parameters: parameters, encoding: JSONEncoding.default , headers: nil)
                .responseObject { (response: DataResponse<ZonesResponse>) in
                    
                    if let zoneResponse = response.result.value {
                        
                        print(zoneResponse.status)
                        print(zoneResponse.message ?? "No msg!")
                        print(zoneResponse.zoneDetails.toJSONString(prettyPrint: true) ?? "No zone details!")

                        if (zoneResponse.SUCCESS) {
                            self.view.showActivityView(withLabel: "Success")
                            self.view.hideActivityViewWith(afterDelay: 1)
                            _ = zoneResponse.zoneDetails.commit()
                            self.performSegue(withIdentifier: "zoneSegue", sender: ["zoneDetails":zoneResponse.zoneDetails,"inspectionType":inspectionType])
                        } else {
                            self.view.showActivityView(withLabel: "Failed")
                            self.view.hideActivityViewWith(afterDelay: 1)
                        }
                    } else {
                        self.view.showActivityView(withLabel: "Something went wrong!")
                        self.view.hideActivityViewWith(afterDelay: 1)
                    }
                }.responseJSON(completionHandler: { result in
                    print("result = \(result)")
                })
            
        } else {
            
            let zoneDetails = ZoneDetails.find(inspectionTypeID: inspectionType.id)
            
            if zoneDetails != nil {
                self.view.showActivityView(withLabel: "Success")
                self.view.hideActivityViewWith(afterDelay: 0)
                self.performSegue(withIdentifier: "zoneSegue", sender: zoneDetails)
            } else {
                self.view.showToast("Inspection type not sync yet!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
                self.view.hideActivityViewWith(afterDelay: 0)
            }
        }
    }
}
