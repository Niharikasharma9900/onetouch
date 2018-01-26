//
//  Constants.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 09/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import Foundation
import UIKit

let VERSION = 9.0

//let themeTinColor = UIColor.init(red: 0, green: 122, blue: 255, alpha: 1)

var themeTinColor = UIColor(netHex:0x2665CC)
var themeButtonColor = UIColor(netHex:0x2665CC)

var themeSecondaryTinColor = UIColor(netHex:0x8B8C8B)


let otiBaseDomainURL = "http://scaniq.secureserverdot.com/RRdb/NFC/TestV" + String(VERSION)
let otiBaseDomainURLPDF = "http://scaniq.secureserverdot.com/RRdb/NFC/tcpdf/examples/V" + String(VERSION) + "_";

let otiSignInURL = otiBaseDomainURL + "/login.php"
let otiGetZonesURL = otiBaseDomainURL + "/get_zones.php"
let otiGetReportLayoutURL = otiBaseDomainURL + "/pdfReportLayout.php"
let otiGetVehicleURL = otiBaseDomainURL + "/getVehicleZoneTags.php"

let otiSubmitResultURL = otiBaseDomainURL + "/submit.php"
let otiSubmitResultFactoryURL = otiBaseDomainURL + "/submitFactory.php"

let otiPostTimeStampURL = otiBaseDomainURL + "/zone_timestamp.php"
let otiGeneratePDF = otiBaseDomainURLPDF + "pdfReport.php"

let otiImageUploadURL = otiBaseDomainURL + "/imageUpload.php"
let otiAudioUploadURL = otiBaseDomainURL + "/audioUpload.php"

let kToastNoPopTime : Double = 2

let DevelopmentMode : Bool = false
