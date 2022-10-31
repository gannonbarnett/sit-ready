//
//  PartyData.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import os.log


func makeRandomString(_ length : Int = 4) -> String {
    var charArray : [Character] = []
    for char in "qwertyuiopasdfghjklzxcvbnm" {
        charArray.append(char)
    }
    
    var randomString = ""
    for _ in 0 ..< length {
        let index = Int(arc4random_uniform(UInt32(charArray.count)))
        randomString.append(charArray[index])
    }
    return randomString
}

class PartyData : NSObject, NSCoding {
    public static var thereAreLoadedParties : Bool = false
    public static var loadedParties : [PartyData] = []
    
    enum accessLevel : Int {
        case Spectator = 0, Admin = 1
    }
    
    //MARK: Properties
    var times : [Int : SingleData] = [:]
    let dateFormatter : DateFormatter = DateFormatter()
    let timeFormatter : DateFormatter = DateFormatter()
    
    //initilizers
    var name : String
    var creatorName : String
    var dateSaved : Date
    var spectatorCode : String
    var adminCode : String
    var numberEntries : Int
    var raceCode : String
    var access : accessLevel

    //var notes : String? = nil
    
    //MARK: Types
    struct PropertyKey {
        static let raceAsString = "raceAsString"
    }
    
    func asString() -> String {
        var description = ""
        description.addLine(name)
        description.addLine(creatorName)
        description.addLine(String(dateSaved.timeIntervalSinceReferenceDate))
        description.addLine(spectatorCode)
        description.addLine(adminCode)
        description.addLine(String(numberEntries))
        description.addLine(raceCode)
        description.addLine(String(access.rawValue))
        for t in times {
            description.addLine(String(t.value.ID))
            t.value.startTime != nil ? description.addLine(String(t.value.startTime!.timeIntervalSinceReferenceDate)) : description.addLine("nil")
            t.value.finishTime != nil ? description.addLine(String(t.value.finishTime!.timeIntervalSinceReferenceDate)) : description.addLine("nil")
        }
        
        //notes == nil ? description.append("nil") : description.append(notes!)
        return description
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("Races")
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(asString(), forKey: PropertyKey.raceAsString)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let raceDescription = aDecoder.decodeObject(forKey: PropertyKey.raceAsString) as? String else {
            return nil
        }
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        let lines : [String] = raceDescription.components(separatedBy: "\n")
        
        let name = lines[0]
        let creatorName = lines[1]
        let dateCreated = Date(timeIntervalSinceReferenceDate: Double(lines[2])!)
        let spectatorCode = lines[3]
        let adminCode = lines[4]
        let numberEntries = Int(lines[5])!
        let raceCode = lines[6]
        
        //patch for removing creator level.
        let rawV = Int(lines[7])! == 2 ? 1 : Int(lines[7])!
        let access = accessLevel(rawValue: rawV)!
        
        //get race data, go by every 3
        var dataArray : [SingleData] = []
        var i = 8
        
        //var notes : String? = nil
        
        while i < lines.count - 1 {
            guard let raceID = Int(lines[i]) else {
                //assume notes if can't make string out of line
               // if lines[i] == "nil" {notes = nil} else {notes = lines[i]}
                break
            }
            i += 1

            var startTime : Date? = nil
            var finishTime : Date? = nil
            
            //following lines are start/finish times, could be "nil"
            if lines[i] != "nil" {startTime = Date(timeIntervalSinceReferenceDate: Double(lines[i])!)}
            i += 1
            if lines[i] != "nil" {finishTime = Date(timeIntervalSinceReferenceDate: Double(lines[i])!)}
            i += 1
            dataArray.append(SingleData(ID: raceID, start: startTime, finish: finishTime))
        }
        
        self.init(name: name, creatorName: creatorName, numberEntries: numberEntries, dateSaved: dateCreated, spectatorCode: spectatorCode, adminCode: adminCode, access: access, raceCode: raceCode)
        
        for data in dataArray {
            addData(data)
        }
    }
    
    init(name: String, creatorName: String, numberEntries: Int) {
        self.name = name
        self.access = accessLevel.Admin
        
        self.creatorName = creatorName
        self.numberEntries = numberEntries
        self.dateSaved = Date()
        self.spectatorCode = makeRandomString()
        self.adminCode = makeRandomString()
        self.raceCode = makeRandomString(15)
        
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        for i in 0 ..< numberEntries {
            self.times[i] = SingleData(ID: i)
        }
    }
    
    init(name: String, creatorName: String, numberEntries : Int, dateSaved: Date, spectatorCode: String, adminCode: String, access: accessLevel, raceCode: String) {
        self.name = name
        self.creatorName = creatorName
        self.numberEntries = numberEntries
        self.dateSaved = dateSaved
        self.spectatorCode = spectatorCode
        self.adminCode = adminCode
        self.access = access
        self.raceCode = raceCode
      //  self.notes = notes
        
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        for i in 0 ..< numberEntries {
            self.times[i] = SingleData(ID: i)
        }
    }
    
