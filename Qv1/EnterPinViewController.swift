//
//  EnterPinViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/17/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import SinchVerification

class EnterPinViewController: UIViewController {

    
    var verification:Verification!
    var applicationKey = "9dd11fb9-3460-423c-83b8-95ce145d8e18"
    var userPhoneNumber = ""
    
    
    
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
        verification.verify(enterPINTextField.text!) { (success: Bool, error: Error?) -> Void in
            if success == true {
                self.errorTextLabel.text = "Verified"
                
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.enterPINTextField.isEnabled = true
               // self.performSegue(withIdentifier: "loginSegue", sender: self.userPhoneNumber)
    
            } else {
                self.errorTextLabel.text = error?.localizedDescription
            }
        }
        
    }

    


}
