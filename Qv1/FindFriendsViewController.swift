//
//  FindFriendsViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/20/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Contacts

class FindFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    let currentUserRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
    
    let currentUserID = (FIRAuth.auth()?.currentUser?.uid)!
    
    let brightGreen = UIColor.init(hexString: "A8E855")
    let red = UIColor.init(hexString: "FF4E56")
    let actionGreen = UIColor.init(hexString: "00D1D5")
    let blue = UIColor.init(hexString: "004488")
    let grey = UIColor.init(hexString: "D8D8D8")
    
    var contactArray : [Recipient] = []
    var friendsArray : [Recipient] = []
    var selectedCells : [UITableViewCell] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        let ref = FIRDatabase.database().reference().child("users")
        var newRecipient :[NSObject : AnyObject] = [ : ]
        var recipientID = ""

        ref.observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
          
            var friend : Recipient = Recipient ()
            
            friend.imageURL1 = snapshotValue["profileImageURL"] as! String
            friend.recipientID = snapshot.key
            friend.recipientName = snapshotValue["fullName"] as! String
            friend.phoneNumber = snapshotValue["phoneNumber"] as! String
            
            if friend.recipientID == self.currentUserID {
                
                print("current user")
                
            } else if self.searchForContactUsingPhoneNumber(phoneNumber: friend.phoneNumber).count > 0 {
                
                print("FRIEND NUMBER\(friend.phoneNumber)")
                self.contactArray.append(friend)
            }
            
            self.tableView.reloadData()
    
        })
        
        
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)! as! AddFriendTableViewCell
        let recipientForCell = contactArray[indexPath.row]
        
        print("didSelect")
        selectedCell.isSelected = true
        selectedCells.append(selectedCell)
        
        friendsArray.append(recipientForCell)
        
        selectedCell.selectionButton.backgroundColor = actionGreen
        selectedCell.selectionButton.setTitle("✓", for: .normal)
        selectedCell.selectionButton.setTitleColor(UIColor.white, for: .normal)
        selectedCell.selectionButton.layer.borderColor = actionGreen.cgColor
        
        //print(selectedCells)
        print(friendsArray)
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let deSelectedCell = tableView.cellForRow(at: indexPath)! as! AddFriendTableViewCell
        let recipientForCell = contactArray[indexPath.row]
     
        print("didDeSelect")
        
        deSelectedCell.isSelected = false
        
        
        deSelectedCell.selectionButton.backgroundColor = UIColor.white
        deSelectedCell.selectionButton.setTitle("+", for: .normal)
        deSelectedCell.selectionButton.setTitleColor(blue, for: .normal)
        deSelectedCell.selectionButton.layer.borderColor = blue.cgColor
        
        delete(recipient: recipientForCell)
        removeCell(cell: deSelectedCell)
            
        //print(selectedCells)
        print(friendsArray)
            
            
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contactArray.count
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func delete(recipient: Recipient) {
        
        friendsArray = friendsArray.filter() {$0 !== recipient}
    
    }
    
    func removeCell (cell: AddFriendTableViewCell) {
        
        selectedCells = selectedCells.filter() {$0 !== cell}
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell", for: indexPath) as! AddFriendTableViewCell
        let contactForCell : Recipient = contactArray[indexPath.row]
        
        cell.contactUserImageView.sd_setImage(with: URL(string: contactForCell.imageURL1))
        cell.contactUserImageView.layer.cornerRadius = cell.contactUserImageView.layer.frame.width / 2
        cell.contactUserImageView.layer.masksToBounds = true
        
        cell.contactUserNameLabel.text = contactForCell.recipientName
        
        cell.selectionButton.layer.cornerRadius = cell.selectionButton.layer.frame.width / 2
        cell.selectionButton.layer.masksToBounds = true
        cell.selectionButton.layer.borderColor = blue.cgColor
        cell.selectionButton.layer.borderWidth = 0.2
        
        return cell
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
                        
                        print("USER NUMBER \(phoneNumberToCompareAgainst)")
                        print("CONTACT NUMBER\(phoneNumberToCompare)")
                        
                        
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

}
