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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("First")
        apiRequests.getUserId("Cookieking232") {memberId in
            dispatch_async(dispatch_get_main_queue()){
                self.label.text = memberId
            }
        }
        
        
        

        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

