//
//  PasswordViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/13/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Navajo_Swift


class PasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nowCreatePasswordTextLabel: UILabel!
    @IBOutlet weak var passwordTextFieldLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    
    var firstName = ""
    var lastName = ""
    var emailAddress = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.delegate = self
        passwordValidationLabel.isHidden = true
        nextButton.isHidden = true
        
        UIView.animate(withDuration: 0.8, animations:{
            self.passwordTextField.alpha = 0
            self.nowCreatePasswordTextLabel.alpha = 0
            self.passwordTextField.alpha = 1
            self.nowCreatePasswordTextLabel.alpha = 1
            
        })
        

     
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(PasswordViewController.getHintsFromTextField),
            object: textField)
        self.perform(
            #selector(PasswordViewController.getHintsFromTextField),
            with: textField,
            afterDelay: 0.5)
        return true
    }
    
    func getHintsFromTextField(textField: UITextField) {
        if isValidPassword(password: passwordTextField.text!) == true {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.passwordValidationLabel.alpha = 0
                self.passwordValidationLabel.isHidden = false
                self.passwordValidationLabel.textColor = UIColor.init(hexString: "AAE65F")
                self.passwordValidationLabel.text = "✓"
                self.passwordValidationLabel.alpha = 1
                
                self.nextButton.alpha = 0
                self.nextButton.isHidden = false
                self.nextButton.alpha = 1
            })
            
        }
    }
    
    func isValidPassword(password: String) -> Bool{
    
    var lengthRule = NJOLengthRule(min: 6, max: 24)
    var uppercaseRule = NJORequiredCharacterRule(preset: .symbolCharacter)
    
    let validator = NJOPasswordValidator(rules: [lengthRule, uppercaseRule])
    
    if let failingRules = validator.validate(password) {
        var errorMessages: [String] = []
        
        failingRules.forEach { rule in
            errorMessages.append(rule.localizedErrorDescription)
        }
        
        passwordValidationLabel.isHidden = false
        passwordValidationLabel.textColor = UIColor.red
        passwordValidationLabel.text = errorMessages.joined(separator: "\n")
        return false
   
    }
        
        return true
    
}

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        FIRAuth.auth()?.createUser(withEmail: emailAddress, password: passwordTextField.text!, completion: {
            (user, error) in
            print ("We tried to create a user:")
            if error != nil {
                print("We have an error: \(error)")
            } else {
                print("Created user successfully")
                
            FIRDatabase.database().reference().child("users").child(user!.uid).child("email").setValue(self.emailAddress)
      
                
                FIRDatabase.database().reference().child("users").child(user!.uid).child("firstName").setValue(self.firstName)
            
                
                FIRDatabase.database().reference().child("users").child(user!.uid).child("lastName").setValue(self.lastName)
              FIRDatabase.database().reference().child("users").child(user!.uid).child("fullName").setValue("\(self.firstName) \(self.lastName)")
             FIRDatabase.database().reference().child("users").child(user!.uid).child("uID").setValue(user!.uid)
                
            
            }
        })

        
        
    }

}
