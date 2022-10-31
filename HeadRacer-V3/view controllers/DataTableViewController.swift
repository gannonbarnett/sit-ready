//
//  DataTableViewController.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import UIKit

class DataTableViewController: UITableViewController {

    var party : PartyData? = nil
    
    let stackView_MIN_WIDTH = 300
    
    let margin_WIDTH = 45
    var stackView_spacing : CGFloat = CGFloat(5)

    override func viewDidLoad() {
        super.viewDidLoad()
        let tableWidth = Int(self.tableView.frame.width)
        if tableWidth > stackView_MIN_WIDTH + margin_WIDTH * 2 {
            let extraSpace : Int = (tableWidth - margin_WIDTH * 2) - stackView_MIN_WIDTH
            //five spaces to add room
            stackView_spacing = CGFloat(extraSpace / 2)
        }
        
        self.view.backgroundColor = UIColor.clear
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func getContentSizeHeight() -> CGFloat {
        return CGFloat(party!.getNumberEntries()) * tableView.rowHeight
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //each time, plus the top info cell
        return party!.getNumberEntries() + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeArray = party!.IDsByPlace()
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoCell
            cell.AdminCode_StackView.isHidden = true
            cell.SpectatorCode_Label.text! = party!.spectatorCode
            cell.AccessLevel_Label.text = party!.access == .Admin ? "Admin" : "Spectator"
            if party!.access == .Admin {
                cell.AdminCode_StackView.isHidden = false
                cell.AdminCode_Label.text! = party!.adminCode
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! DataTableViewCell
        
        var ID = 0
        switch DetailViewController.sort {
        case .ID:
            ID = indexPath.row - 1
        case .Place:
            ID = placeArray[indexPath.row - 1]
        }
        
        //because first cell is notes cell, subtract 1
        cell.setSpacing(stackView_spacing)
        cell.ID_Label.text = String(describing: ID + 1)
        cell.StartTime_Label.text = party!.getStartTimeDesc(ID)
        cell.FinishTime_Label.text = party!.getFinishTimeDesc(ID)
        cell.TotalTime_Label.text = party!.getTimeElapsedDesc(ID)
        cell.Place_Label.text = party!.getPlaceDesc(ID)
        cell.NoData_Label.setInvisible()
        cell.StartTime_Label.setVisible()
        cell.FinishTime_Label.setVisible()
        cell.TotalTime_Label.setVisible()
        
        if cell.StartTime_Label.text == "No start data" {cell.StartTime_Label.setInvisible()}
        if cell.FinishTime_Label.text == "No finish data" {cell.FinishTime_Label.setInvisible()}
        
        //start and finish times would be hidden if there is no data.
        if cell.StartTime_Label.isHidden && cell.FinishTime_Label.isHidden {
            cell.TotalTime_Label.setInvisible()
            cell.NoData_Label.setVisible()
        }
        
        guard DetailViewController.showMedals == true else {
            cell.Medal_View.isHidden = true
            return cell
        }
        
        cell.Medal_View.isHidden = false
        switch cell.Place_Label.text! {
        case "1st":
            cell.Medal_View.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "goldtake1"))
        case "2nd":
            cell.Medal_View.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "silvertake1.png"))
        case "3rd":
            cell.Medal_View.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "bronzetake1"))
        default:
            cell.Medal_View.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return InfoCell.height
        }
        return DataTableViewCell.height
    }
}
