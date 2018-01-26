//
//  ModelNumberViewController.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 25/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit
import WebKit


class ModelNumberViewController: UIViewController{
 
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtValue: UITextField!
   
    
    var componentType: ComponentType!
    var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //   txtValue.text = componentType.getModelValue()
        // Do any additional setup after loading the view.
    }
 
//    func loadHtmlFile() {
//       let url1 = Bundle.main.url(forResource: "key", withExtension:"html")
//     let request = URLRequest(url: url1!)
//       webView.loadRequest(request)
//         let docString = webView.stringByEvaluatingJavaScript(from: "result")
//            print(docString)
//
//    }
//
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        if let title = componentType.compTypeDesc {
            lblTitle?.text = title
        }
        if let value = componentType.modelValue {
           
            txtValue?.text = value
        }
        
        switch componentType.getModelType() {
        case .double:
            txtValue.keyboardType = .decimalPad
          //  loadHtmlFile()
            break
        case .int:
            txtValue.keyboardType = .numberPad
           
            break
        default:
            break
        }
       txtValue.becomeFirstResponder()
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions
    @IBAction func btnResetTapped(_ sender: Any) {
        txtValue.text = nil
    }
    
    @IBAction func btnDoneTapped(_ sender: Any) {
        txtValue.resignFirstResponder()
        componentType.modelValue = txtValue.text
        self.dismiss(animated: true, completion: nil)
    }
}
