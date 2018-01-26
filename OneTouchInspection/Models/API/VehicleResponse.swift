//
//  VehicleResponse.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 14/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper

class VehicleResponse: BaseResponse {
    
    var asset : Asset!
    
    override func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        asset <- map["results"]
    }
}

