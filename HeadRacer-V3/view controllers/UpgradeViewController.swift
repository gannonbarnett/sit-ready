//
//  UpgradeViewController.swift
//  HeadRacer-V3
//
//  Created by Gannon Barnett on 1/10/18.
//  Copyright © 2018 Barnett. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import Firebase

class UpgradeViewController: UIViewController {

    var master_VC : MasterViewController {
        return self.navigationController?.viewControllers[0] as! MasterViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func purchaseProduct() {
        SwiftyStoreKit.retrieveProductsInfo(["com.Barnett.SitReady.PremiumUpgrade"]) { result in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    SwiftyStoreKit.purchaseProduct("com.Barnett.SitReady.PremiumUpgrade", quantity: 1, atomically: false) { result in
                        switch result {
                        case .success(let product):
                            
                            PremiumAccess = true
                            UserDefaults.standard.set(true, forKey: "Premium")
                            
                            if product.needsFinishTransaction {
                                SwiftyStoreKit.finishTransaction(product.transaction)
                            }
                            print("Purchase Success: \(product.productId)")
                        case .error(let error):
                            switch error.code {
                            case .unknown: print("Unknown error. Please contact support")
                            case .clientInvalid: print("Not allowed to make the payment")
                            case .paymentCancelled: break
                            case .paymentInvalid: print("The purchase identifier was invalid")
                            case .paymentNotAllowed: print("The device is not allowed to make the payment")
                            case .storeProductNotAvailable: print("The product is not available in the current storefront")
                            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func BuyPremium_ButtonTouched(_ sender: UIButton) {
        purchaseProduct()
    }
    
    @IBAction func Restore_ButtonTouched(_ sender: UIButton) {
        verifyPurchase()
    }
    
    @IBAction func UseCode_ButtonTouched(_ sender: UIButton) {
        presentAlert_UseCodeOption()
    }
    
    //In-app purchases
    func verifyPurchase() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = "com.Barnett.SitReady.PremiumUpgrade"
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let receiptItem):
                    
                    PremiumAccess = true
                    UserDefaults.standard.set(true, forKey: "Premium")
                    self.presentAlert_RestoreSuccessful()
                    print("\(productId) is purchased: \(receiptItem)")
                    
                case .notPurchased:
                    
                    self.presentAlert_RestoreFailed_NoPurchase()
                    print("The user has never purchased \(productId)")
                }
                
            case .error(let error):
                self.presentAlert_RestoreFailed_Other(error)
                print("Receipt verification failed: \(error)")
            }
        }
        
    }
    
    func presentAlert_UseCodeOption() {
        let alert = UIAlertController(title: "Already paid money for the app?", message: "If you've already paid for the first version of the app, use the contact us link through the help page and send a picture of your apple reciept. Once verified, we'll send you a code to recieve Premium free of charge.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Use code", style: UIAlertActionStyle.default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            guard textField.text != "" || textField.text != nil else {
                return
            }
            
            let ref = Database.database().reference()
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                print(snapshot.hasChild("PromoCodes"))
                
                if snapshot.childSnapshot(forPath: "PromoCodes").hasChild(textField.text!){
                    PremiumAccess = true
                    UserDefaults.standard.set(true, forKey: "Premium")
                    self.presentAlert_RestoreSuccessful()
                } else {
                    self.presentAlert_RestoreFailed_NoPurchase()
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_NoCodeEntered() {
        let alert = UIAlertController(title: "Enter a code", message: "No code entered", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_RestoreSuccessful() {
        let alert = UIAlertController(title: "Restore successful!", message: "Premium mode activated.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_RestoreFailed_NoPurchase() {
        let alert = UIAlertController(title: "Restore failed", message: "The product has never been purchased by this account.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert_RestoreFailed_Other(_ error : Error) {
        let alert = UIAlertController(title: "Restore failed", message: "Attempted restoration failed with error \(error)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
