//
//  Asset.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 15/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class Asset: SRKObject, Mappable {
    
    dynamic var inspectionTypeID : NSNumber!
    dynamic var lastOdometerValue : NSNumber!
    
    dynamic var licensePlateID : String!
    dynamic var vehicleType : String!
    dynamic var vehicleMake : String!
    dynamic var vehicleModel : String!
    dynamic var vehicleYear : String!
    dynamic var vinNumber : String!
    dynamic var lastOdometerDT : String!
    dynamic var stateProvince : String!
    
    var tagLocations : [NFCTagLocation] = []

    override init() {
        super.init()
    }
    
    required init?(map: Map){
        super.init()
    }
    
    func mapping(map: Map) {
        
        if let value = map["VehicleID"].currentValue as? String {
            id = NSNumber(value: Int(value)!)
        }
        if let value = map["inspectionTypeID"].currentValue as? String {
            inspectionTypeID = NSNumber(value: Int(value)!)
        }
        if let value = map["Last_OdometerValue"].currentValue as? String {
            lastOdometerValue = NSNumber(value: Int(value)!)
        }
        licensePlateID <- map["LicensePlate"]
        vehicleType <- map["VehicleType"]
        vehicleMake <- map["VehicleMake"]
        vehicleModel <- map["VehicleModel"]
        vehicleYear <- map["VehicleYear"]
        vinNumber <- map["VINNumber"]
        lastOdometerDT <- map["Last_OdometerDT"]
        stateProvince <- map["State_Province"]
        
        tagLocations <- map["Zones"]

    }
}

