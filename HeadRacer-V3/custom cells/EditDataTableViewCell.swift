//
//  EditDataTableViewCell.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import UIKit

class EditDataTableViewCell: UITableViewCell {
    
    let timeFormatter : DateFormatter = DateFormatter()
    @IBOutlet var master_StackView: UIStackView!
    
    var ID : Int? = nil
    var startTime : Date? = nil
    var finishTime : Date? = nil
    
    var timer : Timer? = nil
    
    let interval = 0.05
    
    let currentCalender = Calendar.autoupdatingCurrent
    
    @IBOutlet var ID_Label: UILabel!
    @IBOutlet var StartTime_Label: UILabel!
    @IBOutlet var FinishTime_Label: UILabel!
    @IBOutlet var Timer_Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .medium
        if startTime != nil { StartTime_Label.text = timeFormatter.string(from: startTime!)}
        if finishTime != nil { FinishTime_Label.text = timeFormatter.string(from: finishTime!)}
    }
    
    func setSpacing(_ spacing : CGFloat) {
        master_StackView.spacing = spacing
        self.setNeedsDisplay()
    }
    
    var timerShouldContinue : Bool = true
    func checkTimer() {
        guard shouldHideTimer() == false else { return }
        Timer_Label.setVisible()
        if finishTime != nil {
             timerShouldContinue = false
            let data = SingleData(ID: ID!, start: startTime, finish: finishTime)
            Timer_Label.text = data.getTimeElapsedDesc()
            return
        }
        addTimer()
    }
    
    func shouldHideTimer() -> Bool {
        if startTime == nil { return true }
        return false
    }
    
    func addTimer() {
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: false)
        Timer_Label.setVisible()
    }
    
    @objc func updateTimerLabel() {
        guard shouldHideTimer() == false else { return }
        guard timerShouldContinue else { return }
        if finishTime != nil {
            let data = SingleData(ID: ID!, start: startTime, finish: finishTime)
            Timer_Label.text = data.getTimeElapsedDesc()
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: false)
        
        let text = Date().timeIntervalSince(startTime!).preciseDescription()
        
        Timer_Label.text = text
    }

    func reset() {
        //prevent bugs with recycled cells.
        //make cell with no data
        ID = nil
        startTime = nil
        finishTime = nil
    
        StartTime_Label.text = "Start Time"
        FinishTime_Label.text = "Finish Time"
        
        //hide time labels until data is confirmed availible.
        StartTime_Label.isHidden = true
        FinishTime_Label.isHidden = true
        
        //show buttons
        StartMark_Button.isHidden = false
        StartMark_Button.isEnabled = true

        FinishMark_Button.isHidden = false
        FinishMark_Button.isEnabled = true
        
        //hide timer
        Timer_Label.setInvisible()
        Timer_Label.text = "0:00"
        timer = nil
    }
    
    func setUp() {
        self.ID_Label.text = String(ID! + 1)
        
        //if there is start time data, hide the start button and reveal the start label
        
        freezeFinishMark()
        
        if startTime != nil {
            enableStartLabel()
            disableStartMark()
            unfreezeFinishMark()
        }
        
        if finishTime != nil {
            enableFinishLabel()
            disableFinishMark()
        }
        checkTimer()
    }
    
    @IBOutlet var StartMark_Button: UIButton!
    @IBAction func StartMark_ButtonTouched(_ sender: UIButton) {
        startTime = Date()
        enableStartLabel()
        disableStartMark()
        unfreezeFinishMark()
        if shouldHideTimer() == false { addTimer() }
    }
    
    @IBOutlet var FinishMark_Button: UIButton!
    @IBAction func FinishMark_ButtonTouched(_ sender: UIButton) {
        checkTimer()
        finishTime = Date()
        enableFinishLabel()
        disableFinishMark()
    }
    
    func getData() -> SingleData{
        return SingleData(ID: ID!, start: startTime, finish: finishTime)
    }
    
    func enableStartLabel() {
        StartTime_Label.isHidden = false
        StartTime_Label.text! = timeFormatter.string(from: startTime!)
    }
    
    func enableFinishLabel() {
        FinishTime_Label.isHidden = false
        FinishTime_Label.text! = timeFormatter.string(from: finishTime!)
    }
    
    func disableStartMark() {
        self.StartMark_Button.isEnabled = false
        StartMark_Button.isHidden = true
    }
    
    func disableFinishMark() {
        self.FinishMark_Button.isEnabled = false
        FinishMark_Button.isHidden = true
    }
    
    func freezeFinishMark() {
        self.FinishMark_Button.isEnabled = false
        FinishMark_Button.titleLabel!.textColor = UIColor.gray
    }
    
    func unfreezeFinishMark(){
        self.FinishMark_Button.isEnabled = true
        FinishMark_Button.titleLabel!.textColor = UIColor.black
    }
}
