//
//  UserHomeViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/26/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseInstanceID
import FirebaseAuth
import FirebaseStorage
import FirebaseMessaging
import SDWebImage
import SwiftLinkPreview

class UserHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {

    
    //removed UIViewControllerPreviewingDelegate
    
    
    @IBOutlet weak var emptyStateView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var newDecisionTextView: UIView!
    
    @IBOutlet weak var newDecisionTextField: UITextField!
    
    @IBOutlet weak var newDecisionButton: UIButton!
    
    @IBOutlet weak var rightLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    
    var kbHeight = 0
    
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

    //empty state
 
    let imageView = UIImageView(image: #imageLiteral(resourceName: "home empty state"))
    
    //arrays
    
    var userPollsThreaded : [Poll] = []
    
    var threads : [String] = []
    
    var threadDict : [String : [Poll]] = ["":[]]
    
    var threadCountDict : [String: Int] = ["": 0]
    
    var receivedPolls : [Poll] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpNavigationBarItems()
        
        tableView.delegate = self
        tableView.dataSource = self
        newDecisionTextField.delegate = self
        tableView.estimatedRowHeight = 181
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        newDecisionButton.isHidden = true
        
        FIRMessaging.messaging().subscribe(toTopic: "user_\(currentUserID!)")
       // FIRMessaging.messaging().unsubscribe(fromTopic: "user_\(currentUserID!)")
        
        let ref : FIRDatabaseReference = FIRDatabase.database().reference().child("users")
        
        //set push notification ID

        ref.child(currentUserID!).child("deviceToken").setValue(FIRInstanceID.instanceID().token())
        
        var newRecipient :[NSObject : AnyObject] = [ : ]
        var recipientID = ""

        
        currentUserReceivedPollsRef.observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let poll = Poll()
            poll.answer1String = snapshotValue["answer1"] as! String
            poll.answer2String = snapshotValue["answer2"] as! String
            poll.questionString = snapshotValue["question"] as! String
            poll.senderUser = snapshotValue["senderUser"] as! String
            poll.pollImageURL = snapshotValue["pollImageURL"] as! String
            poll.pollID = snapshot.key
            poll.pollURL = snapshotValue["pollURL"] as! String
            poll.pollQuestionImageURL = snapshotValue["questionImageURL"] as! String
            poll.dateExpired = snapshotValue["expirationDate"] as! String
            poll.dateCreated = snapshotValue["dateCreated"] as! String
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let calendar = Calendar.current
            let dateString = formatter.string(from: date)
            
            let pollForCellDateExpired = formatter.date(from: poll.dateExpired)
            let currentDate = formatter.date(from: dateString)
            let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateExpired!)
            poll.minutesUntilExpiration = minutesLeft.minute!
            
            poll.createdDate = formatter.date(from: poll.dateCreated)!
            
            
            FIRDatabase.database().reference().child("polls").child(poll.pollID).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
            
            if snapshotValue["expired"] as! String == "true" {
                poll.isExpired = true
            }else {
                poll.isExpired = false
            }

            })
            
            
            FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").observe(.childAdded, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                let recipient = Recipient()

                
                recipient.recipientID = snapshotValue["recipientID"] as! String
                recipient.recipientName = snapshotValue["recipientName"] as! String
                
                recipient.vote = snapshotValue["voteString"] as! String
               
                FIRDatabase.database().reference().child("users").child(recipient.recipientID).observe(.value, with: {
                    snapshot in
                    let snapshotValue = snapshot.value as! NSDictionary
                    recipient.imageURL1 = snapshotValue["profileImageURL"] as! String
                    self.tableView.reloadData()
                    
                })
                
                
                if poll.groupMembers.contains(where: { $0.recipientID == recipient.recipientID})
                { print("group already added")
                    
                } else {
                    
                    poll.groupMembers.append(recipient)
                    
                    print("\(poll.pollID)")
                    print("recipient name added \(poll.groupMembers.last)")
                    
                    
                    poll.groupMembers = poll.groupMembers.sorted(by: {$0.vote < $1.vote})
                    
                    if self.receivedPolls.contains(where: { $0.pollID == poll.pollID})
                    { print("poll already added")
                        
                    } else {
                        
                        self.receivedPolls.append(poll)
                        
                        self.receivedPolls = self.receivedPolls.sorted(by: {$0.minutesUntilExpiration > $1.minutesUntilExpiration})
                        
                        self.tableView.reloadData()
                        
                    }

                }
                
            })

        })
        
//        ref.observe(.childAdded, with: {
//            snapshot in
//            
//            let snapshotValue = snapshot.value as! NSDictionary
//            
//            newRecipient = ["recipientName" as NSObject: (snapshotValue["fullName"] as! String) as AnyObject, "recipientImageURL1" as NSObject: (snapshotValue["profileImageURL"] as! String) as AnyObject, "recipientID" as NSObject: (snapshot.key) as AnyObject, "tag" as NSObject: "user" as AnyObject, "phoneNumber" as NSObject: (snapshotValue["phoneNumber"]) as AnyObject]
//            
//            recipientID = snapshot.key
//            
//            let recipientListRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientID)
//            
//            if recipientID != (FIRAuth.auth()?.currentUser?.uid)! {
//                recipientListRef.setValue(newRecipient)
//            }
//            
//            
//        })
//
//        if( traitCollection.forceTouchCapability == .available){
//            
//            registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: view)
//            
//        }
        
        
        
//        threadDict.removeAll()
        
        FIRDatabase.database().reference().child("users")
    
