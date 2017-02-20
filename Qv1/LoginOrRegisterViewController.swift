//
//  LoginOrRegisterViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/13/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginOrRegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var slideIconImageView: UIImageView!
    @IBOutlet weak var slideLogoLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var emailAddressTextViewLabel: UILabel!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    @IBOutlet weak var passwordTextFieldLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let userDefaults = UserDefaults.standard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailAddressTextField.delegate = self
        passwordTextField.delegate = self

        
        UIView.animate(withDuration: 1.2, animations: {
            self.slideIconImageView.alpha = 0
            self.slideIconImageView.alpha = 1
            self.loginButton.alpha = 0
            self.loginButton.alpha = 1
            
            self.emailAddressTextField.alpha = 0
            self.emailAddressTextField.alpha = 1
            
            self.emailAddressTextViewLabel.alpha = 0
            self.emailAddressTextViewLabel.alpha = 1
            
            self.passwordTextField.alpha = 0
            self.passwordTextField.alpha = 1
            
            self.passwordTextFieldLabel.alpha = 0
            self.passwordTextFieldLabel.alpha = 1
            
            self.slideLogoLabel.alpha = 0
            self.slideLogoLabel.alpha = 1
            self.createAccountButton.alpha = 0
            self.createAccountButton.alpha = 1
            
            

        })

        loginButton.layer.cornerRadius = 4
        loginButton.layer.masksToBounds = true
        
        createAccountButton.layer.borderWidth = 0.2
        createAccountButton.layer.borderColor = UIColor.init(hexString: "00CDCD").cgColor
        createAccountButton.layer.cornerRadius = 4
        createAccountButton.layer.masksToBounds = true
        
        
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont(name: "Proxima Nova", size: 20)!]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.hideKeyboard()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if userDefaults.string(forKey: "email") != nil {
            
            let email = userDefaults.string(forKey: "email")
            
            let password = userDefaults.string(forKey: "password")
            
            
            login(email: email!, password: password!)
            
        }

    }
   
    func hideKeyboard () {
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        FIRAuth.auth()?.signIn(withEmail: emailAddressTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            print ("We are tried to sign in")
            
            if error != nil {
                
                print("We have an error: \(error)")
            } else {
                print("We've signed in successfully")
                
                self.userDefaults.setValue(self.emailAddressTextField.text!, forKey: "email")
                self.userDefaults.setValue(self.passwordTextField.text!, forKey: "password")
                self.performSegue(withIdentifier: "signInSegue", sender: nil)
            }
        })
        

        
        
    }
    
    func login (email: String, password: String) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            print ("We are tried to sign in")
            
            if error != nil {
                
                print("We have an error: \(error)")
            } else {
                print("We've signed in successfully")
            
                self.performSegue(withIdentifier: "signInSegue", sender: nil)
            }
        })
    }

    
   
}
