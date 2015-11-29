//
//  SecondViewController.swift
//  DestinyCompanion
//
//  Created by Brendan Koning on 10/18/15.
//  Copyright © 2015 Brendan Koning. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var titleTableView: UITableView!
    @IBOutlet weak var platformImageTwo: UIImageView!
    @IBOutlet weak var platformImageOne: UIImageView!
    @IBOutlet weak var textInputTwo: UITextField!
    
    @IBOutlet weak var currentGuardianOneLabel: UILabel!
    
    @IBOutlet weak var currentGuardianTwoLabel: UILabel!
    
    @IBOutlet weak var textInputOne: UITextField!
    @IBOutlet weak var tableViewOne: UITableView!
    @IBOutlet weak var tableViewTwo: UITableView!
    
    @IBOutlet weak var guardianTwoSwitch: UISwitch!
    @IBOutlet weak var guardianOneSwitch: UISwitch!
    
    var destiny = DestinyModel()
    
    var currentGuardianOneId = ""
    var currentGuardianOneName = ""
    var currentGuardianOneType = 0
    
    var currentGuardianTwoId = ""
    var currentGuardianTwoName = ""
    var currentGuardianTwoType = 0
    
    var guardianOneStats: [String] = []
    var guardianTwoStats: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        destiny = (tabBarController as! DestinyTabBarController).destiny
        
        self.guardianOneSwitch.addTarget(self, action: Selector("switchChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        self.guardianTwoSwitch.addTarget(self, action: Selector("switchChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        self.guardianOneSwitch.layer.cornerRadius = 16.0
        self.guardianTwoSwitch.layer.cornerRadius = 16.0
        
        self.platformImageOne.image = self.guardianOneSwitch.onImage
        self.currentGuardianOneType = 2
        
        self.platformImageTwo.image = self.guardianTwoSwitch.onImage
        self.currentGuardianTwoType = 2
        
        for _ in destiny.wantedStats{
            guardianOneStats.append("N/A")
            guardianTwoStats.append("N/A")
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonOnePressed(sender: AnyObject) {
        let name = textInputOne.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if(isAlphanumeric(name!)){
            destiny.getUserId(name!, membershipType: self.currentGuardianOneType) {memberId, error in
                dispatch_async(dispatch_get_main_queue()){
                    if(error != "None"){
                        self.currentGuardianOneLabel.text = error
                    }
                    else{
                        self.currentGuardianOneLabel.text = name
                        self.currentGuardianOneLabel.font = UIFont(name: "Helvetica Neue", size: 20)
                        self.currentGuardianOneId = memberId
                        self.currentGuardianOneName = name!
                        self.getStats(self.currentGuardianOneId, membershipType: self.currentGuardianOneType, guardianNumber: 1)
                    }
                }
            }
        }
        else{
            self.currentGuardianOneLabel.text = "Invalid Name"
        }
        
        
    }
    
    
    @IBAction func buttonTwoPressed(sender: AnyObject) {
        let name = textInputTwo.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if(isAlphanumeric(name!)){
            destiny.getUserId(name!, membershipType: self.currentGuardianTwoType) {memberId, error in
                dispatch_async(dispatch_get_main_queue()){
                    if(error != "None"){
                        self.currentGuardianTwoLabel.text = error
                    }
                    else{
                        self.currentGuardianTwoLabel.text = name
                        self.currentGuardianTwoLabel.font = UIFont(name: "Helvetica Neue", size: 20)
                        self.currentGuardianTwoId = memberId
                        self.currentGuardianTwoName = name!
                        self.getStats(self.currentGuardianTwoId, membershipType: self.currentGuardianTwoType, guardianNumber: 2)
                    }
                }
            }
        }
        else{
            self.currentGuardianTwoLabel.text = "Invalid Name"
        }
        
        
        
    }
    
    func getStats(memberId: String, membershipType: Int, guardianNumber: Int){
        destiny.getCharacterStats(memberId, membershipType: membershipType){characterStats in
            var pvpStats = self.destiny.findMergedStats(characterStats)
            var count: Int = 0
            for i in self.destiny.wantedStats{
                if let stat = pvpStats[i] as? Dictionary<String, AnyObject>{
                    if let value = stat["basic"] as? Dictionary<String, AnyObject>{
                        if let displayValue = value["displayValue"] as? String{
                            if(guardianNumber == 1){
                                //TODO: Array fills up with junk when pushing the button a few times.
                                //self.guardianOneStats = []
                                self.guardianOneStats.insert(displayValue, atIndex: count)
                            }
                            if(guardianNumber == 2){
                                //self.guardianTwoStats = []
                                self.guardianTwoStats.insert(displayValue, atIndex: count)
                            }
                            count++
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.tableViewOne.reloadData()
                self.tableViewTwo.reloadData()
                self.compareStats()
                //self.timeLabel.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .LongStyle)
            }
        }
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.destiny.wantedStats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == self.tableViewOne){
            let cell: UITableViewCell = self.tableViewOne.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
            cell.textLabel?.text = self.guardianOneStats[indexPath.row]
            //cell.detailTextLabel?.text = self.guardianOneStats[indexPath.row]
            return cell
        }
        else if(tableView == self.tableViewTwo){
            let cell: UITableViewCell = self.tableViewTwo.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
            cell.textLabel?.text = self.guardianTwoStats[indexPath.row]
            //cell.detailTextLabel?.text = self.guardianTwoStats[indexPath.row]
            return cell
        }
        else{
            let cell: UITableViewCell = self.titleTableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
            cell.textLabel?.text = self.destiny.displayText[indexPath.row]
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell \(indexPath.row)!")
    }
    
    func isAlphanumeric(input: String) -> Bool{
        
        let charSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
        let range = input.rangeOfCharacterFromSet(charSet)
        
        if let _ = range {
            return false
        }
        return true
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    func switchChanged(switchState: UISwitch){
        if(switchState.on){
            //Playstation 2
            if(switchState == self.guardianOneSwitch){
                self.platformImageOne.image = self.guardianOneSwitch.onImage
                self.currentGuardianOneType = 2
                self.textInputOne.placeholder = "Enter PSNID"
            }
            if(switchState == self.guardianTwoSwitch){
                self.platformImageTwo.image = self.guardianTwoSwitch.onImage
                self.currentGuardianTwoType = 2
                self.textInputTwo.placeholder = "Enter PSNID"
            }
            
        }
        else{
            //Xbox 1
            if(switchState == self.guardianOneSwitch){
                self.platformImageOne.image = self.guardianOneSwitch.offImage
                self.currentGuardianOneType = 1
                self.textInputOne.placeholder = "Enter GamerTag"
            }
            if(switchState == self.guardianTwoSwitch){
                self.platformImageTwo.image = self.guardianTwoSwitch.offImage
                self.currentGuardianTwoType = 1
                self.textInputTwo.placeholder = "Enter GamerTag"
            }
            
            
        }
    }
    
    func compareStats(){
        
        for i in 0..<self.destiny.wantedStats.count{
            let index = NSIndexPath.init(forRow: i, inSection: 0)
            
            let cellOne = self.tableViewOne.cellForRowAtIndexPath(index)! as UITableViewCell
            let cellTwo = self.tableViewTwo.cellForRowAtIndexPath(index)! as UITableViewCell
            
            if((cellOne.textLabel!.text != "N/A") && (cellTwo.textLabel!.text != "N/A")){
                
                let cellOneNumber = Double(cellOne.textLabel!.text!)
                let cellTwoNumber = Double(cellTwo.textLabel!.text!)
                
                //print("Comparing \(cellOneNumber) and \(cellTwoNumber)")
                if(cellOneNumber > cellTwoNumber){
                    cellOne.backgroundColor = UIColor.greenColor()
                    cellTwo.backgroundColor = UIColor.whiteColor()
                    //print("Cell1 Larger")
                }
                else{
                    cellOne.backgroundColor = UIColor.whiteColor()
                    cellTwo.backgroundColor = UIColor.greenColor()
                    //print("Cell2Larger")
                    
                }
            }
            
        }

    }
    
    
}

