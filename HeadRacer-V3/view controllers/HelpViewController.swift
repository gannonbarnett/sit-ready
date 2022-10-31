//
//  HelpViewController.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 1/4/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class HelpViewController: UIViewController {


    @IBOutlet var Help_TextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Help_TextView!.text = "Confused? Here are some tips:\n\n  -  To create a new race, click the plus, enter a race name and your name, and press \"Create Race.\"\n\n  -  To join an existing race, make sure you're connected to the internet, and enter the code you were given.\n\n  -  The spectator code will give people access to view the live race results, but not to record times.\n\n  -  The admin code will give people access to view and to record race results.\n\n  -  To record a race result, make sure your access level is \"Admin\" and press the \"Record Data\" button.\n\n  -  Make sure you are looking at the latest results by pressing the \"reload\" button.\n\n - If you would like to report a bug, please contact us using the link below."
    }
    
    @IBAction func ContactUs_ButtonTouched(_ sender: UIButton) {
        let url = URL(string: "https://sitreadyapp.wordpress.com/contact/")!
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
