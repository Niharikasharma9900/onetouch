//
//  keyViewController.swift
//  OneTouchInspection
//
//  Created by Niharika Sharma on 2017-10-17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit

class keyViewController: UIViewController,UIWebViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let myWebView:UIWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        self.view.addSubview(myWebView)
        
        myWebView.delegate = self
        
        
        //3. Load local html file into web view
        let myProjectBundle:Bundle = Bundle.main
        
        let filePath:String = myProjectBundle.path(forResource: "key", ofType: "html")!
        
        let myURL = URL(string: filePath);
        let myURLRequest:URLRequest = URLRequest(url: myURL!)
        
        myWebView.loadRequest(myURLRequest)
    }
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        print("Started to load")
    }
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        print("Finished loading")
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

}
