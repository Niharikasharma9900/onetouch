//
//  SubmitResponse.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 16/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper

class SubmitResponse: BaseResponse {

    var resultID: NSNumber!
    var results: [ComponentType]!

    override func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        results <- map["results"]
        if let value = map["resultID"].currentValue as? String {
            resultID = NSNumber(value: Int(value)!)
        }
    }
}
