//
//  PDFLayout.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 13/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class PDFLayout: SRKObject, Mappable {
    
    dynamic var assetTypeID : NSNumber!

    dynamic var header : String!
    dynamic var footer : String!
    dynamic var validationType : String!
    dynamic var statusNotSafe : String!
    dynamic var statusSafe : String!
    dynamic var statusTempSafe : String!
    dynamic var icon : String!

    dynamic var firstSection : PDFLayoutFirstSection!
    dynamic var secondSection : PDFLayoutSecondSection!
    dynamic var thirdSection : PDFLayoutThirdSection!

    
    override init() {
        super.init()
    }
    
    required init?(map: Map){
        super.init()
    }
    
    func mapping(map: Map) {
        
        if let value = map["PDF_type_ID"].currentValue as? String {
            id = NSNumber(value: Int(value)!)
        }
        
        if let value = map["AssetTypeID"].currentValue as? String {
            assetTypeID = NSNumber(value: Int(value)!)
        }
        header <- map["Header"]
        footer <- map["Footer"]
        validationType <- map["ValidationType"]
        statusNotSafe <- map["Status_not_safe"]
        statusSafe <- map["Status_safe"]
        statusTempSafe <- map["Status_temp_safe"]
        icon <- map["Icon"]

        firstSection <- map["firstSection"]
        secondSection <- map["secondSection"]
        thirdSection <- map["thirdSection"]
    }
}
