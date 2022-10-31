//
//  MasterViewController.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
//import Firebase
import SystemConfiguration
import GoogleMobileAds

//global variables
var sharedSecret = "4a299374c45d421488af1bc73b19acfd"
var adID = "ca-app-pub-6058033124995096/7869033775"

var PremiumAccess : Bool = true

let MaxRaces_NonPremium = 15
let MaxEntries_NonPremium = 15

class MasterViewController: UITableViewController, GADBannerViewDelegate {
    
    var detailViewController: DetailViewController? = nil
    var parties = [PartyData]()
    
    var dates = [Date : [PartyData]]()
    
    @IBOutlet var TotalRaces_Label: UILabel!
    @IBOutlet var MostPopularRace_Label: UILabel!
    @IBOutlet var MostConnections_Label: UILabel!
    
    
    //dictionary of race codes and parties. used for checking for identical parties
    var codes : [String : (Int, PartyData)] {
        var dict : [String : (Int, PartyData)] = [:]
        for i in 0 ..< parties.count {
            let p = parties[i]
            dict[p.raceCode] = (i, p)
        }
        return dict
    }

    var totalTimes : Int {
        var counter = 0
        for party in parties {
            for data in party.times.values {
                if data.elapsedTimeSeconds != nil {
                    counter += 1
                }
            }
        }
        return counter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loadedParties = loadParties() {
            self.parties = loadedParties
        }
        
        //PremiumAccess = UserDefaults.standard.bool(forKey: "Premium")
        self.tableView.reloadData()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    @IBAction func upgradeToPremium_ButtonTouched(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let upgrade_VC = storyBoard.instantiateViewController(withIdentifier: "UpgradeViewController") as! UpgradeViewController
        self.navigationController!.pushViewController(upgrade_VC, animated: true)
    }
    
    
    //advertising 
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func saveParties() {
        let _ = NSKeyedArchiver.archiveRootObject(parties, toFile: PartyData.ArchiveURL.path)
    }
    
    private func loadParties() -> [PartyData]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: PartyData.ArchiveURL.path) as? [PartyData]
    }

    func clearSavedData() {
        let fileDirectory = FileManager()
        let _ = try? fileDirectory.removeItem(atPath: PartyData.ArchiveURL.path)

    }
    
    func updateParty(to party: PartyData) {
        let code = party.raceCode
        let index = codes[code]!.0
        parties[index] = party
        saveParties()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {

                let party = parties[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.party = party
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    //first section is dashboard, has one cell.
    //second section is ad, has one cell
    //third section is partycells, number of cells is number of races.
    
    @objc
    func addParty(_ party : PartyData) {
        parties.insert(party, at: parties.count)
        let section = PremiumAccess ? 1 : 2
        let indexPath = IndexPath(row: parties.count - 1, section: section)
        
        //if this is the only party existing, replace no races cell. Otherwise insert new row.
        if parties.count != 1 {
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
        saveParties()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //dashboard and ad and party cells.
        //if PremiumAccess { return 2 }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

//        //if premium access, no adcell
//        if !PremiumAccess {
//            if section == 1 { return 1 }
//        }
        
        
        if parties.count == 0 {
            tableView.separatorStyle = .none
            return 1
        } else {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        }
        return parties.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //first section is dashbaord
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath) as! DashboardCell
            
//            if PremiumAccess {
//                cell.upgradeToPremium_Button.isHidden = true
//            }else {
//                cell.upgradeToPremium_Button.isHidden = false
//            }
            
            cell.TotalRaces_Label.text = String(parties.count)
            cell.TotalTimes_Label.text = String(totalTimes)
            return cell
        }
        
//        //If Premium access, no adcell
//        if PremiumAccess == false{
//            if indexPath.section == 1 {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as! AdCell
//                let request = GADRequest()
//                request.testDevices = [kGADSimulatorID]
//
//                //set up ad
//                cell.bannerView.adUnitID = adID
//                cell.bannerView.rootViewController = self
//                cell.bannerView.delegate = self
//                cell.bannerView.load(GADRequest())
//
//                return cell
//            }
//        }
        
        guard parties.count != 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoRacesCell", for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartyCell", for: indexPath) as! MasterTableViewCell
        let party = parties[indexPath.row]
        cell.PartyName_Label.text! = party.name
        cell.PartyCreator_Label!.text! = party.creatorName
        cell.Date_Label!.text! = party.getDate()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return DashboardCell.height
        }
        
//        //if premium access, no adcell section
//        if !PremiumAccess {
//            if indexPath.section == 1 {
//                return AdCell.height
//            }
//        }
//
        return MasterTableViewCell.height
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //first section is dashbaord
        if indexPath.section == 0 { return false }
        if parties.count == 0 {
            return false
        }
//        if !PremiumAccess {
//            if indexPath.section == 1 { return false }
//        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.section != 0 else {
            return
        }
        
//        if !PremiumAccess {
//            guard indexPath.section != 1 else {
//                return
//            }
//        }
        
        if editingStyle == .delete {
            parties.remove(at: indexPath.row)
            
            //if there are no more parties, don't delete last row.
            if parties.count != 0 {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            saveParties()
            tableView.reloadData()
        }
    }
}

