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

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    
        
        
        
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath) as! AddFriendTableViewCell
        
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
