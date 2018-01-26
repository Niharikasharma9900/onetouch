//
//  PDFLayoutSecondSection.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 13/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class PDFLayoutSecondSection: SRKObject, Mappable {
    
    dynamic var pdfTypeID : NSNumber!
    dynamic var assetTypeID : NSNumber!
    
    dynamic var headerType : String!
    dynamic var assetType : String!
    dynamic var make : String!
    dynamic var model : String!
    dynamic var year : String!
    dynamic var vinSerial : String!
    dynamic var itemNumber : String!
    dynamic var zoneName : String!
    dynamic var totalComponentTypes : String!
    dynamic var summary : String!
    dynamic var noDefects : String!
    dynamic var defectsFound : String!
    dynamic var stateProvince : String!

    
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
        assetType <- map["AssetType"]
        make <- map["Make"]
        model <- map["Model"]
        year <- map["Year"]
        vinSerial <- map["VIN_Serial"]
        itemNumber <- map["ItemNumber"]
        zoneName <- map["ZoneName"]
        totalComponentTypes <- map["Total_ComponentTypes"]
        summary <- map["Summary"]
        noDefects <- map["No_defects"]
        defectsFound <- map["Defects_found"]
        stateProvince <- map["StateProvince"]

    }
}

