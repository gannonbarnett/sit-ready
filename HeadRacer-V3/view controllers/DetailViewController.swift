//
//  DetailViewController.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DetailViewController: UIViewController, GADBannerViewDelegate  {
    static var sort : SortMethod = .Place
    static var showMedals : Bool = true
    var party : PartyData? = nil
    
    @IBOutlet var bannerView: GADBannerView!
    
    @IBOutlet var container_View: UIView!
    
    @IBOutlet var ContainerViewBottom_Layout: NSLayoutConstraint!
    
    @IBOutlet var RecordData_Button: UIButton!
    
    enum SortMethod {
        case ID, Place
    }
    
    var data_TableVC : DataTableViewController {
        return self.childViewControllers[0] as! DataTableViewController
    }
    
    var MasterVC : MasterViewController {
        return self.navigationController?.splitViewController?.viewControllers[0].childViewControllers[0] as! MasterViewController
    }
    
    func configureView() {
        self.title = party!.name
        if party!.access == .Spectator {
            RecordData_Button.isHidden = true
        } else {
            RecordData_Button.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.setNeedsDisplay()
        data_TableVC.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data_TableVC.party = self.party!
        configureView()
        
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
        } else {
            bannerView.removeFromSuperview()
            bannerView.isHidden = true
            ContainerViewBottom_Layout.constant = CGFloat(0)
        }
    }

    func updateParty(to party: PartyData) {
        self.party = party
        self.title! = party.name
        data_TableVC.party = party
        data_TableVC.tableView.reloadData()
        MasterVC.saveParties()
        MasterVC.updateParty(to: party)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Reload_ButtonTouched(_ sender: UIButton) {
        let code = party!.access == .Admin ? party!.adminCode : party!.spectatorCode
        var reloadParty : PartyData? = nil
        
        let ref = Database.database().reference()
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childSnapshot(forPath: "Codes").hasChild(code){
                
                //if code is present, get data.
                
                //don't change local access level
                let accessLevel = self.party!.access
                                
                var fullCode = "" //full code represents the access level combined with the race code.
                fullCode = snapshot.childSnapshot(forPath: "Codes").childSnapshot(forPath: code).value as! String
            
                var raceCode = fullCode ; raceCode.removeFirst(6) //remove prefix
                
                let RaceDataRef = snapshot.childSnapshot(forPath: "Races").childSnapshot(forPath: raceCode)
                let name : String = RaceDataRef.childSnapshot(forPath: "Name").value as! String
                let creatorName : String = RaceDataRef.childSnapshot(forPath:"CreatorName").value as! String
                let dateCreated : Date = Date(timeIntervalSinceReferenceDate: RaceDataRef.childSnapshot(forPath:"DateCreated").value as! Double)
                let adminCode : String = RaceDataRef.childSnapshot(forPath:"AdminCode").value as! String
                let spectatorCode : String = RaceDataRef.childSnapshot(forPath:"SpectatorCode").value as! String
                let numberEntries : Int = RaceDataRef.childSnapshot(forPath:"NumberEntries").value as! Int
                
                reloadParty = PartyData(name: name, creatorName: creatorName, numberEntries: numberEntries, dateSaved: dateCreated, spectatorCode: spectatorCode, adminCode: adminCode, access: accessLevel, raceCode: raceCode)
                
                let timeData : [[String : Double]] = RaceDataRef.childSnapshot(forPath: "Times").value as! [[String : Double]]
                
                for ID in 0 ..< timeData.count {
                    let entry = timeData[ID]
                    let startTime : Date? = entry["StartTime"] != 0 ? Date(timeIntervalSinceReferenceDate: entry["StartTime"]!) : nil
                    let finishTime : Date? = entry["FinishTime"] != 0 ? Date(timeIntervalSinceReferenceDate: entry["FinishTime"]!) : nil
                    reloadParty!.addData(SingleData(ID: ID, start: startTime, finish: finishTime))
                }
                self.updateParty(to: reloadParty!)
                self.MasterVC.updateParty(to: reloadParty!)
            }
        })
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordDataSegue" {
            let editData_VC = segue.destination as! EditDataViewController
            editData_VC.party = self.party
        }
        if segue.identifier == "SettingsSegue" {
            let settings_VC = segue.destination as! SettingsTableViewController
            settings_VC.party = self.party
        }
    }
}

