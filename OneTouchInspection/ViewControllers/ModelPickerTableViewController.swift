//
//  ModelPickerTableViewController.swift
//  OneTouchInspection
//
//  Created by Ullas Joseph on 25/01/17.
//  Copyright © 2017 BeaconTree. All rights reserved.
//

import UIKit

class ModelPickerTableViewController: UITableViewController {

    var componentType: ComponentType!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return componentType.modelOptions.components(separatedBy: ",").count
  
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelPickerTableCell", for: indexPath)

        // Configure the cell...
        let value = componentType.modelOptions.components(separatedBy: ",")[indexPath.row]
        cell.textLabel?.text = value
        
        
        if componentType.modelValue != nil && value.caseInsensitiveCompare(componentType.modelValue) == ComparisonResult.orderedSame {
            cell.backgroundColor = UIColor.green
        } else {
            if value.caseInsensitiveCompare("black") == ComparisonResult.orderedSame {
                cell.backgroundColor = UIColor.black
                cell.textLabel?.textColor = UIColor.white
            } else if value.caseInsensitiveCompare("brown") == ComparisonResult.orderedSame {
                cell.backgroundColor = UIColor.brown
                cell.textLabel?.textColor = UIColor.white
            } else if value.caseInsensitiveCompare("red") == ComparisonResult.orderedSame {
                cell.backgroundColor = UIColor.red
                cell.textLabel?.textColor = UIColor.white
            } else if value.caseInsensitiveCompare("green") == ComparisonResult.orderedSame {
                cell.backgroundColor = UIColor.green
                cell.textLabel?.textColor = UIColor.white
            } else if value.caseInsensitiveCompare("yellow") == ComparisonResult.orderedSame {
                cell.backgroundColor = UIColor.yellow
                cell.textLabel?.textColor = UIColor.black
            } else {
                cell.backgroundColor = UIColor.lightGray
                cell.textLabel?.textColor = UIColor.black
            }
        }
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        componentType.modelValue = componentType.modelOptions.components(separatedBy: ",")[indexPath.row]
        self.dismiss(animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions
    
    @IBAction func btnCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


}
