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
import Contacts

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createGroupButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var createGroupButton: UIButton!
    
    
    let sectionTitles = ["Friends (Mutual Follows)", "Lists"]
    var profileUserID = ""
    var friendArray : [Recipient] = []
    var groupArray : [Recipient] = []
    var liveThreadArray : [Poll] = []
//    var items : [[Recipient]] = [[]]
    var selectedRecipients : [Recipient] = []
    var selectedCells : [EditFriendTableViewCell] = []
    
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
        
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBarItems()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
    
        let userRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users")
        
        
        userRef.observe(.childAdded, with: {
            snapshot in
            
            
        })
        
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
            friend.phoneNumber = snapshotValue["phoneNumber"] as! String
            
            if friend.recipientID == self.profileUserID {
                
                print("current user")
                
            } else if self.searchForContactUsingPhoneNumber(phoneNumber: friend.phoneNumber).count > 0 {
              self.friendArray.append(friend)
            }
            
            self.tableView.reloadData()
            
        })
        
        selectedCells.forEach { (EditFriendTableViewCell) in
            EditFriendTableViewCell.isSelected = true
        }
        
        
        
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
    
    
    func searchForContactUsingPhoneNumber(phoneNumber: String) -> [CNContact] {
        
        
        let recipient = Recipient()
        var matchingRecipient = Recipient()
        var result: [CNContact] = []
        
        for contact in self.contacts {
            
            if (!contact.phoneNumbers.isEmpty) {
                
                let phoneNumberToCompareAgainst = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                for phoneNumber in contact.phoneNumbers {
                    if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
                        let phoneNumberString = phoneNumberStruct.stringValue
                        let phoneNumberToCompare = phoneNumberString.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")

                        if phoneNumberToCompare == phoneNumberToCompareAgainst {
                            
                            recipient.recipientName = "\(contact.givenName) \(contact.familyName)"
                            recipient.phoneNumber = phoneNumberToCompare
                            
                            matchingRecipient = recipient
                            
                            result.append(contact)
                        } else if phoneNumberToCompare == "1\(phoneNumberToCompareAgainst)" {
                            recipient.recipientName = "\(contact.givenName) \(contact.familyName)"
                            recipient.phoneNumber = phoneNumberToCompare
                            
                            matchingRecipient = recipient
                            
                            result.append(contact)
                        }
                }
                }
            }
        }
        
        return result
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let view = tableView.dequeueReusableCell(withIdentifier: "friendAndListHeaderCell") as! FriendsAndListsHeaderTableViewCell

        view.headerLabel.text = "Friends"
        view.contentView.backgroundColor = UIColor.init(hexString: " 043176")
       
        if section == 1 {
           view.headerLabel.text = "Lists"
           view.contentView.backgroundColor = UIColor.init(hexString: "19C4C3")
        }
        
        return view.contentView
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
            
            self.tableView.reloadData()
            
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
      //  print(selectedRecipientNames)
        
        let selectedRecipientIDs = selectedRecipients.map { $0.recipientID}
      //  print(selectedRecipientIDs)
        
        let selectedRecipientNamesString = selectedRecipientNames.joined(separator: ", ")
      //  print(selectedRecipientNamesString)
        
        let selectedRecipientIDString = selectedRecipientIDs.joined(separator: "+")
      //  print(selectedRecipientIDString)
        
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
        createGroupButtonHeightConstraint.constant = 0
        selectedCells.removeAll()
       
        tableView.reloadData()
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
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
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "editGroupVC") as! GroupViewController
        myVC.groupImageURL = groupToEdit.imageURL1
        myVC.groupName = groupToEdit.recipientName
        myVC.groupID = groupToEdit.recipientID
        
         navigationController?.pushViewController(myVC, animated: true)
    }
  
    
    func setUpNavigationBarItems() {
        
        let pageTitle : UILabel = UILabel()
        
        pageTitle.text = "Friends & Lists"
    
        pageTitle.textColor = UIColor.init(hexString: "4B6184")
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 35))
        
        pageTitle.frame = titleView.bounds
        titleView.addSubview(pageTitle)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
        
        
    }

}




    



