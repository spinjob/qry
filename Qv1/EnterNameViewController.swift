//
//  EnterNameViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/22/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class EnterNameViewController: UIViewController, UITextFieldDelegate

{
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var userFullName = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.layer.borderColor = UIColor.white.cgColor
        navigationController?.isNavigationBarHidden = true
        
        
        FirstNameTextField.delegate = self
        LastNameTextField.delegate = self
        
        FirstNameTextField.becomeFirstResponder()
        
        if (FirstNameTextField.text?.isEmpty)! {
            nextButton.isUserInteractionEnabled = false
            nextButton.alpha = 0.5
        }
        
        userFullName = "\(FirstNameTextField.text) \(LastNameTextField.text)"
    
      
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nextButton.isUserInteractionEnabled = true
        nextButton.alpha = 1.0
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    

    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("fullName").setValue("\(FirstNameTextField.text!) \(LastNameTextField.text!)")
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("uID").setValue(FIRAuth.auth()?.currentUser?.uid)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    
    }

}
