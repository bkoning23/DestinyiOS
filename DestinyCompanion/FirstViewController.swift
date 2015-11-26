//
//  FirstViewController.swift
//  DestinyCompanion
//
//  Created by Brendan Koning on 10/18/15.
//  Copyright © 2015 Brendan Koning. All rights reserved.
//

import UIKit
import Alamofire


class FirstViewController: UIViewController {
    
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var nameInput: UITextField!
    
    var memberType: Int = 0
    var memberId: String = ""
    
    var api = apiRequests()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchPressed(sender: AnyObject) {
        let name = nameInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if(verifyAlphanumeric(name!)){
            api.getUserId(name!) {memberId, membershipType in
                dispatch_async(dispatch_get_main_queue()){
                    self.successLabel.text = memberId
                }
            }
        }
        else{
            self.successLabel.text = "Invalid Name"
            
        }
        nameInput.resignFirstResponder()        
    }
    
    /*
    Checks that provided name is only alphanumeric.
    Set is everything that is not alphanumeric, range is nil
    if nothing is found in the set, failing the if statement.
    */
    func verifyAlphanumeric(input: String) -> Bool{
    
        let charSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
        let range = input.rangeOfCharacterFromSet(charSet)
        
        if let _ = range {
            print("not Okay")
            return false
        }
        return true
        
    }
    
    
}

