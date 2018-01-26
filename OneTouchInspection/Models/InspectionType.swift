//
//  InspectionType.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 09/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class InspectionType: SRKObject, Mappable {

    dynamic var name : String!
    dynamic var typeDescription : String!
    dynamic var companyID : NSNumber!
    dynamic var validationType : String!
    
    dynamic var inspection : Inspection!
    
    override init() {
        super.init()
    }
    
    required init?(map: Map){
        super.init()
    }
    
    func mapping(map: Map) {
        name <- map["Ity_Name"]
        typeDescription <- map["Ity_Description"]
        
        if let value = map["Ity_ID"].currentValue as? String {
            id = NSNumber(value: Int(value)!)
        }
        
        if let value = map["IA_CompanyID"].currentValue as? String {
            companyID = NSNumber(value: Int(value)!)
        }
        
        validationType <- map["Ity_ValidationType"]
    }
    
    class func findAll(inspection : Inspection) -> NSArray? {
        let types = InspectionType.query()
            .where(withFormat: "inspection = %@", withParameters: [inspection])
            .fetch()
        return types
    }
}