//        FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedPolls").observe(.childAdded, with: {
//            snapshot in
//            
//            let threadID = snapshot.key
//            let threadCount = Int(snapshot.childrenCount)
//            
//            self.threadCountDict[threadID] = threadCount
//            
//            
//            if self.threads.count == 0 {
//                self.emptyStateView.isHidden = false
//                self.tableView.isHidden = true
//                
//            } else {
//                self.tableView.isHidden = false
//               self.emptyStateView.isHidden = true
//            }
//            
//            FIRDatabase.database().reference().child("threads").child(threadID).observe(.childAdded, with: {
//                snapshot in
//                
//                
//                let snapshotValue = snapshot.value as! NSDictionary
//                
//                let poll = Poll()
//                poll.answer1String = snapshotValue["answer1"] as! String
//                poll.answer2String = snapshotValue["answer2"] as! String
//                poll.questionString = snapshotValue["question"] as! String
//                poll.senderUser = snapshotValue["senderUser"] as! String
//                poll.pollImageURL = snapshotValue["pollImageURL"] as! String
//                poll.pollID = snapshot.key
//                poll.pollURL = snapshotValue["pollURL"] as! String
//                poll.pollQuestionImageURL = snapshotValue["questionImageURL"] as! String
//                poll.dateExpired = snapshotValue["expirationDate"] as! String
//                poll.dateCreated = snapshotValue["dateCreated"] as! String
//                
//                let date = Date()
//                let formatter = DateFormatter()
//                formatter.dateStyle = .short
//                formatter.timeStyle = .short
//                let calendar = Calendar.current
//                let dateString = formatter.string(from: date)
//                
//                let pollForCellDateExpired = formatter.date(from: poll.dateExpired)
//                let currentDate = formatter.date(from: dateString)
//                let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateExpired!)
//                poll.minutesUntilExpiration = minutesLeft.minute!
//                
//                poll.createdDate = formatter.date(from: poll.dateCreated)!
//
//                if snapshotValue["hasChildren"] as! String == "true" {
//                    poll.hasChildren = true
//                    
//                } else {
//                    poll.hasChildren = false
//                }
//
//                
//                if snapshotValue["expired"] as! String == "true" {
//                    poll.isExpired = true
//                }else {
//                    poll.isExpired = false
//                }
//
//                if snapshotValue["isThreadParent"] as! String == "true" {
//                    poll.isThreadParent = true
//                } else {
//                    poll.isThreadParent = false
//                }
//            
//                
//               
//                if self.threadDict[threadID] == nil {
//                
//                    self.threadDict[threadID] = [poll]
//                    self.threads.append(threadID)
//
//                    
//                } else  {
//                    self.threadDict[threadID]!.append(poll)
//                    
//                    self.threadDict[threadID]! = self.threadDict[threadID]!.sorted(by: {$0.createdDate < $1.createdDate})
//                    //self.tableView.reloadData()
//                    
//                }
//                
//                
//                FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").observe(.childAdded, with: {
//                    snapshot in
//                    let snapshotValue = snapshot.value as! NSDictionary
//                    let recipient = Recipient()
//                    
//                    recipient.recipientID = snapshotValue["recipientID"] as! String
//                    recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
//                    recipient.recipientName = snapshotValue["recipientName"] as! String
//                    recipient.vote = snapshotValue["voteString"] as! String
//                    
//                    
//                    if poll.groupMembers.contains(where: { $0.recipientID == recipient.recipientID})
//                    { print("group already added")
//                        
//                    } else {
//                        
//                        poll.groupMembers.append(recipient)
//                        poll.groupMembers = poll.groupMembers.sorted(by: {$0.vote < $1.vote})
//                        
//                        
//                        self.tableView.reloadData()
//                        
//                    }
//                    
//                })
//                
//        })

//
//        })
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tableView.reloadData()
       
        delay(1, closure: {
    
//            if self.threads.count == 0 {
//                
//                UIView.animate(withDuration: 0.2, animations: {
//                    
//                    self.emptyStateView.alpha = 0
//                    self.emptyStateView.isHidden = false
//                    self.emptyStateView.alpha = 1
//                    self.tableView.isHidden = true
//                    
//                })
//                
//                
//            } else {
//                self.tableView.alpha = 0
//                 self.tableView.isHidden = false
//                self.tableView.alpha = 1
//               
//                self.emptyStateView.isHidden = true
//            }
            
        })
     
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        let threadID = threads[section]
//
//        if self.threadCountDict[threadID]! == 0 {
//            tableView.backgroundView = imageView
//        }
//        
//       return self.threadCountDict[threadID]!
        
        
        return receivedPolls.count
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        
//        return threads.count
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
//        let threadID = threads[indexPath.section]
//        let pollArrayForThread = self.threadDict[threadID]
//
//        let pollForCell : Poll = (pollArrayForThread?[indexPath.row])!
        
        let pollForCell : Poll = receivedPolls[indexPath.row]
        
        
        
        print("number of groupmembers \(pollForCell.groupMembers.count)")
        

        let pollForCellRef = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID)
        let senderUserRef = FIRDatabase.database().reference().child("users").child(pollForCell.senderUser)
        
        let binaryStringCell = tableView.dequeueReusableCell(withIdentifier: "binaryStringPollCell", for: indexPath) as! StringPollTableViewCell
        
        let expiredCell = tableView.dequeueReusableCell(withIdentifier: "binaryStringPollCell", for: indexPath) as! StringPollTableViewCell
        
        let currentUserVoteRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes").child(currentUserID!)
        
