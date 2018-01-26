//
//  KeyboardViewController.swift
//  MathCalc
//
//  Created by Niharika Sharma on 2017-10-23.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit


enum Operation {
    case Addition
    case Multiplication
    case Subtraction
    case Division
    case None
}

class KeyboardViewController: UIInputViewController {
var shouldClearDisplayBeforeInserting = true
    var internalMemory = 0.0
    var nextOperation = Operation.None
    var shouldCompute = false
 
    @IBOutlet weak var display: UITextField!
    @IBOutlet var nextKeyboardButton: UIButton!
     var calculatorView: UIView!
    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterface()
        // Perform custom UI setup here
        clearDisplay()
        self.nextKeyboardButton = UIButton(type: .system)
     
       
 
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        self.nextKeyboardButton.isHidden = true
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    @IBAction func clearDisplay() {
        display.text = "0"
        (textDocumentProxy as UIKeyInput).deleteBackward()
        internalMemory = 0
        nextOperation = Operation.Addition
        shouldClearDisplayBeforeInserting = true
    }
    
    @IBAction func didTapNumber(number: UIButton) {
        if shouldClearDisplayBeforeInserting {
            display.text = ""
            shouldClearDisplayBeforeInserting = false
        }

        if var numberAsString = number.titleLabel?.text {
            var numberAsNSString = numberAsString as NSString
            if var oldDisplay = display?.text! {
                display.text = "\(oldDisplay)\(numberAsNSString.intValue)"
            } else {
                display.text = "\(numberAsNSString.intValue)"
            }
        }
        let button = number as! UIButton
        let title = button.title(for: .normal)
        (textDocumentProxy as UIKeyInput).insertText(title!)
        
    }
    
    @IBAction func didTapDot() {
        if let input = display?.text {
            var hasDot = false
            for ch in input.unicodeScalars {
                if ch == "." {
                    hasDot = true
                    break
                }
            }
            if hasDot == false {
                display.text = "\(input)."
            }
        }
    }
    
    @IBAction func didTapInsert() {
        var proxy = textDocumentProxy as UITextDocumentProxy
        
        if let input = display?.text as String? {
            proxy.insertText(input)
        }
    }
   
  
    
    func loadInterface() {
        // load the nib file
        let calculatorNib = UINib(nibName: "newkeyboard", bundle: nil)
        // instantiate the view
        calculatorView = calculatorNib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        // add the interface to the main view
        view.addSubview(calculatorView)
        
        // copy the background color
        view.backgroundColor = calculatorView.backgroundColor
    }
    
    @IBAction func computeLastOperation() {
        // remember not to compute if another operation is pressed without inputing another number first
        shouldCompute = false
        
        if var input = display?.text {
            var inputAsDouble = (input as NSString).doubleValue
            var result = 0.0
            
            // apply the operation
            switch nextOperation {
            case .Addition:
                result = internalMemory + inputAsDouble
            case .Subtraction:
                result = internalMemory - inputAsDouble
            case .Multiplication:
                result = internalMemory * inputAsDouble
            case .Division:
                result = internalMemory / inputAsDouble
            default:
                result = 0.0
            }
            
            nextOperation = Operation.None
            
            var output = "\(result)"
            
            // if the result is an integer don't show the decimal point
            if output.hasSuffix(".0") {
                output = "\(Int(result))"
            }
            
            // truncatingg to last five digits
            var components = output.components(separatedBy:".")
            if components.count >= 2 {
                var beforePoint = components[0]
                var afterPoint = components[1]
//                if afterPoint.lengthOfBytes(using: String.Encoding.utf8) > 5 {
//                    let index: String.Index = advance(afterPoint.startIndex, 5)
//                    afterPoint = afterPoint.substringToIndex(index)
//                }
                output = beforePoint + "." + afterPoint
            }
            
            
            // update the display
            display.text = output
            
            // save the result
            internalMemory = result
            
            // remember to clear the display before inserting a new number
            shouldClearDisplayBeforeInserting = true
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

}
