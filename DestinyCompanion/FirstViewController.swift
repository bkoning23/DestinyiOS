//
//  FirstViewController.swift
//  DestinyCompanion
//
//  Created by Brendan Koning on 10/18/15.
//  Copyright © 2015 Brendan Koning. All rights reserved.
//

import UIKit


class FirstViewController: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var label: UILabel!
    
    var memberType: Int = 0
    var memberId: String = ""
    
    var api = apiRequests()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("First")
        api.getUserId("Cookieking232") {memberId, membershipType in
            dispatch_async(dispatch_get_main_queue()){
                self.label.text = memberId
            }
            self.memberId = memberId
            self.memberType = membershipType
            self.api.getGames(self.memberId, membershipType: self.memberType){}
            
        }
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

