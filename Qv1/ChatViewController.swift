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

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pollView: UIView!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var sendViewBottomConstraint: NSLayoutConstraint!
    
    var currentUsers : [Recipient] = []
    var userName = ""
    var userImage = ""
    var poll : Poll = Poll()
    var kbHeight = 0
    
    struct message {
        let userName : String!
        var userID : String!
        let message : String!
        let userImage : String!
    }
    
    var messages : [message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        messageTextField.delegate = self
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.init(hexString: "F9F9F9")

        
        questionText.text = poll.questionString
        
        print(currentUsers.count)
        print(poll.pollID)
        
        let databaseRef : FIRDatabaseReference = FIRDatabase.database().reference()
        
        databaseRef.child("polls").child(poll.pollID).child("messages").observe(.childAdded, with: {
            
            snapshot in
        
            let snapshotValue = snapshot.value as! NSDictionary
        
            let userName = snapshotValue["userName"] as! String
            let userImage = snapshotValue["userImage"] as! String
            let userID = snapshotValue["uid"] as! String
            let messageBody = snapshotValue["userMessage"] as! String
            
            self.messages.insert(message(userName: userName , userID: userID, message: messageBody, userImage: userImage ), at: 0)
            
            self.tableView.reloadData()
            
            print(self.messages.count)
        })
       
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
   
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let uid = FIRAuth.auth()?.currentUser?.uid
        let senderID = messages[indexPath.row].userID
        
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI));
        
        
        let userVoteRef = FIRDatabase.database().reference().child("users").child(senderID!)
        let messageUserRef = FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes")
        
        var userAnswer : String = ""
        
        let myMessageCell = tableView.dequeueReusableCell(withIdentifier: "currentUserMessageCell") as! CurrentUserMessageTableViewCell
        let friendMessageCell = tableView.dequeueReusableCell(withIdentifier: "friendMessageCell") as! FriendMessageTableViewCell

        if senderID == uid {
        
        myMessageCell.backgroundColor = UIColor.init(hexString: "F9F9F9")
        myMessageCell.currentUserImage.layer.cornerRadius =  myMessageCell.currentUserImage.layer.frame.size.width / 2
        myMessageCell.currentUserImage.layer.masksToBounds = true
    
        myMessageCell.messageTextView.text = messages[indexPath.row].message
        myMessageCell.messageTextView.layer.cornerRadius = 15
        myMessageCell.messageTextView.layer.masksToBounds = true
        myMessageCell.messageTextView.textContainerInset.left = 8
        myMessageCell.messageTextView.textContainerInset.right = 8
        myMessageCell.messageTextView.textContainerInset.top = 8
        myMessageCell.messageTextView.textContainerInset.bottom = 8
            
        myMessageCell.currentUserImage.sd_setImage(with: URL(string : messages[indexPath.row].userImage as String))
        myMessageCell.currentUserName.text = messages[indexPath.row].userName
        
        
        
            
        
        messageUserRef.observe(.value, with: {
            snapshot in
                
            let snapshotValue = snapshot.value as! NSDictionary
                
            userAnswer = (snapshotValue[FIRAuth.auth()?.currentUser?.uid] as? String)!
            
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
        
        friendMessageCell.messageTextView.layer.borderWidth = 0.1
        friendMessageCell.messageTextView.layer.cornerRadius = 15
        friendMessageCell.messageTextView.layer.masksToBounds = true
        friendMessageCell.backgroundColor = UIColor.init(hexString: "F9F9F9")
        friendMessageCell.userImageView.layer.cornerRadius =  myMessageCell.currentUserImage.layer.frame.size.width / 2
        friendMessageCell.userImageView.layer.masksToBounds = true
            
        friendMessageCell.messageTextView.text = messages[indexPath.row].message
        friendMessageCell.userImageView.sd_setImage(with: URL(string : messages[indexPath.row].userImage as String))
        friendMessageCell.userNameLabel.text = messages[indexPath.row].userName
            
            messageUserRef.observe(.value, with: {
                snapshot in
                
                let snapshotValue = snapshot.value as! NSDictionary
                
                userAnswer = (snapshotValue[senderID] as? String)!
                
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
        return messages.count
    }
    
 
    
    func animateTextFieldView(up: Bool) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.sendViewBottomConstraint.constant = CGFloat(self.kbHeight)
        })
    }
    
    
    func deAnimateTextFieldView(up: Bool) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.sendViewBottomConstraint.constant = 0
        })
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
                let message = ["uid" : uid!, "userName" : self.userName, "userMessage" : messageText, "userImage": self.userImage]
                
                messagesRef.childByAutoId().setValue(message)
                
    
            })
            
        }
        
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        sendButton.isEnabled = true
        sendButton.isUserInteractionEnabled = true
        sendButton.alpha = 1.0
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
