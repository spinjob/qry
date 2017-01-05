//
//  FriendsViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 12/21/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createGroupButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var createGroupButton: UIButton!
    
    
    let sectionTitles = ["Friends (Mutual Follows)", "Lists"]
    var profileUserID = ""
    var friendArray : [Recipient] = []
    var groupArray : [Recipient] = []
//    var items : [[Recipient]] = [[]]
    var selectedRecipients : [Recipient] = []
    var selectedCells : [EditFriendTableViewCell] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        createGroupButtonHeightConstraint.constant = 0
        let friendAndGroupListReference : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(profileUserID).child("recipientList")
        
        friendAndGroupListReference.queryOrdered(byChild: "tag").queryEqual(toValue: "user").observe(.childAdded, with: {
            snapshot in
            
            var friend : Recipient = Recipient ()
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            friend.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            friend.recipientID = snapshotValue["recipientID"] as! String
            friend.recipientName = snapshotValue["recipientName"] as! String
            friend.tag = snapshotValue["tag"] as! String
            
            self.friendArray.append(friend)
            self.tableView.reloadData()
            
        })
        
        selectedCells.forEach { (EditFriendTableViewCell) in
            EditFriendTableViewCell.isSelected = true
        }
        
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("view appeared")
        
        groupArray.removeAll()
        
        let friendAndGroupListReference : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(profileUserID).child("recipientList")
        
        friendAndGroupListReference.queryOrdered(byChild: "tag").queryEqual(toValue: "group").observe(.childAdded, with: {
            snapshot in
            
            var group : Recipient = Recipient ()
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            if self.selectedRecipients.contains(where: { $0.recipientID == group.recipientID})
            { print("group already added")
                
            }
            
            group.recipientID = snapshotValue["recipientID"] as! String
            group.recipientName = snapshotValue["recipientName"] as! String
            group.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            group.tag = snapshotValue["tag"] as! String
            
            self.groupArray.append(group)
            self.tableView.reloadData()
            
        })
        
    }
    
    //TableView Data Source
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let items = [friendArray, groupArray]
        
        if items[indexPath.section][indexPath.row].tag == "group" {
            return 100
        }
        
        return 60
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = [friendArray, groupArray]
        
        return items[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editFriendCell", for: indexPath) as! EditFriendTableViewCell
        let items = [friendArray, groupArray]
        cell.isUserInteractionEnabled = true
        cell.editButton.tag = indexPath.row
        cell.editButton.addTarget(self, action: (#selector(self.editGroup(sender:))), for: .touchUpInside)
        
       // cell.friendImageView.sd_setImage(with: URL(string: items[indexPath.section][indexPath.row].imageURL1))
        //cell.friendImageView.layer.cornerRadius =  cell.friendImageView.layer.frame.size.width / 2
        //cell.friendImageView.layer.masksToBounds = true
        cell.friendNameLabel.text = items[indexPath.section][indexPath.row].recipientName
        
        if cell.isSelected == true {
            cell.actionButtonWidth.constant = 22
            cell.actionButton.setTitle("✓", for: .normal)
            cell.actionButton.layer.cornerRadius = 22 / 2
            cell.actionButton.setBackgroundImage(UIImage(named: "Login Button Background"), for: .normal)
            cell.actionButton.isUserInteractionEnabled = false
        }
        
        if cell.isSelected == false {
            
            cell.actionButtonWidth.constant = 73
            cell.actionButton.layer.cornerRadius = 4
            cell.actionButton.setTitle("Unfollow", for: .normal)
            cell.actionButton.layer.masksToBounds = true
            cell.actionButton.setBackgroundImage(UIImage(named: "redBackground"), for: .normal)
            cell.actionButton.isUserInteractionEnabled = true
            cell.editButton.isHidden = true
            
        }
        
         if items[indexPath.section][indexPath.row].tag == "user" {
            cell.actionButton.isHidden = false
            cell.editButton.isHidden = true
            cell.friendImageView.layer.cornerRadius =  40 / 2
            cell.friendImageView.layer.masksToBounds = true
            cell.imageViewHeight.constant = 40
            cell.imageViewWidth.constant = 40
            cell.friendImageView.sd_setImage(with: URL(string: items[indexPath.section][indexPath.row].imageURL1))
            
        }
        
        
        if  items[indexPath.section][indexPath.row].tag == "group" {
            
            cell.actionButton.isHidden = true
            cell.editButton.isHidden = false
            cell.friendImageView.layer.cornerRadius =  4
            cell.friendImageView.layer.masksToBounds = true
            cell.imageViewHeight.constant = 60
            cell.imageViewWidth.constant = 60
            cell.friendImageView.sd_setImage(with: URL(string: items[indexPath.section][indexPath.row].imageURL1))

        }

        return cell
    
        
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)! as! EditFriendTableViewCell
        let items = [friendArray, groupArray]
        
        selectedCell.isSelected = true
        selectedCells.append(selectedCell)
        
        if items[indexPath.section][indexPath.row].tag == "user" {
        selectedCell.contentView.backgroundColor = UIColor.white

        selectedCell.actionButtonWidth.constant = 22
        selectedCell.actionButton.setTitle("✓", for: .normal)
        selectedCell.actionButton.layer.cornerRadius = 22 / 2
        selectedCell.actionButton.setBackgroundImage(UIImage(named: "Login Button Background"), for: .normal)
        selectedCell.actionButton.isUserInteractionEnabled = false
            
            
        selectedRecipients.append(items[indexPath.section][indexPath.row])
        
            if selectedRecipients.count > 1 {
                createGroupButtonHeightConstraint.constant = 58
            
            }
            
            
        print(selectedRecipients)
            
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let items = [friendArray, groupArray]
        let deSelectedCell = tableView.cellForRow(at: indexPath)! as! EditFriendTableViewCell
        let deSelectedRecipient = items[indexPath.section][indexPath.row]
        deSelectedCell.isSelected = false
        
        
         if items[indexPath.section][indexPath.row].tag == "user" {
        deSelectedCell.actionButtonWidth.constant = 73
        deSelectedCell.actionButton.layer.cornerRadius = 4
        deSelectedCell.actionButton.setTitle("Unfollow", for: .normal)
        deSelectedCell.actionButton.layer.cornerRadius = 4
        deSelectedCell.actionButton.layer.masksToBounds = true
        deSelectedCell.actionButton.setBackgroundImage(UIImage(named: "redBackground"), for: .normal)
        deSelectedCell.actionButton.isUserInteractionEnabled = true
        
        deSelectedCell.editButton.isHidden = true
            
        delete(recipient: deSelectedRecipient)
        removeCell(cell: deSelectedCell)
        
        print(selectedCells)
            
        if selectedRecipients.count < 2 {
                createGroupButtonHeightConstraint.constant = 0
                
            }
        
        print(selectedRecipients)
            
            
        UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let items = [friendArray, groupArray]
        let groupToDelete = items[indexPath.section][indexPath.row].recipientID
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete group tapped")
            
            let ref : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList")
            
            let friendAndGroupListReference : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(self.profileUserID).child("recipientList")
            
            ref.child(groupToDelete).removeValue()
            
            self.groupArray.removeAll()
            
            friendAndGroupListReference.queryOrdered(byChild: "tag").queryEqual(toValue: "group").observe(.childAdded, with: {
                snapshot in
                
                var group : Recipient = Recipient ()
                
                let snapshotValue = snapshot.value as! NSDictionary
                
                if self.selectedRecipients.contains(where: { $0.recipientID == group.recipientID})
                { print("group already added")
                    
                }
                
                group.recipientID = snapshotValue["recipientID"] as! String
                group.recipientName = snapshotValue["recipientName"] as! String
                group.imageURL1 = snapshotValue["recipientImageURL1"] as! String
                group.tag = snapshotValue["tag"] as! String
                
                self.groupArray.append(group)
                self.tableView.reloadData()
                
            })
            
    
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
            

        }
        
        delete.backgroundColor = UIColor.init(hexString: "FF4E56")
       
        
        return [delete]
        
    
    }

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
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
        
        
        var group : Recipient = Recipient()
        
        group.recipientName = selectedRecipientNamesString
        group.imageURL1 = selectedRecipients.first!.imageURL1
        group.imageURL2 = selectedRecipients[1].imageURL1
        group.recipientID = recipientID
        group.tag = "group"
        
        
        newRecipient = ["recipientName" as NSObject: (selectedRecipientNamesString) as AnyObject, "recipientImageURL1" as NSObject: (selectedRecipients.first!.imageURL1 ) as AnyObject,"recipientImageURL2" as NSObject : (selectedRecipients[1].imageURL1 as AnyObject), "recipientID" as NSObject: (recipientID ) as AnyObject, "tag" as NSObject: "group" as AnyObject]
        
        
        
        let recipientListRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientID)
        
        recipientListRef.setValue(newRecipient)
        
        selectedRecipients.forEach { (Recipient) in
            
            let groupMember = ["recipientName" as NSObject: (Recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (Recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (Recipient.recipientID) as AnyObject, "tag" as NSObject: "user" as AnyObject]
            
            recipientListRef.child("groupMembers").child(Recipient.recipientID).setValue(groupMember)
            
        }
        
        selectedRecipients.removeAll()
        tableView.reloadSections([1], with: .fade)
        
    }
    
    
    func delete(recipient: Recipient) {
        selectedRecipients = selectedRecipients.filter() {$0 !== recipient}
    }
    
    func removeCell (cell: EditFriendTableViewCell) {
        selectedCells = selectedCells.filter() {$0 !== cell}
    }
    
    
    
    
    func editGroup (sender: UIButton) {
        let items = [friendArray, groupArray]
        let groupToEdit = items[1][sender.tag]
        
        print(groupToEdit.recipientID)
        print(groupToEdit.imageURL1)
        print(groupToEdit.recipientName)
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "editGroupVC") as! GroupViewController
        myVC.groupImageURL = groupToEdit.imageURL1
        myVC.groupName = groupToEdit.recipientName
        myVC.groupID = groupToEdit.recipientID
        
         navigationController?.pushViewController(myVC, animated: true)
    }
        
    }
    
    



