//
//  Inspection.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 09/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class Inspection: SRKObject, Mappable {

    dynamic var inspName : String!
    dynamic var inspPosition : String!
    dynamic var companyName : String!
    dynamic var companyAddress : String!
    dynamic var companyID : NSNumber!
    var inspectionTypes : [InspectionType] = [] 
    dynamic var userEmail : String!
    dynamic var ccEmail1 : String!
    dynamic var ccEmail2 : String!
    dynamic var appType : String!
    dynamic var demoNFCTag : String!
    dynamic var userNFCTag : String!
    dynamic var startTime : NSNumber!

    override init() {
        super.init()

    }
    
    required init?(map: Map){
        super.init()
    }
    
    func mapping(map: Map) {
        
        inspName <- map["InspName"]
        inspPosition <- map["InspPosition"]
        companyName <- map["CompanyName"]
        companyAddress <- map["CompanyAddress"]
        if let value = map["CompanyID"].currentValue as? String {
            companyID = NSNumber(value: Int(value)!)
        }
        if let value = map["InspectorID"].currentValue as? String {
            id = NSNumber(value: Int(value)!)
        }
        inspectionTypes <- map["InspectionTypes"]
        userEmail <- map["UserEmail"]
        ccEmail1 <- map["CCEmail1"]
        ccEmail2 <- map["CCEmail2"]
        appType <- map["AppType"]
        demoNFCTag <- map["DemoNFCTag"]
        userNFCTag <- map["UserNFCTag"]
        if let value = map["startTime"].currentValue as? String {
            startTime = NSNumber(value: Int(value)!)
        }

    }
    
    override func commit() -> Bool {
        for item in inspectionTypes {
            print("type id : \(item.id)")
            item.inspection = self
            item.commit()
        }
        return super.commit()
    }
    
    class func find(inspectorID : NSNumber) -> Inspection? {
        
        if let inspections = Inspection.query().where(withFormat: "id = %@", withParameters: [inspectorID]).limit(1).fetch() {
            if inspections.count > 0 {
                if let inspection : Inspection = inspections.firstObject as! Inspection? {
                    if let types = InspectionType.findAll(inspection: inspection) {
                        inspection.inspectionTypes = types.flatMap({ $0 as? InspectionType })
                    }
                    return inspection
                }
                
            }
        }
        return nil
    }
}
