//
//  EnterEmail&PasswordViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/31/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EnterEmail_PasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var currentUserID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont(name: "Proxima Nova", size: 20)!]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        
        
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nextButton.isEnabled = true
        nextButton.isUserInteractionEnabled = true
        nextButton.alpha = 1.0
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {
            (user, error) in
            print ("We tried to create a user:")
            if error != nil {
                print("We have an error: \(error)")
            } else {
                print("Created user successfully")
                
                FIRDatabase.database().reference().child("users").child(user!.uid).child("email").setValue(self.emailTextField.text!)
                
                self.performSegue(withIdentifier: "fullNameSegue", sender: self)
            }
        })
        
    }

   // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   //     let nextVC = segue.destination as! EnterNameViewController
   //     nextVC.userID = (FIRAuth.auth()?.currentUser?.uid)!
   //  }
}