    //MARK: Public methods
    private var finishOrder : [Int : Int?] { //key is bow number, value is place.
        var finishDictionary : [Int : Int] = [:]
        var placeLessEntries : [Int : Int?] = [:]
        //create dictionary of key bow number, value time elapsed
        for entry in times.values {
            if let time = entry.elapsedTimeSeconds {
                finishDictionary[entry.ID] = time
            } else {
                placeLessEntries[entry.ID] = nil //add entries without times to nil set, will combine later.
            }
        }
        
        
        //sort dictionary for lowest time elapsed
        //except ordered is really [(key : Int, value : Int)]
        //$0.0 is bow, $0.1 is time in seconds
        let ordered = finishDictionary.sorted(by: {$0.1 < $1.1})
        for place in 0 ..< ordered.count {
            let entryID = ordered[place].key
            finishDictionary[entryID] = place + 1
        }
        placeLessEntries.add(other: finishDictionary); let allEntries = placeLessEntries
        return allEntries
    }
    
    func updateStartTime(ID: Int, time: Date?) {
        guard times[ID]!.startTime == nil else {
            return
        }
        self.times[ID]!.startTime = time
    }
    
    func updateFinishTime(ID: Int, time: Date?) {
        guard times[ID]!.finishTime == nil else {
            return
        }
        self.times[ID]!.finishTime = time
    }

    func setNameTo(_ name : String) {
        self.name = name
    }
    
    func addData(_ time : SingleData) {
        self.times[time.ID] = time
    }
    
    func getDate() -> String{
        return dateFormatter.string(from: dateSaved)
    }
    
    func getName() -> String{
        if name != "" { return name}
        return "Untitled"
    }
    
    func getStartTimeDesc(_ id: Int) -> String{
        guard self.times[id]!.startTime != nil else{
            return "No start data"
        }
        return timeFormatter.string(from: times[id]!.startTime!)
    }
    
    func getFinishTimeDesc(_ id: Int) -> String{
        guard self.times[id]!.finishTime != nil else{
            return "No finish data"
        }
        return timeFormatter.string(from: times[id]!.finishTime!)
    }
    
    func getStartTime(_ id: Int) -> Date? {
        return self.times[id]!.startTime
    }
    
    func getFinishTime(_ id: Int) -> Date? {
        return self.times[id]!.finishTime
    }
    
    func getPlaceofEntry( _ id: Int) -> Int? {
        let place = finishOrder[id]?!
        return place
    }
    
    func getPlaceDesc(_ id: Int) -> String {
        if let place = getPlaceofEntry(id) {
            switch place {
            case 1: return "1st"
            case 2: return "2nd"
            case 3: return "3rd"
            default: return "\(place)th"
            }
        }
        return "-"
    }
    
    //returns array of IDs in order of place
    func IDsByPlace() -> [Int] {
        var orderedArray : [Int] = Array(repeating: 0, count: numberEntries)
        var noPlaceArray : [Int] = []
        for time in times {
            if let place = getPlaceofEntry(time.key) {
            orderedArray[place - 1] = time.key
            }else {
                noPlaceArray.append(time.key)
            }
        }
        if !noPlaceArray.isEmpty {
            for i in 0 ..< noPlaceArray.count {
                orderedArray[orderedArray.count - 1 - i] = noPlaceArray[i]
            }
        }
        return orderedArray
    }
    
    func getNumberEntries() -> Int {
        return self.numberEntries
    }
    
    /*func getNotes() -> String {
        return notes != nil ? notes! : "no notes"
    }*/
    
    func addEntry() {
        numberEntries += 1
        times[numberEntries - 1] = SingleData(ID: numberEntries - 2, start: nil, finish: nil)
    }
    
    func popLastEntry() {
        numberEntries += -1
    }
    
    func getTimeElapsedDesc(_ id: Int) -> String {
        return times[id]!.getTimeElapsedDesc()
    }
    
    func secondsToDescription(_ secondsInput : Int) -> String {
        let minutes : Int = secondsInput / 60
        let seconds : Int = secondsInput - minutes * 60
        return seconds >= 10 ? "\(minutes):\(seconds)" : "\(minutes):0\(seconds)"
    }
    
    //MARK: - Firebase
    
    static func updateToFirebase(data: PartyData) {
        let ref : DatabaseReference = Database.database().reference()
        
        //Add spectator, admin codes to code list
        let codeFile = ref.child("Codes")
        codeFile.child(data.adminCode).setValue(String("admin-" + data.raceCode))
        codeFile.child(data.spectatorCode).setValue(String("spect-" + data.raceCode))
        
        //add race data to race code file
        let raceFile = ref.child("Races").child(data.raceCode)
        
        raceFile.child("Name").setValue(data.name)
        raceFile.child("CreatorName").setValue(data.creatorName)
    raceFile.child("DateCreated").setValue(data.dateSaved.timeIntervalSinceReferenceDate)
        raceFile.child("AdminCode").setValue(data.adminCode)
        raceFile.child("SpectatorCode").setValue(data.spectatorCode)
        raceFile.child("NumberEntries").setValue(data.numberEntries)

        for time in data.times {
            raceFile.child("Times").child(String(time.key)).child("StartTime").setValue(time.value.getStartTime_Double())
            raceFile.child("Times").child(String(time.key)).child("FinishTime").setValue(time.value.getFinishTime_Double())
        }
    }
}
