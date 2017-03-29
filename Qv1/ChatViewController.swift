//
//  ChatViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 11/11/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pollView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var sendViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var senderUserImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var answer1VoteCount: UILabel!
    @IBOutlet weak var answer2VoteCount: UILabel!
    @IBOutlet weak var senderUserName: UILabel!

    
    @IBOutlet weak var answer1TextLabel: UILabel!
    @IBOutlet weak var answer2TextLabel: UILabel!
    
    @IBOutlet weak var pollViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var showHidePollViewButton: UIButton!
    
    @IBOutlet weak var chatMemberViewVerticalConstraint: NSLayoutConstraint!
    
    
    //change chat outlets
    @IBOutlet weak var changeChatButton: UIButton!
    
    @IBOutlet weak var position1ChangeConversationButton: UIButton!
    
    @IBOutlet weak var position2ChangeConversationButton: UIButton!
    
    
    @IBOutlet weak var position0ChangeConversationButton: UIButton!

    @IBOutlet weak var position0ChangeConversationLabel: UILabel!
    
    @IBOutlet weak var position1ChangeConversationLabel: UILabel!
    
    @IBOutlet weak var position2ChangeConversationLabel: UILabel!

    
    @IBOutlet weak var changeConversationView: UIView!
    
    @IBOutlet weak var changeConversationBottomConstraint: UITextField!
    
    @IBOutlet weak var changeConversationTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pieChartView: UIView!
    
    @IBOutlet weak var pieChartCenterImageView: UIImageView!

    @IBOutlet weak var greenBackgroundImageView: UIImageView!

    @IBOutlet weak var redBackgroundImageView: UIImageView!
    
    
    var currentUsers : [Recipient] = []
    var userName = ""
    var userImage = ""
    var poll : Poll = Poll()
    var kbHeight = 0
    var chatMembers : [Recipient] = []
    var senderUser : User = User()
    var answer1Count : Int = 0
    var answer2Count : Int = 0
    var undecidedCount : Int = 0
    
    var answer1UserIDs : [String] = []
    var answer2UserIDs : [String] = []
    var undecidedUserIDs : [String] = []
    
    var showAnswer1Users : Bool = false
    var showAnswer2Users : Bool = false
    var showUndecidedUsers : Bool = false
    var showEverybody : Bool = false
    var viewHasAppeared : Bool = false
    
    struct message {
        let userName : String!
        var userID : String!
        let message : String!
        let userImage : String!
    }
    
    //var messages : [message] = []
    var everybodyMessages : [message] = []
    var answer1Messages : [message] = []
    var answer2Messages : [message] = []
    var undecidedMessages : [message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        print("POLL \(poll.questionString)")
        print("POLL \(poll.groupMembers)")
        
        let databaseRef : FIRDatabaseReference = FIRDatabase.database().reference()
        let recipientsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(poll.pollID).child("sentTo")
        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes")
        let chatMemberRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(poll.pollID).child("sentTo")
        let currentUserID = FIRAuth.auth()?.currentUser?.uid
        let chartView = PieChartView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.pollHeaderLabelTapped(sender:)))
        
        let everybodyMessagesRef = FIRDatabase.database().reference().child("messages").child(poll.pollID).child("messages").child("everybody")
        let answer1MessagesRef = FIRDatabase.database().reference().child("messages").child(poll.pollID).child("messages").child("answer1")
        let answer2MessagesRef = FIRDatabase.database().reference().child("messages").child(poll.pollID).child("messages").child("answer2")
        let noAnswerMessagesRef = FIRDatabase.database().reference().child("messages").child(poll.pollID).child("messages").child("noAnswer")
        
        setUpNavigationBarItems()
        navigationItem.titleView?.isUserInteractionEnabled = true
        navigationItem.titleView?.addGestureRecognizer(tapGestureRecognizer)
        

        tableView.delegate = self
        tableView.dataSource = self
        
        messageTextField.delegate = self
        
        self.hideKeyboard()

    
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = UIColor.init(hexString: "F9F9F9")
        
        answer1TextLabel.text = poll.answer1String
        answer2TextLabel.text = poll.answer2String
    
        changeConversationView.isHidden = true
        tableViewBottomConstraint.constant = 0
        
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
       
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.init(hexString: "F9F9F9")
        
        questionTextLabel?.text = poll.questionString
        
        senderUserName.addGestureRecognizer(tapGestureRecognizer)
        senderUserName.isUserInteractionEnabled = true


        //change conversation view
        
        position1ChangeConversationLabel.text = "Team \(poll.answer1String)"
        position2ChangeConversationLabel.text = "Team \(poll.answer2String)"
        
        showHidePollViewButton.setImage(UIImage(named: "hide icon.png"), for: .normal)
        pollViewHeightConstraint.constant = 96
        questionTextLabel.isHidden = true
        answer1TextLabel.isHidden = true
        answer2TextLabel.isHidden = true
        answer1VoteCount.isHidden = true
        answer2VoteCount.isHidden = true
        greenBackgroundImageView.isHidden = true
        greenBackgroundImageView.layer.cornerRadius = greenBackgroundImageView.layer.frame.size.width / 2
        greenBackgroundImageView.layer.masksToBounds = true
        redBackgroundImageView.isHidden = true
        redBackgroundImageView.layer.cornerRadius = redBackgroundImageView.layer.frame.size.width / 2
        redBackgroundImageView.layer.masksToBounds = true
        pieChartCenterImageView.isHidden = true
        pieChartView.isHidden = true
        chatMemberViewVerticalConstraint.constant = 22
        senderUserName.text = poll.questionString
        collectionView.layer.borderWidth = 0.2
        collectionView.layer.borderColor = UIColor.init(hexString: "D7D7D7").cgColor 
        
        //show correct change conversation icon when chat changes and reloads
        
        changeChatButton.imageView?.image = UIImage(named: "Everybody Conversation (Active)")
        
        if showAnswer1Users == true {
           changeChatButton.imageView?.image = UIImage(named: "Answer 1 Conversation (Active)")
        }
        
        if showAnswer2Users == true {
            changeChatButton.imageView?.image = UIImage(named: "Answer 2 Conversation (Active)")
        }
        
        if showUndecidedUsers == true {
            changeChatButton.imageView?.image = UIImage(named: "Undecided Conversation (Active)")
        }
        

        
        everybodyMessagesRef.observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            let userName = snapshotValue["userName"] as! String
            let userImage = snapshotValue["userImage"] as! String
            let userID = snapshotValue["uid"] as! String
            let messageBody = snapshotValue["userMessage"] as! String
            
            self.everybodyMessages.insert(message(userName: userName , userID: userID, message: messageBody, userImage: userImage ), at: 0)
            
            self.tableView.reloadData()
            
            
        })
        
        
        answer1MessagesRef.observe(.childAdded, with: {
            
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let userName = snapshotValue["userName"] as! String
            let userImage = snapshotValue["userImage"] as! String
            let userID = snapshotValue["uid"] as! String
            let messageBody = snapshotValue["userMessage"] as! String
            
            self.answer1Messages.insert(message(userName: userName , userID: userID, message: messageBody, userImage: userImage ), at: 0)
            
        })
        
        answer2MessagesRef.observe(.childAdded, with: {
            
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let userName = snapshotValue["userName"] as! String
            let userImage = snapshotValue["userImage"] as! String
            let userID = snapshotValue["uid"] as! String
            let messageBody = snapshotValue["userMessage"] as! String
            
            self.answer2Messages.insert(message(userName: userName , userID: userID, message: messageBody, userImage: userImage ), at: 0)
            
        })
        
        noAnswerMessagesRef.observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let userName = snapshotValue["userName"] as! String
            let userImage = snapshotValue["userImage"] as! String
            let userID = snapshotValue["uid"] as! String
            let messageBody = snapshotValue["userMessage"] as! String
            
            self.undecidedMessages.insert(message(userName: userName , userID: userID, message: messageBody, userImage: userImage ), at: 0)
            
        })
                
        
        //figure out current user's vote and update conversation choices
        
        if currentUserID != poll.senderUser {
        pollVoteReference.child(currentUserID!).observe(.value, with: {
            snapshot in
        
            let snapshotValue = snapshot.value as! NSDictionary
            let userAnswer = snapshotValue["voteString"] as! String
            print("CURRENT USER ID\(currentUserID)")
            print("SENDER ID\(self.senderUser.uID)")
        
            if userAnswer == "answer1" {
                
                self.position2ChangeConversationLabel.isHidden = true
                self.position2ChangeConversationButton.isHidden = true
                
            }
            
            if userAnswer == "no vote" {
                self.position2ChangeConversationLabel.isHidden = true
                self.position1ChangeConversationLabel.isHidden = true
                self.position2ChangeConversationButton.isHidden = true
                self.position1ChangeConversationButton.isHidden = true
                
            }
            
            if userAnswer == "answer2" {
                self.position1ChangeConversationLabel.isHidden = true
                self.position1ChangeConversationButton.isHidden = true
                
            }
            
        })
        }
        
        
        //get votes and calculate poll results from Firebase
        
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
            snapshot in

            print(snapshot.childrenCount)
            self.answer1VoteCount.text = String(snapshot.childrenCount)
            
            

        })
    
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.childAdded, with: {
            snapshot in
            
            
            self.answer1UserIDs.append(snapshot.key as! String)
            
        })
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.childAdded, with: {
            snapshot in
            
            self.answer2UserIDs.append(snapshot.key as! String)
            
        })
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "no vote").observe(.childAdded, with: {
            snapshot in
            
            self.undecidedUserIDs.append(snapshot.key as! String)
            
        })
        
        
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
            snapshot in
            
           self.answer2VoteCount.text = String(snapshot.childrenCount)
            
            let answer1Count = Double(self.answer1VoteCount.text!)
            let answer2Count = Double(snapshot.childrenCount)
            let total = answer1Count! + answer2Count
            
            if total > 0 {
                
        
                if answer1Count == 0, Int(answer2Count) > 0 {
                    self.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
   
                    //self.answer2TextLabel.textColor = UIColor.white
                    self.position1ChangeConversationButton.isEnabled = false
                    self.position1ChangeConversationButton.alpha = 0.5
                    self.position1ChangeConversationLabel.textColor = UIColor.lightGray
                    
                    
                }
                
                if answer2Count == 0, Int(answer1Count!) > 0 {
                    
                    self.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
        
                    //self.answer1TextLabel.textColor = UIColor.white
                    self.position2ChangeConversationButton.isEnabled = false
                    self.position2ChangeConversationButton.alpha = 0.5
                    self.position2ChangeConversationLabel.textColor = UIColor.lightGray

                    
                }
                
                if Int(answer1Count!) < Int(answer2Count) {
                    

                    //self.answer2TextLabel.textColor = UIColor.white
                    self.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
          
                    
               }
               
                if Int(answer1Count!) > Int(answer2Count) {
           
                    //self.answer1TextLabel.textColor = UIColor.white
                    self.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                    
                }
                
                
            } else {
                self.answer1VoteCount.text = "0"
                self.answer2VoteCount.text = "0"
                
            }
            
        })
        
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
            snapshot in
            
            self.answer1Count = Int(snapshot.childrenCount)
            
            pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
                snapshot in
                
                self.answer2Count = Int(snapshot.childrenCount)
                
                pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "no vote").observe(.value, with: {
                    snapshot in
                    
                    self.undecidedCount = Int(snapshot.childrenCount)
                    
                    
                    chartView.frame = CGRect(x: 0, y: 0, width: self.pieChartView.frame.size.width, height: 86)
                    self.pieChartCenterImageView.layer.cornerRadius = self.pieChartCenterImageView.layer.frame.size.width / 2
                    self.pieChartCenterImageView.layer.masksToBounds = true
                    
                    chartView.segments = [
                        
                        Segment(color: UIColor.init(hexString: "A8E855"), value: CGFloat(self.answer1Count)),
                        Segment(color: UIColor.init(hexString: "FF4E56"), value: CGFloat(self.answer2Count)),
                        Segment(color: UIColor.init(hexString: "D8D8D8"), value: CGFloat(self.undecidedCount))
                    ]
                    
                    self.pieChartView.addSubview(chartView)
                    
                })
                
            })
            
        })
        
       
        
        
        

       
    }

    
   override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        super.reloadInputViews()
    
        viewHasAppeared = true
    
        print("VIEW HAS APPEARED \(viewHasAppeared)")
  
    
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewHasAppeared = false
        
        showAnswer1Users = false
        showAnswer2Users = false
        showUndecidedUsers = false
        showEverybody = false
        
        
        print("VIEW HAS APPEARED \(viewHasAppeared)")
        
        NotificationCenter.default.removeObserver(self)
    }
    
  
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func setUpNavigationBarItems() {
        
        let senderUserRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(poll.senderUser)
        
        senderUserRef.observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let titleImageView = UIImageView()
            titleImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
            titleImageView.backgroundColor = UIColor.black
            titleImageView.contentMode = .scaleAspectFit
            
            
            let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
            
            titleImageView.frame = titleView.bounds
            titleView.layer.cornerRadius = titleView.layer.frame.size.width / 2
            titleView.layer.masksToBounds = true
            titleView.addSubview(titleImageView)
            
            let editChatMembersImageView = UIImageView()
            let editChatMembersTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.editChatMembersTapped(sender:)))
            
            editChatMembersImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            editChatMembersImageView.image = #imageLiteral(resourceName: "List View Icon")
            editChatMembersImageView.addGestureRecognizer(editChatMembersTapGesture)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editChatMembersImageView)
            
            self.navigationItem.titleView = titleView
            
            UIView.animate(withDuration: 0.5) {
        
                titleView.isHidden = true
                
                self.delay(0.4, closure: {
                    UIView.animate(withDuration: 0.2) {
                        titleView.alpha = 0
                        
                        titleView.alpha = 1
                        
                        titleView.isHidden = false
                    }
                })
                

            }
            
        })
        

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        

        
    }
    
    func editChatMembersTapped (sender: UITapGestureRecognizer) {
        
        
        let imgView = sender.view as! UIImageView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "EditChatViewController") as! EditChatViewController
        let transition:CATransition = CATransition()
        
        controller.pollID = poll.pollID
        controller.sectionTitles = [poll.answer1String, poll.answer2String, "No Answer"]
        controller.answerColors = ["A8E855", "FF4E56", "D8D8D8"]
        
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
        
        
     }
   
    //keyboard function to adjust message textfield position when the keyboard appears
    func keyboardWasShown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                kbHeight = Int(keyboardSize.height + 50)
                self.animateTextFieldView(up: true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.deAnimateTextFieldView(up: true)
    }
    
    
    func animateTextFieldView(up: Bool) {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.sendViewBottomConstraint.constant = CGFloat(self.kbHeight)
        })
    }
    
    
    func deAnimateTextFieldView(up: Bool) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.sendViewBottomConstraint.constant = 0
        })
    }
    

    
    //tableView delegate functions
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let uid = FIRAuth.auth()?.currentUser?.uid
        var senderID = ""
        let previousIndex = (indexPath.row) - 1
        
        var messageText = ""
        
        if showEverybody == true {
            senderID = everybodyMessages[indexPath.row].userID
            messageText = everybodyMessages[indexPath.row].message
        }
        
        if showAnswer1Users == true {
            senderID = answer1Messages[indexPath.row].userID
            messageText = answer1Messages[indexPath.row].message
        }
        
        if showAnswer2Users == true {
            senderID = answer2Messages[indexPath.row].userID
            messageText = answer2Messages[indexPath.row].message
        }
        
        if showUndecidedUsers == true {
             senderID = undecidedMessages[indexPath.row].userID
             messageText = undecidedMessages[indexPath.row].message
        }
        

        
        var lastMessageSenderID = ""
        
        if showEverybody == true, indexPath.row > 0 {
            lastMessageSenderID = (everybodyMessages[previousIndex].userID)!
            messageText = (everybodyMessages[previousIndex].message)!
        }
        
        if showAnswer1Users == true, indexPath.row > 0 {
            lastMessageSenderID = (answer1Messages[previousIndex].userID)!
            messageText = (answer1Messages[previousIndex].message)!
        }
        
        if showAnswer2Users == true, indexPath.row > 0 {
            lastMessageSenderID = (answer2Messages[previousIndex].userID)!
            messageText = (answer2Messages[previousIndex].message)!
        }
        
        if showUndecidedUsers == true, indexPath.row > 0 {
            lastMessageSenderID = (undecidedMessages[previousIndex].userID)!
            messageText = (undecidedMessages[previousIndex].message)!
        }
        
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI));
        
        
        let userVoteRef = FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").child(senderID)
        let messageUserRef = FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!)
        
        var userAnswer : String = ""
        
        let myMessageCell = tableView.dequeueReusableCell(withIdentifier: "currentUserMessageCell") as! CurrentUserMessageTableViewCell
        let friendMessageCell = tableView.dequeueReusableCell(withIdentifier: "friendMessageCell") as! FriendMessageTableViewCell

        let stackedMessageCell = tableView.dequeueReusableCell(withIdentifier: "stackedMessageCell") as! StackedMessageTableViewCell
        
        stackedMessageCell.backgroundColor = UIColor.init(hexString: "F9F9F9")
        
        
        if senderID == uid {
        
        myMessageCell.backgroundColor = UIColor.init(hexString: "F9F9F9")
        
            if showEverybody == true {
                myMessageCell.messageTextView.text = everybodyMessages[indexPath.row].message
            }
            
            if showAnswer1Users == true {
                myMessageCell.messageTextView.text = answer1Messages[indexPath.row].message
            }
            
            if showAnswer2Users == true {
                myMessageCell.messageTextView.text = answer2Messages[indexPath.row].message
            }
            
            if showUndecidedUsers == true {
                myMessageCell.messageTextView.text = undecidedMessages[indexPath.row].message
            }
            
        myMessageCell.messageTextView.layer.cornerRadius = 12
        myMessageCell.messageTextView.layer.masksToBounds = true
        myMessageCell.messageTextView.textContainerInset.left = 8
        myMessageCell.messageTextView.textContainerInset.right = 8
        myMessageCell.messageTextView.textContainerInset.top = 12
        myMessageCell.messageTextView.textContainerInset.bottom = 12
            
        myMessageCell.messageTextView.widthAnchor.constraint(equalToConstant: estimateFrameForText(text: messageText).width)
            
        myMessageCell.answerIndicator.layer.cornerRadius = myMessageCell.answerIndicator.layer.frame.width / 2

        
        messageUserRef.observe(.value, with: {
            snapshot in
                
            let snapshotValue = snapshot.value as! NSDictionary
                
            userAnswer = (snapshotValue["voteString"] as? String)!
            
            if userAnswer == "answer1" {

                myMessageCell.answerIndicator.backgroundColor = UIColor.init(hexString: "#AAE65F")
                
            }
                
            if userAnswer == "answer2" {
                myMessageCell.answerIndicator.backgroundColor = UIColor.init(hexString: "#FF505A")
            }
                
            if userAnswer == "no vote" {
                myMessageCell.answerIndicator.backgroundColor = UIColor.init(hexString: "#D8D8D8")
            }
                
        })
            
    myMessageCell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
            
    return myMessageCell
            
        } else {
        
        friendMessageCell.messageTextView.layer.borderWidth = 0.2
        friendMessageCell.messageTextView.layer.borderColor = UIColor.init(hexString: "D8D8D8").cgColor
        friendMessageCell.messageTextView.layer.cornerRadius = 12
        friendMessageCell.messageTextView.layer.masksToBounds = true
        friendMessageCell.messageTextView.textContainerInset.left = 10
        friendMessageCell.messageTextView.textContainerInset.right = 5
        friendMessageCell.messageTextView.textContainerInset.top = 10
        friendMessageCell.messageTextView.textContainerInset.bottom = 10
        friendMessageCell.backgroundColor = UIColor.init(hexString: "F9F9F9")
        friendMessageCell.userImageView.layer.cornerRadius =  friendMessageCell.userImageView.layer.frame.size.width / 2
        friendMessageCell.userImageView.layer.masksToBounds = true
            
        if showEverybody == true {
        friendMessageCell.messageTextView.text = everybodyMessages[indexPath.row].message
       
        stackedMessageCell.messageTextView.text = everybodyMessages[indexPath.row].message
            
            FIRDatabase.database().reference().child("users").child(everybodyMessages[indexPath.row].userID).observe(.value, with: {
                
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                let profileImageURL = snapshotValue["profileImageURL"] as! String
                
                friendMessageCell.userImageView.sd_setImage(with: URL(string : profileImageURL))
                
            })
            
        friendMessageCell.userNameLabel.text = everybodyMessages[indexPath.row].userName
            }
            
        if showAnswer1Users == true {
            friendMessageCell.messageTextView.text = answer1Messages[indexPath.row].message
            friendMessageCell.userImageView.sd_setImage(with: URL(string : answer1Messages[indexPath.row].userImage as String))
            friendMessageCell.userNameLabel.text = answer1Messages[indexPath.row].userName
            
            stackedMessageCell.messageTextView.text = answer1Messages[indexPath.row].message
            
            }
            
        if showAnswer2Users == true {
            friendMessageCell.messageTextView.text = answer2Messages[indexPath.row].message
            friendMessageCell.userImageView.sd_setImage(with: URL(string : answer2Messages[indexPath.row].userImage as String))
            friendMessageCell.userNameLabel.text = answer2Messages[indexPath.row].userName
            
            stackedMessageCell.messageTextView.text = answer2Messages[indexPath.row].message
        }
            
        if showUndecidedUsers == true {
            friendMessageCell.messageTextView.text = undecidedMessages[indexPath.row].message
            friendMessageCell.userImageView.sd_setImage(with: URL(string : undecidedMessages[indexPath.row].userImage as String))
            friendMessageCell.userNameLabel.text = undecidedMessages[indexPath.row].userName
            
            stackedMessageCell.messageTextView.text = undecidedMessages[indexPath.row].message
        }
            
            
        friendMessageCell.messageTextView.widthAnchor.constraint(equalToConstant: estimateFrameForText(text: messageText).width)
            
        friendMessageCell.answerIndicator.layer.cornerRadius = friendMessageCell.answerIndicator.layer.frame.width / 2
          
        
        userVoteRef.observe(.value, with: {
            snapshot in
                
            let snapshotValue = snapshot.value as! NSDictionary
                
            userAnswer = (snapshotValue["voteString"] as? String)!
                
            if userAnswer == "answer1" {
                
                friendMessageCell.answerIndicator.backgroundColor = UIColor.init(hexString: "#AAE65F")
                
            }
            
            if userAnswer == "answer2" {
                friendMessageCell.answerIndicator.backgroundColor = UIColor.init(hexString: "#FF505A")
            }
            
            if userAnswer == "no vote" {
                friendMessageCell.answerIndicator.backgroundColor = UIColor.init(hexString: "#D8D8D8")
            }
                
        })
            
    
            
        friendMessageCell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
         
        if senderID == lastMessageSenderID, senderID != uid {
                stackedMessageCell.messageTextView.layer.borderWidth = 0.2
                stackedMessageCell.messageTextView.layer.borderColor = UIColor.init(hexString: "D8D8D8").cgColor
                stackedMessageCell.messageTextView.layer.cornerRadius = 12
                stackedMessageCell.messageTextView.layer.masksToBounds = true
                stackedMessageCell.messageTextView.textContainerInset.left = 10
                stackedMessageCell.messageTextView.textContainerInset.right = 5
                stackedMessageCell.messageTextView.textContainerInset.top = 10
                stackedMessageCell.messageTextView.textContainerInset.bottom = 10
                stackedMessageCell.messageTextView.widthAnchor.constraint(equalToConstant: estimateFrameForText(text: messageText).width)
                stackedMessageCell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
                return stackedMessageCell
            
        }
    
        return friendMessageCell
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if showAnswer1Users == true {
            return self.answer1Messages.count
        }
        
        if showAnswer2Users == true {
            return self.answer2Messages.count
        }
        
        
        if showUndecidedUsers == true {
            return self.undecidedMessages.count
        }
        
        return everybodyMessages.count
    }
    
    
    
    //collection view delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        
        if showAnswer1Users == true {
            return self.answer1UserIDs.count
        }
        
        if showAnswer2Users == true {
            return self.answer2UserIDs.count
        }
        
        
        if showUndecidedUsers == true {
            return self.undecidedUserIDs.count
        }
       
        return self.chatMembers.count
        
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatMemberCell", for: indexPath) as! ChatMemberCollectionViewCell
        
        let chatMemberVoteRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").child(self.chatMembers[indexPath.item].recipientID)
        let userRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users")
       
        if showEverybody == true {
            
            FIRDatabase.database().reference().child("users").child(self.chatMembers[indexPath.item].recipientID).observe(.value, with: {
                
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                let profileImageURL = snapshotValue["profileImageURL"] as! String
                
                cell.chatMemberImageView.sd_setImage(with: URL(string : profileImageURL))
                
            })
            //cell.chatMemberImageView.sd_setImage(with: URL(string : self.chatMembers[indexPath.item].imageURL1))
        
            cell.chatMemberImageView.layer.cornerRadius = cell.chatMemberImageView.layer.frame.size.width / 2
            cell.chatMemberImageView.layer.masksToBounds = true
            cell.chatMemberFirstNameLabel.text = self.chatMembers[indexPath.item].recipientName
            cell.chatMemberAnswerIndicator.layer.cornerRadius = cell.chatMemberAnswerIndicator.layer.frame.size.width / 2
        
        chatMemberVoteRef.observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary

            if snapshotValue["voteString"] as! String == "answer1" {
                
                
                cell.chatMemberAnswerIndicator.backgroundColor = UIColor.init(hexString: "#AAE65F")
            }
            
            if snapshotValue["voteString"] as! String == "answer2" {
                cell.chatMemberAnswerIndicator.backgroundColor = UIColor.init(hexString: "#FF505A")
            }
            
            if snapshotValue["voteString"] as! String == "no vote" {
                cell.chatMemberAnswerIndicator.backgroundColor = UIColor.init(hexString: "#D8D8D8")
            }
        
        })
        
        }
        
        
        
        if showAnswer1Users == true {
           
            userRef.child(answer1UserIDs[indexPath.item]).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                cell.chatMemberImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
                cell.chatMemberAnswerIndicator.backgroundColor = UIColor.init(hexString: "#AAE65F")
                cell.chatMemberFirstNameLabel.text = snapshotValue["fullName"] as! String
                
            })
            
        
        }
        
        if showAnswer2Users == true {
            
            userRef.child(answer2UserIDs[indexPath.item]).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                cell.chatMemberImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
                cell.chatMemberAnswerIndicator.backgroundColor = UIColor.init(hexString: "#FF505A")
                cell.chatMemberFirstNameLabel.text = snapshotValue["fullName"] as! String
                
            })
            
        }
        
        if showUndecidedUsers == true {
            
            userRef.child(undecidedUserIDs[indexPath.item]).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                cell.chatMemberImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
                cell.chatMemberAnswerIndicator.backgroundColor = UIColor.init(hexString: "#D8D8D8")
                cell.chatMemberFirstNameLabel.text = snapshotValue["fullName"] as! String
                
            })
            
        }
        
        
        
        return cell
        
    }
    
  
    //Hide Poll Details upon chat scroll
    
    
    
    func scrollViewDidScroll (_ scrollView: UIScrollView) {
        
        if pollViewHeightConstraint.constant == 280, scrollView == tableView {
            showHidePollViewButton.setImage(#imageLiteral(resourceName: "hide icon"), for: .normal)
            pollViewHeightConstraint.constant = 96
            questionTextLabel.isHidden = true
            answer1TextLabel.isHidden = true
            answer2TextLabel.isHidden = true
            answer1VoteCount.isHidden = true
            answer2VoteCount.isHidden = true
            greenBackgroundImageView.isHidden = true
            redBackgroundImageView.isHidden = true
            pieChartView.isHidden = true
            pieChartCenterImageView.isHidden = true
            
            
            chatMemberViewVerticalConstraint.constant = 22
            senderUserName.text = questionTextLabel.text
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        
        if pollViewHeightConstraint.constant == 0, scrollView == tableView, scrollView.scrollsToTop == true {
            
            showHidePollViewButton.setImage(#imageLiteral(resourceName: "show icon"), for: .normal)
            pollViewHeightConstraint.constant = 280
            questionTextLabel.isHidden = false
            answer1TextLabel.isHidden = false
            answer2TextLabel.isHidden = false
            answer1VoteCount.isHidden = false
            answer2VoteCount.isHidden = false
            greenBackgroundImageView.isHidden = false
            redBackgroundImageView.isHidden = false
            pieChartCenterImageView.isHidden = false
            pieChartView.isHidden = false
            
            
            chatMemberViewVerticalConstraint.constant = 213
            questionTextLabel.text = poll.questionString
            
            let senderUserRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(poll.senderUser)
            
            senderUserRef.observe(.value, with: {
                snapshot in
                
                let snapshotValue = snapshot.value as! NSDictionary
                
                self.senderUserName.text = snapshotValue["fullName"] as! String
                
                
            })
            
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
                self.view.reloadInputViews()
            }

            
        }

    }
    
    
 
    //function to determine the frame that any given amount of text would measure so we can adjust the message bubble height and width dynamically
    
    func estimateFrameForText (text : String) -> CGRect {
        
        let size = CGSize(width: 243, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont(name: "Proxima Nova", size: 20)!], context: nil)
    }
   

    @IBAction func sendButtonTapped(_ sender: Any) {
        
        print("send button tapped")
        
        if messageTextField.text != nil, viewHasAppeared == true {
            
            let everybodyMessagesRef = FIRDatabase.database().reference().child("messages").child(poll.pollID).child("messages").child("everybody")
            let answer1MessagesRef = FIRDatabase.database().reference().child("messages").child(poll.pollID).child("messages").child("answer1")
            let answer2MessagesRef = FIRDatabase.database().reference().child("messages").child(poll.pollID).child("messages").child("answer2")
            let noAnswerMessagesRef = FIRDatabase.database().reference().child("messages").child(poll.pollID).child("messages").child("noAnswer")
            
            let messagesRef = FIRDatabase.database().reference().child("polls").child(poll.pollID).child("messages")
            let uid = FIRAuth.auth()?.currentUser?.uid
            let currentUserRef = FIRDatabase.database().reference().child("users").child(uid!)
            let messageText = messageTextField.text!
            
            currentUserRef.observe(.value, with: {
            
                snapshot in
            
                let snapshotValue = snapshot.value as! NSDictionary
                
                self.userName = snapshotValue["fullName"] as! String
                self.userImage = snapshotValue["profileImageURL"] as! String
                
                if self.showEverybody == true {
                    let message = ["uid" : uid!, "userName" : self.userName, "userMessage" : messageText, "userImage": self.userImage, "conversation" : "everybody"]
                
                    
                print("everybody message")
               // messagesRef.childByAutoId().setValue(message)
                everybodyMessagesRef.childByAutoId().setValue(message)
                }
                
                if self.showUndecidedUsers == true {
                    let message = ["uid" : uid!, "userName" : self.userName, "userMessage" : messageText, "userImage": self.userImage, "conversation" : "undecided"]
                    
                    //messagesRef.childByAutoId().setValue(message)
                    noAnswerMessagesRef.childByAutoId().setValue(message)
                }
                
                if self.showAnswer1Users == true {
                    let message = ["uid" : uid!, "userName" : self.userName, "userMessage" : messageText, "userImage": self.userImage, "conversation" : "answer1"]
                    
                    //messagesRef.childByAutoId().setValue(message)
                    answer1MessagesRef.childByAutoId().setValue(message)
                }
                
                if self.showAnswer2Users == true {
                    let message = ["uid" : uid!, "userName" : self.userName, "userMessage" : messageText, "userImage": self.userImage, "conversation" : "answer2"]
                    
                    //messagesRef.childByAutoId().setValue(message)
                    answer2MessagesRef.childByAutoId().setValue(message)
                }
                
                self.messageTextField.text = ""
    
            })
            
            tableView.reloadData()
            
        }
        
        tableView.reloadData()
    }

    
    @IBAction func showHidePollButtonTapped(_ sender: Any) {
        
        expandOrCollapsePollDetails()
        
    }
    
    
    
    func pollHeaderLabelTapped (sender : UITapGestureRecognizer) {
        
        expandOrCollapsePollDetails()
        print("sender text tapped")
        
    }
    
    
    
    func expandOrCollapsePollDetails() {
        if pollViewHeightConstraint.constant == 280 {
            showHidePollViewButton.setImage(UIImage(named: "hide icon.png"), for: .normal)
            pollViewHeightConstraint.constant = 96
            questionTextLabel.isHidden = true
            answer1TextLabel.isHidden = true
            answer2TextLabel.isHidden = true
            answer1VoteCount.isHidden = true
            answer2VoteCount.isHidden = true
            greenBackgroundImageView.isHidden = true
            redBackgroundImageView.isHidden = true
            pieChartView.isHidden = true
            pieChartCenterImageView.isHidden = true
            
            
            chatMemberViewVerticalConstraint.constant = 22
            senderUserName.text = questionTextLabel.text
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
            
        else {
            showHidePollViewButton.setImage(UIImage(named: "show icon.png"), for: .normal)
            pollViewHeightConstraint.constant = 280
            questionTextLabel.isHidden = false
            answer1TextLabel.isHidden = false
            answer2TextLabel.isHidden = false
            answer1VoteCount.isHidden = false
            answer2VoteCount.isHidden = false
            greenBackgroundImageView.isHidden = false
            redBackgroundImageView.isHidden = false
            pieChartCenterImageView.isHidden = false
            pieChartView.isHidden = false
            
            
            chatMemberViewVerticalConstraint.constant = 213
            questionTextLabel.text = poll.questionString
            
            let senderUserRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(poll.senderUser)
            
            senderUserRef.observe(.value, with: {
                snapshot in
                
                let snapshotValue = snapshot.value as! NSDictionary
                
                self.senderUserName.text = snapshotValue["fullName"] as! String
                
                
            })
            
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
                self.view.reloadInputViews()
            }
        }
        
        
    }
  
    
    @IBAction func changeConversationButtonTapped(_ sender: Any) {
       
        
        if tableViewBottomConstraint.constant == 0 {
        tableViewBottomConstraint.constant = 60
        changeConversationView.isHidden = false
            
        }
        
        else {
            
            tableViewBottomConstraint.constant = 0
            changeConversationView.isHidden = true
            
            
        }
        
        if showAnswer1Users == true {
            changeChatButton.imageView?.image = UIImage(named: "Answer 1 Conversation Icon (Active)")
        }
        
        if showAnswer2Users == true {
            changeChatButton.imageView?.image = UIImage(named: "Answer 2 Conversation (Active)")
        }
        
        if showUndecidedUsers == true {
            changeChatButton.imageView?.image = UIImage(named: "Undecided Conversation (Active)")
        }
        
        UIView.animate(withDuration: 0.2) {
             self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func changeConversationPosition1ButtonTapped(_ sender: Any) {

        showEverybody = false
        showAnswer2Users = false
        showUndecidedUsers = false
        showAnswer1Users = true
        changeChatButton.imageView?.image = UIImage(named: "Answer 1 Conversation Icon (Active)")
        collectionView.reloadData()
        tableView.reloadData()
        
        tableViewBottomConstraint.constant = 0
        changeConversationView.isHidden = true
        
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha = 0
            self.collectionView.alpha = 0
            self.tableView.alpha = 1
            self.collectionView.alpha = 1
            
        }
        
        
    }

    
    @IBAction func changeConversationPosition2ButtonTapped(_ sender: Any) {
        showEverybody = false
        showUndecidedUsers = false
        showAnswer1Users = false
        showAnswer2Users = true
        changeChatButton.imageView?.image = UIImage(named: "Answer 2 Conversation (Active)")
        collectionView.reloadData()
        tableView.reloadData()
        
        tableViewBottomConstraint.constant = 0
        changeConversationView.isHidden = true
        
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha = 0
            self.collectionView.alpha = 0
            self.tableView.alpha = 1
            self.collectionView.alpha = 1
        }
        
    }
    

    
    @IBAction func changeConversationPosition0ButtonTapped(_ sender: Any) {
        showAnswer1Users = false
        showAnswer2Users = false
        showUndecidedUsers = false
        showEverybody = true
        changeChatButton.imageView?.image = UIImage(named: "Everybody Conversation (Active)")
        collectionView.reloadData()
        tableView.reloadData()
        
        tableViewBottomConstraint.constant = 0
        changeConversationView.isHidden = true
        
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha = 0
            self.collectionView.alpha = 0
            self.tableView.alpha = 1
            self.collectionView.alpha = 1
            
        }
        
    }
    

    
    func captureView() -> UIImage {
        
        UIGraphicsBeginImageContext(pollView.frame.size)
        pollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(img!, nil, nil, nil)
        return img!
    }
  
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        sendButton.isEnabled = true
        sendButton.isUserInteractionEnabled = true
        sendButton.alpha = 1.0
        
        if pollViewHeightConstraint.constant == 280 {
            showHidePollViewButton.setImage(UIImage(named: "hide icon.png"), for: .normal)
            pollViewHeightConstraint.constant = 96
            questionTextLabel.isHidden = true
            answer1TextLabel.isHidden = true
            answer2TextLabel.isHidden = true
            answer1VoteCount.isHidden = true
            answer2VoteCount.isHidden = true
            greenBackgroundImageView.isHidden = true
            redBackgroundImageView.isHidden = true
            pieChartView.isHidden = true
            pieChartCenterImageView.isHidden = true
            
            
            chatMemberViewVerticalConstraint.constant = 22
            senderUserName.text = questionTextLabel.text
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func hideKeyboard () {
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func isSenderID (currentUserIDString :String) -> Bool {
        if currentUserIDString == senderUser.uID {
            return true
        } else {
            return false
        }
    }
    

}
