//
//  NFCTagLocation.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 15/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class NFCTagLocation: SRKObject, Mappable {
    
    dynamic var zoneNameID : NSNumber!
    dynamic var vehicleID : NSNumber!
    dynamic var zoneID : NSNumber!

    dynamic var nfcTagID : String!
    dynamic var zoneName : String!
    
    override init() {
        super.init()
    }
    
    required init?(map: Map){
        super.init()
    }
    
    func mapping(map: Map) {
        
        if let value = map["NFCTagLocationID"].currentValue as? String {
            id = NSNumber(value: Int(value)!)
        }
        
        if let value = map["ZoneNameID"].currentValue as? String {
            zoneNameID = NSNumber(value: Int(value)!)
        }
        if let value = map["VehicleID"].currentValue as? String {
            vehicleID = NSNumber(value: Int(value)!)
        }
        if let value = map["ZoneID"].currentValue as? String {
            zoneID = NSNumber(value: Int(value)!)
        }
        nfcTagID <- map["NFCTagID"]
        zoneName <- map["ZONE_Name"]
    }
}

