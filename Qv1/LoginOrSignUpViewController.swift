//
//  LoginOrSignUpViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/22/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import DigitsKit
import Fabric

class LoginOrSignUpViewController: UIViewController {

    @IBOutlet weak var createAccountButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let digitsButton = DGTAuthenticateButton(authenticationCompletion: { (session, error) in
            // Inspect session/error objects
        })

       self.view.addSubview(digitsButton!)

    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        
    }
    

    
}
