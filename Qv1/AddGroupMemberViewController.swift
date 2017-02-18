//
//  AddGroupMemberViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/8/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AddGroupMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addToListButton: UIButton!
    @IBOutlet weak var addToListButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var tableView: UITableView!
    var selectedRecipients : [Recipient] = []
    var selectedCells : [AddGroupMemberTableViewCell] = []
    var friendArray : [Recipient] = []
    var groupID : String = ""
    var currentGroupMembers : [Recipient] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        addToListButtonHeightConstraint.constant = 0
        
        let profileUserID = FIRAuth.auth()?.currentUser?.uid
        
        let friendAndGroupListReference : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(profileUserID!).child("recipientList")
        
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
        
        let groupReference : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(groupID).child("groupMembers")
        
        
        groupReference.observe(.childAdded, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            
            var groupMember = Recipient()
            
            groupMember.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            groupMember.recipientID = snapshotValue["recipientID"] as! String
            groupMember.recipientName = snapshotValue["recipientName"] as! String
            
            self.currentGroupMembers.append(groupMember)
        })

        
        
        
        
        tableView.reloadData()
        
    
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return friendArray.count
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddGroupMemberTableViewCell", for: indexPath) as! AddGroupMemberTableViewCell
        
        let friendForCell = self.friendArray[indexPath.row]
        
        if currentGroupMembers.contains(where: {$0.recipientID == friendForCell.recipientID}) {
            
            cell.isUserInteractionEnabled = false
            cell.friendImageView.alpha = 0.5
            cell.friendNameLabel.alpha = 0.5
            cell.alreadyOnListLabel.isHidden = false
            cell.selectFriendButton.isHidden = true
            cell.friendNameLabel.text = friendForCell.recipientName
            cell.friendImageView.sd_setImage(with: URL(string: friendForCell.imageURL1))
            cell.friendImageView.layer.cornerRadius =  cell.friendImageView.layer.frame.size.width / 2
            cell.friendImageView.layer.masksToBounds = true
   
      
        } else {

        cell.alreadyOnListLabel.isHidden = true
        cell.friendNameLabel.text = friendForCell.recipientName
        cell.friendImageView.sd_setImage(with: URL(string: friendForCell.imageURL1))
        cell.friendImageView.layer.cornerRadius =  cell.friendImageView.layer.frame.size.width / 2
        cell.friendImageView.layer.masksToBounds = true

        cell.selectFriendButton.layer.cornerRadius = cell.selectFriendButton.layer.frame.size.width / 2
        cell.selectFriendButton.layer.masksToBounds = true
        
        cell.selectFriendButton.setTitle("+", for: .normal)
        cell.selectFriendButton.setTitleColor(UIColor.init(hexString: "004488"), for: .normal)
        
        cell.selectFriendButton.setBackgroundImage(UIImage(named: "LeastVotesAnswerBackground"), for: .normal)
        cell.selectFriendButton.layer.borderWidth = 0.2
        cell.selectFriendButton.layer.borderColor = UIColor.init(hexString: "004488").cgColor
        
        }
        

        return cell
        
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)! as! AddGroupMemberTableViewCell
        
        selectedCell.isSelected = true
        
        addToListButtonHeightConstraint.constant = 58
        
        selectedCells.append(selectedCell)

        selectedCell.selectFriendButton.setTitle("✓", for: .normal)
        selectedCell.selectFriendButton.setTitleColor(UIColor.white, for: .normal)
        selectedCell.selectFriendButton.titleColor(for: .normal)
        selectedCell.selectFriendButton.layer.borderWidth = 0
        selectedCell.selectFriendButton.setBackgroundImage(UIImage(named: "Login Button Background"), for: .normal)
            
            
     selectedRecipients.append(friendArray[indexPath.row])
        
        if selectedRecipients.count > 0 {
                addToListButtonHeightConstraint.constant = 58

            }

            
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
            
        }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell = tableView.cellForRow(at: indexPath)! as! AddGroupMemberTableViewCell
        let deSelectedRecipient = friendArray[indexPath.row]
        
        deSelectedCell.isSelected = false
        
        deSelectedCell.selectFriendButton.setTitle("+", for: .normal)
        deSelectedCell.selectFriendButton.setTitleColor(UIColor.init(hexString: "004488"), for: .normal)
        deSelectedCell.selectFriendButton.setBackgroundImage(UIImage(named: "LeastVotesAnswerBackground"), for: .normal)
        deSelectedCell.selectFriendButton.layer.borderWidth = 0.2
        deSelectedCell.selectFriendButton.layer.borderColor = UIColor.init(hexString: "004488").cgColor
        
        
        delete(recipient: deSelectedRecipient)
        removeCell(cell: deSelectedCell)
        
        
        if selectedRecipients.count < 1 {
            addToListButtonHeightConstraint.constant = 0
            
        }
    
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func delete(recipient: Recipient) {
        selectedRecipients = selectedRecipients.filter() {$0 !== recipient}
    }
    
   
    func removeCell (cell: AddGroupMemberTableViewCell) {
        selectedCells = selectedCells.filter() {$0 !== cell}
    }
    
    @IBAction func addToListButtonTapped(_ sender: Any) {
        
     let groupReference : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(groupID).child("groupMembers")
        
     selectedRecipients.forEach { (Recipient) in
        
        let recipientDict : [NSObject : AnyObject]  = ["recipientID" as NSObject: Recipient.recipientID as AnyObject, "recipientImageURL1" as NSObject: Recipient.imageURL1 as AnyObject, "recipientName" as NSObject: Recipient.recipientName as AnyObject, "tag" as NSObject: "user" as AnyObject]
        
        groupReference.child(Recipient.recipientID).setValue(recipientDict)
        
        }

        self.performSegue(withIdentifier: "unwindToGroupAfterAddingMembersWithSegue", sender: self)
        
    }
    
    
    
}


    


