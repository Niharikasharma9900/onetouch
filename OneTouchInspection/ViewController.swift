//
//  ViewController.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 23/11/16.
//  Copyright © 2016 BeaconTree. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var reader : ACRAudioJackReader?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let image : UIImage = UIImage(named: "Icon")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: imageView)
        
        
        // Initialize ACRAudioJackReader object.
        reader = ACRAudioJackReader.init(mute: true)
        
        reader?.setDelegate(self)

        // Set mute to YES if the reader is unplugged, otherwise NO.
//        reader?.mute = Utils.ajdisReaderPlugged()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Set mute to YES if the reader is unplugged, otherwise NO.
//        reader?.mute = Utils.ajdisReaderPlugged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func ajd_dismiss(_ alertView: UIAlertView) {
        alertView.dismiss(withClickedButtonIndex: 0, animated: true)
    }
    
    // MARK: - Audio Jack Reader
    
    func reader(_ reader: ACRAudioJackReader, didNotify result: ACRResult) {
//        responseCondition.lock()
//        self.result = result
//        self.resultReady = true
//        responseCondition.signal()
//        responseCondition.unlock()
    }
    
    func reader(_ reader: ACRAudioJackReader, didSendFirmwareVersion firmwareVersion: String) {
//        responseCondition.lock()
//        self.firmwareVersion = firmwareVersion
//        self.firmwareVersionReady = true
//        responseCondition.signal()
//        responseCondition.unlock()
    }
    
    func reader(_ reader: ACRAudioJackReader, didSend status: ACRStatus) {
//        responseCondition.lock()
//        self.status = status
//        self.statusReady = true
//        responseCondition.signal()
//        responseCondition.unlock()
    }
    
    func readerDidNotifyTrackData(_ reader: ACRAudioJackReader) {
        // Show the track data alert.
        DispatchQueue.main.async(execute: {() -> Void in
            let trackDataAlert = UIAlertView(title: "Information",
                                             message: "Processing the track data...",
                                             delegate: nil,
                                             cancelButtonTitle: "",
                                             otherButtonTitles: "")
            trackDataAlert.show()
            // Dismiss the track data alert after 5 seconds.
            self.perform(#selector(self.ajd_dismiss), with: trackDataAlert, afterDelay: 5)
        })
    }
}

