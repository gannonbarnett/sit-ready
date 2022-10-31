//
//  DashboardCell.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 1/10/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit

class DashboardCell: UITableViewCell {
    static var height : CGFloat {
        if PremiumAccess { return CGFloat(125) } else { return CGFloat(187) }
    }
    @IBOutlet var TotalRaces_Label: UILabel!
    @IBOutlet var TotalTimes_Label: UILabel!
    
    @IBOutlet var upgradeToPremium_Button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
