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
import FirebaseStorage
import SDWebImage


class SelectRecipientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var poll : Poll = Poll()
    var pollID = ""
    var dictPoll : [NSObject : AnyObject] = [:]
    var recipientList : [Recipient] = []
    var groupRecipientList : [Recipient] = []
    var users : [User] = []
    var selectedRecipients  : [Recipient] = []
    var questionImage : UIImage = UIImage()
    var questionImageURL : String = "no question image"

    var groupToEdit : Recipient = Recipient()
    var groupMembers : [Recipient] = []
    
    let sectionTitles = ["Lists", "Friends"]
    
    
    @IBOutlet weak var sendButton: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dictPoll)
        print(poll.pollID)
        print("View Did Load Question Image \(questionImage)")
        
        let pollRef = FIRDatabase.database().reference().child("polls").child(pollID)
        let userRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList")
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont(name: "Proxima Nova", size: 20)!]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if questionImage.size != CGSize(width: 0, height: 0) {
            
            let profileImageData = UIImageJPEGRepresentation(questionImage, 0.4)
            
            FIRStorage.storage().reference().child("PollImages/\(poll.pollID)/pollImage.jpg").put(profileImageData!, metadata: nil){
                metadata, error in
                
                if error != nil {
                    print("error \(error)")
                }
                else {
                    pollRef.child("questionImageURL").setValue((metadata?.downloadURL()?.absoluteString)!)
                    self.questionImageURL = (metadata?.downloadURL()?.absoluteString)!
                    
                }
                
            }
            
        }
        userRef.queryOrdered(byChild: "tag").queryEqual(toValue: "group").observe(.childAdded, with: {
            
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            var group : Recipient = Recipient()
            
            group.recipientName = snapshotValue["recipientName"] as! String
            group.recipientID = snapshotValue["recipientID"] as! String
            group.tag = snapshotValue["tag"] as! String
            group.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            
            self.groupRecipientList.append(group)
            
        })
        
        userRef.queryOrdered(byChild: "tag").queryEqual(toValue: "user").observe(FIRDataEventType.childAdded, with: {(snapshot) in
            print(snapshot)
            
            
            let recipient = Recipient()
            
            let snapshotvalue = snapshot.value as! NSDictionary
            
            recipient.recipientName = snapshotvalue["recipientName"] as! String
            recipient.recipientID = snapshotvalue["recipientID"] as! String
            recipient.tag = snapshotvalue["tag"] as! String
            recipient.imageURL1 = snapshotvalue["recipientImageURL1"] as! String
        
            self.recipientList.sort(by: {$0.recipientName > $1.recipientName})
            self.recipientList.append(recipient)
            
            self.tableView.reloadData()
            
        })
        
    }
    
    func editGroupScreen (sender : UIButton!) {
        
        groupToEdit = groupRecipientList[sender.tag]
        
        performSegue(withIdentifier: "editGroupSegue", sender: groupToEdit)
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let items = [groupRecipientList, recipientList]
        
        if items[indexPath.section][indexPath.row].tag == "group" {
            return 80
        }
        
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = [groupRecipientList, recipientList]
        
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      let items = [groupRecipientList, recipientList]
        
      let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
        
      cell.tag = indexPath.row
        
      cell.userProfileImageView.layer.cornerRadius =  cell.userProfileImageView.layer.frame.size.width / 2
      cell.userProfileImageView.layer.masksToBounds = true
        
      let recipientForCell = items[indexPath.section][indexPath.row]
        

      cell.userNameLabel.text = recipientForCell.recipientName
        
      cell.userProfileImageView.sd_setImage(with: URL(string : recipientForCell.imageURL1))
       
    //group cell
        
      let groupCell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as! GroupTableViewCell
        
        
      groupCell.groupMember1ImageView.sd_setImage(with: URL(string : recipientForCell.imageURL1))
        groupCell.groupMember1ImageView.layer.cornerRadius = 4
        groupCell.groupMember1ImageView.layer.masksToBounds = true
      
      groupCell.groupNameLabel.text = recipientForCell.recipientName
      groupCell.tag = indexPath.row
      groupCell.groupMemberCollectionView.tag = indexPath.row
        
      groupCell.editButton.tag = indexPath.row
      groupCell.editButton.addTarget(self, action: #selector(self.editGroupScreen(sender:)), for: .touchUpInside)
    
    if indexPath.section == 0 {
        
        return groupCell
       
    }
       
    else {
        
        return cell
        
        }
    
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientList[collectionView.tag].recipientID).child("groupMembers")
    
        var collectionViewCellCount : Int = 2
        ref.observe(.childAdded, with: {
            
            snapshot in
            collectionViewCellCount = Int(snapshot.childrenCount)

        })
        
        
        return collectionViewCellCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   
        let items = [groupRecipientList, recipientList]
        
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(items[indexPath.section][indexPath.row].recipientID).child("groupMembers")
        
        collectionView.showsHorizontalScrollIndicator = false
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pollGroupMemberCell", for: indexPath) as! GroupMemberCollectionViewCell
        
        cell.groupMemberImageView.layer.cornerRadius = cell.groupMemberImageView.layer.frame.size.width / 2
        cell.groupMemberImageView.layer.masksToBounds = true
        
        var listMembers : [Recipient] = []
        
        ref.observe(.childAdded, with: {
            snapshot in
        
            
            
            let recipient = Recipient()
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            recipient.recipientName = snapshotValue["recipientName"] as! String
            recipient.recipientID = snapshotValue["recipientID"] as! String
            recipient.tag = snapshotValue["tag"] as! String
            recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            
            listMembers.append(recipient)
            
        
        })
        
        cell.groupMemberImageView.sd_setImage(with: URL(string:listMembers[collectionView.tag].imageURL1))
        
        return cell
        
    }
 
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.white
        
        let items = [groupRecipientList, recipientList]
        
        
        if indexPath.section == 1 {

        let selectedRecipient = items[indexPath.section][indexPath.row]
        selectedRecipients.append(selectedRecipient)
            
        }

        
        
        if indexPath.section == 0 {

            
            
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(items[indexPath.section][indexPath.row].recipientID).child("groupMembers")
            
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
                    let indexPathForGroupMember = NSIndexPath(row: indexToDisable!, section: 1)
                    
                    
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
        
    
        let items = [groupRecipientList, recipientList]
        
        let deSelectedRecipient = items[indexPath.section][indexPath.row]
        
        if indexPath.section == 1 {

        delete(recipient: items[indexPath.section][indexPath.row])
            
        print(selectedRecipients)
            
        }
        
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(items[indexPath.section][indexPath.row].recipientID).child("groupMembers")
        
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
                
                let indexToEnable = self.recipientList.index(where: { $0.recipientID.contains(Recipient.recipientID) == true})
                let indexPathForGroupMember = NSIndexPath(row: indexToEnable!, section: 1)
                
                
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
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        let pollRef = FIRDatabase.database().reference().child("polls").child(pollID)
        pollRef.setValue(dictPoll)
               
        print("Send Tapped Question Image \(questionImage)")
        
        
        self.selectedRecipients.forEach { (Recipient) in
        
        let recipientID = Recipient.recipientID
        print(Recipient.recipientName)
        let recipientDict : [NSObject : AnyObject] = ["recipientName" as NSObject: (Recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (Recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (recipientID) as AnyObject, "tag" as NSObject: "user" as AnyObject]
        let voter : [NSObject : AnyObject] = ["recipientName" as NSObject: (Recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (Recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (recipientID) as AnyObject, "voteString" as NSObject: "no vote" as AnyObject]
        let ref = FIRDatabase.database().reference().child("users").child(recipientID).child("receivedPolls").child(pollID)
        let sentToRef = FIRDatabase.database().reference().child("polls").child(pollID).child("sentTo").child(recipientID)
        let voteRef = FIRDatabase.database().reference().child("polls").child(pollID).child("votes").child(recipientID)
            
   
        sentToRef.setValue(recipientDict)
        ref.setValue(self.dictPoll)
        ref.child("questionImageURL").setValue(self.questionImageURL)
        voteRef.setValue(voter)
    
     }
        
         self.performSegue(withIdentifier: "unwindToMenuSend", sender: self)
    
    }

    
    @IBAction func unwindAfterEditing(segue: UIStoryboardSegue){
    
    tableView.reloadData()
    
    
    }

    
    func delete(recipient: Recipient) {
        selectedRecipients = selectedRecipients.filter() {$0 !== recipient}
    }

    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGroupSegue" {
        let nextVC = segue.destination as! EditGroupViewController
        nextVC.group = sender as! Recipient
        
        print(nextVC.group)
    
        }
        }
    
    }



    



