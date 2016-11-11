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
    var receivedPolls : [Poll] = []
    var selectedButton : [Int : UIButton] = [:]
    var senderUser : User = User()
    let ref : FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    let pollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var newRecipient : [NSObject : AnyObject] = [ : ]
        var recipientID = ""
        
        ref.observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as? NSDictionary
            
            newRecipient = ["recipientName" as NSObject: (snapshotValue?["fullName"] as! String) as AnyObject, "recipientImageURL1" as NSObject: (snapshotValue?["profileImageURL"] as! String) as AnyObject, "recipientID" as NSObject: (snapshotValue?["uID"] as! String) as AnyObject, "tag" as NSObject: "user" as AnyObject]
            
            recipientID = snapshotValue?["uID"] as! String
            
            let recipientListRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientID)
            
            recipientListRef.setValue(newRecipient)

        
            })
        
        
        pollRef.observe(.childAdded, with: {
            snapshot in
            
            
            let poll = Poll()

            let snapshotValue = snapshot.value as! NSDictionary
            
            poll.answer1String = snapshotValue["answer1"] as! String
            poll.answer2String = snapshotValue["answer2"] as! String
            poll.questionString = snapshotValue["question"] as! String
            poll.senderUser = snapshotValue["senderUser"] as! String
            
            
            self.receivedPolls.append(poll)
            
            self.tableView.reloadData()
            
            
        })
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        print(receivedPolls)
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton

    }

 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedPolls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "pollCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PollTableViewCell
        
        let userRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("users")
        
        print(receivedPolls[indexPath.row].pollID)
        
       // let pollSenderUserRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls").child(receivedPolls[indexPath.row].pollID)
        
        
        
        cell.answer1Button.tag = indexPath.row
        cell.answer2Button.tag = indexPath.row
        
        
        cell.answer1Button.layer.borderWidth = 0.5
        cell.answer1Button.layer.cornerRadius = 3.5
        cell.answer1Button.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
        
        cell.answer2Button.layer.borderWidth = 0.5
        cell.answer2Button.layer.cornerRadius = 3.5
        cell.answer2Button.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
        
        cell.answer1Button.setTitle(receivedPolls[indexPath.row].answer1String, for: .normal);
        cell.answer2Button.setTitle(receivedPolls[indexPath.row].answer2String, for: .normal);
        cell.questionStringLabel.text = receivedPolls[indexPath.row].questionString
        
        
        cell.senderUserImageView.layer.cornerRadius =  cell.senderUserImageView.layer.frame.size.width / 2
        cell.senderUserImageView.layer.masksToBounds = true
        cell.senderUserImageView.layer.borderWidth = 0.2
        cell.senderUserImageView.layer.borderColor = UIColor.init(hexString: "506688").cgColor
        
        cell.answer1Button.addTarget(self, action: #selector(self.answerButton1Tapped(sender:)), for: .touchUpInside)
        cell.answer2Button.addTarget(self, action: #selector(self.answerButton2Tapped(sender:)), for: .touchUpInside)
        
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
    
    
    
    func answerButton1Tapped (sender : UIButton){
        sender.isSelected = !sender.isSelected;
        
        if selectedButton[sender.tag] != nil {
            if selectedButton[sender.tag] != sender {
                selectedButton[sender.tag]?.isSelected = false
                selectedButton[sender.tag]?.layer.backgroundColor = UIColor.white.cgColor
                
                selectedButton.updateValue(sender, forKey: sender.tag)
                sender.isSelected = true
                sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
            } else {
                selectedButton.removeValue(forKey: sender.tag)
                sender.isSelected = false
                sender.layer.backgroundColor = UIColor.white.cgColor
            }
        } else {
            
            selectedButton.updateValue(sender, forKey: sender.tag)
            sender.isSelected = true
            sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
        }
        print(selectedButton[sender.tag]?.titleLabel?.text!)
    }
    
    
    func answerButton2Tapped (sender : UIButton){
        
        sender.isSelected = !sender.isSelected;
        
        if selectedButton.first != nil {
            if selectedButton[sender.tag] != sender {
                selectedButton[sender.tag]?.isSelected = false
                selectedButton[sender.tag]?.layer.backgroundColor = UIColor.white.cgColor
                
                selectedButton.updateValue(sender, forKey: sender.tag)
                sender.isSelected = true
                sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
            } else {
                selectedButton.removeValue(forKey: sender.tag)
                sender.isSelected = false
                sender.layer.backgroundColor = UIColor.white.cgColor
            }
        } else {
            
            selectedButton.updateValue(sender, forKey: sender.tag)
            sender.isSelected = true
            sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
        }
        print(selectedButton[sender.tag]?.titleLabel?.text!)
    }
}
