//
//  CustomCompareCell.swift
//  DestinyCompanion
//
//  Created by Brendan Koning on 11/29/15.
//  Copyright © 2015 Brendan Koning. All rights reserved.
//

import UIKit



class CustomCompareCell: UITableViewCell {
    
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelFirst: UILabel!
    @IBOutlet weak var labelSecond: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
