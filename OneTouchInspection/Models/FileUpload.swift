//
//  FileUpload.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 16/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit

enum mediaType: Int {
    
    case image = 1
    case audio = 2
}

class FileUpload: NSObject {

    var mediaType: mediaType = .image
    var defectID: Int!
    var subIndex: Int!

    var filePath: String!
    
    init(filePath: String, defectID: Int, mediaType: mediaType) {
        self.filePath   = filePath
        self.defectID = defectID
        self.mediaType  = mediaType
    }
}
