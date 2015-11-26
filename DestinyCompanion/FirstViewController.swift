//
//  FirstViewController.swift
//  DestinyCompanion
//
//  Created by Brendan Koning on 10/18/15.
//  Copyright © 2015 Brendan Koning. All rights reserved.
//

import UIKit
import Alamofire



class FirstViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
   
    
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var platformSwitch: UISwitch!
    @IBOutlet weak var platformImage: UIImageView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var statTable: UITableView!
    
    
    var memberType: Int = 0
    var memberId: String = ""
    
    var api = apiRequests()
    
    var items: [String] = ["asdf", "fdas", "123"]
    var wantedStats: [String] = ["killsDeathsRatio"]
    
    var stats: [String] = ["N/A"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.nameInput.delegate = self
        self.platformSwitch.addTarget(self, action: Selector("switchChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        //This is needed to make the switch look right in the "off" position
        self.platformSwitch.layer.cornerRadius = 16.0
        
        //Playstation
        self.platformImage.image = self.platformSwitch.onImage
        self.memberType = 2
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        let name = nameInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if(isAlphanumeric(name!)){
            api.getUserId(name!, membershipType: memberType) {memberId, error in
                dispatch_async(dispatch_get_main_queue()){
                    if(error != "None"){
                        self.successLabel.text = error
                    }
                    else{
                        self.successLabel.text = memberId
                        self.memberId = memberId
                    }
                    
                }
            }
        }
        else{
            self.successLabel.text = "Invalid Name"
        }
        dismissKeyboard()
    }
    
    /*
    Checks that provided name is only alphanumeric.
    Set is everything that is not alphanumeric, range is nil
    if nothing is found in the set, failing the if statement.
    */
    func isAlphanumeric(input: String) -> Bool{
    
        let charSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
        let range = input.rangeOfCharacterFromSet(charSet)

        if let _ = range {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        searchPressed(textField)
        return true
    }
    
    func switchChanged(switchState: UISwitch){
        if(switchState.on){
            //Playstation
            self.platformImage.image = self.platformSwitch.onImage
            self.memberType = 2
            self.nameInput.placeholder = "Enter PSNID"
        }
        else{
            //Xbox
            self.platformImage.image = self.platformSwitch.offImage
            self.memberType = 1
            self.nameInput.placeholder = "Enter GamerTag"
            
        }
    }
    
    @IBAction func getStatsPressed(sender: AnyObject) {
        api.getPvPStats(self.memberId, membershipType: self.memberType){pvpStats in
            print("PvP Stats")
            print(pvpStats)
            var count: Int = 0
            for i in self.wantedStats{
                
                if let stat = pvpStats[i] as? Dictionary<String, AnyObject>{
                    if let value = stat["basic"] as? Dictionary<String, AnyObject>{
                        if let displayValue = value["displayValue"] as? String{
                            self.stats.insert(displayValue, atIndex: count)
                            count++
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.statTable.reloadData()
                
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wantedStats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = self.statTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.wantedStats[indexPath.row]
        cell.detailTextLabel?.text = self.stats[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell \(indexPath.row)!")
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

    
    
}

