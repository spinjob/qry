//
//  FullNameViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/13/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FullNameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var whatsYourNameLabel: UILabel!
    @IBOutlet weak var firstNameTextFieldLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextFieldLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.becomeFirstResponder()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        self.hideKeyboard()
        
        
        nextButton.isHidden = true
        
        UIView.animate(withDuration: 0.8, animations:{
            self.whatsYourNameLabel.alpha = 0
            self.firstNameTextFieldLabel.alpha = 0
            self.lastNameTextFieldLabel.alpha = 0
            self.whatsYourNameLabel.alpha = 1
            self.firstNameTextFieldLabel.alpha = 1
            self.lastNameTextFieldLabel.alpha = 1
     
        })
        
    }


    func textFieldDidEndEditing(_ textField: UITextField) {
        if firstNameTextField.text != "", lastNameTextField.text != "" {
            nextButton.isHidden = false
        }
        
        if firstNameTextField.text == "", lastNameTextField.text == "" {
            nextButton.isHidden = true
        }
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if firstNameTextField.text != "", lastNameTextField.text != ""{
            
            performSegue(withIdentifier: "nameToEmailSegue", sender: self)
            
            
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       if textField == lastNameTextField, firstNameTextField.text != ""{

        UIView.animate(withDuration: 0.5, animations: {
            self.nextButton.alpha = 0
            self.nextButton.isHidden = false
            self.nextButton.alpha = 1
        })
        }
    }
   
    
override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        let nextVC = segue.destination as! EmailAddressViewController
    
        nextVC.firstName = firstNameTextField.text!
        nextVC.lastName = lastNameTextField.text!
    
    }
    
    func hideKeyboard () {
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

    
@IBAction func nextButtonTapped(_ sender: Any) {
    
    }


}
