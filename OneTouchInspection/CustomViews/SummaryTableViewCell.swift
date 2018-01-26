//
//  SummaryTableViewCell.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 29/03/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import M13Checkbox

class SummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var checkboxWidth: NSLayoutConstraint!

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRoot: UILabel!
    @IBOutlet weak var lblModelValue: UILabel!
    
    @IBOutlet weak var checkBox: M13Checkbox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBox.boxLineWidth = 4
        checkBox.checkmarkLineWidth = 6
        checkBox.cornerRadius = 3
        checkBox.boxType = .square
        checkBox.tintColor = themeTinColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Utils
    
    func configur(defect: SubmitDefect, indexPath: IndexPath) {
        
        self.lblModelValue.isHidden = false
        self.checkBox.isUserInteractionEnabled = false
        
        if defect.requiresCheckbox == 0 {
            checkboxWidth.constant = 0
            checkBox.isHidden = true
        } else {
            checkboxWidth.constant = 64
            checkBox.isHidden = false
        }
        
        if let title = defect.componentTypeDesc {
            self.lblTitle.text = title
        }
        if let root = defect.root {
            self.lblRoot.text = root
        }
        if defect.modelTypeID.intValue > 0 {
            if let value = defect.modelValue {
                self.lblModelValue.text = value
            } else {
                self.lblModelValue.text = nil
            }
        } else {
            self.lblModelValue.isHidden = true
        }

        if defect.defectId != nil && defect.defectId.intValue > 0 {
            checkBox.setCheckState(.checked, animated: false)
        } else {
            checkBox.setCheckState(.checked, animated: false)
        }
        
        self.layoutIfNeeded()
    }
}
    
