//
//  AddPartyViewController.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddPartyViewController: UIViewController, GADBannerViewDelegate  {

    @IBOutlet var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateStepperValue()
        hideKeyboardWhenTappedAround()
        Code_TextField.delegate = self
        PartyName_TextField.delegate = self
        CreatorName_TextField.delegate = self
        
        if !PremiumAccess {
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
            bannerView.isHidden = true
        }
    }
    
    var MasterVC : MasterViewController {
        return self.navigationController?.viewControllers[0] as! MasterViewController
    }
    
    //Joining party
    @IBOutlet var Code_TextField: UITextField!

    var code : String? {
        return Code_TextField.text
    }
    
    @IBAction func JoinParty_ButtonTouched(_ sender: UIButton) {
        guard code != nil && code != "" else {
            presentAlert_EmptyCodeField()
            return
        }
        
        if PremiumAccess == false {
            guard MasterVC.parties.count <= MaxRaces_NonPremium else {
                presentAlert_MaxParties()
                self.navigationController?.popViewController(animated: true)
                return
            }
        }

        var party : PartyData? = nil
        let ref = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childSnapshot(forPath: "Codes").hasChild(self.code!){
                
                //if code is present, get data.

                var accessLevel : PartyData.accessLevel = .Spectator
                
                var fullCode = "" //full code represents the access level combined with the race code.
                fullCode = snapshot.childSnapshot(forPath: "Codes").childSnapshot(forPath: self.code!).value as! String
                
                if fullCode.hasPrefix("admin-") {accessLevel = .Admin}
                
                //remove prefix
                var raceCode = fullCode ; raceCode.removeFirst(6)
                
                duplicateCheck : if self.MasterVC.codes.contains(where: {$0.key == raceCode}) {
                    
                    //check to see if this code would update access Level. If it does, continue loading data.
                    guard accessLevel != .Admin || self.MasterVC.codes[raceCode]!.1.access != .Spectator else {
                        self.MasterVC.parties[self.MasterVC.codes[raceCode]!.0].access = .Admin
                        self.MasterVC.saveParties()
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    
                    self.presentAlert_DuplicateRace()
                    return
                }
                
                let RaceDataRef = snapshot.childSnapshot(forPath: "Races").childSnapshot(forPath: raceCode)
                let name : String = RaceDataRef.childSnapshot(forPath: "Name").value as! String
                let creatorName : String = RaceDataRef.childSnapshot(forPath:"CreatorName").value as! String
                let dateCreated : Date = Date(timeIntervalSinceReferenceDate: RaceDataRef.childSnapshot(forPath:"DateCreated").value as! Double)
                let adminCode : String = RaceDataRef.childSnapshot(forPath:"AdminCode").value as! String
                let spectatorCode : String = RaceDataRef.childSnapshot(forPath:"SpectatorCode").value as! String
                let numberEntries : Int = RaceDataRef.childSnapshot(forPath:"NumberEntries").value as! Int
                party = PartyData(name: name, creatorName: creatorName, numberEntries: numberEntries, dateSaved: dateCreated, spectatorCode: spectatorCode, adminCode: adminCode, access: accessLevel, raceCode: raceCode)
                
                let timeData : [[String : Double]] = RaceDataRef.childSnapshot(forPath: "Times").value as! [[String : Double]]
                
                for ID in 0 ..< timeData.count {
                    let entry = timeData[ID]
                    let startTime : Date? = entry["StartTime"] != 0 ? Date(timeIntervalSinceReferenceDate: entry["StartTime"]!) : nil
                    let finishTime : Date? = entry["FinishTime"] != 0 ? Date(timeIntervalSinceReferenceDate: entry["FinishTime"]!) : nil
                    party!.addData(SingleData(ID: ID, start: startTime, finish: finishTime))
                }
                
                
                self.MasterVC.addParty(party!)
                self.MasterVC.saveParties()
                self.navigationController?.popViewController(animated: true)
            }else{
                self.presentAlert_InvalidCode(code: self.code!)
            }
        })
    }
    
    //Creating party
    @IBOutlet var NumberEntries_Label: UILabel!
    @IBOutlet var NumberEntries_Stepper: UIStepper!
    @IBAction func NumberEntries_StepperChanged(_ sender: UIStepper) {
        if PremiumAccess == false {
            guard Int(NumberEntries_Stepper.value) <= MaxEntries_NonPremium else {
                presentAlert_MaxEntries()
                NumberEntries_Stepper.value = Double(MaxEntries_NonPremium)
                return
            }
        }
        updateStepperValue()
    }

    func updateStepperValue(){
        NumberEntries_Label.text! = String(Int(NumberEntries_Stepper.value))
    }
    
    @IBOutlet var PartyName_TextField: UITextField!

    @IBOutlet var CreatorName_TextField: UITextField!

    @IBAction func CreateParty_ButtonTouched(_ sender: UIButton) {
        guard PartyName_TextField.text != "" && CreatorName_TextField.text != "" else {
            presentAlert_EmptyNameFields()
            return
        }
        
        if PremiumAccess == false {
            guard MasterVC.parties.count < MaxRaces_NonPremium else {
                presentAlert_MaxParties()
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
        
        let name = PartyName_TextField.text!
        let creatorName = CreatorName_TextField.text!
        let numberEntries = Int(NumberEntries_Stepper.value)
        let party = PartyData(name: name, creatorName: creatorName, numberEntries: numberEntries)
        MasterVC.addParty(party)
        PartyData.updateToFirebase(data: party)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Alerts
    
    func presentAlert_EmptyCodeField() {
        let alert = UIAlertController(title: "No code entered", message: "Please enter a code and retry", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_InvalidCode(code: String) {
        let alert = UIAlertController(title: "Party doesn't exist", message: "Unable to join party with code \"\(code)\"", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_DuplicateRace() {
        let alert = UIAlertController(title: "This race already exists", message: "You are already connected to this race with this access level.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_MaxParties() {
        let alert = UIAlertController(title: "Party limit reached", message: "Please upgrade to premium for access to unlimited races and even more features!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Maybe later", style: UIAlertActionStyle.destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Get Premium", style: UIAlertActionStyle.default, handler: sendToUpgradeVC))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_MaxEntries() {
        let alert = UIAlertController(title: "Entry limit reached", message: "Please upgrade to premium for access to unlimited size entries and even more features!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Maybe later", style: UIAlertActionStyle.destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Get Premium", style: UIAlertActionStyle.default, handler: sendToUpgradeVC))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_EmptyNameFields() {
        let alert = UIAlertController(title: "Missing name", message: "Please make sure both name fields are not empty and try again.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendToUpgradeVC(action: UIAlertAction) {
        let upgrade_VC = self.storyboard?.instantiateViewController(withIdentifier: "UpgradeViewController") as! UpgradeViewController
        self.navigationController!.pushViewController(upgrade_VC, animated: true)
    }
}

extension AddPartyViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
