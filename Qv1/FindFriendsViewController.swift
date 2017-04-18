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
    @IBOutlet weak var addFriendsButton: UIButton!
    
    @IBOutlet weak var addFriendsHeightConstraint: NSLayoutConstraint!
    
    
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
    var recipientList : [Recipient] = []
    
    var onboarding : Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFriendsHeightConstraint.constant = 0
        
        let ref = FIRDatabase.database().reference().child("users")
        let currentUserRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
        var newRecipient :[NSObject : AnyObject] = [ : ]
        var recipientID = ""
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        
        if onboarding == true {
            setUpNavigationBarItems()
           
            ref.observe(.childAdded, with: {
                snapshot in
                
                let snapshotValue = snapshot.value as! NSDictionary
                
                var friend : Recipient = Recipient ()
                
                friend.imageURL1 = snapshotValue["profileImageURL"] as! String
                friend.recipientID = snapshot.key
                friend.recipientName = snapshotValue["fullName"] as! String
                friend.phoneNumber = snapshotValue["phoneNumber"] as! String
                friend.recipientFirstName = snapshotValue["firstName"] as! String
                friend.recipientLastName = snapshotValue["lastName"] as! String
                
                if friend.recipientID == self.currentUserID {
                    
                    print("current user")
                    
                } else if self.searchForContactUsingPhoneNumber(phoneNumber: friend.phoneNumber).count > 0 {
                    
                    print("FRIEND NUMBER\(friend.phoneNumber)")
                    self.contactArray.append(friend)
                    self.contactArray = self.contactArray.sorted(by: {$0.recipientFirstName < $1.recipientFirstName})
                }
                
                self.tableView.reloadData()
                
            })
            
            
            
        } else {
            
            ref.observe(.childAdded, with: {
                snapshot in
                
                let snapshotValue = snapshot.value as! NSDictionary
                
                var friend : Recipient = Recipient ()
                
                friend.imageURL1 = snapshotValue["profileImageURL"] as! String
                friend.recipientID = snapshot.key
                friend.recipientName = snapshotValue["fullName"] as! String
                friend.phoneNumber = snapshotValue["phoneNumber"] as! String
                friend.recipientFirstName = snapshotValue["firstName"] as! String
                friend.recipientLastName = snapshotValue["lastName"] as! String
                
                if friend.recipientID == self.currentUserID {
                    
                    print("current user")
                    
                } else if self.searchForContactUsingPhoneNumber(phoneNumber: friend.phoneNumber).count > 0 {
                    
                    print("FRIEND NUMBER\(friend.phoneNumber)")
                    
                    if (self.recipientList.contains(where: { $0.recipientID == friend.recipientID}))
                    { print("friend already added")
                        
                    } else {
                    self.contactArray.append(friend)
                    self.contactArray = self.contactArray.sorted(by: {$0.recipientFirstName < $1.recipientFirstName})
                    }
                }
                
                self.tableView.reloadData()
                
            })
            
        }
        
        
        

        
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
        
        
        addFriendsHeightConstraint.constant = 50
        
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
        
        if friendsArray.count == 0 {
            addFriendsHeightConstraint.constant = 0
        }
        //print(selectedCells)
        print(friendsArray)
            
            
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }

        
    }
    
    func setUpNavigationBarItems () {
        

        let skipImageView = UIImageView()
        let discoverIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.skipIconTapped(sender:)))
        
        skipImageView.frame = CGRect(x: 0, y: 0, width: 42, height: 24)
        
        skipImageView.addGestureRecognizer(discoverIconTapGesture)
        
        skipImageView.image = #imageLiteral(resourceName: "Skip Icon")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: skipImageView)
        
        
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false

    }
    
    func skipIconTapped (sender: UITapGestureRecognizer) {
        
        let imgView = sender.view as! UIImageView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "UserHomeViewController") as! UserHomeViewController
        let transition:CATransition = CATransition()
        
        
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
        
        
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

    @IBAction func addFriendsButtonTapped(_ sender: Any) {
        
       let recipientListRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList")
    
        friendsArray.forEach{
            (Recipient) in
            
           let newRecipient = ["recipientName" as NSObject: (Recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (Recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (Recipient.recipientID) as AnyObject, "tag" as NSObject: "user" as AnyObject, "phoneNumber" as NSObject: (Recipient.phoneNumber) as AnyObject]
            
            
            recipientListRef.child(Recipient.recipientID).setValue(newRecipient)
        }
         self.performSegue(withIdentifier: "unwindToMenuFromFindFriends", sender: self)
    }
}
