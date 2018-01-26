//
//  SubmitReportHandler.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 16/02/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

protocol SubmitReportHandlerDelegate {
    func reportSubmitted(defects: [SubmitDefect])
    func reportSubmitError(message: String)
}

class SubmitReportHandler: NSObject {

    let helper : SubmitReportHelper = SubmitReportHelper()
    var submit: Submit!
    var delegate:SubmitReportHandlerDelegate?
    var fileUploads: [FileUpload] = [FileUpload]()
    func sendRecord(submit: Submit, timeStamps: [ZoneTimeStamp]) {
        
        self.submit = submit
        
        let parameters: Parameters = helper.getSubmitJSONBody(submit: submit)
        
        var url = otiSubmitResultURL
        
        if submit.validationType != nil && submit.validationType == "maint" {
            url = otiSubmitResultFactoryURL
        }
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default , headers: nil)
            .responseJSON(completionHandler: {json in
            
                print("json = \(json)")

            })
            .responseObject { (response: DataResponse<SubmitResponse>) in
                
                if let submitResponse = response.result.value {
                    
                    print(submitResponse.status)
                    print(submitResponse.message ?? "No msg!")
                    print("Submit resuld id \(submitResponse.resultID)")
                    print(submitResponse.results.toJSONString(prettyPrint: true) ?? "No submit redults!")

                    if (submitResponse.SUCCESS) {
                        submit.inspectionResultID = submitResponse.resultID
                        self.sendTimeStamp(timeStamps: timeStamps, resultID: submitResponse.resultID)
                        self.updateDefectIds(results: submitResponse.results)
                        self.uploadRecord()
                    } else {
                        self.delegate?.reportSubmitError(message: submitResponse.message)
                    }
                } else {
                    self.delegate?.reportSubmitError(message: "Network Error..!")
                }
        }
    }
    
    func updateDefectIds(results: [ComponentType]) {
        
        for type in submit.submitDefects {
            for result in results {
                if result.id == type.compTypeID {
                    type.defectId = result.defectID
                    type.resultID = result.resultID
                    break
                }
            }
        }
    }
    
    func sendTimeStamp(timeStamps: [ZoneTimeStamp], resultID: NSNumber) {
        
        let parameters: Parameters = helper.getTimeStampBody(timeStamps: timeStamps, resultID: resultID)

        Alamofire.request(otiPostTimeStampURL, method: .post, parameters: parameters, encoding: JSONEncoding.default , headers: nil)
            .responseObject { (response: DataResponse<BaseResponse>) in
                
                if let timeStanpResponse = response.result.value {
                    
                    print(timeStanpResponse.status)
                    print(timeStanpResponse.message ?? "No msg!")
                    for stamp in timeStamps {
//                        _ = stamp.remove()
                    }
                }
        }
    }
    
    func uploadRecord() {
        
        fileUploads.removeAll()
        
        for type in submit.submitDefects {
            if let imagePath = type.imagePath {
                fileUploads.append(FileUpload.init(filePath: imagePath, defectID: type.defectId.intValue, mediaType: .image))
            }
            if let audioPath = type.audioPath {
                fileUploads.append(FileUpload.init(filePath: audioPath, defectID: type.defectId.intValue, mediaType: .audio))
            }
        }
        
        if fileUploads.count > 0 {
            uploadFile(fileUpload: fileUploads.first!)
        } else {
            sendRequestToGeneratePDF()
        }
        
    }
    
    func uploadFile(fileUpload: FileUpload) {
        
        switch fileUpload.mediaType {
        case .image:
            let fileName = "IMG_" + String(fileUpload.defectID) + ".jpg"
            Alamofire.upload(multipartFormData: { multipartFormData in
                if let imageData = UIImageJPEGRepresentation(Utils.readImage(name: fileUpload.filePath)!, 0.3) {
                    multipartFormData.append(imageData, withName: "uploaded_file", fileName: fileName, mimeType: "image/jpg")
                }
            }, to: otiImageUploadURL, method: .post, headers: ["Authorization": "auth_token"],
               encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.response { [weak self] response in
                        guard self != nil else {
                            return
                        }
                        if response.response?.statusCode == 200 {
                            self?.fileUploads.remove(at: 0)
                            if (self?.fileUploads.count)! > 0 {
                                self?.uploadFile(fileUpload: (self?.fileUploads.first!)!)
                            } else {
                                self?.sendRequestToGeneratePDF()
                            }
                        } else {
                            if (self?.fileUploads.count)! > 0 {
                                self?.uploadFile(fileUpload: (self?.fileUploads.first!)!)
                            } else {
                                self?.sendRequestToGeneratePDF()
                            }
                        }
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print("error:\(encodingError)")
                    if (self.fileUploads.count) > 0 {
                        self.uploadFile(fileUpload: (self.fileUploads.first!))
                    } else {
                        self.sendRequestToGeneratePDF()
                    }
                }
            })
            
            break
        case .audio:
            let fileName = "Audio_" + String(fileUpload.defectID) + ".acc"
            Alamofire.upload(multipartFormData: { multipartFormData in
                if let audioData = Utils.readAudio(name: fileUpload.filePath) {
                    multipartFormData.append(audioData, withName: "uploaded_file", fileName: fileName, mimeType: "audio/acc")
                }
            }, to: otiAudioUploadURL, method: .post, headers: ["Authorization": "auth_token"],
               encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.response { [weak self] response in
                        debugPrint("response \(response.response?.statusCode)")
                        if response.response?.statusCode == 200 {
                            debugPrint("self?.fileUploads.count \(self?.fileUploads.count)")
                            self?.fileUploads.removeFirst()
                            if (self?.fileUploads.count)! > 0 {
                                self?.uploadFile(fileUpload: (self?.fileUploads.first!)!)
                            } else {
                                self?.sendRequestToGeneratePDF()
                            }
                        } else {
                            if (self?.fileUploads.count)! > 0 {
                                self?.uploadFile(fileUpload: (self?.fileUploads.first!)!)
                            } else {
                                self?.sendRequestToGeneratePDF()
                            }
                        }
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print("error:\(encodingError)")
                    if (self.fileUploads.count) > 0 {
                        self.uploadFile(fileUpload: (self.fileUploads.first!))
                    } else {
                        self.sendRequestToGeneratePDF()
                    }
                }
            })
            
            break
        }
        
        

    }
    
    func sendRequestToGeneratePDF() {
        
        let parameters: Parameters = helper.getDefectsToGeneratePDF(submit: submit)
        print("sendRequestToGeneratePDF parameters :")
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String

        // here "jsonData" is the dictionary encoded in JSON data
        print(jsonString)

        Alamofire.request(otiGeneratePDF, method: .post, parameters: parameters, encoding: JSONEncoding.default , headers: nil)
            .responseObject { (response: DataResponse<BaseResponse>) in
                
                if let timeStanpResponse = response.result.value {
                    
                    print(timeStanpResponse.status)
                    print(timeStanpResponse.message ?? "No msg!")
                    
                    self.delegate?.reportSubmitted(defects: self.submit.submitDefects)

                } else {
                    self.delegate?.reportSubmitError(message: "Something went wrong!")
                }
            }.responseJSON(completionHandler: {(response) in
                print("response \(response)")

            })
    }
}
