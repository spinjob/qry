//
//  EnterPinViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/17/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
//import SinchVerification
import AWSMobileHubHelper
import AWSDynamoDB


class EnterPinViewController: UIViewController {

    
    //var verification:Verification!
    var applicationKey = "9dd11fb9-3460-423c-83b8-95ce145d8e18"
    var userPhoneNumberProvided = ""
    var userID = ""
    
    func insertData(newUserPhoneNumber : String!){
        
        let itemToCreate = QUser()
        
        itemToCreate?._userId = AWSIdentityManager.defaultIdentityManager().identityId!
        itemToCreate?._userPhoneNumber = newUserPhoneNumber
        
        AWSDynamoDBObjectMapper.default().save(itemToCreate!, completionHandler: {error -> Void in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print(itemToCreate?._userId)
            print(itemToCreate?._userPhoneNumber)
            print("Item saved.")
        })
    }
    
    
    @IBOutlet weak var enterPINTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var errorTextLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorTextLabel.text = ""
        spinner.isHidden = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        enterPINTextField.becomeFirstResponder()
        enterPINTextField.keyboardType = UIKeyboardType.numberPad
    
    }
    
    
    @IBAction func verifyButtonTapped(_ sender: AnyObject) {
        
        enterPINTextField.resignFirstResponder()
        spinner.isHidden = false
        spinner.startAnimating()
        
        enterPINTextField.isEnabled = false
        //verification.verify(enterPINTextField.text!) { (success: Bool, error: Error?) -> Void in
           // if success == true {
//                self.errorTextLabel.text = "Verified"
//                
//                self.spinner.isHidden = true
//                self.spinner.stopAnimating()
//                self.enterPINTextField.isEnabled = true
//                
//                self.insertData(newUserPhoneNumber: self.userPhoneNumberProvided)
//                
//                self.performSegue(withIdentifier: "loginSegue", sender: self)
//                }
//                self.errorTextLabel.text = error?.localizedDescription
//        }
    

        
        
        
    }

    


}
