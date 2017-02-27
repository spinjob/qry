//
//  UserHomeViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/26/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SDWebImage
import SwiftLinkPreview

class UserHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
   
    //current user data
    
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    
    
    //Database References
    
    let currentUserRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
    let currentUserReceivedPollsRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls")

    //brand colors
    
    let brightGreen = UIColor.init(hexString: "A8E855")
    let red = UIColor.init(hexString: "FF4E56")
    let actionGreen = UIColor.init(hexString: "00D1D5")
    let blue = UIColor.init(hexString: "004488")
    let grey = UIColor.init(hexString: "D8D8D8")

    //arrays
    
    var livePolls : [Poll] = []
    var expiredPolls : [Poll] = []
    var publicPolls : [Poll] = []
    
    //sections
    
    let sectionTitles = ["Live", "Closed"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBarItems()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 181
        tableView.rowHeight = UITableViewAutomaticDimension
        
        currentUserReceivedPollsRef.queryOrdered(byChild: "expired").queryEqual(toValue: "false").observe(.childAdded, with: {
            snapshot in
          
            let poll = Poll()
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            poll.answer1String = snapshotValue["answer1"] as! String
            poll.answer2String = snapshotValue["answer2"] as! String
            poll.questionString = snapshotValue["question"] as! String
            poll.senderUser = snapshotValue["senderUser"] as! String
            poll.pollImageURL = snapshotValue["pollImageURL"] as! String
            poll.pollID = snapshot.key
            poll.pollURL = snapshotValue["pollURL"] as! String
            poll.pollImageDescription = snapshotValue["pollImageDescription"] as! String
            poll.pollImageTitle = snapshotValue["pollImageTitle"] as! String
            poll.pollQuestionImageURL = snapshotValue["questionImageURL"] as! String
            poll.dateExpired = snapshotValue["expirationDate"] as! String
            poll.dateCreated = snapshotValue["dateCreated"] as! String
            
            poll.isExpired = false
            
            let date = Date()
            let formatter = DateFormatter()
            
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            let calendar = Calendar.current
            let dateString = formatter.string(from: date)
            let dateOfExpiration = formatter.date(from: poll.dateExpired)
            let currentDate = formatter.date(from: dateString)
            let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: dateOfExpiration!)
            
            poll.minutesUntilExpiration = minutesLeft.minute!
    
            if self.livePolls.contains(where: { $0.pollID == poll.pollID})
            { print("poll already added")
                
            } else {
            
            self.livePolls.append(poll)
            
            print(self.livePolls)
            
            self.livePolls = self.livePolls.sorted(by: {$0.minutesUntilExpiration < $1.minutesUntilExpiration})
            
            self.tableView.reloadData()
            
            }
            
        })
        
        currentUserReceivedPollsRef.queryOrdered(byChild: "expired").queryEqual(toValue: "true").observe(.childAdded, with: {
            snapshot in
            
            let poll = Poll()
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            poll.answer1String = snapshotValue["answer1"] as! String
            poll.answer2String = snapshotValue["answer2"] as! String
            poll.questionString = snapshotValue["question"] as! String
            poll.senderUser = snapshotValue["senderUser"] as! String
            poll.pollImageURL = snapshotValue["pollImageURL"] as! String
            poll.pollID = snapshot.key
            poll.pollURL = snapshotValue["pollURL"] as! String
            poll.pollImageDescription = snapshotValue["pollImageDescription"] as! String
            poll.pollImageTitle = snapshotValue["pollImageTitle"] as! String
            poll.pollQuestionImageURL = snapshotValue["questionImageURL"] as! String
            poll.dateExpired = snapshotValue["expirationDate"] as! String
            poll.dateCreated = snapshotValue["dateCreated"] as! String
            poll.isExpired = true
            
            let date = Date()
            let formatter = DateFormatter()
            
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            let calendar = Calendar.current
            let dateString = formatter.string(from: date)
            let dateOfExpiration = formatter.date(from: poll.dateExpired)
            let currentDate = formatter.date(from: dateString)
            let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: dateOfExpiration!)
            
            poll.minutesUntilExpiration = minutesLeft.minute!
            
            if self.expiredPolls.contains(where: { $0.pollID == poll.pollID})
            { print("poll already added")
                
            } else {
            
            self.expiredPolls.append(poll)
            
            self.expiredPolls = self.expiredPolls.sorted(by: {$0.minutesUntilExpiration > $1.minutesUntilExpiration})
            

            self.tableView.reloadData()
            
            }
            
            UIView.animate(withDuration: 2, animations: {
                self.tableView.alpha = 0
                self.tableView.alpha = 1

            })
        })
   
      
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = [livePolls, expiredPolls]
        
        print("number of rows in section\(items[section].count)")
     
        return items[section].count
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let items = [livePolls, expiredPolls]
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let pollArrays = [livePolls, expiredPolls]
        let pollForCell : Poll = pollArrays[indexPath.section][indexPath.row]
        
        let pollForCellRef = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID)
        let senderUserRef = FIRDatabase.database().reference().child("users").child(pollForCell.senderUser)
        
        let binaryStringCell = tableView.dequeueReusableCell(withIdentifier: "binaryStringPollCell", for: indexPath) as! StringPollTableViewCell
        
        let currentUserVoteRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes").child(currentUserID!)

        
        //Question Text
        binaryStringCell.questionStringTextView.textContainerInset = UIEdgeInsets.zero
        binaryStringCell.questionStringTextView.textContainer.lineFragmentPadding = 0
        binaryStringCell.questionStringTextView.text = pollForCell.questionString
        
        //Sender User
       senderUserRef.observe(.value, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let senderUserImageURLString = snapshotValue["profileImageURL"] as! String
        
        
            binaryStringCell.senderImageView.sd_setImage(with: URL(string: senderUserImageURLString))
            binaryStringCell.senderFullNameLabel.text = snapshotValue["fullName"] as! String
        
        })
        
        binaryStringCell.senderImageView.layer.cornerRadius = binaryStringCell.senderImageView.layer.frame.width / 2
        binaryStringCell.senderImageView.layer.masksToBounds = true
        
        //Group Member Array population
        FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes").observe(.childAdded, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let recipient = Recipient()
            
            recipient.recipientID = snapshotValue["recipientID"] as! String
            recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            recipient.recipientName = snapshotValue["recipientName"] as! String
            recipient.vote = snapshotValue["voteString"] as! String
            
            
            if pollForCell.groupMembers.contains(where: { $0.recipientID == recipient.recipientID})
            { print("group already added")
                
            } else {

            pollForCell.groupMembers.append(recipient)
            binaryStringCell.groupMembersCollectionView.reloadData()
            }

        })
        

        
        //answer1Button
        binaryStringCell.answer1Button.tag = indexPath.row
        binaryStringCell.answer1Button.addTarget(self, action: #selector(self.answer1ButtonTapped(sender:)), for: .touchUpInside)
        binaryStringCell.answer1Button.layer.cornerRadius = 4
        binaryStringCell.answer1Button.layer.masksToBounds = true
        binaryStringCell.answer1Button.setTitle(pollForCell.answer1String, for: .normal)
        
        //answer2Button
        binaryStringCell.answer2Button.tag = indexPath.row
        binaryStringCell.answer2Button.addTarget(self, action: #selector(self.answer2ButtonTapped(sender:)), for: .touchUpInside)
        binaryStringCell.answer2Button.layer.cornerRadius = 4
        binaryStringCell.answer2Button.layer.masksToBounds = true
        binaryStringCell.answer2Button.setTitle(pollForCell.answer2String, for: .normal)
        
        //answerSelectedView
        binaryStringCell.answerSelectedView.layer.cornerRadius = 4
        binaryStringCell.answerSelectedView.backgroundColor = actionGreen
        binaryStringCell.answerSelectedView.tag = indexPath.row
        let answeredViewTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.answeredViewTapped(sender:)))
        binaryStringCell.answerSelectedView.addGestureRecognizer(answeredViewTapGesture)
        
        if pollForCell.isExpired == false {
            binaryStringCell.answerSelectedView.isUserInteractionEnabled = true
        } else{
            
            binaryStringCell.answerSelectedView.isUserInteractionEnabled = false
        }
  
        
        currentUserVoteRef.observe(.value, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let vote = snapshotValue["voteString"] as! String
            
            print(vote)
            
        //user vote based formatting
            if vote == "no vote" {
                binaryStringCell.answer1Button.isHidden = false
                binaryStringCell.answer2Button.isHidden = false
                binaryStringCell.answerSelectedView.isHidden = true
                
                
            } else if vote == "answer1" {
                
                binaryStringCell.answer1Button.isHidden = true
                binaryStringCell.answer2Button.isHidden = true
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.answerSelectedTextLabel.text = "Answered \(pollForCell.answer1String)"
                
            } else if vote == "answer2" {
                
                binaryStringCell.answer1Button.isHidden = true
                binaryStringCell.answer2Button.isHidden = true
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.answerSelectedTextLabel.text = "Answered \(pollForCell.answer2String)"
                
            }
        })
            
        //Time Remaining View
        
            binaryStringCell.pieChartCenterView.layer.cornerRadius = binaryStringCell.pieChartCenterView.layer.frame.width / 2
            binaryStringCell.timerView.layer.cornerRadius = binaryStringCell.timerView.layer.frame.width / 2
            
            binaryStringCell.pieChartCenterView.layer.masksToBounds = true
    
            
            let date = Date()
            let formatter = DateFormatter()
            let calendar = Calendar.current
            
            
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let dateString = formatter.string(from: date)
            
            let pollForCellDateExpired = formatter.date(from: pollForCell.dateExpired)
            let pollForCellDateCreated = formatter.date(from: pollForCell.dateCreated)
            let currentDate = formatter.date(from: dateString)
            
            let hoursLeft = calendar.dateComponents([.hour], from: currentDate!, to: pollForCellDateExpired!)
            let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateExpired!)
            let daysLeft = calendar.dateComponents([.day], from: currentDate!, to: pollForCellDateExpired!)
            let minutesTotal = calendar.dateComponents([.minute], from: pollForCellDateCreated!, to:pollForCellDateExpired! )
            let minutesLeftDouble : Double = Double(pollForCell.minutesUntilExpiration)
            let minutesTotalDouble : Double = Double(minutesTotal.minute!)
        
            let percentageLeft : Double = (minutesLeftDouble / minutesTotalDouble)*100
            
            
            if hoursLeft.hour! < 1 {
                binaryStringCell.timeLeftNumberLabel.text = "\(minutesLeft.minute!)"
                
                if hoursLeft.hour! == 1{
                    binaryStringCell.timeLeftUnitLabel.text = "minute"
                }
                
                binaryStringCell.timeLeftUnitLabel.text = "minutes"
                
            }
            
            
            if daysLeft.day! > 1 {
                binaryStringCell.timeLeftNumberLabel.text = "\(daysLeft.day!)"
                
                binaryStringCell.timeLeftUnitLabel.text = "days"
                
            }
            
            if daysLeft.day! == 1 {
                binaryStringCell.timeLeftNumberLabel.text = "\(daysLeft.day!)"
                
                binaryStringCell.timeLeftUnitLabel.text = "day"
                
            }
            
            if hoursLeft.hour! > 1, daysLeft.day! < 1 {
                
                binaryStringCell.timeLeftNumberLabel.text = "\(hoursLeft.hour!)"
                
                binaryStringCell.timeLeftUnitLabel.text = "hours"
            }
            
            if hoursLeft.hour! == 1 {
                binaryStringCell.timeLeftNumberLabel.text = "\(hoursLeft.hour!)"
                
                
                binaryStringCell.timeLeftUnitLabel.text = "hour"

                
            }
        
        
        if minutesLeft.minute! > 0, pollForCell.isExpired == false {
            
            
            let chartView = PieChartView()
            
            chartView.frame = CGRect(x: 0, y: 0, width: binaryStringCell.timerView.frame.size.width, height: 34)
            
            if percentageLeft < 10 {
                chartView.segments = [
                    Segment(color: UIColor.init(hexString: "FFFFFF"), value: CGFloat(100 - percentageLeft)),
                    Segment(color: red, value: CGFloat(percentageLeft))
                    
                ]
                
            } else {
                
                chartView.segments = [
                    
                    Segment(color: UIColor.init(hexString: "FFFFFF"), value: CGFloat(100 - percentageLeft)),
                    Segment(color: blue, value: CGFloat(percentageLeft))
                    
                ]
                
            }
            
            binaryStringCell.timerView.addSubview(chartView)
            binaryStringCell.timerView.isHidden = false
            binaryStringCell.pieChartCenterView.isHidden = false
            binaryStringCell.timeLeftUnitLabel.isHidden = false
            binaryStringCell.timeLeftNumberLabel.isHidden = false
       
            
        } else if minutesLeft.minute! < 0, pollForCell.isExpired == false  {
            pollForCellRef.child("expired").setValue("true")
            tableView.reloadData()
            
        } else {

            binaryStringCell.timeLeftNumberLabel.isHidden = true
            binaryStringCell.timeLeftUnitLabel.isHidden = true
            binaryStringCell.pieChartCenterView.isHidden = true
            binaryStringCell.timerView.isHidden = true
        }
        
        
        
        
 
        //Collection View
        
        binaryStringCell.groupMembersCollectionView.tag = indexPath.row
        
        
        return binaryStringCell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? StringPollTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var groupMembers : [Recipient] = []
        
        let combinedPolls = livePolls + expiredPolls

        return combinedPolls[collectionView.tag].groupMembers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.showsHorizontalScrollIndicator = false
        
        livePolls.append(contentsOf: expiredPolls)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newGroupMemberCollectionViewCell", for: indexPath) as! PollRecipientCollectionViewCell
    
        let combinedPolls = livePolls + expiredPolls
        
        let pollForCell : Poll = combinedPolls[collectionView.tag]
        let recipientForCollectionCell = pollForCell.groupMembers[indexPath.item]

        if recipientForCollectionCell.vote == "no vote" {
            
            cell.answerIndicatorImageView.backgroundColor = grey
          
            
        } else if recipientForCollectionCell.vote == "answer1" {
            
            cell.answerIndicatorImageView.backgroundColor = brightGreen
            
            
        } else if recipientForCollectionCell.vote == "answer2" {
            
            cell.answerIndicatorImageView.backgroundColor = red
 
        }

        cell.answerIndicatorImageView.layer.cornerRadius = cell.answerIndicatorImageView.layer.frame.width / 2
        
        cell.recipientImageView.sd_setImage(with: URL(string: recipientForCollectionCell.imageURL1))
        cell.recipientImageView.layer.cornerRadius = cell.recipientImageView.layer.frame.width / 2
        cell.recipientImageView.layer.masksToBounds = true
    
        return cell
        
    }
    
    
    func answer1ButtonTapped (sender: UIButton) {
        
        let buttonIndexPath = IndexPath(row: sender.tag, section: 0)
        let binaryStringCell = tableView.cellForRow(at: buttonIndexPath) as! StringPollTableViewCell
        let pollForRow = livePolls[sender.tag]
        
        
        UIView.animate(withDuration: 0.2, animations: {
            binaryStringCell.answer2Button.alpha = 0
            binaryStringCell.answer2Button.isHidden = true
            
            binaryStringCell.answer1Button.alpha = 0
            binaryStringCell.answer1Button.isHidden = true
            
             binaryStringCell.answerSelectedTextLabel.text = "Answered \(self.livePolls[sender.tag].answer1String)"
        })
    
       
        delay(0.2, closure: {
            
            UIView.animate(withDuration: 0.2, animations: {
                
                binaryStringCell.answerSelectedView.alpha = 0
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.answerSelectedView.alpha = 1
                
            })
            
        })
        
        
        FIRDatabase.database().reference().child("polls").child(pollForRow.pollID).child("votes").child(currentUserID!).child("voteString").setValue("answer1")
        
        binaryStringCell.groupMembersCollectionView.reloadData()
       
        
          }
    
    func answer2ButtonTapped (sender: UIButton) {
        
        let buttonIndexPath = IndexPath(row: sender.tag, section: 0)
        let binaryStringCell = tableView.cellForRow(at: buttonIndexPath) as! StringPollTableViewCell
        let pollForRow = livePolls[sender.tag]
        
        
        UIView.animate(withDuration: 0.2, animations: {
            binaryStringCell.answer2Button.alpha = 0
            binaryStringCell.answer2Button.isHidden = true
            
            binaryStringCell.answer1Button.alpha = 0
            binaryStringCell.answer1Button.isHidden = true
            
            binaryStringCell.answerSelectedTextLabel.text = "Answered \(self.livePolls[sender.tag].answer2String)"
        })
        
        
        delay(0.2, closure: {
            
            UIView.animate(withDuration: 0.2, animations: {
                
                binaryStringCell.answerSelectedView.alpha = 0
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.answerSelectedView.alpha = 1
                
            })
            
        })
      
        FIRDatabase.database().reference().child("polls").child(pollForRow.pollID).child("votes").child(currentUserID!).child("voteString").setValue("answer2")
        
        binaryStringCell.groupMembersCollectionView.reloadData()
        
        
    }
    
    func answeredViewTapped (sender: UITapGestureRecognizer) {
        
        let buttonIndexPath = IndexPath(row: sender.view!.tag, section: 0)
        let binaryStringCell = tableView.cellForRow(at: buttonIndexPath) as! StringPollTableViewCell
        
        UIView.animate(withDuration: 0.2, animations: {
            
            binaryStringCell.answerSelectedView.alpha = 1
            binaryStringCell.answerSelectedView.isHidden = true
            binaryStringCell.answerSelectedView.alpha = 0
           

        })
        
        
        delay(0.2, closure: {
            
            UIView.animate(withDuration: 0.2, animations: {
                
                binaryStringCell.answer2Button.alpha = 1
                binaryStringCell.answer2Button.isHidden = false
                
                binaryStringCell.answer1Button.alpha = 1
                binaryStringCell.answer1Button.isHidden = false
                
            })
            
        })
        
        
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    
    
    func setUpNavigationBarItems () {
        
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "Profile Image Border"))
        
        titleImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        titleImageView.contentMode = .scaleAspectFit
       // let titleImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.logoTapped(sender:)))
       // titleImageView.addGestureRecognizer(titleImageViewTapGesture)
        titleImageView.isUserInteractionEnabled = true
        
        navigationItem.titleView = titleImageView
        
        let profileIconImageView = UIImageView()
        //let profileIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.myProfileImageTapped(sender:)))
        
        profileIconImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        profileIconImageView.layer.cornerRadius = profileIconImageView.frame.size.width / 2
        profileIconImageView.layer.borderWidth = 1
        profileIconImageView.layer.borderColor = UIColor.init(hexString: "004488").cgColor
        profileIconImageView.layer.masksToBounds = true
      //  profileIconImageView.addGestureRecognizer(profileIconTapGesture)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileIconImageView)
        
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            let profileImageURLString = snapshotValue["profileImageURL"] as! String
            let profileImageURL = URL(string: profileImageURLString)
            
            profileIconImageView.sd_setImage(with: profileImageURL)
            
        })
        
        
        let notificationIconImageView = UIImageView()
       // let notificationIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.notificationIconTapped(sender:)))
        
        notificationIconImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
     //   notificationIconImageView.addGestureRecognizer(notificationIconTapGesture)
        
        notificationIconImageView.image = #imageLiteral(resourceName: "new message notification icon")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationIconImageView)
        
        
        
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        
        UIView.animate(withDuration: 1, animations: {
            
            profileIconImageView.alpha = 0
            profileIconImageView.alpha = 1
        })
        
    }
    
    
    
}
