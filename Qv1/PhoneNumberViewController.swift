//
//  PhoneNumberViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/17/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneNumberHeaderLabel: UILabel!
    
    @IBOutlet weak var phoneNumberFieldLabel: UILabel!
    
    @IBOutlet weak var validatedIconLabel: UILabel!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var firstName = ""
    var lastName = ""
    var emailAddress = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTextField.delegate = self
        validatedIconLabel.isHidden = true
        nextButton.isHidden = true
        
        UIView.animate(withDuration: 0.8, animations:{
            self.phoneNumberTextField.alpha = 0
            self.phoneNumberHeaderLabel.alpha = 0
            self.phoneNumberTextField.alpha = 1
            self.phoneNumberHeaderLabel.alpha = 1
        })

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(PhoneNumberViewController.getHintsFromTextField),
            object: textField)
        self.perform(
            #selector(PhoneNumberViewController.getHintsFromTextField),
            with: textField,
            afterDelay: 0.5)
        return true
    }
    
    
    func getHintsFromTextField(textField: UITextField) {
        if validate(phoneNumber: phoneNumberTextField.text!) == true {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.validatedIconLabel.alpha = 0
                self.validatedIconLabel.isHidden = false
                self.validatedIconLabel.textColor = UIColor.init(hexString: "AAE65F")
                self.validatedIconLabel.text = "✓"
                self.validatedIconLabel.alpha = 1
                
                self.nextButton.alpha = 0
                self.nextButton.isHidden = false
                self.nextButton.alpha = 1
            })
            
        }
    }


    func validate(phoneNumber: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phoneNumber)
        
        print(result)
        return result
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if self.validate(phoneNumber: textField.text!) == true {
            
            performSegue(withIdentifier: "phoneToPasswordSegue", sender: self)
        }
        
        return true
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        let nextVC = segue.destination as! PasswordViewController
        
        nextVC.firstName = firstName
        nextVC.lastName = lastName
        nextVC.emailAddress = emailAddress
        nextVC.phoneNumber = phoneNumberTextField.text!
    }

}
