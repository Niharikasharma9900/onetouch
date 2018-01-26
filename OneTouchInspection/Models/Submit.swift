//
//  Submit.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 16/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import SharkORM

class Submit: SRKObject {

    dynamic var inspectorID : NSNumber!
    dynamic var typeID : NSNumber!
    dynamic var latitude : NSNumber = NSNumber.init(value: 0)
    dynamic var longitude : NSNumber = NSNumber.init(value: 0)
    dynamic var safeToDrive : NSNumber = NSNumber.init(value: false)

    dynamic var time : NSDate!
    dynamic var inspectionResultID : NSNumber!
    dynamic var startTime : NSDate!
    dynamic var vehicleID : NSNumber = NSNumber.init(value: 0)
    dynamic var vehicle2ID : NSNumber = NSNumber.init(value: 0)
    dynamic var vehicle3ID : NSNumber = NSNumber.init(value: 0)

    dynamic var inspectionTypeId : NSNumber!

    dynamic var odometerReading : String!
    dynamic var userEmail : String!
    dynamic var demoEmail : String = ""
    dynamic var validationType : String!
    dynamic var companyName : String!
    dynamic var inspName : String!
    dynamic var inspPosition : String!

    dynamic var ccEmail1 : String!
    dynamic var ccEmail2 : String!
    dynamic var inspectionType : String!
    dynamic var companyAddress : String!

    var submitVehicles: [SubmitVehicle]!
    var submitDefects: [SubmitDefect]!
    var checkPoints: [CheckPoint]!
    var tagDefects: [TagDefect] = [TagDefect]()
    
    dynamic var layout : PDFLayout!

}
