//
//  Utils.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 11/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import SystemConfiguration

class Utils: NSObject {

    class func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
//        return false
    }

    class func readImage(name: String) -> UIImage? {
        let paths               = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(name)
            return UIImage(contentsOfFile: imageURL.path)
        }
        return nil
    }
    
    class func writeImage(image: UIImage) -> String? {
        let fileManager = FileManager.default

        let paths               = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dirPath          = paths.first
        {
            let name = String(NSDate().timeIntervalSince1970)
            
            let paths = (dirPath as NSString).appendingPathComponent(name)
            print(paths)
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            if fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil) {
                return name
            }
        }
        return nil
    }
    
    class func readAudio(name: String) -> Data? {
        let paths               = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let dirPath          = paths.first
        {
            let audioURL = URL(fileURLWithPath: name)
            do {
                let data = try Data(contentsOf: audioURL)
                return data
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
