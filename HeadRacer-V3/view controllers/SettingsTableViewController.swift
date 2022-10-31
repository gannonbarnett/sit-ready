//
//  SettingsTableViewController.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 1/9/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    var party : PartyData? = nil
    
    var detail_VC : DetailViewController {
        return self.navigationController?.viewControllers[0] as! DetailViewController
    }
    
    @IBOutlet var OrdResults_SegmentedControl: UISegmentedControl!
    
    @IBOutlet var Medals_Switch : UISwitch!
    
    @IBAction func OrdResults_SegmentedControlChanged(_ sender: UISegmentedControl) {
        DetailViewController.sort = OrdResults_SegmentedControl.selectedSegmentIndex == 0 ? DetailViewController.SortMethod.ID : DetailViewController.SortMethod.Place
    }
    
    @IBOutlet var NumberEntries_Label: UILabel!
    @IBOutlet var NumberEntries_Stepper: UIStepper!
    
    @IBAction func NumberEntries_StepperChanged(_ sender: UIStepper) {
        if !PremiumAccess {
            guard Int(NumberEntries_Stepper.value) < MaxEntries_NonPremium else {
                self.presentAlert_MaxEntries()
                NumberEntries_Stepper.value = Double(MaxEntries_NonPremium)
                return
            }
        }
        NumberEntries_Label.text = String(Int(NumberEntries_Stepper.value))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if party!.numberEntries < Int(NumberEntries_Stepper.value) {
            for _ in party!.numberEntries ..< Int(NumberEntries_Stepper.value) {
                party!.addEntry()
            }
        }
        
        DetailViewController.showMedals = Medals_Switch.isOn
        
        detail_VC.updateParty(to: party!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OrdResults_SegmentedControl.selectedSegmentIndex = DetailViewController.sort == DetailViewController.SortMethod.ID ? 0 : 1
        NumberEntries_Label.text = String(party!.numberEntries)
        NumberEntries_Stepper.value = Double(party!.numberEntries)
        NumberEntries_Stepper.minimumValue = Double(party!.numberEntries)
        
        Medals_Switch.isOn = DetailViewController.showMedals
        hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if party!.access == .Admin { return 2}
        return 1
    }
    
    func presentAlert_MaxEntries() {
        let alert = UIAlertController(title: "Entry limit reached", message: "Please upgrade to premium for access to unlimited size entries and even more features!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Maybe later", style: UIAlertActionStyle.destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Get Premium", style: UIAlertActionStyle.default, handler: sendToUpgradeVC))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendToUpgradeVC(action: UIAlertAction) {
        let upgrade_VC = self.storyboard?.instantiateViewController(withIdentifier: "UpgradeViewController") as! UpgradeViewController
        self.navigationController!.pushViewController(upgrade_VC, animated: true)
    }
    
}
