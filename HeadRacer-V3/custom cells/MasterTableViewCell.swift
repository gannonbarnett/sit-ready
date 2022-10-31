//
//  MasterTableViewCell.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 1/3/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit

class MasterTableViewCell: UITableViewCell {
    static let height = CGFloat(70)
    
    @IBOutlet var PartyName_Label: UILabel!
    @IBOutlet var Date_Label: UILabel!
    
    @IBOutlet var PartyCreator_Label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
