//
//  extensions.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 12/28/17.
//  Copyright © 2017 Barnett. All rights reserved.
//

import Foundation
import UIKit
func presentAlert_NoWifi(viewController: UIViewController) {
    let alert = UIAlertController(title: "No Internet Connection", message: "Functionality may be limited with current network status.", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
    viewController.present(alert, animated: true, completion: nil)
}

extension Date {
    
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second!
    }
    
    func nanoseconds(from date: Date) -> Int {
        return Int(( self.timeIntervalSince1970 * 1000 ) - ( date.timeIntervalSince1970 * 1000 ))
    }
    
    func seconds(from date: Date, digits: Int) -> Double {
        let time = Calendar.current.dateComponents([.second, .nanosecond], from: date, to: self)
        let nanoseconds = time.nanosecond ?? 0
        let seconds = time.second ?? 0
        let tenths = Double(nanoseconds / ( 10 ^ 8)).rounded() / 10
        return Double(seconds) + tenths
    }
}

extension TimeInterval {
    func preciseDescription() -> String{
        let ti = self
        
        let ms = Int((self.truncatingRemainder(dividingBy: 1) * 1000))
        let tenthSeconds = Int((Double(ms) / 100.0).rounded(.down))
        let seconds = Int(ti.truncatingRemainder(dividingBy: 60))
        let minutes = Int((ti / 60).truncatingRemainder(dividingBy: 60))
        let hours = Int(ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.1d",hours,minutes,seconds,tenthSeconds)
    }
}

extension Dictionary {
    mutating func add(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

extension UILabel {
    
    func setInvisible() {
        self.textColor = UIColor.clear
    }
    
    func setVisible() {
        self.textColor = UIColor.black
    }
}

extension String {
    mutating func addLine(_ string : String) {
        self.append("\(string)\n")
    }
}

extension UIColor {
    static let gold = UIColor(red:1.00, green:0.84, blue:0.00, alpha:1.0)
    static let silver = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.0)
    static let bronze = UIColor(red:0.80, green:0.50, blue:0.20, alpha:1.0)
}


extension UIViewController {
    @objc func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
}