//        binaryStringCell.contentView.tag = indexPath.section
//        expiredCell.contentView.tag = indexPath.section


        //Binary String Cell
        
        //Question Text
        binaryStringCell.questionStringTextView.textContainerInset = UIEdgeInsets.zero
        binaryStringCell.questionStringTextView.textContainer.lineFragmentPadding = 0
        binaryStringCell.questionStringTextView.text = pollForCell.questionString
        
        expiredCell.questionStringTextView.textContainerInset = UIEdgeInsets.zero
        expiredCell.questionStringTextView.textContainer.lineFragmentPadding = 0
        expiredCell.questionStringTextView.text = pollForCell.questionString
        
        //pollImage
        
        binaryStringCell.pollImageView.layer.cornerRadius = 4
        binaryStringCell.pollImageView.layer.masksToBounds = true
        binaryStringCell.pollImageView.alpha = 0.8
        binaryStringCell.groupMembersCollectionView.isHidden = false
       
        expiredCell.pollImageView.layer.cornerRadius = 4
        expiredCell.pollImageView.layer.masksToBounds = true
        expiredCell.pollImageView.alpha = 0.8
        expiredCell.groupMembersCollectionView.isHidden = false
        
        
        //senderImageView Tap Gesture
        
        
        let userImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.userImageTapped(sender:)))
        
        let expiredUserImageTapGesure = UITapGestureRecognizer(target: self, action: #selector(self.userImageTapped(sender:)))
        
        binaryStringCell.senderImageView.addGestureRecognizer(userImageTapGesture)
        
        expiredCell.senderImageView.addGestureRecognizer(expiredUserImageTapGesure)
        
        
        binaryStringCell.senderImageView.isUserInteractionEnabled = true
        
        binaryStringCell.isUserInteractionEnabled = true
        
        expiredCell.senderImageView.isUserInteractionEnabled = true
        
        expiredCell.isUserInteractionEnabled = true
        
        //Threading Formatting
        
        if pollForCell.isThreadParent == false {
            binaryStringCell.senderImageView.isHidden = true
            binaryStringCell.imageViewThread.isHidden = false
            binaryStringCell.threadTopLine.isHidden = false
            binaryStringCell.senderFullNameLabel.isHidden = true
            binaryStringCell.answerSelectedView.isUserInteractionEnabled = true
            
            expiredCell.senderImageView.isHidden = true
            expiredCell.imageViewThread.isHidden = false
            expiredCell.threadTopLine.isHidden = false
            expiredCell.senderFullNameLabel.isHidden = true
            
        } else {
            binaryStringCell.senderImageView.isHidden = false
            binaryStringCell.imageViewThread.isHidden = true
            binaryStringCell.threadTopLine.isHidden = true
            binaryStringCell.threadBottomLine.isHidden = false
            binaryStringCell.senderFullNameLabel.isHidden = false
            binaryStringCell.answerSelectedView.isUserInteractionEnabled = true
            
            expiredCell.senderImageView.isHidden = false
            expiredCell.imageViewThread.isHidden = true
            expiredCell.threadTopLine.isHidden = true
            expiredCell.threadBottomLine.isHidden = false
            expiredCell.senderFullNameLabel.isHidden = false
            
        }
        
        
        if binaryStringCell.answer1Button.isHidden == true {
            binaryStringCell.answerSelectedView.isHidden = false
        }
        
       
        if pollForCell.hasChildren == false {
            binaryStringCell.threadBottomLine.isHidden = true
            expiredCell.threadBottomLine.isHidden = true
        } else {
            binaryStringCell.threadBottomLine.isHidden = false
            expiredCell.threadBottomLine.isHidden = false
        }
        
        
        binaryStringCell.imageViewThread.layer.cornerRadius = binaryStringCell.imageViewThread.layer.frame.width / 2
        binaryStringCell.imageViewThread.layer.backgroundColor = grey.cgColor
        binaryStringCell.imageViewThread.layer.masksToBounds = true
        
        expiredCell.imageViewThread.layer.cornerRadius = binaryStringCell.imageViewThread.layer.frame.width / 2
        expiredCell.imageViewThread.layer.backgroundColor = grey.cgColor
        expiredCell.imageViewThread.layer.masksToBounds = true
        
        
        
        if pollForCell.pollQuestionImageURL == "no question image" {
            binaryStringCell.pollImageView.isHidden = true
            binaryStringCell.pollImageViewHeight.constant = 48
            
            expiredCell.pollImageView.isHidden = true
            expiredCell.pollImageViewHeight.constant = 48
        } else {
        
        binaryStringCell.pollImageView.isHidden = false
        binaryStringCell.pollImageViewHeight.constant = 124
        binaryStringCell.pollImageView.sd_setImage(with: URL(string: pollForCell.pollQuestionImageURL))
            
        expiredCell.pollImageView.isHidden = false
        expiredCell.pollImageViewHeight.constant = 124
        expiredCell.pollImageView.sd_setImage(with: URL(string: pollForCell.pollQuestionImageURL))
            
        }


        //Sender User
       senderUserRef.observe(.value, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let senderUserImageURLString = snapshotValue["profileImageURL"] as! String
        
        
            binaryStringCell.senderImageView.sd_setImage(with: URL(string: senderUserImageURLString))
            binaryStringCell.senderFullNameLabel.text = snapshotValue["fullName"] as! String
            expiredCell.senderImageView.sd_setImage(with: URL(string: senderUserImageURLString))
            expiredCell.senderFullNameLabel.text = snapshotValue["fullName"] as! String
        
        })
        
        binaryStringCell.senderImageView.layer.cornerRadius = binaryStringCell.senderImageView.layer.frame.width / 2
        binaryStringCell.senderImageView.layer.masksToBounds = true
        binaryStringCell.senderImageView.tag = indexPath.row
        
        expiredCell.senderImageView.layer.cornerRadius = binaryStringCell.senderImageView.layer.frame.width / 2
        expiredCell.senderImageView.layer.masksToBounds = true
        expiredCell.senderImageView.tag = indexPath.row
        
        //chatButton
        let chatImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chatIconTapped(sender:)))
        
        let expiredChatImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.chatIconTapped(sender:)))

        binaryStringCell.conversationIconImageView.addGestureRecognizer(chatImageViewTapGesture)
        binaryStringCell.conversationIconImageView.tag = indexPath.row
        binaryStringCell.conversationIconImageView.isUserInteractionEnabled = true
        
        expiredCell.conversationIconImageView.addGestureRecognizer(expiredChatImageViewTapGesture)
        expiredCell.conversationIconImageView.tag = indexPath.row
        expiredCell.conversationIconImageView.isUserInteractionEnabled = true

        //answer1Button
        binaryStringCell.answer1Button.tag = indexPath.row
        binaryStringCell.answer1Button.addTarget(self, action: #selector(self.answer1ButtonTapped(sender:)), for: .touchUpInside)
        binaryStringCell.answer1Button.layer.cornerRadius = 4
        binaryStringCell.answer1Button.layer.masksToBounds = true
        binaryStringCell.answer1Button.setTitle(pollForCell.answer1String, for: .normal)
        binaryStringCell.answer1Button.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
        
        //answer2Button
        binaryStringCell.answer2Button.tag = indexPath.row
        binaryStringCell.answer2Button.addTarget(self, action: #selector(self.answer2ButtonTapped(sender:)), for: .touchUpInside)
        binaryStringCell.answer2Button.layer.cornerRadius = 4
        binaryStringCell.answer2Button.layer.masksToBounds = true
        binaryStringCell.answer2Button.setTitle(pollForCell.answer2String, for: .normal)
        binaryStringCell.answer2Button.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2)
        
        //answerSelectedView
        binaryStringCell.answerSelectedView.layer.cornerRadius = 4
        binaryStringCell.answerSelectedView.backgroundColor = actionGreen
        binaryStringCell.answerSelectedView.layer.backgroundColor = actionGreen.cgColor
        binaryStringCell.answerSelectedView.tag = indexPath.row
        let answeredViewTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.answeredViewTapped(sender:)))
        let expiredAnsweredViewTapGesture :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.answeredViewTapped(sender:)))
        
        binaryStringCell.answerSelectedView.addGestureRecognizer(answeredViewTapGesture)
    
        
        binaryStringCell.answerSelectedView.isUserInteractionEnabled = true
        binaryStringCell.answerSelectedView.isHidden = false
        binaryStringCell.answer1Button.isHidden = true
        binaryStringCell.answer2Button.isHidden = true
        binaryStringCell.expiredIconImageView.isHidden = true
        binaryStringCell.timerView.isHidden = false
        binaryStringCell.conversationIconImageView.image = #imageLiteral(resourceName: "pollConversationIcon")
        binaryStringCell.timeLeftNumberLabel.isHidden = false
        binaryStringCell.timeLeftUnitLabel.isHidden = false
        binaryStringCell.pieChartCenterView.isHidden = false
        binaryStringCell.timerView.isHidden = false
        
        
        //Expired answerSelectedView
        expiredCell.answerSelectedView.layer.cornerRadius = 4
        expiredCell.answerSelectedView.backgroundColor = grey
        expiredCell.answerSelectedView.layer.backgroundColor = grey.cgColor
        expiredCell.answerSelectedView.tag = indexPath.row
        expiredCell.answerSelectedView.addGestureRecognizer(expiredAnsweredViewTapGesture)
        
        expiredCell.answerSelectedView.isUserInteractionEnabled = false
        expiredCell.answerSelectedView.isHidden = false
        expiredCell.conversationIconImageView.isHidden = false
        expiredCell.answer1Button.isHidden = true
        expiredCell.answer2Button.isHidden = true
        expiredCell.expiredIconImageView.isHidden = false
        expiredCell.timerView.isHidden = true
        expiredCell.conversationIconImageView.image = #imageLiteral(resourceName: "pollConversationIconInactive")
        expiredCell.timeLeftNumberLabel.isHidden = true
        expiredCell.timeLeftUnitLabel.isHidden = true
        expiredCell.pieChartCenterView.isHidden = true
        expiredCell.timerView.isHidden = true
        

          currentUserVoteRef.observe(.value, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let vote = snapshotValue["voteString"] as! String

            
            if vote == "no vote" {
                
                binaryStringCell.conversationIconImageView.isHidden = true
                expiredCell.answerSelectedTextLabel.text = "You didn't answer"
                binaryStringCell.answer1Button.isHidden = false
                binaryStringCell.answer2Button.isHidden = false
                binaryStringCell.answerSelectedView.isHidden = true
                
        
            } else if vote == "answer1" {
                
                expiredCell.answerSelectedTextLabel.text = "Your answer was \(pollForCell.answer1String)"
                binaryStringCell.answerSelectedTextLabel.text = "Answered \(pollForCell.answer1String)"
                
            } else if vote == "answer2" {
                
                expiredCell.answerSelectedTextLabel.text = "Your answer was \(pollForCell.answer2String)"
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
                    binaryStringCell.timeLeftUnitLabel.text = "min"
                }
                
                binaryStringCell.timeLeftUnitLabel.text = "mins"
                
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
        
        
        print("Minutes Left \(minutesLeft.minute!)")
        
        
        if minutesLeft.minute! > 0 {
            
            let chartView = PieChartView()
            
            chartView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            
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
            FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedPolls").child(pollForCell.pollID).child("expired").setValue("true")
        //FIRDatabase.database().reference().child("threads").child(threads[indexPath.section]).child(pollForCell.pollID).child("expired").setValue("true")
            
            expiredCell.groupMembersCollectionView.tag = indexPath.row
            print("Expired Cell Collection View Tag \(expiredCell.groupMembersCollectionView.tag)")
            
            
            
            if expiredCell.answer1Button.isHidden == true {
                expiredCell.answerSelectedView.isHidden = false
            }
            
            return expiredCell
            
        }

        //Collection View
        print("POLL EXPIRED \(pollForCell.isExpired)")
        
        if pollForCell.isExpired == true {
           
            expiredCell.groupMembersCollectionView.tag = indexPath.row

            if expiredCell.answer1Button.isHidden == true {
                expiredCell.answerSelectedView.isHidden = false
            }
            
            return expiredCell
        }

      
         binaryStringCell.groupMembersCollectionView.tag = indexPath.row
        
        return binaryStringCell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? StringPollTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        
        
        tableViewCell.isUserInteractionEnabled = true
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        let tableViewSection = collectionView.superview!.tag
//        let thread = threads[collectionView.superview!.tag]
//        let pollArrayForThread = threadDict[thread]!
//
//        let pollForCell = pollArrayForThread[collectionView.tag]
        
        let pollForCell = receivedPolls[collectionView.tag]

        return pollForCell.groupMembers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

//        let tableViewSection = collectionView.superview!.tag
//        let tableViewRow = collectionView.tag
//        let thread = threads[collectionView.superview!.tag]
//        let pollArrayForThread = threadDict[thread]!
//        let pollForCell = pollArrayForThread[collectionView.tag]
        
        let pollForCell = receivedPolls[collectionView.tag]
        let recipientForCollectionCell = pollForCell.groupMembers[indexPath.item]
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newGroupMemberCollectionViewCell", for: indexPath) as! PollRecipientCollectionViewCell

     
        cell.answerIndicatorImageView.layer.borderWidth = 1
        cell.answerIndicatorImageView.layer.borderColor = UIColor.white.cgColor
        cell.recipientImageView.layer.borderWidth = 0
        cell.recipientImageView.layer.borderColor = UIColor.white.cgColor


        if recipientForCollectionCell.vote == "no vote" {
            
            //cell.answerIndicatorImageView.backgroundColor = grey
            cell.answerIndicatorImageView.isHidden = true
            
        } else if recipientForCollectionCell.vote == "answer1" {
            
            cell.answerIndicatorImageView.backgroundColor = brightGreen
            cell.answerIndicatorImageView.isHidden = false
            
        } else if recipientForCollectionCell.vote == "answer2" {
            
            cell.answerIndicatorImageView.backgroundColor = red
            cell.answerIndicatorImageView.isHidden = false
        }

        cell.answerIndicatorImageView.layer.cornerRadius = cell.answerIndicatorImageView.layer.frame.width / 2
        
        cell.recipientImageView.sd_setImage(with: URL(string: recipientForCollectionCell.imageURL1))
        cell.recipientImageView.layer.cornerRadius = cell.recipientImageView.layer.frame.width / 2
        cell.recipientImageView.layer.masksToBounds = true
    
        return cell
        
    }
    
    
    func answer1ButtonTapped (sender: UIButton) {
    
        let tableViewSection = 0
        let tableViewRow = sender.tag
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let pollForRow = receivedPolls[sender.tag]
//        
//        let tableViewSection = sender.superview!.tag
//        let tableViewRow = sender.tag
//        let thread = threads[sender.superview!.tag]
//        let pollArrayForThread = threadDict[thread]!
//        let pollForRow = pollArrayForThread[sender.tag]
//        let indexPath = IndexPath(row: tableViewRow, section: tableViewSection)
    
//        tableView.reloadRows(at: [indexPath], with: .fade)
        
        let buttonIndexPath = IndexPath(row: tableViewRow, section: tableViewSection)
        let binaryStringCell = tableView.cellForRow(at: buttonIndexPath) as! StringPollTableViewCell
        
       // binaryStringCell.groupMembersCollectionView.reloadData()
        
        FIRDatabase.database().reference().child("users").child(pollForRow.senderUser).observe(.value, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
           
            binaryStringCell.senderImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
            
        })
        
        UIView.animate(withDuration: 0.1, animations: {
            binaryStringCell.answer2Button.alpha = 0
            binaryStringCell.answer2Button.isHidden = true
            binaryStringCell.answer1Button.alpha = 0
            binaryStringCell.answer1Button.isHidden = true
            
             binaryStringCell.answerSelectedTextLabel.text = "Answered \(pollForRow.answer1String))"
        })
        
 
        delay(0.2, closure: {
            
            UIView.animate(withDuration: 0.1, animations: {
                
                binaryStringCell.answerSelectedView.alpha = 0
                binaryStringCell.conversationIconImageView.alpha = 0
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.conversationIconImageView.isHidden = false
                binaryStringCell.conversationIconImageView.alpha = 1
                binaryStringCell.answerSelectedView.alpha = 1
                
            })
            
        })
        
        
    FIRDatabase.database().reference().child("polls").child(pollForRow.pollID).child("votes").child(currentUserID!).child("voteString").setValue("answer1")

    FIRDatabase.database().reference().child("users").child(currentUserID!).child("votes").child(pollForRow.pollID).child("answerChoice").setValue("answer1")
    FIRDatabase.database().reference().child("users").child(currentUserID!).child("votes").child(pollForRow.pollID).child("answerString").setValue(pollForRow.answer1String)
        
        updatePollVotes(indexPath: indexPath)
       
    }
    
    func answer2ButtonTapped (sender: UIButton) {
       
        let tableViewSection = 0
        let tableViewRow = sender.tag
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let pollForRow = receivedPolls[sender.tag]
//
//      let tableViewSection = sender.superview!.tag
//      let tableViewRow = sender.tag
//      let thread = threads[sender.superview!.tag]
//      let pollArrayForThread = threadDict[thread]!
//      let pollForRow = pollArrayForThread[sender.tag]
//      let indexPath = IndexPath(row: tableViewRow, section: tableViewSection)
        
        
        
       // tableView.reloadRows(at: [indexPath], with: .fade)
        
        
        let buttonIndexPath = IndexPath(row: tableViewRow, section: tableViewSection)
        let binaryStringCell = tableView.cellForRow(at: buttonIndexPath) as! StringPollTableViewCell
        
       // binaryStringCell.groupMembersCollectionView.reloadData()
        
        FIRDatabase.database().reference().child("users").child(pollForRow.senderUser).observe(.value, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            
            binaryStringCell.senderImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
            
        })
        
        
        UIView.animate(withDuration: 0.2, animations: {

            binaryStringCell.answer1Button.alpha = 0
            binaryStringCell.answer1Button.isHidden = true
            binaryStringCell.answer2Button.alpha = 0
            binaryStringCell.answer2Button.isHidden = true
            
            
            binaryStringCell.answerSelectedTextLabel.text = "Answered \(pollForRow.answer2String)"
        })
        
        
        delay(0.2, closure: {
            
            UIView.animate(withDuration: 0.2, animations: {
                
                binaryStringCell.answerSelectedView.alpha = 0
                binaryStringCell.conversationIconImageView.alpha = 0
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.conversationIconImageView.isHidden = false
                binaryStringCell.conversationIconImageView.alpha = 1
                binaryStringCell.answerSelectedView.alpha = 1
                
            })
            
            

        })
      
        FIRDatabase.database().reference().child("polls").child(pollForRow.pollID).child("votes").child(currentUserID!).child("voteString").setValue("answer2")
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("votes").child(pollForRow.pollID).child("answerChoice").setValue("answer2")
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("votes").child(pollForRow.pollID).child("answerString").setValue(pollForRow.answer2String)
      
        updatePollVotes(indexPath: indexPath)
       //  tableView.reloadData()
        
    }
    
    func answeredViewTapped (sender: UITapGestureRecognizer) {
        
        
        let tableViewSection = 0
        let tableViewRow = sender.view?.tag
        let indexPath = IndexPath(row: tableViewRow!, section: 0)
        let pollForRow = receivedPolls[tableViewRow!]

//        let tableViewSection = sender.view?.superview?.tag
//        
//        let tableViewRow = sender.view?.tag
//        
//        let thread = threads[tableViewSection!]
//        let pollArrayForThread = threadDict[thread]!
//        let pollForRow = pollArrayForThread[tableViewRow!]

        let buttonIndexPath = IndexPath(row: tableViewRow!, section: tableViewSection)

        let binaryStringCell = tableView.cellForRow(at: buttonIndexPath) as! StringPollTableViewCell
        
        FIRDatabase.database().reference().child("users").child(pollForRow.senderUser).observe(.value, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            
            binaryStringCell.senderImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
            
        })
        
        UIView.animate(withDuration: 0.2, animations: {
            
            
            binaryStringCell.answerSelectedView.alpha = 1
            binaryStringCell.answerSelectedView.isHidden = true
            binaryStringCell.answerSelectedView.alpha = 0
            binaryStringCell.conversationIconImageView.alpha = 1
            binaryStringCell.conversationIconImageView.isHidden = true
            binaryStringCell.conversationIconImageView.alpha = 0
           

        })
        
        
        delay(0.2, closure: {
            
            UIView.animate(withDuration: 0.2, animations: {
                
                binaryStringCell.answer2Button.alpha = 0
                binaryStringCell.answer2Button.isHidden = false
                binaryStringCell.answer2Button.alpha = 1
                
                binaryStringCell.answer1Button.alpha = 0
                binaryStringCell.answer1Button.isHidden = false
                binaryStringCell.answer1Button.alpha = 1
                
            })
            
        })
        
      

    }
    
    
    func chatIconTapped (sender: UITapGestureRecognizer) {
        
//        let tableViewSection = sender.view?.superview?.tag
//        
        let tableViewRow = sender.view?.tag
//        
//        let thread = threads[tableViewSection!]
//        let pollArrayForThread = threadDict[thread]!
//        let pollForRow = pollArrayForThread[tableViewRow!]
        
        let pollForRow = receivedPolls[tableViewRow!]
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        
        
        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(pollForRow.pollID).child("votes")
        
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
            snapshot in
            
            myVC.answer1Count = Int(snapshot.childrenCount)
            
        })
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
            snapshot in
            
            myVC.answer2Count = Int(snapshot.childrenCount)
            
        })
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "no vote").observe(.value, with: {
            snapshot in
            
            myVC.undecidedCount = Int(snapshot.childrenCount)
            
        })
        
        
        myVC.poll = pollForRow
        myVC.chatMembers = pollForRow.groupMembers
        myVC.showEverybody = true
         
        navigationController?.pushViewController(myVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
       
//        let tableViewSection = indexPath.section
//        
//        let tableViewRow = indexPath.row
//        
//        let thread = threads[tableViewSection]
//        let pollArrayForThread = threadDict[thread]!
//        let pollForRow = pollArrayForThread[tableViewRow]
//        let indexPathForPoll = IndexPath(row: tableViewRow, section: tableViewSection)

      
        let pollForRow = receivedPolls[indexPath.row]
        
        print(pollForRow.isExpired)
        print(pollForRow.minutesUntilExpiration)

        
        let leave = UITableViewRowAction(style: .normal, title: "Leave") { action, index in
            print("delete group tapped")
            
//         let threadRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls").child(thread).child(pollForRow.pollID)
//            
//
//         self.threadDict[thread] = self.threadDict[thread]?.filter() {$0 !== pollForRow}
            
            
        let receivedPollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls").child(pollForRow.pollID)
            
            self.receivedPolls = self.receivedPolls.filter({$0 !== pollForRow})
            
            receivedPollRef.removeValue()
            
            tableView.reloadData()
            
            
            UIView.animate(withDuration: 0.1) {
                
                self.view.layoutIfNeeded()
            }
            
            
        }
        
        let end = UITableViewRowAction(style: .normal, title: "End") { action, index in
            print("end poll tapped")
            
            
            let pollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForRow.pollID)
           
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let dateString = formatter.string(from: date)

        FIRDatabase.database().reference().child("polls").child(pollForRow.pollID).child("expired").setValue("true")
            FIRDatabase.database().reference().child("polls").child(pollForRow.pollID).child("expirationDate").setValue(dateString)
            
            FIRDatabase.database().reference().child("users").child(self.currentUserID!).child("receivedPolls").child(pollForRow.pollID).child("expirationDate").setValue(dateString)
            
            FIRDatabase.database().reference().child("users").child(self.currentUserID!).child("receivedPolls").child(pollForRow.pollID).child("expired").setValue("true")
            
            self.receivedPolls[indexPath.row].isExpired = true
            
            tableView.reloadData()
            
            
            UIView.animate(withDuration: 0.1) {
                
                self.view.layoutIfNeeded()
            }
            
            
        }
        
        leave.backgroundColor = red
        
        end.backgroundColor = grey
        
        if pollForRow.senderUser == currentUserID, pollForRow.minutesUntilExpiration > 0 {
            
            return [end]
        }
        
       
        return [leave]
        
        
    }
    
    
    func deletePoll(indexPath: IndexPath) {
        
    
        
    }

    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        

        return true
        
    }

    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    
    
    func userImageTapped (sender : UITapGestureRecognizer) {
        
//      let tableViewSection = sender.view?.superview?.tag
        
        let tableViewRow = sender.view?.tag
        
//      let threadID = threads[tableViewSection!]
//      let pollArrayForThread = threadDict[threadID]
//      let pollForCell = pollArrayForThread?[tableViewRow!]
        
        let pollForCell = receivedPolls[tableViewRow!]
        
        print(pollForCell.questionString)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        let transition:CATransition = CATransition()
        
        controller.profileUserID = (pollForCell.senderUser)
            
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        
        if pollForCell.senderUser == currentUserID {
            transition.subtype = kCATransitionFromLeft
        } else {
            transition.subtype = kCATransitionFromRight
        }
        
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
        
        
    }
    
    
    func keyboardWasShown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            
            print("keyboardWasShown")
            
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                kbHeight = Int(keyboardSize.height + 44)
                self.animateTextFieldView(up: true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.deAnimateTextFieldView(up: true)
        print("keyboardWillHide")
    }
    
    
    func animateTextFieldView(up: Bool) {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.bottomLayoutConstraint.constant = CGFloat(self.kbHeight)
        })
    }
    
    
    func deAnimateTextFieldView(up: Bool) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomLayoutConstraint.constant = 0
        })
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
        let profileIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.myProfileImageTapped(sender:)))
        
        profileIconImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        profileIconImageView.layer.cornerRadius = profileIconImageView.frame.size.width / 2
        profileIconImageView.layer.borderWidth = 1
        profileIconImageView.layer.borderColor = UIColor.init(hexString: "004488").cgColor
        profileIconImageView.layer.masksToBounds = true
        profileIconImageView.addGestureRecognizer(profileIconTapGesture)
        
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileIconImageView)
        
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            let profileImageURLString = snapshotValue["profileImageURL"] as! String
            let profileImageURL = URL(string: profileImageURLString)
            
            profileIconImageView.sd_setImage(with: profileImageURL)
            
        })
        
