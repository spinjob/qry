//
//  EnterNameViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/22/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper
import FBSDKLoginKit

class EnterNameViewController: UIViewController, UITextFieldDelegate

{
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var userFullName = ""
    var userID = ""

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.layer.borderColor = UIColor.white.cgColor
        navigationController?.isNavigationBarHidden = true
        
        
        FirstNameTextField.delegate = self
        
        FirstNameTextField.becomeFirstResponder()
        
        if (FirstNameTextField.text?.isEmpty)! {
            nextButton.isUserInteractionEnabled = false
            nextButton.alpha = 0.5
        }
        
        userFullName = "\(FirstNameTextField.text) \(LastNameTextField.text)"
    
      
    }
    
    func insertData() {
        
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let itemToCreate = QUser()
        
        itemToCreate?._userId = AWSIdentityManager.defaultIdentityManager().identityId
        
        objectMapper.save(itemToCreate!, completionHandler: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nextButton.isUserInteractionEnabled = true
        nextButton.alpha = 1.0
    }
    

    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        

        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    
    }

}
