//
//  BaseResponse.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 09/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper

class BaseResponse: Mappable {
    
    var status: String! {
        didSet {
            SUCCESS =  status == "success"
        }
    }
    var message: String!
    var SUCCESS: Bool = false
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
    }
}
