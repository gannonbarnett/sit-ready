//
//  EditDataViewController.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import UIKit
import GoogleMobileAds

class EditDataViewController: UIViewController, GADBannerViewDelegate  {

    var party : PartyData? = nil
        
    @IBOutlet var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataTable = self.childViewControllers[0] as! EditDataTableViewController
        dataTable.party = self.party
        
        if PremiumAccess == false {
            //advertising
            //request
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            
            //set up ad
            bannerView.adUnitID = adID
            bannerView.rootViewController = self
            bannerView.delegate = self
            bannerView.load(GADRequest())
        }else {
            bannerView.isHidden = true
        }
    }
    
    @IBAction func StartAll_ButtonTouched(_ sender: UIButton) {
        let date = Date()
        for time in party!.times {
            party?.updateStartTime(ID: time.key, time: date)
        }
        let dataTable = self.childViewControllers[0] as! EditDataTableViewController
        dataTable.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateAllData()
    }
    
    func updateAllData() {
        let tableView = self.childViewControllers[0] as! EditDataTableViewController
        tableView.collectAllData()
        self.party = tableView.party
        let detail_VC = self.navigationController?.viewControllers[0] as! DetailViewController
        detail_VC.updateParty(to: self.party!)
        
        PartyData.updateToFirebase(data: party!)
    }
}
