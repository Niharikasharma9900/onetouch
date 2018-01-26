//
//  ComponentType.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 23/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import ObjectMapper
import SharkORM

enum modelTypes: String {
    
    case double = "double"
    case range = "range"
    case dropdown = "dropdown"
    case int = "int"
    case bool = "bool"
    case timeRange = "time-time"
    case time = "time"

    case none = "none"

}

class ComponentType: SRKObject, Mappable {
    
    dynamic var compTypeDesc : String!
    dynamic var compTypeNotes : String!
    

    dynamic var imagePath : String!
    dynamic var audioPath : String!
    
    dynamic var modelValue : String!
    dynamic var root : String!
    
    
    dynamic var correctiveActionItems : String!
    dynamic var notes : String!
    dynamic var defectType : String!
    dynamic var regulationCode : String!
    dynamic var modelLabel : String!
    dynamic var modelType : String!
    dynamic var modelOptions : String!
    dynamic var lowAlarmDefectType : String!
    dynamic var highAlarmDefectType : String!
    dynamic var veryHighAlarmDefectType : String!
    dynamic var veryLowAlarmDefectType : String!

    var modelValueRecorded : Bool = false

    
    dynamic var resultID : NSNumber!
    dynamic var defectID : NSNumber = 0
    dynamic var requiresPicture : NSNumber = 0
    dynamic var requiresAudio : NSNumber = 0
    dynamic var requiresCheckbox : NSNumber = 0
    dynamic var stepsID : NSNumber!
    dynamic var modelSecondaryAlarmStatus : NSNumber = 0
    dynamic var modelPrimaryAlarmStatus : NSNumber = 0
    
    dynamic var modelDataMin : NSNumber = 0
    dynamic var modelDataMax : NSNumber = 0
    dynamic var modelLowAlarmVal : NSNumber = 0
    dynamic var modelHighAlarmVal : NSNumber = 0
    dynamic var modelVeryHighAlarmVal : NSNumber = 0
    dynamic var modelVeryLowAlarmVal : NSNumber = 0

    override init() {
        super.init()
    }
    
    required init?(map: Map){
        super.init()
    }
    
    func getModelType() -> modelTypes {
        return modelTypes(rawValue: modelType ?? "none") ?? .none;
    }
    
    func getModelValue() -> String{
        return modelValue
    }
    
    func setModelValue(modelValue : String!){
        self.modelValue = modelValue
    }
    
   
    func mapping(map: Map) {
        
        if let value = map["CompType_ID"].currentValue{
            if let valueString = value as? String {
                id = NSNumber(value: Int(valueString)!)
            } else if let valueNumber = value as? NSNumber {
                id = valueNumber
            }
        }
        
        compTypeDesc <- map["CompType_Desc"]
        compTypeNotes <- map["CompType_notes"]
        
        
        correctiveActionItems <- map["CorrectiveActionItems"]
        notes <- map["Notes"]
        defectType <- map["DefectType"]
        regulationCode <- map["Regulation_Code"]
        modelLabel <- map["modelLabel"]
        modelType <- map["modelType"]
        modelOptions <- map["modelOptions"]
        lowAlarmDefectType <- map["low_alarm_defect_type"]
        highAlarmDefectType <- map["high_alarm_defect_type"]
        veryHighAlarmDefectType <- map["very_high_alarm_defect_type"]
        veryLowAlarmDefectType <- map["very_low_alarm_defect_type"]

        if let value = map["IResultID"].currentValue as? String {
            resultID = NSNumber(value: Int(value)!)
        }
        if let value = map["NFCDefectID"].currentValue as? String {
            defectID = NSNumber(value: Int(value)!)
        }
        if let value = map["RequiresPicture"].currentValue as? String {
            requiresPicture = NSNumber(value: Int(value)!)
        }
        if let value = map["RequiresAudio"].currentValue as? String {
            requiresAudio = NSNumber(value: Int(value)!)
        }
        if let value = map["RequiresCheckbox"].currentValue as? String {
            requiresCheckbox = NSNumber(value: Int(value)!)
        }
        if let value = map["IStep_ID"].currentValue as? String {
            stepsID = NSNumber(value: Int(value)!)
        }
        if let value = map["model_secondary_alarm_status"].currentValue as? String {
            modelSecondaryAlarmStatus = NSNumber(value: Int(value)!)
        }
        if let value = map["model_primary_alarm_status"].currentValue as? String {
            modelPrimaryAlarmStatus = NSNumber(value: Int(value)!)
        }
        
        if let value = map["model_data_min"].currentValue as? String {
            modelDataMin = NSNumber(value: Double(value)!)
        }
        if let value = map["model_data_max"].currentValue as? String {
            modelDataMax = NSNumber(value: Double(value)!)
        }
        if let value = map["model_low_alarm_val"].currentValue as? String {
            modelLowAlarmVal = NSNumber(value: Double(value)!)
        }
        if let value = map["model_high_alarm_val"].currentValue as? String {
            modelHighAlarmVal = NSNumber(value: Double(value)!)
        }
        if let value = map["model_very_high_alarm_val"].currentValue as? String {
            modelVeryHighAlarmVal = NSNumber(value: Double(value)!)
        }
        if let value = map["model_very_low_alarm_val"].currentValue as? String {
            modelVeryLowAlarmVal = NSNumber(value: Double(value)!)
        }
    }
    
    
    