//        
//        let newDecisionIconImageView = UIImageView()
//        let newDecisionIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.newDecisionIconTapped(sender:)))
//        
//        newDecisionIconImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
//        
//        newDecisionIconImageView.addGestureRecognizer(newDecisionIconTapGesture)
//        
//        newDecisionIconImageView.image = #imageLiteral(resourceName: "newDecisionIcon")
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newDecisionIconImageView)
//        
//
//        navigationController?.navigationBar.backgroundColor = UIColor.white
//        navigationController?.navigationBar.isTranslucent = false
        
        
        let discoverImageView = UIImageView()
        let discoverIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.discoverIconTapped(sender:)))
        
        discoverImageView.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        
        discoverImageView.addGestureRecognizer(discoverIconTapGesture)
        
        discoverImageView.image = #imageLiteral(resourceName: "Discover icon")
        
        let discoverBarButtonItem = UIBarButtonItem(customView: discoverImageView)
        
        
        
        let globalPollsImageView = UIImageView()
        
        let globalPollsIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.globalPollsIconTapped(sender:)))
        
        globalPollsImageView.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        
        globalPollsImageView.addGestureRecognizer(globalPollsIconTapGesture)
        
        globalPollsImageView.image = #imageLiteral(resourceName: "Global Icon")
        
        let globalPollsBarButtonItem = UIBarButtonItem(customView: globalPollsImageView)
        
        
        
        let barbuttonSpaceImageView = UIImageView()
        
        barbuttonSpaceImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        
        let barButtonSpace = UIBarButtonItem(customView: barbuttonSpaceImageView)
        
        navigationItem.rightBarButtonItems = [discoverBarButtonItem, barButtonSpace, globalPollsBarButtonItem]
        
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        
        UIView.animate(withDuration: 1, animations: {
            
            profileIconImageView.alpha = 0
            profileIconImageView.alpha = 1
        })
        
    }
    
    func newDecisionIconTapped (sender: UITapGestureRecognizer) {
        
        let imgView = sender.view as! UIImageView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreatePollViewController") as! CreatePollViewController
        let transition:CATransition = CATransition()
        
        
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
        
        
    }
    
    
    func discoverIconTapped (sender: UITapGestureRecognizer) {
        
        let imgView = sender.view as! UIImageView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FindFriendsViewController") as! FindFriendsViewController
        let transition:CATransition = CATransition()
     
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("recipientList").queryOrdered(byChild: "tag").queryEqual(toValue: "user").observe(.childAdded, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let friend = Recipient()
            
            friend.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            friend.recipientID = snapshot.key
            friend.recipientName = snapshotValue["recipientName"] as! String
            friend.phoneNumber = snapshotValue["phoneNumber"] as! String
            friend.tag = snapshotValue["tag"] as! String
            
            controller.recipientList.append(friend)
            
        })
        
        
        
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
        
        
    }
    
    func globalPollsIconTapped (sender: UITapGestureRecognizer) {
        
        let imgView = sender.view as! UIImageView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DiscoverViewController") as! DiscoverViewController
      
        let transition:CATransition = CATransition()

        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
        
        
    }
    
    func myProfileImageTapped (sender : UITapGestureRecognizer) {
        
        let imgView = sender.view as! UIImageView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let controller = storyboard.instantiateViewController(withIdentifier: "PollProfileViewController") as! PollProfileViewController

        let controller = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        let transition:CATransition = CATransition()
        
        controller.profileUserID = (FIRAuth.auth()?.currentUser?.uid)!
       
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        
        //  self.present(controller, animated: true, completion: nil)
        
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
        
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
    }
  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let input = textField.text
    
        print("returned")
 
        self.view.endEditing(true)
        
        return false
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(UserHomeViewController.getHintsFromTextField), object: textField)
        
        self.perform(#selector(UserHomeViewController.getHintsFromTextField), with: textField, afterDelay: 0.5)
        
        return true
    }
    
    
    func getHintsFromTextField(textField: UITextField) {
        
        let input = textField.text!
        
        if input != "" {
            
           rightLayoutConstraint.constant = 45
           newDecisionButton.isHidden = false
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
            
           
        } else {
            rightLayoutConstraint.constant = 8
            newDecisionButton.isHidden = true
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
            
        }
        
           
    }
    
    
    
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//        
//        guard let indexPath = tableView.indexPathForRow(at: location) else {return nil}
//        guard let cell = tableView.cellForRow(at: indexPath) else {return nil}
//        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "PollImageDetailViewController") as? PollImageDetailViewController else { return nil }
//        
//        let thread = threads[indexPath.section]
//        
//        let pollArrayForThread = threadDict[thread]
//        
//        let pollForCell = pollArrayForThread?[indexPath.row]
//        
//        let photoURL =  pollForCell?.pollQuestionImageURL
//        
//        
//        detailVC.photoURL = photoURL!
//        detailVC.preferredContentSize = CGSize(width: 300, height: 300)
//        previewingContext.sourceRect = cell.frame
//        
//        
//        if photoURL == "no question image" {return nil}
//        
//        
//        return detailVC
//        
//        
//    }
//    
//
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//        
//        show(viewControllerToCommit, sender: self)
//        
//    }
    
    
    
    @IBAction func unwindToMenuAfterSendingThreadPoll(segue: UIStoryboardSegue){
        
        newDecisionTextField.endEditing(true)
        newDecisionTextField.text = ""
        view.endEditing(true)
        
        tableView.reloadData()
       // tableView.updateConstraints()
        
        
    }

    
    @IBAction func unwindToMenuAfterSendingNewThreadPoll(segue: UIStoryboardSegue){
        
         newDecisionTextField.endEditing(true)
         newDecisionTextField.text = ""
         view.endEditing(true)
       // tableView.reloadData()
       // tableView.updateConstraints()
        
        
    }
    
    
    @IBAction func unwindToMenuFromFindFriends (segue: UIStoryboardSegue){
        
        newDecisionTextField.endEditing(true)
        newDecisionTextField.text = ""
        view.endEditing(true)
        tableView.reloadData()
        // tableView.updateConstraints()
    
    }
    
    
    
    
    @IBAction func newDecisionButtonTapped(_ sender: Any) {
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "CreatePollViewController") as! CreatePollViewController
        
        print("\(newDecisionTextField.text)")
        
        myVC.questionStringFromHome = newDecisionTextField.text!
        
        navigationController?.pushViewController(myVC, animated: true)
        
    }
    
    func updatePollVotes (indexPath : IndexPath) {
        
//        let threadID = threads[indexPath.section]
//        let poll = threadDict[threadID]?[indexPath.row]
        
          let poll = receivedPolls[indexPath.row]
          poll.groupMembers.removeAll()
        
        FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            let recipient = Recipient()
            
            recipient.recipientID = snapshotValue["recipientID"] as! String
            recipient.recipientName = snapshotValue["recipientName"] as! String
            recipient.vote = snapshotValue["voteString"] as! String
           
            FIRDatabase.database().reference().child("users").child(recipient.recipientID).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                recipient.imageURL1 = snapshotValue["profileImageURL"] as! String
                
                if (poll.groupMembers.contains(where: { $0.recipientID == recipient.recipientID}))
                { print("group already added")
                    
                } else {
        
                    poll.groupMembers.append(recipient)
                    poll.groupMembers = (poll.groupMembers.sorted(by: {$0.vote < $1.vote}))
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                    
                    
                }

                
            })
          
            
            
            
        })
