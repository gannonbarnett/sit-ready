//
//  DataTableViewCell.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import UIKit

class DataTableViewCell: UITableViewCell {
    static let height : CGFloat = CGFloat(88)
    
    @IBOutlet var Medal_View: UIView!
    
    @IBOutlet var ID_Label: UILabel!
    @IBOutlet var TotalTime_Label: UILabel!
    @IBOutlet var StartTime_Label: UILabel!
    @IBOutlet var FinishTime_Label: UILabel!
    @IBOutlet var Place_Label: UILabel!
    @IBOutlet var NoData_Label: UILabel!
    
    @IBOutlet var master_StackView: UIStackView!
    
    func setSpacing(_ spacing : CGFloat) {
        master_StackView.spacing = spacing
        self.setNeedsDisplay()
    }

}
