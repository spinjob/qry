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
    
    let sectionTitles = ["Friends", "Groups"]
    var profileUserID = ""
    var friendArray : [Recipient] = []
    var groupArray : [Recipient] = []
    var items : [[Recipient]] = [[]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.reloadData()
        
        print(profileUserID)
        print(friendArray)
        print(groupArray)
    }
    
    
    //TableView Data Source
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if items[indexPath.section][indexPath.row].tag == "group" {
            return 100
        }
        
        return 60
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return friendArray.count
        }
        
        return groupArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editFriendCell", for: indexPath) as! EditFriendTableViewCell

        
        cell.friendImageView.sd_setImage(with: URL(string: items[indexPath.section][indexPath.row].imageURL1))
        cell.friendImageView.layer.cornerRadius =  cell.friendImageView.layer.frame.size.width / 2
        cell.friendImageView.layer.masksToBounds = true
        cell.friendNameLabel.text = items[indexPath.section][indexPath.row].recipientName
        
        cell.actionButton.layer.cornerRadius = 4
        cell.actionButton.layer.masksToBounds = true
        
        cell.editButton.isHidden = true
        
        
        
        if items[indexPath.section][indexPath.row].tag == "group" {
            
            cell.actionButton.isHidden = true
            cell.editButton.isHidden = false
            cell.friendImageView.layer.cornerRadius =  4
            cell.friendImageView.layer.masksToBounds = true
            cell.imageViewHeight.constant = 60
            cell.imageViewWidth.constant = 60
            
            
            
        }

        return cell
    
        
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)! as! EditFriendTableViewCell
        selectedCell.isSelected = true
        
        if items[indexPath.section][indexPath.row].tag == "user" {
        selectedCell.contentView.backgroundColor = UIColor.white

        selectedCell.actionButtonWidth.constant = 22
        selectedCell.actionButton.setTitle("✓", for: .normal)
        selectedCell.actionButton.layer.cornerRadius = 22 / 2
        selectedCell.actionButton.setBackgroundImage(UIImage(named: "Login Button Background"), for: .normal)
        selectedCell.actionButton.isUserInteractionEnabled = false
    
        print("Is Selected: \(selectedCell.isSelected)")
            
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell = tableView.cellForRow(at: indexPath)! as! EditFriendTableViewCell
        deSelectedCell.isSelected = false
        
         if items[indexPath.section][indexPath.row].tag == "user" {
        deSelectedCell.actionButtonWidth.constant = 73
        deSelectedCell.actionButton.layer.cornerRadius = 4
        deSelectedCell.actionButton.setTitle("Following", for: .normal)
        deSelectedCell.actionButton.layer.cornerRadius = 4
        deSelectedCell.actionButton.layer.masksToBounds = true
        deSelectedCell.actionButton.setBackgroundImage(UIImage(named: "greenBackground"), for: .normal)
        deSelectedCell.actionButton.isUserInteractionEnabled = true
        
        deSelectedCell.editButton.isHidden = true
        
        print("Is Selected: \(deSelectedCell.isSelected)")
            
        UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
            
        }
        
    }

    
    }

