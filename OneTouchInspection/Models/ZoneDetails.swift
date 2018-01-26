//
//  ZoneDetails.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 12/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

class ZoneDetails: SRKObject, Mappable {

    var zones : [Zone] = []
    
    override init() {
        super.init()
        
    }
    
    required init?(map: Map){
        super.init()
    }
    
    func mapping(map: Map) {
        id <- map["inspectionTypeID"]
        zones <- map["Zones"]
    }
    
    override func commit() -> Bool {
        for item in zones {
            item.zoneDetails = self
            item.commit()
        }
        return super.commit()
    }

    class func find(inspectionTypeID : NSNumber) -> ZoneDetails? {
        
        if let zoneDetails = ZoneDetails.query().where(withFormat: "id = %@", withParameters: [inspectionTypeID]).limit(1).fetch() {
            if zoneDetails.count > 0 {
                if let zoneDetail : ZoneDetails = zoneDetails.firstObject as! ZoneDetails? {
                    if let types = Zone.findAll(zoneDetail: zoneDetail) {
                        zoneDetail.zones = types.flatMap({ $0 as? Zone })
                    }
                    return zoneDetail
                }
                
            }
        }
        return nil
    }
}
