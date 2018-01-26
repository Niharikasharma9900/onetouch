//
//  SubmitReportHelper.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 16/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class SubmitReportHelper: NSObject {
    
    
    let dateFormatter = DateFormatter()
    
    
    func getSubmitJSONBody(submit: Submit) -> Parameters {
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        var parameters: Parameters = Parameters()
        
        parameters["userID"] = submit.inspectorID.intValue
        parameters["inspectionTypeID"] = submit.typeID.intValue
        parameters["inspectorID"] = submit.inspectorID.intValue
        
        parameters["longitude"] = submit.longitude.doubleValue
        parameters["latitude"] = submit.latitude.doubleValue
        
        parameters["date"] = dateFormatter.string(for: submit.time)
        parameters["startTime"] = dateFormatter.string(for: submit.startTime)
        
        parameters["demoEmail"] = submit.demoEmail
        parameters["vehicleID"] = submit.vehicleID.intValue
        parameters["vehicle2ID"] = submit.vehicle2ID.intValue
        parameters["vehicle3ID"] = submit.vehicle3ID.intValue
        
        parameters["odometerReading"] = submit.odometerReading != nil ?? "0"
        parameters["isVehicleSafe"] = submit.safeToDrive.boolValue ? "Yes" : "No"
        
        
        if submit.tagDefects.count > 0 {
            var tagDefects: [Parameters] = [Parameters]()
            for result in submit.tagDefects {
                var tagDefect: Parameters = Parameters()
                tagDefect["zoneName"] = result.zoneName
                tagDefect["assetID"] = result.assetID.intValue
                tagDefect["zoneNFCTag"] = result.zoneNFCTag
                tagDefect["submitID"] = result.submitID
                tagDefect["zoneNameID"] = result.zoneNameID.intValue
                tagDefect["inspectionType"] = result.inspectionType.intValue
                tagDefects.append(tagDefect)
            }
            parameters["tagDefects"] = tagDefects
        }
        
        
        var defects: [Parameters] = [Parameters]()
        for type in submit.submitDefects {
            var defect: Parameters = Parameters()
            defect["componentTypeID"] = type.compTypeID.intValue
            defect["note"] = type.notes
            defect["modelTypeID"] = type.modelTypeID.intValue
            defect["modelValue"] = type.modelValue
            defect["modelDefectType"] = type.modelDefectType
            defects.append(defect)
        }
        parameters["defects"] = defects
        
        return parameters
    }
    
    func getTimeStampBody(timeStamps: [ZoneTimeStamp], resultID: NSNumber) -> Parameters {
        
        var parameters: Parameters = Parameters()
        
        var zoneStamps: [Parameters] = [Parameters]()
        for stamp in timeStamps {
            var zoneStamp: Parameters = Parameters()
            zoneStamp["inspectionTypeID"] = stamp.inspectionType.intValue
            zoneStamp["zoneNameID"] = stamp.zoneNameID.intValue
            zoneStamp["date"] = dateFormatter.string(for: stamp.time)
            zoneStamp["timeStamp"] = stamp.timeStamp
            zoneStamp["assetID"] = stamp.assetID.intValue
            zoneStamp["resultID"] = resultID.intValue
            zoneStamps.append(zoneStamp)
        }
        parameters["stamps"] = zoneStamps
        
        return parameters
        
    }
    
    func getDefectsToGeneratePDF(submit:Submit) -> Parameters {
        var parameters: Parameters = Parameters()
        
        var defects: [Parameters] = [Parameters]()
        for type in submit.submitDefects {
            var defect: Parameters = Parameters()
            defect["zoneName"] = type.zoneName
            defect["componentTypeDesc"] = type.componentTypeDesc
            defect["photoTaken"] = type.photoTaken
            defect["audioRecorded"] = type.audioRecorded
            defect["notes"] = type.notes
            defect["defectId"] = type.defectId.intValue
            defect["issueArea"] = type.issueArea
            defect["defectType"] = type.defectType
            defect["regulationCode"] = type.regulationCode
            
            defects.append(defect)
        }
        parameters["defects"] = defects
        
        parameters["header"] = submit.layout.header
        parameters["footer"] = submit.layout.footer
        parameters["icon"] = submit.layout.icon
        parameters["statusSafe"] = submit.layout.statusSafe
        parameters["statusNotSafe"] = submit.layout.statusNotSafe
        parameters["statusTempSafe"] = submit.layout.statusTempSafe
        
        
        var isGPSLocationNeeded:Bool = true
        for defect in submit.submitDefects {
            if defect.modelTypeID.intValue > 0 {
                parameters["location"] = submit.companyAddress
                isGPSLocationNeeded = false
                break
            }
        }
        if isGPSLocationNeeded {
            parameters["location"] = getLocation(submit: submit)
        }
        
        
        parameters["firstSection"] = getFirstSection(submit: submit, isGPSLocationNeeded: isGPSLocationNeeded)
        parameters["secondSection"] = getSecondSection(submit: submit)
        parameters["thirdSection"] = getThirdSection(submit: submit)
        
        parameters["tagDefectsTable"] = getTagDefectsTable(submit: submit)

        parameters["inspectionID"] = submit.inspectionResultID.intValue

        parameters["date"] = dateFormatter.string(for: submit.time)
        parameters["startTime"] = dateFormatter.string(for: submit.startTime)

        parameters["CompanyName"] = submit.companyName
        parameters["InspectorID"] = submit.inspectorID.intValue
        parameters["InspName"] = submit.inspName
        parameters["InspPosition"] = submit.inspPosition

        parameters["userEmail"] = submit.userEmail
        parameters["demoEmail"] = submit.demoEmail

        parameters["readingType"] = ""

        if submit.validationType == "preinsp" {
            parameters["readingType"] = "Odometer Reading"
        } else if submit.validationType == "EQUIPMENT" {
            parameters["readingType"] = "Hour Meter"
        }
        parameters["ccEmail1"] = submit.ccEmail1
        parameters["ccEmail2"] = submit.ccEmail2
        
        parameters["Glocation"] = String(format:"%.2f", submit.latitude.doubleValue) + "," + String(format:"%.2f", submit.longitude.doubleValue)
        parameters["odometerReading"] = submit.odometerReading ?? ""
        
        parameters["isVehicleSafe"] = submit.safeToDrive.boolValue ? "Yes" : "No"
        
        parameters["inspectionType"] = submit.inspectionType
        parameters["inspectionTypeId"] = submit.inspectionTypeId.intValue
        parameters["validationType"] = submit.validationType
        
        return parameters
        
    }
    
    func getLocation(submit:Submit) -> String {
        return ""
    }
    
    func getFirstSection(submit:Submit, isGPSLocationNeeded:Bool) -> String {
        
        let firstSection:PDFLayoutFirstSection = submit.layout.firstSection
        
        if firstSection.headerType == "vertical" {
            var table:String = ""
            if firstSection.companyName != nil && firstSection.companyName.characters.count > 0 {
                table += "<tr><td ><strong>  " + firstSection.companyName + ":</strong></td><td align=\"center\">  " + submit.companyName + "</td></tr>"
            }
            if firstSection.userName != nil && firstSection.userName.characters.count > 0 {
                table += "<tr><td ><strong>  " + firstSection.userName + ":</strong></td><td align=\"center\">  " + submit.inspName + "</td></tr>"
            }
            if firstSection.position != nil && firstSection.position.characters.count > 0 {
                table += "<tr><td ><strong>  " + firstSection.position + ":</strong></td><td align=\"center\">  " + submit.inspPosition + "</td></tr>"
            }
            if firstSection.employeeID != nil && firstSection.employeeID.characters.count > 0 {
                table += "<tr><td ><strong>  " + firstSection.employeeID + ":</strong></td><td align=\"center\">  " + String(submit.inspectorID.intValue) + "</td></tr>"
            }
            if firstSection.readingType != nil && firstSection.readingType.characters.count > 0 {
                table += "<tr><td ><strong>  " + firstSection.readingType + ":</strong></td><td align=\"center\">  " + submit.odometerReading + "</td></tr>"
            }
            if isGPSLocationNeeded {
                if firstSection.location != nil && firstSection.location.characters.count > 0 {
                    table += "<tr><td ><strong>  " + firstSection.location + ":</strong></td><td align=\"center\">  <a href=\"http://maps.google.ca/maps?q=" + String(submit.latitude.doubleValue) + "," + String(submit.longitude.doubleValue) + "\" align=\"center\">" + getLocation(submit: submit) + " </a></td></tr>"
                }
            } else {
                if firstSection.location != nil && firstSection.location.characters.count > 0 {
                    table += "<tr><td ><strong>  " + firstSection.location + ":</strong></td><td align=\"center\">  " + submit.companyAddress + "</td></tr>"
                }
            }
            
            if firstSection.startTime != nil && firstSection.startTime.characters.count > 0 {
                let dateString: String = dateFormatter.string(for: submit.startTime)!
                table += "<tr><td ><strong>  " + firstSection.startTime + ":</strong></td><td align=\"center\">  " + dateString + "</td></tr>"
            }
            if firstSection.endTime != nil && firstSection.endTime.characters.count > 0 {
                let dateString: String = dateFormatter.string(for: submit.time)!
                table += "<tr><td ><strong>  " + firstSection.endTime + ":</strong></td><td align=\"center\">  " + dateString + "</td></tr>"
            }
            if firstSection.totalTime != nil && firstSection.totalTime.characters.count > 0 {
                let diff:TimeInterval = submit.time.timeIntervalSince1970 - submit.startTime.timeIntervalSince1970
                let diffMinutes:TimeInterval = (diff / 60).remainder(dividingBy: 60)
                let diffHours:TimeInterval = (diff / (60 * 60 )).remainder(dividingBy: 24)
                table += "<tr><td ><strong>  " + firstSection.totalTime + ":</strong></td><td align=\"center\">  " + String(diffHours) + " : " + String(diffMinutes) + "</td></tr>"
            }
            if submit.inspectionType != nil && submit.inspectionType.caseInsensitiveCompare("Dump Truck") == ComparisonResult.orderedSame {
                table += "<tr><td ><strong> Odometer Reading:</strong></td><td align=\"center\">  " + submit.odometerReading + "</td></tr>"
            }
            return table
        } else {
            var titleRow:String = "<tr>"
            var valueRow:String = "<tr>"
            if firstSection.companyName != nil && firstSection.companyName.characters.count > 0 {
                titleRow += "<td ><strong>  " + firstSection.companyName + ":</strong></td>"
                valueRow += "<td align=\"center\">  " + submit.companyName + "</td>"
            }
            if firstSection.userName != nil && firstSection.userName.characters.count > 0 {
                titleRow += "<td ><strong>  " + firstSection.userName + ":</strong></td>"
                valueRow += "<td align=\"center\">  " + submit.inspName + "</td>"
            }
            if firstSection.position != nil && firstSection.position.characters.count > 0 {
                titleRow += "<td ><strong>  " + firstSection.position + ":</strong></td>"
                valueRow += "<td align=\"center\">  " + submit.inspPosition + "</td>"
            }
            if firstSection.employeeID != nil && firstSection.employeeID.characters.count > 0 {
                titleRow += "<td ><strong>  " + firstSection.employeeID + ":</strong></td>"
                valueRow += "<td align=\"center\">  " + String(submit.inspectorID.intValue) + "</td>"
            }
            if firstSection.readingType != nil && firstSection.readingType.characters.count > 0 {
                titleRow += "<td ><strong>  " + firstSection.readingType + ":</strong></td>"
                valueRow += "td align=\"center\">  " + submit.odometerReading + "</td>"
            }
            if isGPSLocationNeeded {
                if firstSection.location != nil && firstSection.location.characters.count > 0 {
                    titleRow += "<td ><strong>  " + firstSection.location + ":</strong></td>"
                    valueRow += "<td align=\"center\">  <a href=\"http://maps.google.ca/maps?q=" + String(submit.latitude.doubleValue) + "," + String(submit.longitude.doubleValue) + "\\\" align=\\\"center\\\">" + getLocation(submit: submit) + " </a></td>"
                }
            } else {
                if firstSection.location != nil && firstSection.location.characters.count > 0 {
                    titleRow += "<td ><strong>  " + firstSection.location + ":</strong></td>"
                    valueRow += "<td align=\"center\"> " + submit.companyAddress + " </a></td>"
                }
            }
            
            if firstSection.startTime != nil && firstSection.startTime.characters.count > 0 {
                titleRow += "<td ><strong>  " + firstSection.startTime + ":</strong></td>"
                valueRow += "<td align=\"center\">  " + dateFormatter.string(for: submit.startTime)! + "</td>"
            }
            if firstSection.endTime != nil && firstSection.endTime.characters.count > 0 {
                titleRow += "<td ><strong>  " + firstSection.endTime + ":</strong></td>"
                valueRow += "<td align=\"center\">  " + dateFormatter.string(for: submit.time)! + "</td>"
            }
            if firstSection.totalTime != nil && firstSection.totalTime.characters.count > 0 {
                let diff:TimeInterval = submit.time.timeIntervalSince1970 - submit.startTime.timeIntervalSince1970
                let diffMinutes:TimeInterval = (diff / 60).remainder(dividingBy: 60)
                let diffHours:TimeInterval = (diff / (60 * 60 )).remainder(dividingBy: 24)
                titleRow += "<td ><strong>  " + firstSection.totalTime + ":</strong></td>"
                valueRow += "<td align=\"center\">  " + String(diffHours) + " : " + String(diffMinutes) + "</td>"
            }
            if submit.inspectionType != nil && submit.inspectionType.caseInsensitiveCompare("Dump Truck") == ComparisonResult.orderedSame {
                titleRow += "<td ><strong>  Odometer Reading:</strong></td>"
                valueRow += "<td align=\"center\">  " + submit.odometerReading + "</td>"
            }
            titleRow += "</tr>"
            valueRow += "</tr>"
            return titleRow + valueRow
            
        }
    }
    
    func getSecondSection(submit:Submit) -> String {
        
        let secondSection:PDFLayoutSecondSection = submit.layout.secondSection
        
        if submit.validationType.caseInsensitiveCompare("COTTAGE") == ComparisonResult.orderedSame {
            //            getSecondSectionForCottage(jsonBody, submit, context)
        } else {
            
            let vehicleList = getVehicleList(submit: submit)
            
            if secondSection.headerType.caseInsensitiveCompare("vertical") == ComparisonResult.orderedSame {
                
                var table:String = ""
                if secondSection.assetType != nil && secondSection.assetType.characters.count > 0 {
                    table += "<tr><td ><strong>  " + secondSection.assetType + ":</strong></td>  " + getAssetValues(vehicleList: vehicleList, key: "vehicleType") + "</tr>"
                }
                if secondSection.make != nil && secondSection.make.characters.count > 0 {
                    table += "<tr><td ><strong>  " + secondSection.make + ":</strong></td>  " + getAssetValues(vehicleList: vehicleList, key: "vehicleMake") + "</tr>"
                }
                if secondSection.model != nil && secondSection.model.characters.count > 0 {
                    table += "<tr><td ><strong>  " + secondSection.model + ":</strong></td>  " + getAssetValues(vehicleList: vehicleList, key: "vehicleModel") + "</tr>"
                }
                if secondSection.year != nil && secondSection.year.characters.count > 0 {
                    table += "<tr><td ><strong>  " + secondSection.year + ":</strong></td>  " + getAssetValues(vehicleList: vehicleList, key: "vehicleYear") + "</tr>"
                }
                if secondSection.vinSerial != nil && secondSection.vinSerial.characters.count > 0 {
                    table += "<tr><td ><strong>  " + secondSection.vinSerial + ":</strong></td>  " + getAssetValues(vehicleList: vehicleList, key: "vinNumber") + "</tr>"
                }
                if secondSection.itemNumber != nil && secondSection.itemNumber.characters.count > 0 {
                    table += "<tr><td ><strong>  " + secondSection.itemNumber + ":</strong></td>  " + getAssetValues(vehicleList: vehicleList, key: "licensePlateID") + "</tr>"
                }
                if secondSection.stateProvince != nil && secondSection.stateProvince.characters.count > 0 {
                    table += "<tr><td ><strong>  " + secondSection.stateProvince + ":</strong></td>  " + getAssetValues(vehicleList: vehicleList, key: "stateProvince") + "</tr>"
                }
                if submit.inspectionType != nil && submit.inspectionType.caseInsensitiveCompare("Dump Truck") == ComparisonResult.orderedSame {
                    table += "<tr><td ><strong>  License Plate:</strong></td>  " + getAssetValues(vehicleList: vehicleList, key: "licensePlateID") + "</tr>"
                }
                return table
            }
            else {
                var table:String = "<tr>"
                if secondSection.assetType != nil && secondSection.assetType.characters.count > 0 {
                    table += "<td ><strong>  " + secondSection.assetType + ":</strong></td>  "
                }
                if secondSection.make != nil && secondSection.make.characters.count > 0 {
                    table += "<td ><strong>  " + secondSection.make + ":</strong></td>  "
                }
                if secondSection.model != nil && secondSection.model.characters.count > 0 {
                    table += "<td ><strong>  " + secondSection.model + ":</strong></td>  "
                }
                if secondSection.year != nil && secondSection.year.characters.count > 0 {
                    table += "<td ><strong>  " + secondSection.year + ":</strong></td>  "
                }
                if secondSection.vinSerial != nil && secondSection.vinSerial.characters.count > 0 {
                    table += "<td ><strong>  " + secondSection.vinSerial + ":</strong></td>  "
                }
                if secondSection.itemNumber != nil && secondSection.itemNumber.characters.count > 0 {
                    table += "<td ><strong>  " + secondSection.itemNumber + ":</strong></td>  "
                }
                if secondSection.stateProvince != nil && secondSection.stateProvince.characters.count > 0 {
                    table += "<td ><strong>  " + secondSection.stateProvince + ":</strong></td>  "
                }
                if submit.inspectionType != nil && submit.inspectionType.caseInsensitiveCompare("Dump Truck") == ComparisonResult.orderedSame {
                    table += "<td ><strong>  License Plate:</strong></td>  "
                }
                table += "</tr>"
                for vehicle in vehicleList {
                    table += "<tr>"
                    if secondSection.assetType != nil && secondSection.assetType.characters.count > 0 {
                        table += "<td >" + vehicle["vehicleType"]! + "</td>"
                    }
                    if secondSection.make != nil && secondSection.make.characters.count > 0 {
                        table += "<td >" + vehicle["vehicleMake"]! + "</td>"
                    }
                    if secondSection.model != nil && secondSection.model.characters.count > 0 {
                        table += "<td >" + vehicle["vehicleModel"]! + "</td>"
                    }
                    if secondSection.year != nil && secondSection.year.characters.count > 0 {
                        table += "<td >" + vehicle["vehicleYear"]! + "</td>"
                    }
                    if secondSection.vinSerial != nil && secondSection.vinSerial.characters.count > 0 {
                        table += "<td >" + vehicle["vinNumber"]! + "</td>"
                    }
                    if secondSection.itemNumber != nil && secondSection.itemNumber.characters.count > 0 {
                        table += "<td >" + vehicle["licensePlateID"]! + "</td>"
                    }
                    if secondSection.stateProvince != nil && secondSection.stateProvince.characters.count > 0 {
                        table += "<td >" + vehicle["stateProvince"]! + "</td>"
                    }
                    if submit.inspectionType != nil && submit.inspectionType.caseInsensitiveCompare("Dump Truck") == ComparisonResult.orderedSame {
                        table += "<td >" + vehicle["licensePlateID"]! + "</td>"
                    }
                    table += "</tr>"
                }
                return table
                
            }
        }
        return ""
    }
    
    func getVehicleList(submit:Submit) -> [Dictionary<String, String>] {
        
        var vehicleList:[Dictionary<String,String>] = []
        
        for vehicle in submit.submitVehicles {
            if vehicle.vehicleType.caseInsensitiveCompare("Trailer") != ComparisonResult.orderedSame {
                var vehicleObj = Dictionary<String, String>()
                vehicleObj["vehicleType"] = vehicle.vehicleType
                vehicleObj["vehicleMake"] = vehicle.vehicleMake
                vehicleObj["vehicleModel"] = vehicle.vehicleModel
                vehicleObj["vehicleYear"] = vehicle.vehicleYear
                vehicleObj["vinNumber"] = vehicle.vinNumber
                vehicleObj["licensePlateID"] = vehicle.licensePlateID
                vehicleObj["stateProvince"] = vehicle.stateProvince
                vehicleList.append(vehicleObj)
            }
        }
        for vehicle in submit.submitVehicles {
            if vehicle.vehicleType.caseInsensitiveCompare("Trailer") == ComparisonResult.orderedSame {
                var vehicleObj = Dictionary<String, String>()
                vehicleObj["vehicleType"] = vehicle.vehicleType
                vehicleObj["vehicleMake"] = vehicle.vehicleMake
                vehicleObj["vehicleModel"] = vehicle.vehicleModel
                vehicleObj["vehicleYear"] = vehicle.vehicleYear
                vehicleObj["vinNumber"] = vehicle.vinNumber
                vehicleObj["licensePlateID"] = vehicle.licensePlateID
                vehicleObj["stateProvince"] = vehicle.stateProvince
                vehicleList.append(vehicleObj)
            }
        }
        return vehicleList
    }
    
    func getAssetValues(vehicleList:[Dictionary<String, String>], key:String) -> String {
        var line:String = ""
        for vehicle in vehicleList {
            line += "<td align=\"center\">" + vehicle[key]! + "</td>"
        }
        return line
    }
    
    func getThirdSection(submit:Submit) -> String {
        
        let thirdSection:PDFLayoutThirdSection = submit.layout.thirdSection
        if thirdSection.headerType.caseInsensitiveCompare("vertical") == ComparisonResult.orderedSame {
            var table:String = ""
            if thirdSection.zoneName != nil && thirdSection.zoneName.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.zoneName + ":</strong></td>  "
                for defect in submit.submitDefects {
                    table += "<td align=\"center\">" + defect.zoneName + "</td>"
                }
                table += "</tr>"
            }
            if thirdSection.issueArea != nil && thirdSection.issueArea.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.issueArea + ":</strong></td>  "
                for defect in submit.submitDefects {
                    table += "<td align=\"center\">" + defect.issueArea + "</td>"
                }
                table += "</tr>"
            }
            if thirdSection.defectIdentified != nil && thirdSection.defectIdentified.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.defectIdentified + ":</strong></td>  "
                for defect in submit.submitDefects {
                    table += "<td align=\"center\">" + defect.componentTypeDesc + "</td>"
                }
                table += "</tr>"
            }
            if thirdSection.defectType != nil && thirdSection.defectType.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.defectType + ":</strong></td>  "
                for defect in submit.submitDefects {
                    table += "<td align=\"center\">" + defect.defectType + "</td>"
                }
                table += "</tr>"
            }
            if thirdSection.regulationCode != nil && thirdSection.regulationCode.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.regulationCode + ":</strong></td>  "
                for defect in submit.submitDefects {
                    table += "<td align=\"center\">" + defect.regulationCode + "</td>"
                }
                table += "</tr>"
            }
            if thirdSection.photoTaken != nil && thirdSection.photoTaken.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.photoTaken + ":</strong></td>  "
                for defect in submit.submitDefects {
                    table += "<td align=\"center\">" + defect.photoTaken + "</td>"
                }
                table += "</tr>"
            }
            if thirdSection.audioRecorded != nil && thirdSection.audioRecorded.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.audioRecorded + ":</strong></td>  "
                for defect in submit.submitDefects {
                    if defect.audioRecorded != nil && defect.audioRecorded.caseInsensitiveCompare("Yes") == ComparisonResult.orderedSame {
                        table += "<td align=\"center\">" + defect.audioRecorded + "<a href=\"http://scaniq.secureserverdot.com/RRdb/NFC/audio/Audio_" + String(defect.defectId.intValue) + ".acc\" align=\"center\">  Listen</a> </td>"
                    } else {
                        table += "<td align=\"center\">" + defect.audioRecorded + "</td>"
                    }
                }
                table += "</tr>"
            }
            if thirdSection.modelValue != nil && thirdSection.modelValue.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.modelValue + ":</strong></td>  "
                for defect in submit.submitDefects {
                    table += "<td align=\"center\">" + (defect.modelValue != nil ? defect.modelValue : "") + "</td>"
                }
                table += "</tr>"
            }
            if thirdSection.modelDefectType != nil && thirdSection.modelDefectType.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.modelDefectType + ":</strong></td>  "
                for defect in submit.submitDefects {
                    table += "<td align=\"center\" style=\"color: red \">" + defect.modelDefectType + "</td>"
                    
                    
                    if defect.modelDefectType.lowercased().contains("major") {
                        table += "<td align=\"center\" style=\"color: red \"><strong>" + defect.modelDefectType.capitalized + "</strong></td>"
                    } else if defect.modelDefectType.lowercased().contains("minor") {
                        
                        table += "<td align=\"center\"><strong><span style=\"background-color: #FFFF00\">" + defect.modelDefectType.capitalized + "</span></strong></td>"
                        
                    } else if defect.modelDefectType.lowercased().contains("other") {
                        table += "<td align=\"center\" style=\"color: blue \"><strong>" + defect.modelDefectType.capitalized + "</strong></td>"
                    } else {
                        table += "<td align=\"center\">" + defect.modelDefectType.capitalized + "</td>"
                    }
                }
                table += "</tr>"
            }
            return table
        } else {
            var table:String = "<tr>"
            if thirdSection.zoneName != nil && thirdSection.zoneName.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.zoneName + ":</strong></td>  "
            }
            if thirdSection.issueArea != nil && thirdSection.issueArea.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.issueArea + ":</strong></td>  "
            }
            if thirdSection.defectIdentified != nil && thirdSection.defectIdentified.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.defectIdentified + ":</strong></td>  "
            }
            if thirdSection.defectType != nil && thirdSection.defectType.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.defectType + ":</strong></td>  "
            }
            if thirdSection.regulationCode != nil && thirdSection.regulationCode.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.regulationCode + ":</strong></td>  "
            }
            if thirdSection.photoTaken != nil && thirdSection.photoTaken.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.photoTaken + ":</strong></td>  "
            }
            if thirdSection.audioRecorded != nil && thirdSection.audioRecorded.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.audioRecorded + ":</strong></td>  "
            }
            if thirdSection.modelValue != nil && thirdSection.modelValue.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.modelValue + ":</strong></td>  "
            }
            if thirdSection.modelDefectType != nil && thirdSection.modelDefectType.characters.count > 0 {
                table += "<td ><strong>  " + thirdSection.modelDefectType + ":</strong></td>  "
            }
            table += "</tr>"
            for defect in submit.submitDefects {
                table += "<tr>"
                if thirdSection.zoneName != nil && thirdSection.zoneName.characters.count > 0 {
                    table += "<td>" + defect.zoneName + "</td>"
                }
                if thirdSection.issueArea != nil && thirdSection.issueArea.characters.count > 0 {
                    table += "<td >" + defect.issueArea + "</td>"
                }
                if thirdSection.defectIdentified != nil && thirdSection.defectIdentified.characters.count > 0 {
                    table += "<td >" + defect.componentTypeDesc + "</td>"
                }
                if thirdSection.defectType != nil && thirdSection.defectType.characters.count > 0 {
                    table += "<td >" + defect.defectType + "</td>"
                }
                if thirdSection.regulationCode != nil && thirdSection.regulationCode.characters.count > 0 {
                    table += "<td >" + defect.regulationCode + "</td>"
                }
                if thirdSection.photoTaken != nil && thirdSection.photoTaken.characters.count > 0 {
                    table += "<td >" + defect.photoTaken + "</td>"
                }
                if thirdSection.audioRecorded != nil && thirdSection.audioRecorded.characters.count > 0 {
                    if defect.audioRecorded != nil && defect.audioRecorded.caseInsensitiveCompare("Yes") == ComparisonResult.orderedSame {
                        table += "<td >" + defect.audioRecorded + "<a href=\"http://scaniq.secureserverdot.com/RRdb/NFC/audio/Audio_" + String(defect.defectId.intValue) + ".acc\" align=\"center\">  Listen</a> </td>"
                    } else {
                        table += "<td >" + defect.audioRecorded + "</td>"
                    }
                    //                    table += "<td >" + defect.AudioRecorded + "</td>"
                }
                if thirdSection.modelValue != nil && thirdSection.modelValue.characters.count > 0 {
                    table += "<td >" + (defect.modelValue != nil ? defect.modelValue : "") + "</td>"
                }
                if thirdSection.modelDefectType != nil && thirdSection.modelDefectType.characters.count > 0 {
                    
                    if defect.modelDefectType.lowercased().contains("major") {
                        table += "<td style=\"color: red \"> <strong>" + defect.modelDefectType.capitalized + "</strong></td>"
                    } else if defect.modelDefectType.lowercased().contains("minor") {
                        table += "<td  ><strong><span style=\"background-color: #FFFF00\">" + defect.modelDefectType.capitalized + "</span></strong></td>"
                    } else if defect.modelDefectType.lowercased().contains("other") {
                        table += "<td style=\"color: blue \"><strong>" + defect.modelDefectType.capitalized + "</strong></td>"
                    } else {
                        table += "<td >" + defect.modelDefectType.capitalized + "</td>"
                    }
                }
                table += "</tr>"
            }
            return table
            
        }
    }
    
    func getTagDefectsTable(submit:Submit) -> String {
        
        if submit.tagDefects.count == 0 {
            return ""
        }
        
        var table:String = "<tr>" +
            //                "<td ><strong>  Zone Name ID </strong></td>" +
            "<td ><strong>  Zone Name </strong></td>" +
            "<td ><strong>  NFCTag </strong></td>" +
        "</tr>";
        for defect in submit.tagDefects {
            table += "<tr>";
            //            table += "<td>" + defect.getZoneNameID() + "</td>";
            table += "<td>" + defect.zoneName + "</td>";
            table += "<td>" + defect.zoneNFCTag + "</td>";
            table += "</tr>";
        }
        return table
    }
}
