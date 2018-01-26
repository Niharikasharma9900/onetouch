//
//  PDFLayoutThirdSection.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 13/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class PDFLayoutThirdSection: SRKObject, Mappable {
    
    dynamic var pdfTypeID : NSNumber!
    dynamic var assetTypeID : NSNumber!
    
    dynamic var headerType : String!
    dynamic var zoneName : String!
    dynamic var issueArea : String!
    dynamic var defectIdentified : String!
    dynamic var defectType : String!
    dynamic var regulationCode : String!
    dynamic var photoTaken : String!
    dynamic var audioRecorded : String!
    dynamic var modelValue : String!
    dynamic var modelDefectType : String!
    
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
        zoneName <- map["ZoneName"]
        issueArea <- map["IssueArea"]
        defectIdentified <- map["Defect_Identified"]
        defectType <- map["DefectType"]
        regulationCode <- map["RegulationCode"]
        photoTaken <- map["PhotoTaken"]
        audioRecorded <- map["AudioRecorded"]
        modelValue <- map["ModelValue"]
        modelDefectType <- map["ModelDefectType"]
    }
}



