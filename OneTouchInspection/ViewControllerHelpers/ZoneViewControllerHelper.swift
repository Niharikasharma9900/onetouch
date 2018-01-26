//
//  ZoneViewControllerHelper.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 13/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit

class ZoneViewControllerHelper: NSObject {

    class func getAssetDetailsFetchMessage(validationType: String) -> String {
        
        switch validationType {
        case "preinsp":
            return "Fetching vehicle details..."
            
        case "EQUIPMENT":
            return "Fetching asset details..."
            
        case "PIPELINE":
            return "Fetching asset details..."
            
        case "HELICOPTER":
            return "Fetching helicopter details..."
            
        default:
            return "Fetching asset details..."
        }
    }
    
    class func prepareSubmit(submit: Submit, assets: [Asset], inspection: Inspection, inspectionType:InspectionType, zoneDetails: ZoneDetails) {
        
        let nonTrailer = assets.filter { $0.vehicleType != "Trailer" }
        if nonTrailer.count > 0 {
            submit.vehicleID = (nonTrailer.first?.id)!
        }
        
        let trailer = assets.filter { $0.vehicleType == "Trailer" }
        if trailer.count > 0 {
            submit.vehicle2ID = trailer[0].id
        }
        if trailer.count > 1 {
            submit.vehicle3ID = trailer[1].id
        }
        
        var vehicleList: [SubmitVehicle] = [SubmitVehicle]()
        

        vehicleList.append(contentsOf: nonTrailer.map{ item -> SubmitVehicle in
            
            let submitVehicle = SubmitVehicle()
            submitVehicle.vehicleType = item.vehicleType
            submitVehicle.vehicleMake = item.vehicleMake
            submitVehicle.vehicleModel = item.vehicleModel
            submitVehicle.vehicleYear = item.vehicleYear
            submitVehicle.vinNumber = item.vinNumber
            submitVehicle.licensePlateID = item.licensePlateID
            submitVehicle.stateProvince = item.stateProvince
            return submitVehicle
        })

        vehicleList.append(contentsOf: trailer.map{ item -> SubmitVehicle in
            
            let submitVehicle = SubmitVehicle()
            submitVehicle.vehicleType = item.vehicleType
            submitVehicle.vehicleMake = item.vehicleMake
            submitVehicle.vehicleModel = item.vehicleModel
            submitVehicle.vehicleYear = item.vehicleYear
            submitVehicle.vinNumber = item.vinNumber
            submitVehicle.licensePlateID = item.licensePlateID
            submitVehicle.stateProvince = item.stateProvince
            return submitVehicle
        })
        
        submit.submitVehicles = vehicleList
        
        
        var defects : [SubmitDefect] = [SubmitDefect]()
        var checkPoints : [CheckPoint] = [CheckPoint]()

        for zone in zoneDetails.zones {
            
            let checkPoint: CheckPoint = CheckPoint()
            checkPoint.name = zone.name
            
            var count: Int = 0
            
            for step in zone.steps {
                
                for type in step.componentTypes {
                    count += 1
                    
                    if type.defectID.intValue > 0 || (type.getModelType() != .none && type.modelValue != nil && type.modelValue.characters.count > 0 && type.modelValueRecorded) {
                        
                        if !checkPoint.defectFound.boolValue {
                            checkPoint.defectFound = NSNumber.init(booleanLiteral: true)
                        }
                        
                        let defect: SubmitDefect = SubmitDefect()
                        defect.root = zone.name + " >> " + step.stepDescription
                        defect.zoneName = zone.name
                        
                        defect.compTypeID = type.id
                        defect.imagePath = type.imagePath
                        defect.audioPath = type.audioPath
                        defect.componentTypeDesc = type.compTypeDesc

                        defect.photoTaken = (type.imagePath != nil && type.imagePath.characters.count > 0) ? "Yes" : "No"
                        defect.audioRecorded = (type.audioPath != nil && type.audioPath.characters.count > 0) ? "Yes" : "No"

                        defect.notes = type.notes
                        defect.defectId = type.defectID
                        defect.defectType = type.defectType
                        defect.stepsID = type.stepsID

                        
                        defect.issueArea = step.stepDescription

                        defect.requiresCheckbox = type.requiresCheckbox
                        defect.modelDefectType = type.findDefectType()


                        if type.regulationCode != nil {
                            defect.regulationCode = type.regulationCode
                        } else {
                            defect.regulationCode = ""
                        }
                        defect.modelTypeID = type.getModelTypeID()
                        defect.modelValue = type.modelValue
                        
                        defects.append(defect)
                    }
                    
                }
            }
            checkPoint.instructionsCount = NSNumber.init(value: count)
            checkPoints.append(checkPoint)
        }
        submit.checkPoints = checkPoints
        submit.submitDefects = defects

        submit.companyName = inspection.companyName
        submit.inspName = inspection.inspName
        submit.inspPosition = inspection.inspPosition
        submit.ccEmail1 = inspection.ccEmail1
        submit.ccEmail2 = inspection.ccEmail2

        submit.inspectionType = inspectionType.name
        submit.inspectionTypeId = inspectionType.id

    }
}
