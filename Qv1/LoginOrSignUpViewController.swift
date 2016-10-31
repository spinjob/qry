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
import FBSDKCoreKit
import FBSDKLoginKit

class LoginOrSignUpViewController: UIViewController {

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    var newUserFirstName = ""
    var newUserName = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func createUser () {
        
        if (FBSDKAccessToken.current() != nil) {
            FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"email,first_name,last_name"]).start(completionHandler: { (connection, result, error) in
                if error != nil {
                    
                    let userFacebookDict = result as! NSDictionary
                    
                    self.newUserName = (userFacebookDict.value(forKey: "name") as? String)!
                
                    let objectMapper = AWSDynamoDBObjectMapper.default()
                    
                    let itemToCreate = QUser()
                    
                    itemToCreate?._userId = AWSIdentityManager.defaultIdentityManager().identityId!
                    itemToCreate?._userName = self.newUserName
                    
                    objectMapper.save(itemToCreate!, completionHandler: {(error: Error?) -> Void in
                        
                        if let error = error {
                            
                            print("Amazon DynamoDB Save Error: \(error)")
                            
                            return
                            
                        }
                        
                        print("Item saved.")
                    })
                
                
                } else {
                    print(error)
                }
            })
            
        }
        
        
        
    }
    func handleLoginWithSignInProvider(signInProvider: AWSSignInProvider) {
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider, completionHandler:
            {(result: Any?, error: Error?) -> Void in
                if error == nil {
                    self.createUser()
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
        let nextViewController = segue.destination as! HomeViewController
        nextViewController.currentUserID = AWSIdentityManager.defaultIdentityManager().identityId!
    }
 
}
