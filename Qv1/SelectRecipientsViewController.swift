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

class SelectRecipientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var contactStore = CNContactStore()
    
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch =
            [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
             CNContactEmailAddressesKey,
             CNContactPhoneNumbersKey,
             CNContactImageDataAvailableKey,
             CNContactImageDataKey,
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
       
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont(name: "Proxima Nova", size: 20)!]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let contactCellIdentifier = "FriendTableViewCell"
        //let userCellIdentifier = "UserTableViewCell"

        
        let contactCell = tableView.dequeueReusableCell(withIdentifier: contactCellIdentifier, for: indexPath) as! FriendTableViewCell
        //let userCell = tableView.dequeueReusableCell(withIdentifier: userCellIdentifier, for: indexPath) as! UserTableViewCell
        
        
        
        contactCell.friendNameLabel.text = "\(contacts[indexPath.row].givenName) \(contacts[indexPath.row].familyName)"
        if contacts[indexPath.row].phoneNumbers.first?.value == nil {
            contactCell.friendPhoneNumberLabel.text = "No phone number!"
        } else {
            contactCell.friendPhoneNumberLabel.text = ((contacts[indexPath.row].phoneNumbers.first?.value)! as CNPhoneNumber).stringValue
        }
        contactCell.friendProfileImageView.layer.cornerRadius = 3
        contactCell.friendProfileImageView.layer.masksToBounds = true
        contactCell.selectedBackgroundView?.backgroundColor = UIColor.white
        
        
        //userCell.userProfileImageView.layer.cornerRadius = userCell.userProfileImageView.frame.height/2
        //userCell.userProfileImageView.clipsToBounds = true
        
        //userCell.userNameLabel.text = "\(contacts[indexPath.row].givenName) \(contacts[indexPath.row].familyName)"
        
       
        return contactCell
            

    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        var highlightedCell = tableView.cellForRow(at: indexPath)
        highlightedCell?.contentView.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        var unHighlightedCell = tableView.cellForRow(at: indexPath)
        unHighlightedCell?.contentView.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.contentView.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var deSelectedCell = tableView.cellForRow(at: indexPath)
        deSelectedCell?.contentView.backgroundColor = UIColor.white
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
