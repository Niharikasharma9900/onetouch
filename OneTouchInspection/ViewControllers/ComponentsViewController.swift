//
//  ComponentsTableViewController.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 17/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
//import PMAudioRecorderViewController
import IQAudioRecorderController
import WWCalendarTimeSelector



class ComponentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ComponentTypeTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IQAudioRecorderViewControllerDelegate, WWCalendarTimeSelectorProtocol {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var step: Step!
    var indexPathCamera: IndexPath!
    var indexPathMic: IndexPath!
    var indexPathModel: IndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lblTitle?.text = step.stepDescription
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return step.componentTypes.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ComponentTypeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "componentTypeTableCellID", for: indexPath) as! ComponentTypeTableViewCell
        cell.delegate = self
        cell.configur(type: step.componentTypes[indexPath.row], indexPath: indexPath)
        return cell
    }
 
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modelNumberSegue" {
            let modelVC = (segue.destination as? UINavigationController)?.viewControllers.first as? ModelNumberViewController
            modelVC?.componentType = self.step.componentTypes[indexPathModel.row]
        } else if segue.identifier == "modelPickerSegue" {
            let modelVC = (segue.destination as? UINavigationController)?.viewControllers.first as?
            ModelPickerTableViewController
            modelVC?.componentType = self.step.componentTypes[indexPathModel.row]
        }
    }
    
    
    //MARK: - Delegates

    // MARK: - ComponentTypeTableViewCellDelegate

    func checkboxDidSelect() {
        self.tableView.reloadData()
    }
    
    func cameraDidSelect(indexPath: IndexPath) {
        
        self.indexPathCamera = indexPath

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let picker = UIImagePickerController()
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.delegate = self
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        } else {
            self.view.showToast("No camera found!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        }
    }
    
    func micDidSelect(indexPath: IndexPath) {
        
        self.indexPathMic = indexPath
        
        let recorder = IQAudioRecorderViewController()
        recorder.title = "Recorder"
        recorder.maximumRecordDuration = 10
        recorder.allowCropping = false
        recorder.delegate = self
        self.presentBlurredAudioRecorderViewControllerAnimated(recorder)
    }
    
    func modelDidSelect(indexPath: IndexPath) {
        
        self.indexPathModel = indexPath
        
        switch self.step.componentTypes[indexPath.row].getModelType() {
            
        case .dropdown:
            self.performSegue(withIdentifier: "modelPickerSegue", sender: nil)
            break
            
        case .time:
            let componentType = self.step.componentTypes[indexPath.row]
            showDateTimePicker(componentType: componentType, isEndDate: false)
            break
        case .timeRange:
            let componentType = self.step.componentTypes[indexPath.row]
            showDateTimePicker(componentType: componentType, isEndDate: false)
            break
        default:
            self.performSegue(withIdentifier: "modelNumberSegue", sender: nil)
            break
        }
        sendLocalNotification()
    }
    
    func modelEndDateDidSelect(indexPath: IndexPath) {
        
        self.indexPathModel = indexPath
        
        let componentType = self.step.componentTypes[indexPath.row]
        showDateTimePicker(componentType: componentType, isEndDate: true)
        
    }
    

    //MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let chosenImage : UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let imageName = Utils.writeImage(image: chosenImage) {
                self.step.componentTypes[indexPathCamera.row].imagePath = imageName
            }
        }
        dismiss(animated:true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - IQAudioRecorderViewControllerDelegate

    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        self.step.componentTypes[indexPathMic.row].audioPath = filePath
        controller.dismiss(animated: true, completion: nil)
        self.tableView.reloadData()
    }

    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    
    //MARK: - WWCalendarTimeSelectorProtocol

    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm z"
        let componentType = self.step.componentTypes[indexPathModel.row]
        if componentType.getModelType() == .time {
            componentType.modelValue = dateFormatter.string(from: date)
        } else if componentType.getModelType() == .timeRange {
            
            var startDate = ""
            var endDate = ""
            
            if let value = componentType.modelValue {
                let components = value.components(separatedBy: " - ")
                if components.count > 0 {
                    startDate = components[0]
                }
                if components.count > 1 {
                    endDate = components[1]
                }
            }
            if selector.view.tag == 100 {
                startDate = dateFormatter.string(from: date)
            } else if selector.view.tag == 200 {
                endDate = dateFormatter.string(from: date)
            }
            componentType.modelValue = startDate + " - " + endDate

        }
        self.tableView.reloadData()
    }
    
    //MARK: - Utils
    
    func showDateTimePicker(componentType: ComponentType, isEndDate: Bool) {
        let selector = WWCalendarTimeSelector.instantiate()
        selector.view.tag = isEndDate ? 200 : 100
        selector.optionStyles.showTime(true)
        selector.optionTimeStep = .oneMinute
        selector.delegate = self
        if componentType.getModelType() == .timeRange {
            if isEndDate {
                selector.optionTopPanelTitle = "Choose end date"
            } else {
                selector.optionTopPanelTitle = "Choose start date"
            }
        } else {
            if componentType.compTypeDesc != nil && componentType.compTypeDesc.characters.count > 0 {
                selector.optionTopPanelTitle = componentType.compTypeDesc
            } else {
                selector.optionTopPanelTitle = "Choose date"
            }
        }

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm z"
        
        var startDate = ""
        var endDate = ""
        
        if let value = componentType.modelValue {
            let components = value.components(separatedBy: " - ")
            if components.count > 0 {
                startDate = components[0]
            }
            if components.count > 1 {
                endDate = components[1]
            }
            if componentType.getModelType() == .time {
                selector.optionCurrentDate = dateFormatter.date(from: value)!
            } else if componentType.getModelType() == .timeRange {
                if isEndDate {
                    if endDate.characters.count > 0 {
                        selector.optionCurrentDate = dateFormatter.date(from: endDate)!
                    }
                } else {
                    if startDate.characters.count > 0 {
                        selector.optionCurrentDate = dateFormatter.date(from: startDate)!
                    }
                }
            }
        }
        selector.optionCalendarBackgroundColorTodayHighlight = themeTinColor
        selector.optionCalendarBackgroundColorPastDatesHighlight = themeTinColor
        selector.optionCalendarBackgroundColorFutureDatesHighlight = themeTinColor
        selector.optionClockBackgroundColorAMPMHighlight = themeTinColor
        selector.optionClockBackgroundColorHourHighlight = themeTinColor
        selector.optionClockBackgroundColorHourHighlightNeedle = themeTinColor
        selector.optionClockBackgroundColorMinuteHighlight = themeTinColor
        selector.optionClockBackgroundColorMinuteHighlightNeedle = themeTinColor
        selector.optionButtonFontColorCancel = themeTinColor
        selector.optionButtonFontColorDone = themeTinColor
        selector.optionButtonFontColorCancelHighlight = themeTinColor.withAlphaComponent(0.25)
        selector.optionButtonFontColorDoneHighlight = themeTinColor.withAlphaComponent(0.25)
        selector.optionTopPanelBackgroundColor = themeTinColor
        selector.optionSelectorPanelBackgroundColor = themeTinColor.withAlphaComponent(0.9)
        self.present(selector, animated: true, completion: nil)
    }

    func sendLocalNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "modalValueChangedLocalNotificationIdentifier"), object: nil)
    }
}
