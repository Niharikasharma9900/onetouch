//
//  Zone.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 12/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class Zone: SRKObject, Mappable {
    
    dynamic var inspectionTypeID : NSNumber!

    dynamic var name : String!
    dynamic var zoneNameID : NSNumber!

    dynamic var zoneNFCTag : String!
    
    dynamic var updated : NSNumber = 0
    dynamic var assetID : NSNumber!

    
    dynamic var zoneDetails : ZoneDetails!

    var steps : [Step] = []

    override init() {
        super.init()
    }
    
    required init?(map: Map){
        super.init()
    }
    
    func mapping(map: Map) {
                
        if let value = map["ZONE_ID"].currentValue as? String {
            id = NSNumber(value: Int(value)!)
        }
        
        if let value = map["IType_ID"].currentValue as? String {
            inspectionTypeID = NSNumber(value: Int(value)!)
        }
        
        name <- map["ZoneName"]

        if let value = map["ZoneNameID"].currentValue as? String {
            zoneNameID = NSNumber(value: Int(value)!)
        }
        
        zoneNFCTag <- map["NFCTagID"]
        steps <- map["Steps"]

    }
    
    class func findAll(zoneDetail : ZoneDetails) -> NSArray? {
        let types = Zone.query()
            .where(withFormat: "zoneDetails = %@", withParameters: [zoneDetail])
            .fetch()
        return types
    }
}
