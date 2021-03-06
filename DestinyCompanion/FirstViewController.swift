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
   
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var platformSwitch: UISwitch!
    @IBOutlet weak var platformImage: UIImageView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var statTable: UITableView!
    @IBOutlet weak var currentPlayerLabel: UITextView!
    
    var destiny = DestinyModel()
    
    let PLAYSTATION = 2
    let XBOX = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tbc = tabBarController as! DestinyTabBarController
        destiny = tbc.destiny
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.nameInput.delegate = self
        self.platformSwitch.addTarget(self, action: Selector("switchChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        //This is needed to make the switch look right in the "off" position
        self.platformSwitch.layer.cornerRadius = 16.0
        
        //Playstation
        self.platformImage.image = self.platformSwitch.onImage
        self.destiny.setMemberType(2)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        statTable.tableFooterView = UIView()
        
        self.currentPlayerLabel.textContainer.lineFragmentPadding = 0
        
        for _ in destiny.wantedStats{
            destiny.stats.append("N/A")
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        let name = nameInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if(isAlphanumeric(name!)){
            destiny.getUserId(name!, membershipType: destiny.memberType) {memberId, error in
                dispatch_async(dispatch_get_main_queue()){
                    if(error != "None"){
                        self.currentPlayerLabel.text = error
                    }
                    else{
                        self.destiny.setMemberId(memberId)
                        self.currentPlayerLabel.text = name
                        self.currentPlayerLabel.font = UIFont(name: "Helvetica Neue", size: 20)
                        self.getStatsPressed(self)
                    }          
                }
            }
        }
        else{
            self.currentPlayerLabel.text = "Invalid Name"
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
            self.destiny.setMemberType(PLAYSTATION)
            self.nameInput.placeholder = "Enter PSNID"
        }
        else{
            //Xbox
            self.platformImage.image = self.platformSwitch.offImage
            self.destiny.setMemberType(XBOX)
            self.nameInput.placeholder = "Enter GamerTag"
            
        }
    }
    
    @IBAction func getStatsPressed(sender: AnyObject) {
        destiny.getCharacterStats(self.destiny.memberId, membershipType: self.destiny.memberType){characterStats in
            print("PvP Stats")
            self.destiny.characterStats = characterStats
            var pvpStats = self.destiny.findMergedStats(characterStats)
            var count: Int = 0
            for i in self.destiny.wantedStats{
                if let stat = pvpStats[i] as? Dictionary<String, AnyObject>{
                    if let basic = stat["basic"] as? Dictionary<String, AnyObject>{
                        if(i == "secondsPlayed"){
                            if let value = basic["value"] as? Int{
                                self.destiny.stats[count] = String(value)
                                count++
                            }
                        }
                        else if let displayValue = basic["displayValue"] as? String{
                            self.destiny.stats[count] = displayValue
                            count++
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.statTable.reloadData()
                self.timeLabel.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .LongStyle)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.destiny.wantedStats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.statTable.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        let displayText = self.destiny.displayText[indexPath.row]
        var statText = self.destiny.stats[indexPath.row]
        
        if(displayText == "Time Played" && statText != "N/A"){
            let value = Int(statText)!
            let seconds = value % 60
            let minutes = (value / 60) % 60
            let hours = (value / 3600) % 24
            let days = (value / 86400)
            statText = "\(days)d:\(hours)h:\(minutes)m:\(seconds)s"
        }
        
        cell.textLabel?.text = displayText
        cell.detailTextLabel?.text = statText
        
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
    
    @IBAction func setPrimaryGuardian(sender: AnyObject) {
        destiny.setPrimaryGuardian()
        print("Primary Guardian is: \(destiny.primaryGuardianId)")
    }

    
    
}

