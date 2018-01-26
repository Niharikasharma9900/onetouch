//
//  PDFLayoutFirstSection.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 13/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class PDFLayoutFirstSection: SRKObject, Mappable {
    
    dynamic var pdfTypeID : NSNumber!
    dynamic var assetTypeID : NSNumber!
    
    dynamic var headerType : String!
    dynamic var companyName : String!
    dynamic var userName : String!
    dynamic var position : String!
    dynamic var readingType : String!
    dynamic var employeeID : String!
    dynamic var location : String!
    dynamic var startTime : String!
    dynamic var endTime : String!
    dynamic var totalTime : String!
    
    
    override init() {
        super.init()
    }
    
    required init?(map: Map){
        super.init()
    }
    
    func mapping(map: Map) {
        
        if let value = map["id"].currentValue as? String {
            id = NSNumber(value: Int(value)!)
        }
        if let value = map["PDF_type_ID"].currentValue as? String {
            pdfTypeID = NSNumber(value: Int(value)!)
        }
        if let value = map["AssetTypeID"].currentValue as? String {
            assetTypeID = NSNumber(value: Int(value)!)
        }
        headerType <- map["HeaderType"]
        companyName <- map["CompanyName"]
        userName <- map["UserName"]
        position <- map["Position"]
        readingType <- map["ReadingType"]
        employeeID <- map["EmployeeID"]
        location <- map["Location"]
        startTime <- map["StartTime"]
        endTime <- map["EndTime"]
        totalTime <- map["TotalTime"]

    }
}
