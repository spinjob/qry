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
    
    var poll : Poll = Poll()
    var pollID = ""
    var dictPoll : [NSObject : AnyObject] = [:]
    var recipientList : [Recipient] = []
    var users : [User] = []
    var selectedRecipients  : [Recipient] = []

    var groupToEdit : Recipient = Recipient()
    var groupMembers : [Recipient] = []
    
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
        
      cell.tag = indexPath.row
        
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
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.white
        
        
        if recipientList[indexPath.row].tag == "user" {

        let selectedRecipient = recipientList[indexPath.row]
        selectedRecipients.append(selectedRecipient)
         print(selectedRecipient.recipientName)
            
        }

        
        
        if recipientList[indexPath.row].tag == "group" {
            
        print(recipientList[indexPath.row].recipientName)
        print(recipientList[indexPath.row].recipientID)
            
            
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientList[indexPath.row].recipientID).child("groupMembers")
            
            ref.observe(FIRDataEventType.childAdded, with: {(snapshot) in
                
                let recipient = Recipient()
                
                let snapshotValue = snapshot.value as! NSDictionary
                
                recipient.recipientName = snapshotValue["recipientName"] as! String
                recipient.recipientID = snapshotValue["recipientID"] as! String
                recipient.tag = snapshotValue["tag"] as! String
                recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
                
                self.groupMembers.append(recipient)
                print("SELF\(self.groupMembers)")
                
                
                
                self.groupMembers.forEach { (Recipient) in
                    
                    let indexToDisable = self.recipientList.index(where: { $0.recipientID.contains(Recipient.recipientID) == true})
                    let indexPathForGroupMember = NSIndexPath(row: indexToDisable!, section: 0)
                    
                    
                    tableView.cellForRow(at: indexPathForGroupMember as IndexPath)?.isUserInteractionEnabled = false
                    tableView.cellForRow(at: indexPathForGroupMember as IndexPath)?.alpha = 0.5
                    
                    if self.selectedRecipients.contains(where: { $0.recipientID == Recipient.recipientID}) {
                        
                        print("already selected")
                        
                    }  else {
                        
                        self.selectedRecipients.append(Recipient)
                        print(self.selectedRecipients)
    
                    }
                }
            self.groupMembers.removeAll(keepingCapacity: true)
            
            })
            
            
            
            
                     
            print("GROUP OF USERS after \(groupMembers)")
            
        }

        
    }
  
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedRecipient = recipientList[indexPath.row]
        
        print("GROUP OF USERS \(groupMembers)")
        
        if recipientList[indexPath.row].tag == "user" {

        delete(recipient: recipientList[indexPath.row])
            
        print(selectedRecipients)
            
        }
        
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientList[indexPath.row].recipientID).child("groupMembers")
        
        ref.observe(FIRDataEventType.childAdded, with: {(snapshot) in
            
            let recipient = Recipient()
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            recipient.recipientName = snapshotValue["recipientName"] as! String
            recipient.recipientID = snapshotValue["recipientID"] as! String
            recipient.tag = snapshotValue["tag"] as! String
            recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            
            self.groupMembers.append(recipient)
            print("SELF\(self.groupMembers)")
            
            
            
            self.groupMembers.forEach { (Recipient) in
                
                let indexToDisable = self.recipientList.index(where: { $0.recipientID.contains(Recipient.recipientID) == true})
                let indexPathForGroupMember = NSIndexPath(row: indexToDisable!, section: 0)
                
                
                tableView.cellForRow(at: indexPathForGroupMember as IndexPath)?.isUserInteractionEnabled = true
                tableView.cellForRow(at: indexPathForGroupMember as IndexPath)?.alpha = 1
                tableView.deselectRow(at: indexPathForGroupMember as IndexPath, animated: true)
                self.delete(recipient: Recipient)
            
            }
            
            self.groupMembers.removeAll(keepingCapacity: true)
            
            print("SELF RECIPIENTLIST \(self.recipientList)")
            
        })
        
      print("AFTER RECIPIENTLIST \(recipientList)")
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        
        self.selectedRecipients.forEach { (Recipient) in
        let recipientID = Recipient.recipientID
        let ref = FIRDatabase.database().reference().child("users").child(recipientID).child("receivedPolls").child(pollID)
        ref.setValue(self.dictPoll)
    
     }

        
    
    }

    
    
    
    func delete(recipient: Recipient) {
        selectedRecipients = selectedRecipients.filter() {$0 !== recipient}
    }

    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nextVC = segue.destination as! EditGroupViewController
        nextVC.group = sender as! Recipient
        
        print(nextVC.group)
    
        
        }
    
    }



    



