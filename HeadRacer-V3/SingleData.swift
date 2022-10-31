//
//  SingleData.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation
import Darwin

struct SingleData {
    var ID : Int
    var startTime : Date?
    var finishTime : Date?
    
    var elapsedTimeSeconds : Int? {
        guard startTime != nil && finishTime != nil else {
            return nil
        }
        let timeInSeconds = finishTime!.seconds(from: startTime!)
        return timeInSeconds
    }
    
    func getTimeElapsedDesc(decimals: Int = 3) -> String {
        //change decimals for increased accuracy
        guard startTime != nil && finishTime != nil else {
            return "Inc. Data"
        }
        return finishTime!.timeIntervalSince(startTime!).preciseDescription()
    }

    init(ID : Int) {
        self.ID = ID
        startTime = nil
        finishTime = nil
    }
    
    init(ID : Int, time: Date, timeMode: Bool) {
        self.ID = ID
        //timeMode is true when start times are inputted.
        if timeMode { startTime = time } else { finishTime = time }
    }
    
    init(ID : Int, start: Date?, finish: Date?) {
        self.ID = ID
        self.startTime = start
        self.finishTime = finish
    }
    
    func getFinishTime_Double() -> Double{
        if let time = finishTime {return time.timeIntervalSinceReferenceDate}
        return 0
    }
    
    func getStartTime_Double() -> Double{
        if let time = startTime {return time.timeIntervalSinceReferenceDate}
        return 0
    }
    
    func getSimpleFormat() -> [String : Any?] {
        var data : [String : Any?] = [:]
        data["StartTime"] = getStartTime_Double()
        data["FinishTime"] = getFinishTime_Double()
        return data
    }
}
