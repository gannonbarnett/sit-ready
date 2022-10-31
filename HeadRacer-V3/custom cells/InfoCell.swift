//
//  InfoCell.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 1/9/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {
    static let height : CGFloat = CGFloat(86)
    @IBOutlet var AccessLevel_Label: UILabel!
    @IBOutlet var AdminCode_Label: UILabel!
    @IBOutlet var SpectatorCode_Label: UILabel!
    @IBOutlet var AdminCode_StackView: UIStackView!
}