    class func findAll(zoneDetail : ZoneDetails) -> NSArray? {
        let types = Zone.query()
            .where(withFormat: "zoneDetails = %@", withParameters: [zoneDetail])
            .fetch()
        return types
    }
    
    func findDefectType() -> String {
        
        var defect: String = "No defect"
        
        if getModelType() == modelTypes.dropdown || getModelType() == modelTypes.bool || getModelType() == modelTypes.time || getModelType() == modelTypes.timeRange  {
            return defect
        }
        if modelValue == nil {
            return defect
        }
        if let modelValue = Double(self.modelValue) {
            
            if modelPrimaryAlarmStatus.intValue > 0 {
                if modelValue >= modelDataMin.doubleValue && modelValue < modelLowAlarmVal.doubleValue {
                    defect = lowAlarmDefectType
                } else if modelValue <= modelDataMax.doubleValue && modelValue > modelHighAlarmVal.doubleValue{
                    defect = highAlarmDefectType
                }
            }
            
            if modelPrimaryAlarmStatus.intValue > 0 {
                if modelValue >= modelDataMin.doubleValue && modelValue < modelLowAlarmVal.doubleValue {
                    defect = lowAlarmDefectType
                } else if modelValue <= modelDataMax.doubleValue && modelValue > modelHighAlarmVal.doubleValue {
                    defect = highAlarmDefectType
                }
                
            }
            
            if modelSecondaryAlarmStatus.intValue > 0 {
                if modelValue >= modelDataMin.doubleValue && modelValue < modelVeryLowAlarmVal.doubleValue {
                    defect = veryLowAlarmDefectType
                } else if modelValue <= modelDataMax.doubleValue && modelValue > modelVeryHighAlarmVal.doubleValue {
                    defect = veryHighAlarmDefectType
                }
                if modelValue >= modelVeryLowAlarmVal.doubleValue && modelValue < modelLowAlarmVal.doubleValue {
                    defect = lowAlarmDefectType
                } else if modelValue <= modelVeryHighAlarmVal.doubleValue && modelValue > modelHighAlarmVal.doubleValue {
                    defect = highAlarmDefectType
                }
            }
        }

        return defect;
    }
    
    func getModelTypeID() -> NSNumber {
        switch getModelType() {
        case .double:
            return 1
        case .range:
            return 2
        case .dropdown:
            return 3
        case .int:
            return 4
        case .bool:
            return 5
        case .timeRange:
            return 6
        case .time:
            return 7
        default:
            return 0
        }
    }
    

}
