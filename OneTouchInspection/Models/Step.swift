//
//  Step.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 17/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class Step: SRKObject, Mappable {
    
    dynamic var number : NSNumber!
    
    dynamic var stepDescription : String!
    dynamic var stepTypeName : String!
    
    dynamic var zoneID : NSNumber!
    dynamic var isAllowtoSkip : NSNumber!
    dynamic var stepTypeID : NSNumber!

    
    var componentTypes : [ComponentType] = []
    
    override init() {
        super.init()
    }
    
    required init?(map: Map){
        super.init()
    }
    
    func mapping(map: Map) {
        
        if let value = map["IStep_ID"].currentValue as? String {
            id = NSNumber(value: Int(value)!)
        }
        
        if let value = map["IStep_Number"].currentValue as? String {
            number = NSNumber(value: Int(value)!)
        }
        
        stepDescription <- map["IStep_Description"]
        stepTypeName <- map["StepTypeName"]

        if let value = map["ZONE_ID"].currentValue as? String {
            zoneID = NSNumber(value: Int(value)!)
        }
        
        if let value = map["isAllowtoSkip"].currentValue as? String {
            isAllowtoSkip = NSNumber(value: Int(value)!)
        }
        if let value = map["StepTypeID"].currentValue as? String {
            stepTypeID = NSNumber(value: Int(value)!)
        }
        
        componentTypes <- map["ComponentType"]
        
    }
    
    class func findAll(zoneDetail : ZoneDetails) -> NSArray? {
        let types = Zone.query()
            .where(withFormat: "zoneDetails = %@", withParameters: [zoneDetail])
            .fetch()
        return types
    }
}
