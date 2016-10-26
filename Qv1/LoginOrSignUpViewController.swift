//
//  LoginOrSignUpViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/22/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB
import FBSDKLoginKit

class LoginOrSignUpViewController: UIViewController {

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }
    
    
    func handleLoginWithSignInProvider(signInProvider: AWSSignInProvider) {
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider, completionHandler:
            {(result: Any?, error: Error?) -> Void in
                if error == nil {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
        })
        
    }
    
    func handleFacebookLogin() {
        // Facebook login permissions can be optionally set, but must be set
        // before user authenticates.
        AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile"]);
        
        handleLoginWithSignInProvider(signInProvider: AWSFacebookSignInProvider.sharedInstance())
    }
    
    @IBAction func LogInButtonTapped(_ sender: AnyObject) {
        
        handleFacebookLogin()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextViewController = segue.destination as! VerifyPhoneViewController
        nextViewController.userID = AWSIdentityManager.defaultIdentityManager().identityId!
    }
 
}
