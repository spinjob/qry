//
//  EditGroupViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 11/6/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class EditGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var group : Recipient = Recipient()
    
    var groupMemberIDString : String = ""
    
    var groupMembers : [Recipient] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupNameTextField.delegate = self
        
        
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(group.recipientID).child("groupMembers")
            
        
        ref.observe(FIRDataEventType.childAdded, with: {(snapshot) in
                print(snapshot)
                
                
                let recipient = Recipient()
                
                let snapshotValue = snapshot.value as! NSDictionary
                
                recipient.recipientName = snapshotValue["recipientName"] as! String
            
            
                recipient.recipientID = snapshotValue["recipientID"] as! String
                recipient.tag = snapshotValue["tag"] as! String
                recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String

                self.groupMembers.append(recipient)
                self.tableView.reloadData()
                
            })
        
        
        groupNameTextField.text = group.recipientName
        tableView.delegate = self
        tableView.dataSource = self

        

    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = true
        saveButton.isUserInteractionEnabled = true
        saveButton.alpha = 1.0
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupMemberCell") as! GroupMemberTableViewCell
        
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(self.removeUserFromGroup(sender:)), for: .touchUpInside)
        
        cell.groupMemberImageView.layer.cornerRadius =  cell.groupMemberImageView.layer.frame.size.width / 2
        cell.groupMemberImageView.layer.masksToBounds = true
        
        let groupMemberCell = groupMembers[indexPath.row]
        
        
        cell.groupMemberNameLable.text = groupMemberCell.recipientName
    
        cell.groupMemberImageView.sd_setImage(with: URL(string : groupMemberCell.imageURL1))
        
        
        
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers.count
        print(groupMembers.count)
        
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let ref : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(group.recipientID).child("recipientName")
        
        ref.setValue(groupNameTextField.text)
        
        self.performSegue(withIdentifier: "unwindAfterEditing", sender: self)
        
    }
    
    func removeUserFromGroup (sender : UIButton) {
        
        print("remove pressed")
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(group.recipientID).child("groupMembers").child(groupMembers[sender.tag].recipientID)
        
        ref.removeValue()
        tableView.reloadData()
        
        print("data reloaded")
    }
    
}
