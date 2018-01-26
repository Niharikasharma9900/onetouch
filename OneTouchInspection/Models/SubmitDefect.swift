//
//  SubmitDefect.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 16/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import SharkORM

class SubmitDefect: SRKObject {

//    dynamic var defectOfflineId : String!

    dynamic var defectId : NSNumber!
    dynamic var resultID : NSNumber!
    dynamic var compTypeID : NSNumber!
    dynamic var stepsID : NSNumber!
    dynamic var modelTypeID : NSNumber!
    dynamic var requiresCheckbox : NSNumber!
//    dynamic var modelTypeID : NSNumber!

    dynamic var zoneName : String!
    dynamic var componentTypeDesc : String!
    dynamic var photoTaken : String!
    dynamic var audioRecorded : String!
    dynamic var notes : String!
    dynamic var regulationCode : String!
    dynamic var root : String!
    dynamic var imagePath : String!
    dynamic var audioPath : String!
    dynamic var defectType : String!
    dynamic var submitID : String!
    dynamic var issueArea : String!
    dynamic var modelValue : String!
    dynamic var modelDefectType : String!

}
