//
//  LoginOrSignUpViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/22/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import Foundation
import UIKit
import DigitsKit
import Fabric
import FirebaseAuth
import FirebaseDatabase

class LoginOrSignUpViewController: UIViewController {

    @IBOutlet weak var createAccountButton: UIButton!
    let userDefaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let digitsButton = DGTAuthenticateButton(authenticationCompletion: { (session, error) in
            // Inspect session/error objects
        })

       self.view.addSubview(digitsButton!)

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if userDefaults.string(forKey: "email") != nil {
            
            let email = userDefaults.string(forKey: "email")
            
            let password = userDefaults.string(forKey: "password")
            
            
            login(email: email!, password: password!)
            
        }
    }
    
    
    
    func login (email: String, password: String) {
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            print ("We are tried to sign in")
            
            if error != nil {
                
                print("We have an error: \(error)")
            } else {
                print("We've signed in successfully")
                
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        
    }
    

    
}
