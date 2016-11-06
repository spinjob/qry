//
//  HomeViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/18/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var currentUserID = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var newRecipient : [NSObject : AnyObject] = [ : ]
        var recipientID = ""
        
        let ref : FIRDatabaseReference = FIRDatabase.database().reference().child("users")
        
        ref.observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as? NSDictionary
            
            newRecipient = ["recipientName" as NSObject: (snapshotValue?["fullName"] as! String) as AnyObject, "recipientImageURL1" as NSObject: (snapshotValue?["profileImageURL"] as! String) as AnyObject, "recipientID" as NSObject: (snapshotValue?["uID"] as! String) as AnyObject, "tag" as NSObject: "user" as AnyObject]
            
            recipientID = snapshotValue?["uID"] as! String
            
            let recipientListRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientID)
            
            recipientListRef.setValue(newRecipient)

        
            })

        
        
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton

    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        return cell
    }
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        do {
            try FIRAuth.auth()?.signOut()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginOrSignUpViewController") as! LoginOrSignUpViewController
            present(vc, animated: true, completion: nil)
            print("You logged out")
            
        } catch let error as Error {
            print("\(error)")
        }
        
    }
   
}
