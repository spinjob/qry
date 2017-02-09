//
//  GroupViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 12/29/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class GroupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var editPictureView: UIView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveChangesButton: UIButton!
    
    @IBOutlet weak var saveChangesButtonHeightConstraint: NSLayoutConstraint!
    
    var imagePicker = UIImagePickerController()
    var groupMembers : [Recipient] = []
    var groupImageURL : String = ""
    var groupName : String = ""
    var groupID : String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        groupImageView.isHidden = false
        groupImageView.layer.cornerRadius = 3
        groupImageView.layer.borderWidth = 0.3
        groupImageView.layer.borderColor = UIColor(hexString: "004488").cgColor
        groupImageView.layer.masksToBounds = true
        groupImageView.sd_setImage(with: URL(string: groupImageURL))
        
        groupNameTextField.text = groupName
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.delegate = self
        editPictureView.addGestureRecognizer(tap)
        groupNameTextField.addTarget(self, action: #selector(GroupViewController.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        
        
        saveChangesButtonHeightConstraint.constant = 0
        
        
        imagePicker.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        groupNameTextField.delegate = self
        
        
        
        let groupReference : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(groupID).child("groupMembers")
    
        
        groupReference.observe(.childAdded, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            
            var groupMember = Recipient()
            
            groupMember.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            groupMember.recipientID = snapshotValue["recipientID"] as! String
            groupMember.recipientName = snapshotValue["recipientName"] as! String
            
            self.groupMembers.append(groupMember)
            
            print(self.groupMembers)
        
            self.tableView.reloadData()
        })
        
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let groupPictureURLRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(groupID).child("recipientImageURL1")
        groupImageView.isHidden = false
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        
        let groupImageData = UIImageJPEGRepresentation(image, 0.4)
        
        FIRStorage.storage().reference().child("Users/\(FIRAuth.auth()?.currentUser!.uid)/\(groupID)").put(groupImageData!, metadata: nil){
            metadata, error in
            
            if error != nil {
                print("error \(error)")
            }
            else {
                let downloadURL = metadata?.downloadURL()?.absoluteString
                groupPictureURLRef.setValue(downloadURL)

            }}
        
        groupImageView.image = image
        groupImageView.backgroundColor = UIColor.clear
        

        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "editGroupMemberCell", for: indexPath) as! EditGroupMemberTableViewCell
        
        let groupMemberForCell = self.groupMembers[indexPath.row]
        
        
        cell.groupMemberNameLabel.text = groupMemberForCell.recipientName
        cell.groupMemberImageView.sd_setImage(with: URL(string: groupMemberForCell.imageURL1))
        cell.groupMemberImageView.layer.cornerRadius =  cell.groupMemberImageView.layer.frame.size.width / 2
        cell.groupMemberImageView.layer.masksToBounds = true
        cell.removeButton.layer.cornerRadius = 4
        cell.removeButton.layer.masksToBounds = true
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(self.removeButtonTapped(sender:)), for: .touchUpInside)
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groupMembers.count
        
    }
    
    
    func handleTap(sender: UITapGestureRecognizer) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addFriendButtonTapped(_ sender: Any) {
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "AddGroupMemberViewController") as! AddGroupMemberViewController
        myVC.groupID = groupID
        
        navigationController?.pushViewController(myVC, animated: true)
    }


    func textFieldDidChange(textField: UITextField) {
       saveChangesButtonHeightConstraint.constant = 58
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func saveChangesButtonTapped(_ sender: Any) {
        let groupNameReference : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(groupID).child("recipientName")
        
        groupNameReference.setValue(groupNameTextField.text)
    
        saveChangesButtonHeightConstraint.constant = 0
        
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }

        
    }

    func removeButtonTapped (sender: UIButton) {
        
        let groupReference : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(groupID).child("groupMembers")
        
        groupReference.child(groupMembers[sender.tag].recipientID).removeValue()
        
        groupMembers.remove(at: sender.tag)
        
        tableView.reloadData()
    }
    
     @IBAction func unwindToGroupAfterAddingMembers (segue: UIStoryboardSegue) {
    
    }
    

}
