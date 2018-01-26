//
//  ComponentTypeTableViewCell.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 24/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import M13Checkbox
import MMSegmentSlider

protocol ComponentTypeTableViewCellDelegate {
    func checkboxDidSelect()
    func cameraDidSelect(indexPath: IndexPath)
    func micDidSelect(indexPath: IndexPath)
    func modelDidSelect(indexPath: IndexPath)
    func modelEndDateDidSelect(indexPath: IndexPath)
}

class ComponentTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var checkboxWidth: NSLayoutConstraint!
    @IBOutlet weak var cameraHeight: NSLayoutConstraint!
    @IBOutlet weak var micHeight: NSLayoutConstraint!
    @IBOutlet weak var modelHeight: NSLayoutConstraint!
    @IBOutlet weak var modelEndDateHeight: NSLayoutConstraint!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var lblCamera: UILabel!
    @IBOutlet weak var btnMic: UIButton!
    @IBOutlet weak var lblMic: UILabel!
    
    @IBOutlet weak var checkbox: M13Checkbox!

    @IBOutlet weak var btnModelValue: UIButton!
    @IBOutlet weak var btnModelEndDate: UIButton!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var sliderModelValue: MMSegmentSlider!

    @IBOutlet weak var lblSlider: UILabel!
    var componentType: ComponentType!
    
    var delegate: ComponentTypeTableViewCellDelegate?
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkbox.boxLineWidth = 4
        checkbox.checkmarkLineWidth = 6
        checkbox.cornerRadius = 3
        checkbox.boxType = .square
        checkbox.tintColor = themeTinColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Actions
    
    @IBAction func btnCameraTapped(_ sender: Any) {
        
        delegate?.cameraDidSelect(indexPath: self.indexPath)
    }
    
    @IBAction func checkboxValueChanged(_ sender: M13Checkbox) {
        
        if self.componentType.getModelType() == .bool {
            if sender.checkState == .checked {
                componentType.modelValue = "Yes"
            } else {
                componentType.modelValue = "No"
            }
            componentType.modelValueRecorded = true
        } else {
            if sender.checkState == .checked {
                componentType.defectID = 1
            } else {
                componentType.defectID = 0
            }
        }
        

        delegate?.checkboxDidSelect()
    }
    
    @IBAction func btnMicTapped(_ sender: Any) {
        delegate?.micDidSelect(indexPath: self.indexPath)
    }
    
    @IBAction func btnModelValueTapped(_ sender: Any) {
        componentType.modelValueRecorded = true
        btnModelValue.backgroundColor = UIColor.green
        delegate?.modelDidSelect(indexPath: self.indexPath)
    }
    
    @IBAction func btnModelEndDateTapped(_ sender: Any) {
        componentType.modelValueRecorded = true
        btnModelValue.backgroundColor = UIColor.green
        delegate?.modelEndDateDidSelect(indexPath: self.indexPath)
    }

    
    @IBAction func sliderModelValueChanged(_ sender: MMSegmentSlider) {
        let value: Double = sender.values[sender.selectedItemIndex] as! Double
        componentType.modelValue = String(value)
        self.sliderView.layer.borderColor = UIColor.green.cgColor
        self.sliderView.layer.borderWidth = 2.0
        self.sliderView.layer.cornerRadius = 5.0
        componentType.modelValueRecorded = true
    }
    
    // MARK: - Utils

    func configur(type: ComponentType, indexPath: IndexPath) {
        
        self.componentType = type
        self.indexPath = indexPath
        self.modelEndDateHeight.constant = 0
        lblTitle.text = type.compTypeDesc
        
        if type.requiresCheckbox == 0 {
            checkboxWidth.constant = 0
            checkbox.isHidden = true
        } else {
            checkboxWidth.constant = 64
            checkbox.isHidden = false
        }
        
        if type.imagePath != nil && type.imagePath.characters.count > 0 {
            btnCamera.setImage(Utils.readImage(name: type.imagePath), for: .normal)
            lblCamera.textColor = UIColor.green
            lblCamera.text = "Photo Taken"
        } else {
            btnCamera.setImage(UIImage.init(named: "camera"), for: .normal)
            lblCamera.textColor = UIColor.red
            lblCamera.text = "Photo Option"
        }
        
        if type.audioPath != nil && type.audioPath.characters.count > 0 {
            lblMic.textColor = UIColor.green
            lblMic.text = "Audio Recorded"
        } else {
            lblMic.textColor = UIColor.red
            lblMic.text = "Audio Option"
        }
        
        if type.defectID.intValue > 0 {
            checkbox.setCheckState(.checked, animated: false)

            if type.requiresPicture.intValue > 0 {
                cameraHeight.constant = 64
            } else {
                cameraHeight.constant = 0
            }
            if type.requiresAudio.intValue > 0 {
                micHeight.constant = 64
            } else {
                micHeight.constant = 0
            }
        } else {
            checkbox.setCheckState(.unchecked, animated: false)
            cameraHeight.constant = 0
            micHeight.constant = 0
        }

        btnModelValue.isHidden = true
        sliderView.isHidden = true
        
        switch type.getModelType() {
            
        case .range:
            
            modelHeight.constant = 75
            sliderView.isHidden = false
            
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            
            var values: [Double] = [Double]()
            var labels: [String] = [String]()

            var min: Double = 0
            var max: Double = 1
            var step: Double = 0.25

            if let options = componentType.modelOptions {
                let components = options.components(separatedBy: ",")
                if components.count > 2 {
                    if let minVal = Double(components[0]) {
                        min = minVal
                    }
                    if let maxVal = Double(components[1]) {
                        max = maxVal
                    }
                    if let stepVal = Double(components[2]) {
                        step = stepVal
                    }
                }
            }
            
            var i : Double = min
            
            while i <= max {
                values.append(i)
                labels.append(formatter.string(for: i)!)
                i += step
            }
            sliderModelValue.values = values
            sliderModelValue.labels = labels

            if type.modelValue != nil && type.modelValue.characters.count > 0 {
                if let index = values.index(of: Double(type.modelValue)!) {
                    sliderModelValue.setSelectedItemIndex(index, animated: false)
                }
                componentType.modelValueRecorded = true
            } else {
                sliderModelValue.setSelectedItemIndex(0, animated: false)
                componentType.modelValueRecorded = false
            }
            if type.modelValueRecorded {
                self.sliderView.layer.borderColor = UIColor.green.cgColor
                self.sliderView.layer.borderWidth = 2.0
                self.sliderView.layer.cornerRadius = 5.0
            } else {
                self.sliderView.layer.borderColor = UIColor.clear.cgColor
                self.sliderView.layer.borderWidth = 0.0
                self.sliderView.layer.cornerRadius = 5.0
            }
            
            break
            
        case .double, .int:
            
            modelHeight.constant = 64
            btnModelValue.isHidden = false

            if type.modelValue == nil || type.modelValue.characters.count == 0 {
                btnModelValue.setTitle("Enter Data", for: .normal)
                btnModelValue.setTitleColor(UIColor.white, for: .normal)
                type.modelValueRecorded = false
            } else {
                btnModelValue.setTitle(type.modelValue, for: .normal)
                btnModelValue.setTitleColor(UIColor.black, for: .normal)
                type.modelValueRecorded = true
            }
            
            btnModelValue.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
            
            if type.modelValueRecorded {
                
                btnModelValue.backgroundColor = UIColor.green

                if type.findDefectType().caseInsensitiveCompare("major") == ComparisonResult.orderedSame {
                    btnModelValue.backgroundColor = UIColor.red
                } else if type.findDefectType().caseInsensitiveCompare("minor") == ComparisonResult.orderedSame {
                    btnModelValue.backgroundColor = UIColor.yellow
                } else if type.findDefectType().caseInsensitiveCompare("Other") == ComparisonResult.orderedSame {
                    btnModelValue.backgroundColor = Utils.hexStringToUIColor(hex: "#ADD8E6")
                }
                
            } else {
                btnModelValue.backgroundColor = Utils.hexStringToUIColor(hex: "#C8C8C8")
            }
            break
        case .dropdown:
            
            modelHeight.constant = 64
            btnModelValue.isHidden = false
            
            if type.modelValue == nil || type.modelValue.characters.count == 0 {
                btnModelValue.setTitle("Choose Value", for: .normal)
                btnModelValue.setTitleColor(UIColor.white, for: .normal)
                type.modelValueRecorded = false
            } else {
                btnModelValue.setTitle(type.modelValue, for: .normal)
                btnModelValue.setTitleColor(UIColor.black, for: .normal)
                type.modelValueRecorded = true
            }
            
            btnModelValue.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
            
            if type.modelValueRecorded {
                btnModelValue.backgroundColor = UIColor.green
            } else {
                btnModelValue.backgroundColor = Utils.hexStringToUIColor(hex: "#C8C8C8")
            }
            if (componentType.getModelValue() == "") {
                componentType.setModelValue(modelValue: "");
            }
            
            break
        case .time:
            modelHeight.constant = 64
            btnModelValue.isHidden = false
            
            if type.modelValue == nil || type.modelValue.characters.count == 0 {
                btnModelValue.setTitle("Choose Date", for: .normal)
                btnModelValue.setTitleColor(UIColor.white, for: .normal)
                type.modelValueRecorded = false
            } else {
                btnModelValue.setTitle(type.modelValue, for: .normal)
                btnModelValue.setTitleColor(UIColor.black, for: .normal)
                type.modelValueRecorded = true
            }
            
            btnModelValue.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
            
            if type.modelValueRecorded {
                btnModelValue.backgroundColor = UIColor.green
            } else {
                btnModelValue.backgroundColor = Utils.hexStringToUIColor(hex: "#C8C8C8")
            }
            break
        case .timeRange:
            modelHeight.constant = 120
            modelEndDateHeight.constant = 60
            btnModelValue.isHidden = false
            
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
            
            if startDate.characters.count == 0 {
                btnModelValue.setTitle("Choose Start Date", for: .normal)
                btnModelValue.setTitleColor(UIColor.white, for: .normal)
                btnModelValue.backgroundColor = Utils.hexStringToUIColor(hex: "#C8C8C8")
            } else {
                btnModelValue.setTitle(startDate, for: .normal)
                btnModelValue.setTitleColor(UIColor.black, for: .normal)
                btnModelValue.backgroundColor = UIColor.green
            }
            
            if endDate.characters.count == 0 {
                btnModelEndDate.setTitle("Choose End Date", for: .normal)
                btnModelEndDate.setTitleColor(UIColor.white, for: .normal)
                btnModelEndDate.backgroundColor = Utils.hexStringToUIColor(hex: "#C8C8C8")
            } else {
                btnModelEndDate.setTitle(endDate, for: .normal)
                btnModelEndDate.setTitleColor(UIColor.black, for: .normal)
                btnModelEndDate.backgroundColor = UIColor.green
            }
            
            btnModelValue.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
            btnModelEndDate.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)

            if startDate.characters.count > 0 && endDate.characters.count > 0 {
                type.modelValueRecorded = true
            } else {
                type.modelValueRecorded = false
            }
            break
            
        case .bool:
            modelHeight.constant = 0
            
            if type.modelValue != nil && type.modelValue.characters.count > 0 {
                
                if type.modelValue.caseInsensitiveCompare("Yes") == ComparisonResult.orderedSame {
                    checkbox.setCheckState(.checked, animated: false)
                } else {
                    checkbox.setCheckState(.unchecked, animated: false)
                }
                type.modelValueRecorded = true
            } else {
                type.modelValueRecorded = false
            }
            
            break
        default:
            modelHeight.constant = 0
            break
        }
        
    }
}
