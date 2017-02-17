//
//  NotificationViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/16/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    let notificationRef : FIRDatabaseReference = FIRDatabase.database().reference().child("notifications")
    var notifications : [AppNotifications] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpNavigationBarItems()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        notificationRef.queryOrdered(byChild: "recipientID").queryEqual(toValue: currentUserID).observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            let notification = AppNotifications()
            
            notification.activityType = snapshotValue["activity type"] as! String
            notification.messageID = snapshotValue["messageID"] as! String
            notification.pollID = snapshotValue["pollID"] as! String
            notification.recipientID = snapshotValue["recipientID"] as! String
            notification.senderID = snapshotValue["senderID"] as! String
            notification.timeSent = snapshotValue["time sent"] as! String
            
            self.notifications.append(notification)
            self.notifications = self.notifications.sorted(by: {$0.timeSent > $1.timeSent})
            
            self.tableView.reloadData()
            
        
        })
        
        
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if notifications[indexPath.row].activityType == "messages"{
        }
        
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationForCell = notifications[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        let recipientRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(notificationForCell.recipientID)
        
        cell.arrowIconImageView.alpha = 0.5
        
        if notificationForCell.activityType == "poll received" {
            let senderRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(notificationForCell.senderID)
            
            senderRef.observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                let senderName = snapshotValue["fullName"] as! String
                let senderImageURL = snapshotValue["profileImageURL"] as! String
    
                cell.notificationIconImageView.sd_setImage(with: URL(string: senderImageURL))
                    
                cell.actionableObjectLabel.text = senderName
                
            })
            
            cell.notificationTypeLabel.text = "asked you a question"
            cell.notificationIconImageView.layer.cornerRadius = cell.notificationIconImageView.layer.frame.width / 2
            cell.notificationIconImageView.layer.masksToBounds = true
            cell.notificationIconImageView.layer.borderWidth = 0.2
            cell.notificationIconImageView.layer.borderColor = UIColor.init(hexString: "00428A").cgColor
            
        }
        
        if notificationForCell.activityType == "poll expired" {
            
            let pollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(notificationForCell.pollID)
            
            pollRef.observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                let pollTitle = snapshotValue["question"] as! String
                
                cell.actionableObjectLabel.text = pollTitle
            })
            
            cell.notificationTypeLabel.text = "responses have closed"
            cell.notificationIconImageView.layer.cornerRadius = 0
            cell.notificationIconImageView.layer.masksToBounds = false
            cell.notificationIconImageView.layer.borderWidth = 0
            cell.notificationIconImageView.image = #imageLiteral(resourceName: "Expired Notification Icon")
            
            
        }
      
          return cell
    }
    
    func setUpNavigationBarItems() {
        
        let pageTitle : UILabel = UILabel()
        
        pageTitle.text = "Notifications"
        
        
        pageTitle.textColor = UIColor.init(hexString: "4B6184")
        
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 35))
        
        pageTitle.frame = titleView.bounds
        titleView.addSubview(pageTitle)
        
        self.navigationItem.titleView = titleView
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
        
        
    }
    
    

    

}
