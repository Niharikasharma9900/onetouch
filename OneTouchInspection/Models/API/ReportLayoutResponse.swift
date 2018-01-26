//
//  ReportLayoutResponse.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 13/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper

class ReportLayoutResponse: BaseResponse {
    
    var layout : PDFLayout!
    
    override func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        layout <- map["results"]
    }
}
