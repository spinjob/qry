//
//  LoginViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/31/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self

    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            print ("We are tried to sign in")
            
            if error != nil {
                
                print("We have an error: \(error)")
            } else {
                print("We've signed in successfully")
                
                self.userDefaults.setValue(self.emailTextField.text!, forKey: "email")
                self.userDefaults.setValue(self.passwordTextField.text!, forKey: "password")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
    
    }
    

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        loginButton.isEnabled = true
        loginButton.isUserInteractionEnabled = true
        loginButton.alpha = 1.0
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
