//
//  CheckPoint.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 16/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import SharkORM

class CheckPoint: SRKObject {

//    dynamic var checkPointID : String!

    dynamic var defectFound : NSNumber = NSNumber.init(value: false)
    dynamic var instructionsCount : NSNumber!
    
    dynamic var name : String!
    dynamic var submitID : String!
}
