//
//  EditDataTableViewController.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import UIKit

class EditDataTableViewController: UITableViewController {

    var party : PartyData? = nil
    let stackView_MIN_WIDTH = 330
    let margin_WIDTH = 20
    var stackView_spacing = CGFloat(5)
    
    var editDataVC : EditDataViewController {
        return parent! as! EditDataViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableWidth = Int(self.tableView.frame.width)
        if tableWidth > stackView_MIN_WIDTH + margin_WIDTH * 2 {
            let extraSpace : Int = (tableWidth - margin_WIDTH * 2) - stackView_MIN_WIDTH
            //five spaces to add room
            print(extraSpace)
            stackView_spacing = CGFloat(extraSpace / 2)
        }
        
        
        /*
        if tableWidth < CGFloat(288) {
            
        }*/
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectData(forRow row: Int) {
        //let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! EditDataTableViewCell
        let cell = tableView.visibleCells[0] as! EditDataTableViewCell
        party!.updateStartTime(ID: row, time: cell.startTime)
        party!.updateFinishTime(ID: row, time: cell.finishTime)
    }
    
    // MARK: - Table view data source

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return party!.getNumberEntries()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditDataCell", for: indexPath) as! EditDataTableViewCell
        let rawID = indexPath.row
        cell.setSpacing(stackView_spacing)
        cell.reset()
        cell.ID = rawID
        cell.startTime = party!.getStartTime(rawID)
        cell.finishTime = party!.getFinishTime(rawID)
        cell.setUp()
        return cell
    }

    @IBAction func Mark_ButtonTouched(_ sender: UIButton) {
        collectAllData()
        editDataVC.updateAllData()
    }
    
    func collectAllData() {
        for index in tableView.indexPathsForVisibleRows! {
            collectData(forRow: index.row)
        }
    }
    
    var isScrolling = false {
        didSet{
            collectAllData()
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { scrollViewDidEndScrolling(scrollView) }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrolling(scrollView)
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndScrolling(scrollView)
    }
    
    func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
        isScrolling = false
    }

}
