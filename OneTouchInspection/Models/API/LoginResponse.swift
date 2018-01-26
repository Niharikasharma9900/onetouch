//
//  LoginResponse.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 09/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper

class LoginResponse: BaseResponse {

    var inspection : Inspection!
    
    override func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        inspection <- map["results"]
    }
}
