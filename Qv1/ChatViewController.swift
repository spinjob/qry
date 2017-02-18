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
    
    @IBOutlet weak var position3ChangeConversationButton: UIButton!
    
    @IBOutlet weak var position0ChangeConversationButton: UIButton!

    @IBOutlet weak var position0ChangeConversationLabel: UILabel!
    
    @IBOutlet weak var position1ChangeConversationLabel: UILabel!
    
    @IBOutlet weak var position2ChangeConversationLabel: UILabel!
    
    @IBOutlet weak var position3ChangeConversationLabel: UILabel!
    
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
    var showEverybody : Bool = true
    
    struct message {
        let userName : String!
        var userID : String!
        let message : String!
        let userImage : String!
    }
    
    var messages : [message] = []
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
        
        changeChatButton.imageView?.image = UIImage(named: "Everybody Active Conversation (Active)")
        
        if showAnswer1Users == true {
           changeChatButton.imageView?.image = UIImage(named: "Answer 1 Conversation Icon (Active).png")
        }
        
        if showAnswer2Users == true {
            changeChatButton.imageView?.image = UIImage(named: "Answer 2 Conversation (Active).png")
        }
        
        if showUndecidedUsers == true {
            changeChatButton.imageView?.image = UIImage(named: "Undecided Conversation (Active).png")
        }
        

        
        databaseRef.child("polls").child(poll.pollID).child("messages").queryOrdered(byChild: "conversation").queryEqual(toValue: "everybody").observe(.childAdded, with: {
            
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let userName = snapshotValue["userName"] as! String
            let userImage = snapshotValue["userImage"] as! String
            let userID = snapshotValue["uid"] as! String
            let messageBody = snapshotValue["userMessage"] as! String
            
            self.everybodyMessages.insert(message(userName: userName , userID: userID, message: messageBody, userImage: userImage ), at: 0)
            
        })
        
        databaseRef.child("polls").child(poll.pollID).child("messages").queryOrdered(byChild: "conversation").queryEqual(toValue: "answer1").observe(.childAdded, with: {
            
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let userName = snapshotValue["userName"] as! String
            let userImage = snapshotValue["userImage"] as! String
            let userID = snapshotValue["uid"] as! String
            let messageBody = snapshotValue["userMessage"] as! String
            
            self.answer1Messages.insert(message(userName: userName , userID: userID, message: messageBody, userImage: userImage ), at: 0)
            
        })
        
        
        databaseRef.child("polls").child(poll.pollID).child("messages").queryOrdered(byChild: "conversation").queryEqual(toValue: "answer2").observe(.childAdded, with: {
            
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let userName = snapshotValue["userName"] as! String
            let userImage = snapshotValue["userImage"] as! String
            let userID = snapshotValue["uid"] as! String
            let messageBody = snapshotValue["userMessage"] as! String
            
            self.answer2Messages.insert(message(userName: userName , userID: userID, message: messageBody, userImage: userImage ), at: 0)
            
        })
        
        databaseRef.child("polls").child(poll.pollID).child("messages").queryOrdered(byChild: "conversation").queryEqual(toValue: "undecided").observe(.childAdded, with: {
            
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let userName = snapshotValue["userName"] as! String
            let userImage = snapshotValue["userImage"] as! String
            let userID = snapshotValue["uid"] as! String
            let messageBody = snapshotValue["userMessage"] as! String
            
            self.undecidedMessages.insert(message(userName: userName , userID: userID, message: messageBody, userImage: userImage ), at: 0)
            
        })
        

        
        databaseRef.child("polls").child(poll.pollID).child("messages").observe(.childAdded, with: {
            
            snapshot in
        
            let snapshotValue = snapshot.value as! NSDictionary
        
            let userName = snapshotValue["userName"] as! String
            let userImage = snapshotValue["userImage"] as! String
            let userID = snapshotValue["uid"] as! String
            let messageBody = snapshotValue["userMessage"] as! String
            let conversation = snapshotValue["conversation"] as! String
            
            self.messages.insert(message(userName: userName , userID: userID, message: messageBody, userImage: userImage ), at: 0)
            
            self.tableView.reloadData()
        
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
                self.position3ChangeConversationLabel.isHidden = true
                self.position2ChangeConversationButton.isHidden = true
                self.position3ChangeConversationButton.isHidden = true
                
            }
            
            if userAnswer == "no vote" {
                self.position2ChangeConversationLabel.isHidden = true
                self.position1ChangeConversationLabel.isHidden = true
                self.position2ChangeConversationButton.isHidden = true
                self.position1ChangeConversationButton.isHidden = true
                
            }
            
            if userAnswer == "answer2" {
                self.position1ChangeConversationLabel.isHidden = true
                self.position3ChangeConversationLabel.isHidden = true
                self.position3ChangeConversationButton.isHidden = true
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
            
        })
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
            snapshot in
            
            self.answer2Count = Int(snapshot.childrenCount)
            
        })
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "no vote").observe(.value, with: {
            snapshot in
            
            self.undecidedCount = Int(snapshot.childrenCount)
            
        })
        

        chartView.frame = CGRect(x: 0, y: 0, width: pieChartView.frame.size.width, height: 86)
        pieChartCenterImageView.layer.cornerRadius = pieChartCenterImageView.layer.frame.size.width / 2
        pieChartCenterImageView.layer.masksToBounds = true
        
        chartView.segments = [

            Segment(color: UIColor.init(hexString: "A8E855"), value: CGFloat(self.answer1Count)),
            Segment(color: UIColor.init(hexString: "FF4E56"), value: CGFloat(answer2Count)),
            Segment(color: UIColor.init(hexString: "D8D8D8"), value: CGFloat(undecidedCount))
        ]
        
        pieChartView.addSubview(chartView)
    }

    
   override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        super.reloadInputViews()
  
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        
        if showEverybody == true {
            senderID = everybodyMessages[indexPath.row].userID
        }
        
        if showAnswer1Users == true {
            senderID = answer1Messages[indexPath.row].userID
        }
        
        if showAnswer2Users == true {
            senderID = answer2Messages[indexPath.row].userID
        }
        
        if showUndecidedUsers == true {
             senderID = undecidedMessages[indexPath.row].userID
        }
        
        
        let messageText = messages[indexPath.row].message
        
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI));
        
        
        let userVoteRef = FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").child(senderID)
        let messageUserRef = FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!)
        
        var userAnswer : String = ""
        
        let myMessageCell = tableView.dequeueReusableCell(withIdentifier: "currentUserMessageCell") as! CurrentUserMessageTableViewCell
        let friendMessageCell = tableView.dequeueReusableCell(withIdentifier: "friendMessageCell") as! FriendMessageTableViewCell

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
            
        myMessageCell.messageTextView.layer.cornerRadius = 6
        myMessageCell.messageTextView.layer.masksToBounds = true
        myMessageCell.messageTextView.textContainerInset.left = 8
        myMessageCell.messageTextView.textContainerInset.right = 8
        myMessageCell.messageTextView.textContainerInset.top = 12
        myMessageCell.messageTextView.textContainerInset.bottom = 12
            
        myMessageCell.messageTextView.widthAnchor.constraint(equalToConstant: estimateFrameForText(text: messageText!).width)

        
        messageUserRef.observe(.value, with: {
            snapshot in
                
            let snapshotValue = snapshot.value as! NSDictionary
                
            userAnswer = (snapshotValue["voteString"] as? String)!
            
            if userAnswer == "answer1" {
                myMessageCell.answerIndicator.image = UIImage(named: "green answer.png")
            }
                
            if userAnswer == "answer2" {
                myMessageCell.answerIndicator.image = UIImage(named: "red answer.png")
            }
                
            if userAnswer == "no vote" {
                myMessageCell.answerIndicator.image = UIImage(named: "grey answer.png")
            }
                
        })
            
    myMessageCell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
            
    return myMessageCell
            
        } else {
        
        friendMessageCell.messageTextView.layer.borderWidth = 0.2
        friendMessageCell.messageTextView.layer.borderColor = UIColor.init(hexString: "D8D8D8").cgColor
        friendMessageCell.messageTextView.layer.cornerRadius = 6
        friendMessageCell.messageTextView.layer.masksToBounds = true
        friendMessageCell.messageTextView.textContainerInset.left = 12
        friendMessageCell.messageTextView.textContainerInset.right = 5
        friendMessageCell.messageTextView.textContainerInset.top = 10
        friendMessageCell.messageTextView.textContainerInset.bottom = 10
        friendMessageCell.backgroundColor = UIColor.init(hexString: "F9F9F9")
        friendMessageCell.userImageView.layer.cornerRadius =  friendMessageCell.userImageView.layer.frame.size.width / 2
        friendMessageCell.userImageView.layer.masksToBounds = true
            
        if showEverybody == true {
        friendMessageCell.messageTextView.text = everybodyMessages[indexPath.row].message
        //friendMessageCell.userImageView.sd_setImage(with: URL(string : everybodyMessages[indexPath.row].userImage as String))
            
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
            }
            
        if showAnswer2Users == true {
            friendMessageCell.messageTextView.text = answer2Messages[indexPath.row].message
            friendMessageCell.userImageView.sd_setImage(with: URL(string : answer2Messages[indexPath.row].userImage as String))
            friendMessageCell.userNameLabel.text = answer2Messages[indexPath.row].userName
        }
            
        if showUndecidedUsers == true {
            friendMessageCell.messageTextView.text = undecidedMessages[indexPath.row].message
            friendMessageCell.userImageView.sd_setImage(with: URL(string : undecidedMessages[indexPath.row].userImage as String))
            friendMessageCell.userNameLabel.text = undecidedMessages[indexPath.row].userName
        }
            
            
        friendMessageCell.messageTextView.widthAnchor.constraint(equalToConstant: estimateFrameForText(text: messageText!).width)
            
        userVoteRef.observe(.value, with: {
            snapshot in
                
            let snapshotValue = snapshot.value as! NSDictionary
                
            userAnswer = (snapshotValue["voteString"] as? String)!
                
            if userAnswer == "answer1" {
                friendMessageCell.answerIndicator.image = UIImage(named: "green answer.png")
            }
                
            if userAnswer == "answer2" {
                friendMessageCell.answerIndicator.image = UIImage(named: "red answer.png")
            }
                
            if userAnswer == "no vote" {
                friendMessageCell.answerIndicator.image = UIImage(named: "grey answer.png")
            }
                
        })
            
        friendMessageCell.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
            
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
        
        chatMemberVoteRef.observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary

            if snapshotValue["voteString"] as! String == "answer1" {
                cell.chatMemberAnswerIndicator.image = UIImage(named: "green answer.png")
            }
            
            if snapshotValue["voteString"] as! String == "answer2" {
                cell.chatMemberAnswerIndicator.image = UIImage(named: "red answer.png")
            }
            
            if snapshotValue["voteString"] as! String == "no vote" {
                cell.chatMemberAnswerIndicator.image = UIImage(named: "grey answer.png")
            }
        
        })
        
        }
        
        
        
        if showAnswer1Users == true {
           
            userRef.child(answer1UserIDs[indexPath.item]).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                cell.chatMemberImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
                cell.chatMemberAnswerIndicator.image = UIImage(named: "green answer.png")
                cell.chatMemberFirstNameLabel.text = snapshotValue["fullName"] as! String
                
            })
            
        
        }
        
        if showAnswer2Users == true {
            
            userRef.child(answer2UserIDs[indexPath.item]).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                cell.chatMemberImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
                cell.chatMemberAnswerIndicator.image = UIImage(named: "red answer.png")
                cell.chatMemberFirstNameLabel.text = snapshotValue["fullName"] as! String
                
            })
            
        }
        
        if showUndecidedUsers == true {
            
            userRef.child(undecidedUserIDs[indexPath.item]).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                cell.chatMemberImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
                cell.chatMemberAnswerIndicator.image = UIImage(named: "grey answer.png")
                cell.chatMemberFirstNameLabel.text = snapshotValue["fullName"] as! String
                
            })
            
        }
        
        
        
        return cell
        
    }
    
  
    //Hide Poll Details upon chat scroll
    
    
    
    func scrollViewDidScroll (_ scrollView: UIScrollView) {
        
        if pollViewHeightConstraint.constant == 280, scrollView == tableView {
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
        
        
        if pollViewHeightConstraint.constant == 0, scrollView == tableView, scrollView.scrollsToTop == true {
            
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
    
    
 
    //function to determine the frame that any given amount of text would measure so we can adjust the message bubble height and width dynamically
    
    func estimateFrameForText (text : String) -> CGRect {
        
        let size = CGSize(width: 243, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont(name: "Proxima Nova", size: 20)!], context: nil)
    }
    
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        if messageTextField.text != nil {
            
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
                
                messagesRef.childByAutoId().setValue(message)
                }
                
                if self.showUndecidedUsers == true {
                    let message = ["uid" : uid!, "userName" : self.userName, "userMessage" : messageText, "userImage": self.userImage, "conversation" : "undecided"]
                    
                    messagesRef.childByAutoId().setValue(message)
                }
                
                if self.showAnswer1Users == true {
                    let message = ["uid" : uid!, "userName" : self.userName, "userMessage" : messageText, "userImage": self.userImage, "conversation" : "answer1"]
                    
                    messagesRef.childByAutoId().setValue(message)
                }
                
                if self.showAnswer2Users == true {
                    let message = ["uid" : uid!, "userName" : self.userName, "userMessage" : messageText, "userImage": self.userImage, "conversation" : "answer2"]
                    
                    messagesRef.childByAutoId().setValue(message)
                }
                
                self.messageTextField.text = ""
    
            })
            
            tableView.reloadData()
            
        }
        
       // tableView.reloadData()
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
            changeChatButton.imageView?.image = UIImage(named: "Answer 1 Conversation Icon (Active).png")
        }
        
        if showAnswer2Users == true {
            changeChatButton.imageView?.image = UIImage(named: "Answer 2 Conversation (Active).png")
        }
        
        if showUndecidedUsers == true {
            changeChatButton.imageView?.image = UIImage(named: "Undecided Conversation (Active).png")
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
        changeChatButton.imageView?.image = UIImage(named: "Answer 1 Conversation Icon (Active).png")
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
        changeChatButton.imageView?.image = UIImage(named: "Answer 2 Conversation (Active).png")
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
    

    @IBAction func changeConversationPosition3ButtonTapped(_ sender: Any) {
        showEverybody = false
        showAnswer1Users = false
        showAnswer2Users = false
        showUndecidedUsers = true
        changeChatButton.imageView?.image = UIImage(named: "Undecided Conversation (Active).png")
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
        changeChatButton.imageView?.image = UIImage(named: "Everybody Conversation (Active).png")
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
