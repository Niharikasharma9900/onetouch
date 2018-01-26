//
//  ZonesResponse.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 12/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper

class ZonesResponse: BaseResponse {

    var zoneDetails : ZoneDetails!
    
    override func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        zoneDetails <- map["results"]
    }
}