//    
//        FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedPolls").observe(.value, with: {
//            snapshot in
//            
//            FIRDatabase.database().reference().child("threads").child(threadID).observe(.childAdded, with: {
//                snapshot in
//                let snapshotValue = snapshot.value as! NSDictionary
//
//                FIRDatabase.database().reference().child("polls").child((poll?.pollID)!).child("votes").observe(.childAdded, with: {
//                    snapshot in
//                    let snapshotValue = snapshot.value as! NSDictionary
//                    let recipient = Recipient()
//                    
//                    recipient.recipientID = snapshotValue["recipientID"] as! String
//                    recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
//                    recipient.recipientName = snapshotValue["recipientName"] as! String
//                    recipient.vote = snapshotValue["voteString"] as! String
//                    
//                    
//                    if (poll?.groupMembers.contains(where: { $0.recipientID == recipient.recipientID}))!
//                    { print("group already added")
//                        
//                    } else {
//                        
//                        poll?.groupMembers.append(recipient)
//                        poll?.groupMembers = (poll?.groupMembers.sorted(by: {$0.vote < $1.vote}))!
//                        self.tableView.reloadRows(at: [indexPath], with: .fade)
//                        
//                        
//                    }
//                    
//                    
//                })
//        
//                
//            })
//
//            
//        })
//        
//
//        
//        
    }

    
}
