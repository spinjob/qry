//
//  ViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/17/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase



class VerifyPhoneViewController: UIViewController {

    var applicationKey = "25f6a494-e70d-4663-8e77-dbd7a756e130"
    var userID = ""
    
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var smsVerificationButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var statusTextLabel: UILabel!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    spinner.isHidden = true
    statusTextLabel.text = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        phoneNumberTextField.becomeFirstResponder()
        phoneNumberTextField.keyboardType = UIKeyboardType.numberPad
        
    }
    
    @IBAction func smsVericationButtonTapped(_ sender: AnyObject) {
        disableUI(disable: true)
    
        
    }
    
    func disableUI(disable: Bool){
        var alpha :CGFloat = 1.0
        if disable == true {
            alpha = 0.5
            phoneNumberTextField.resignFirstResponder()
            spinner.startAnimating()
            self.statusTextLabel.text = ""
            self.spinner.isHidden = true
            let delayTime =  DispatchTime.now() + 30
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                self.disableUI(disable: false)
            })
            

        } else {
            self.phoneNumberTextField.becomeFirstResponder()
            self.spinner.isHidden = false
            self.spinner.stopAnimating()
        }
        
    self.phoneNumberTextField.isEnabled = false
    self.smsVerificationButton.alpha = 0
    self.smsVerificationButton.isEnabled = false
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterPinSegue" {
            let nextVC = segue.destination as! EnterPinViewController
            nextVC.userPhoneNumberProvided = phoneNumberTextField.text!
            nextVC.userID = userID

        }
        
    }

}

