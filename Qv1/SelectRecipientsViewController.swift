//
//  SelectRecipientsViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/29/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import AddressBook
import Contacts
import FirebaseDatabase
import FirebaseAuth
import SDWebImage


class SelectRecipientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var answer1String : String = ""
    var answer2String : String = ""
    var expiration : Timer = Timer()
    var pollID : String = ""
    var questionString : String = ""
    var recipients : [String] = []
    var answer1Percentage : Double = 0
    var expired : Bool = false
    var senderUser : String = ""
    
    
    var recipientList : [Recipient] = []
    var users : [User] = []
    var selectedRecipients  : [Recipient] = []
    
    var groupToEdit : Recipient = Recipient()

    
    
    
    @IBOutlet weak var sendButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        let userRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList")
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont(name: "Proxima Nova", size: 20)!]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        userRef.observe(FIRDataEventType.childAdded, with: {(snapshot) in
            print(snapshot)
            
            
            let recipient = Recipient()
            
            let snapshotvalue = snapshot.value as! NSDictionary
            
            recipient.recipientName = snapshotvalue["recipientName"] as! String
            recipient.recipientID = snapshotvalue["recipientID"] as! String
            recipient.tag = snapshotvalue["tag"] as! String
            recipient.imageURL1 = snapshotvalue["recipientImageURL1"] as! String
            
            if recipient.tag == "group" {
               recipient.imageURL2 = snapshotvalue["recipientImageURL2"] as! String
            } else {
             print("not a group")
            }
        
            self.recipientList.sort(by: {$0.recipientName > $1.recipientName})
            self.recipientList.append(recipient)
            
            self.tableView.reloadData()
            
        })
        
    }
    
    func editGroupScreen (sender : UIButton!) {
        
        groupToEdit = recipientList[sender.tag]
        
        performSegue(withIdentifier: "editGroupSegue", sender: groupToEdit)
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(recipientList)
        print(recipientList.count)
        
        return recipientList.count
        
        
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
     //user cell
      let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
        
      cell.userProfileImageView.layer.cornerRadius =  cell.userProfileImageView.layer.frame.size.width / 2
        cell.userProfileImageView.layer.masksToBounds = true
        
      let recipientCell = recipientList[indexPath.row]
        

      cell.userNameLabel.text = recipientCell.recipientName
        
      cell.userProfileImageView.sd_setImage(with: URL(string : recipientCell.imageURL1))
       
    //group cell
        
      let groupCell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as! GroupTableViewCell
        
        
      groupCell.groupMember1ImageView.sd_setImage(with: URL(string : recipientCell.imageURL1))
      groupCell.groupMember2ImageView.sd_setImage(with: URL(string : recipientCell.imageURL2))
      groupCell.groupNameLabel.text = recipientCell.recipientName

        
      groupCell.editButton.tag = indexPath.row
      groupCell.editButton.addTarget(self, action: #selector(self.editGroupScreen(sender:)), for: .touchUpInside)
    
        
        if recipientCell.tag == "group" {
            
        return groupCell
            
            
        } else {
        
     return cell
        
        }
    
    }

    
    @IBAction func createGroupButtonTapped(_ sender: Any) {
        
        var newRecipient : [NSObject : AnyObject] = [ : ]

        
        let selectedRecipientNames = selectedRecipients.map { $0.recipientName}
        print(selectedRecipientNames)
        
        let selectedRecipientIDs = selectedRecipients.map { $0.recipientID}
        print(selectedRecipientIDs)
        
        let selectedRecipientNamesString = selectedRecipientNames.joined(separator: ", ")
        print(selectedRecipientNamesString)
        
        let selectedRecipientIDString = selectedRecipientIDs.joined(separator: "+")
        print(selectedRecipientIDString)
        
        let recipientID = UUID().uuidString
        
        
        let ref : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList")
        
        newRecipient = ["recipientName" as NSObject: (selectedRecipientNamesString) as AnyObject, "recipientImageURL1" as NSObject: (selectedRecipients.first!.imageURL1 ) as AnyObject,"recipientImageURL2" as NSObject : (selectedRecipients[1].imageURL1 as AnyObject), "recipientID" as NSObject: (recipientID ) as AnyObject, "tag" as NSObject: "group" as AnyObject]
        
        
        print(newRecipient)
        
            
        let recipientListRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientID)
            
        recipientListRef.setValue(newRecipient)
        
        selectedRecipients.forEach { (Recipient) in
            
        let groupMember = ["recipientName" as NSObject: (Recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (Recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (Recipient.recipientID) as AnyObject, "tag" as NSObject: "user" as AnyObject]
           
        recipientListRef.child("groupMembers").child(Recipient.recipientID).setValue(groupMember)
            
        }
        
        selectedRecipients.removeAll()
        
        tableView.reloadData()
    
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.white
        
        let selectedRecipient = recipientList[indexPath.row]
        selectedRecipients.append(selectedRecipient)

        print(selectedRecipients)
        
    }
  
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedRecipient = recipientList[indexPath.row]
        selectedRecipients.remove(at: indexPath.row)
        print(selectedRecipients)
        tableView.reloadData()
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        print("send tapped")
        
    
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nextVC = segue.destination as! EditGroupViewController
        nextVC.group = sender as! Recipient
        
        print(nextVC.group)
    
        
    }
    
    }



    



