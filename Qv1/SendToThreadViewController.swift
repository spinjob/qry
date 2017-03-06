//
//  SendToThreadViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/28/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SendToThreadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var askEverybodyButton: UIButton!
    
    @IBOutlet weak var askAnswer1GroupButton: UIButton!
    
    @IBOutlet weak var askAnswer2GroupButton: UIButton!
    
    @IBOutlet weak var askNoAnswerGroupButton: UIButton!
    
    @IBOutlet weak var startNewGroupHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pollQuestionLabel: UILabel!
    
    
    var pollID = ""
    var parentPollID = ""
    var parentThreadID = ""

    
    var sectionTitles : [String] = [""]
    
    var dictPoll : [NSObject : AnyObject] = [:]
    var currentUserRecipientDict : [NSObject : AnyObject] = [:]
    var currentUserVoterDict : [NSObject : AnyObject] = [:]
    
    var questionString = ""
    var answer1String = ""
    var answer2String = ""
    var answer1Group : [Recipient] = []
    var answer2Group : [Recipient] = []
    var noanswerGroup : [Recipient] = []
    
    var pollsInThread : [Poll] = []
    
    var questionImageURL : String = ""
    
    var selectedRecipients : [Recipient] = []
    var selectedUserCells : [ThreadAnswerGroupUserTableViewCell] = []
    
    let brightGreen = UIColor.init(hexString: "A8E855")
    let red = UIColor.init(hexString: "FF4E56")
    let actionGreen = UIColor.init(hexString: "00D1D5")
    let blue = UIColor.init(hexString: "004488")
    let grey = UIColor.init(hexString: "D8D8D8")
    
    let currentUserRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
    
    @IBOutlet weak var startNewGroupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("POLL TO SEND \(dictPoll)")
        let allGroups = answer1Group + answer2Group + noanswerGroup
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        askEverybodyButton.layer.cornerRadius = 4
        askEverybodyButton.layer.masksToBounds = true
        //askEverybodyButton.layer.borderWidth = 0.4
        askEverybodyButton.layer.borderColor = actionGreen.cgColor
        
        askAnswer1GroupButton.setTitle("Add group that said \(answer1String)", for: .normal)
        askAnswer1GroupButton.layer.cornerRadius = 4
        askAnswer1GroupButton.layer.masksToBounds = true
       // askAnswer1GroupButton.layer.borderWidth = 0.4
        askAnswer1GroupButton.layer.borderColor = actionGreen.cgColor
        
        askAnswer2GroupButton.setTitle("Add group that said \(answer2String)", for: .normal)
        askAnswer2GroupButton.layer.cornerRadius = 4
        askAnswer2GroupButton.layer.masksToBounds = true
       // askAnswer2GroupButton.layer.borderWidth = 0.4
        askAnswer2GroupButton.layer.borderColor = actionGreen.cgColor
        
        askNoAnswerGroupButton.layer.cornerRadius = 4
        askNoAnswerGroupButton.layer.masksToBounds = true
        //askNoAnswerGroupButton.layer.borderWidth = 0.4
        askNoAnswerGroupButton.layer.borderColor = actionGreen.cgColor
        
        pollQuestionLabel.text = questionString
        
        
        let pollRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("polls").child(pollID)
        let pollVoteRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("polls").child(parentPollID).child("votes")
    
        FIRDatabase.database().reference().child("threads").child(parentThreadID).observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            
            let poll : Poll = Poll()
    
            poll.answer1String = snapshotValue["answer1"] as! String
            poll.answer2String = snapshotValue["answer2"] as! String
            poll.questionString = snapshotValue["question"] as! String
            poll.senderUser = snapshotValue["senderUser"] as! String
            poll.pollID = snapshot.key
            poll.dateExpired = snapshotValue["expirationDate"] as! String
            poll.dateCreated = snapshotValue["dateCreated"] as! String
            
            let formatter = DateFormatter()
            let calendar = Calendar.current
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            poll.createdDate = formatter.date(from: poll.dateCreated)!
            
            self.pollsInThread.append(poll)
            self.pollsInThread = self.pollsInThread.sorted(by: {$0.createdDate < $1.createdDate})
        
        })
        
        
        pollVoteRef.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let answer1GroupMember : Recipient = Recipient()
            answer1GroupMember.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            answer1GroupMember.recipientID = snapshotValue["recipientID"] as! String
            answer1GroupMember.recipientName = snapshotValue["recipientName"] as! String
            
            self.answer1Group.append(answer1GroupMember)
            print("Answer 1 Group \(self.answer1Group)")
            self.tableView.reloadData()
            
        })
        
        pollVoteRef.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let answer2GroupMember : Recipient = Recipient()
            answer2GroupMember.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            answer2GroupMember.recipientID = snapshotValue["recipientID"] as! String
            answer2GroupMember.recipientName = snapshotValue["recipientName"] as! String
            
            self.answer2Group.append(answer2GroupMember)
            print("Answer 2 Group \(self.answer2Group)")
            self.tableView.reloadData()
            
        })
        
        pollVoteRef.queryOrdered(byChild: "voteString").queryEqual(toValue: "no vote").observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let noAnswerGroupMember : Recipient = Recipient()
            noAnswerGroupMember.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            noAnswerGroupMember.recipientID = snapshotValue["recipientID"] as! String
            noAnswerGroupMember.recipientName = snapshotValue["recipientName"] as! String
            
            self.noanswerGroup.append(noAnswerGroupMember)
            print("No Answer Group \(self.noanswerGroup)")
            self.tableView.reloadData()
            
        })
        
        
        currentUserRef.observe(.value, with: {
            
            snapshot in
            let recipient = Recipient()
            let snapshotValue = snapshot.value as! NSDictionary
            recipient.recipientName = snapshotValue["fullName"] as! String
            recipient.imageURL1 = snapshotValue["profileImageURL"] as! String
            recipient.recipientID = snapshotValue["uID"] as! String
            
            
            
            self.currentUserRecipientDict = ["recipientName" as NSObject: (recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (recipient.recipientID) as AnyObject, "tag" as NSObject: "user" as AnyObject, "hasLeft" as NSObject: "0" as AnyObject]
            
            self.currentUserVoterDict = ["recipientName" as NSObject: (recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (recipient.recipientID) as AnyObject, "voteString" as NSObject: "no vote" as AnyObject]
            
            
            
        })

        

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedRecipients.count
        
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        
//        return self.sectionTitles.count
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
//    {
//    
//        return 0
//    }
//    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
        
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let userForCell = selectedRecipients[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "answerGroupMember") as! ThreadAnswerGroupUserTableViewCell
        
        cell.answerGroupMemberImageView.layer.cornerRadius = cell.answerGroupMemberImageView.layer.frame.width / 2
        cell.answerGroupMemberImageView.layer.masksToBounds = true
        cell.answerGroupMemberImageView.sd_setImage(with: URL(string: userForCell.imageURL1))
        cell.answerGroupMemberNameLabel.text = userForCell.recipientName
        cell.selectAnswerGroupMemberButton.layer.cornerRadius = cell.selectAnswerGroupMemberButton.layer.frame.width / 2
        cell.selectAnswerGroupMemberButton.layer.masksToBounds = true
        
        
        if selectedRecipients.count == 0 {
            
            startNewGroupHeightConstraint.constant = 0
        }
    

        return cell
        
        
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        
//        return self.sectionTitles[section]
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let view = tableView.dequeueReusableCell(withIdentifier: "answerGroupHeader") as! ThreadAnswerGroupHeaderTableViewCell
//        
//        view.answerStringLabel.text = self.sectionTitles[section]
//        view.selectAnswerGroupButton.layer.cornerRadius = view.selectAnswerGroupButton.layer.frame.width / 2
//        view.selectAnswerGroupButton.layer.backgroundColor = UIColor.white.cgColor
//        view.selectAnswerGroupButton.layer.borderWidth = 0.2
//        view.selectAnswerGroupButton.setTitle("+", for: .normal)
//        view.selectAnswerGroupButton.layer.masksToBounds = true
//        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.headerViewTapped(sender:)))
//        view.selectAnswerGroupButton.addGestureRecognizer(viewTapGesture)
//        
//        view.selectAnswerGroupButton.tag = section
//        view.isUserInteractionEnabled = true
//        //view.backgroundColor = grey
//        
//        if section == 2 {
//            view.staticAnsweredLabel.text = "DIDN'T ANSWER"
//            view.answerStringLabel.isHidden = true
//        }
//
//        return view
//        
//    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let items = [answer1Group, answer2Group, noanswerGroup]
//        let selectedCell = tableView.cellForRow(at: indexPath)! as! ThreadAnswerGroupUserTableViewCell
//        selectedCell.contentView.backgroundColor = UIColor.white
//
//        let selectedRecipient = items[indexPath.section][indexPath.row]
//        selectedRecipients.append(selectedRecipient)
//        selectedUserCells.append(selectedCell)
//        
//        selectedCell.selectAnswerGroupMemberButton.setTitle("✓", for: .normal)
//        selectedCell.selectAnswerGroupMemberButton.setTitleColor(UIColor.white, for: .normal)
//        selectedCell.selectAnswerGroupMemberButton.backgroundColor = actionGreen
//
//        
//        if selectedUserCells.count > 1 {
//        
//        }
//        
//    
//        if selectedRecipients.count > 0 {
//    
//        }
//    
//        if selectedRecipients.count == 1 {
// 
//        }
//    
//    
//        UIView.animate(withDuration: 0.1) {
//            self.view.layoutIfNeeded()
//        }
//            print(selectedRecipients)
//
//    }
    
//    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        
//        let deSelectedCell = tableView.cellForRow(at: indexPath)! as! ThreadAnswerGroupUserTableViewCell
//        
//        let items = [answer1Group, answer2Group, noanswerGroup]
//        
//        let deSelectedRecipient = items[indexPath.section][indexPath.row]
//        
//        removeCell(cell: deSelectedCell)
//        delete(recipient: deSelectedRecipient)
//        
//        deSelectedCell.selectAnswerGroupMemberButton.setTitle("+", for: .normal)
//        deSelectedCell.selectAnswerGroupMemberButton.setTitleColor(grey, for: .normal)
//        deSelectedCell.selectAnswerGroupMemberButton.backgroundColor = UIColor.white
//            
//        if selectedRecipients.count < 2 {
//           
//                
//        }
//    }
//    
//    func removeCell (cell: UITableViewCell) {
//        
//        selectedUserCells = selectedUserCells.filter() {$0 !== cell}
//    }
//    
//    func delete(recipient: Recipient) {
//        selectedRecipients = selectedRecipients.filter() {$0 !== recipient}
//    }
//    
//    func headerViewTapped (sender: UITapGestureRecognizer) {
//        let section = (sender.view?.tag)!
//        let totalRows = tableView.numberOfRows(inSection: section)
//        
//        for row in 0..<totalRows {
//            
//            let indexPath = IndexPath(row: row, section: section )
//        
//            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
//        }
//    }

    
    @IBAction func askEverybodyButtonTapped(_ sender: Any) {

        
        print(selectedRecipients)
        
        
        if selectedRecipients.count == 0 {
            startNewGroupHeightConstraint.constant = 0
        }
        
        
        if askEverybodyButton.backgroundColor == actionGreen {
            
            selectedRecipients.removeAll()

            askEverybodyButton.setTitle("Added entire group", for: .normal)
            askEverybodyButton.setTitleColor(actionGreen, for: .normal)
            askEverybodyButton.layer.backgroundColor = UIColor.white.cgColor
        
            
            askAnswer1GroupButton.alpha = 0.5
            askAnswer1GroupButton.isEnabled = false
            
            askAnswer2GroupButton.alpha = 0.5
            askAnswer2GroupButton.isEnabled = false
            
            askNoAnswerGroupButton.alpha = 0.5
            askNoAnswerGroupButton.isEnabled = false
            
            selectedRecipients = answer1Group + answer2Group + noanswerGroup
            
            startNewGroupHeightConstraint.constant = 50
            
            tableView.reloadData()
        } else {
            
            askEverybodyButton.isSelected = false
            askEverybodyButton.setTitle("Add entire group", for: .normal)
            askEverybodyButton.setTitleColor(UIColor.white, for: .normal)
            askEverybodyButton.backgroundColor = actionGreen
            
            askAnswer1GroupButton.alpha = 1
            askAnswer1GroupButton.isEnabled = true
            askAnswer1GroupButton.backgroundColor = actionGreen
            askAnswer1GroupButton.setTitleColor(UIColor.white, for: .normal)
            askAnswer1GroupButton.setTitle("Add group that said \(answer1String)", for: .normal)
            
            askAnswer2GroupButton.alpha = 1
            askAnswer2GroupButton.isEnabled = true
            askAnswer2GroupButton.backgroundColor = actionGreen
            askAnswer2GroupButton.setTitleColor(UIColor.white, for: .normal)
            askAnswer2GroupButton.setTitle("Add group that said \(answer2String)", for: .normal)
            
            askNoAnswerGroupButton.alpha = 1
            askNoAnswerGroupButton.isEnabled = true
            askNoAnswerGroupButton.backgroundColor = actionGreen
            askNoAnswerGroupButton.setTitleColor(UIColor.white, for: .normal)
            askNoAnswerGroupButton.setTitle("Add group that didn't answer", for: .normal)
            
            startNewGroupHeightConstraint.constant = 0
            
            selectedRecipients.removeAll()
            
            tableView.reloadData()
            
            
        }
        
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
 
        
        
    }
    
    
    @IBAction func askAnswer1GroupButtonTapped(_ sender: Any) {
        
        print(selectedRecipients)
        
        
        if selectedRecipients.count == 0 {
            startNewGroupHeightConstraint.constant = 0
        }
        
        
        if askAnswer1GroupButton.backgroundColor == actionGreen {
        
            
            //askAnswer1GroupButton.isSelected = true
            askAnswer1GroupButton.setTitle("Added group that said \(answer1String)", for: .normal)
            askAnswer1GroupButton.setTitleColor(actionGreen, for: .normal)
            askAnswer1GroupButton.layer.backgroundColor = UIColor.white.cgColor
            
            selectedRecipients = selectedRecipients + answer1Group
            
            startNewGroupHeightConstraint.constant = 50
      
            
            tableView.reloadData()
        } else  {
            
            askAnswer1GroupButton.isSelected = false
            askAnswer1GroupButton.setTitle("Add group that said \(answer1String)", for: .normal)
            askAnswer1GroupButton.setTitleColor(UIColor.white, for: .normal)
            askAnswer1GroupButton.backgroundColor = actionGreen
            
            answer1Group.forEach { (Recipient) in
               delete(recipient: Recipient)
            }
            
            tableView.reloadData()
            
            
            print(selectedRecipients)
        }
        
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
        
        
        
    }
    
    @IBAction func askAnswer2GroupButtonTapped(_ sender: Any) {
      
        print(selectedRecipients)
        
        if selectedRecipients.count == 0 {
            startNewGroupHeightConstraint.constant = 0
        }
        
        if askAnswer2GroupButton.backgroundColor == actionGreen {
            
           // askAnswer2GroupButton.isSelected = true
            askAnswer2GroupButton.setTitle("Added group that said \(answer2String)", for: .normal)
            askAnswer2GroupButton.setTitleColor(actionGreen, for: .normal)
            askAnswer2GroupButton.layer.backgroundColor = UIColor.white.cgColor
            
            selectedRecipients = selectedRecipients + answer2Group
            
            startNewGroupHeightConstraint.constant = 50
            
            tableView.reloadData()
        } else {
            
            askAnswer2GroupButton.isSelected = false
            askAnswer2GroupButton.setTitle("Add group that said \(answer2String)", for: .normal)
            askAnswer2GroupButton.setTitleColor(UIColor.white, for: .normal)
            askAnswer2GroupButton.backgroundColor = actionGreen
            
            answer2Group.forEach { (Recipient) in
                delete(recipient: Recipient)
            }
            
            tableView.reloadData()
        }
        
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func askNoAnswerGroupButtonTapped(_ sender: Any) {
        
        print(selectedRecipients)
        
        if selectedRecipients.count == 0 {
            startNewGroupHeightConstraint.constant = 0
        }
    
        
        if askNoAnswerGroupButton.backgroundColor == actionGreen {
            
           // askNoAnswerGroupButton.isSelected = true
            askNoAnswerGroupButton.setTitle("Added group that didn't answer", for: .normal)
            askNoAnswerGroupButton.setTitleColor(actionGreen, for: .normal)
            askNoAnswerGroupButton.layer.backgroundColor = UIColor.white.cgColor
            
            selectedRecipients = selectedRecipients + noanswerGroup
            
            startNewGroupHeightConstraint.constant = 50
            
            tableView.reloadData()
        }else {
            
            askNoAnswerGroupButton.isSelected = false
            askNoAnswerGroupButton.setTitle("Add group that didn't answer", for: .normal)
            askNoAnswerGroupButton.setTitleColor(UIColor.white, for: .normal)
            askNoAnswerGroupButton.backgroundColor = actionGreen
            
            noanswerGroup.forEach { (Recipient) in
                delete(recipient: Recipient)
            }
            
            tableView.reloadData()
        }
        
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }

        
        
    }
    
    
    @IBAction func startNewGroupButtonTapped(_ sender: Any) {
        
       
        let pollRef = FIRDatabase.database().reference().child("polls").child(pollID)
        let previousPollInThreadRef = FIRDatabase.database().reference().child("polls").child((self.pollsInThread.first?.pollID)!)
        let parentPollRef = FIRDatabase.database().reference().child("polls").child(parentPollID)
        let currentUserID = FIRAuth.auth()?.currentUser?.uid
        let threadRef = FIRDatabase.database().reference().child("threads").child(parentThreadID)
        
        let currentDate = Date()
        var expirationDate = Date()
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        pollRef.setValue(dictPoll)
        threadRef.child(pollID).setValue(dictPoll)
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: currentDate)
        
        
        self.selectedRecipients.forEach { (Recipient) in
            
            let notificationID = UUID().uuidString
            let notificationRef = FIRDatabase.database().reference().child("notifications").child(notificationID)
            
            let notificationDict : [NSObject : AnyObject]  = ["recipientID" as NSObject: Recipient.recipientID as AnyObject, "senderID" as NSObject: currentUserID as AnyObject, "activity type" as NSObject: "poll received" as AnyObject, "time sent" as NSObject: dateString as AnyObject, "is unread" as NSObject: "true" as AnyObject, "pollID" as NSObject: pollID as AnyObject, "messageID" as NSObject: "NA" as AnyObject]
            
            notificationRef.setValue(notificationDict)
            
            
            let recipientID = Recipient.recipientID
            print(recipientID)
            
            let recipientDict : [NSObject : AnyObject] = ["recipientName" as NSObject: (Recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (Recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (recipientID) as AnyObject, "tag" as NSObject: "user" as AnyObject, "hasLeft" as NSObject: "0" as AnyObject]
            
            let voter : [NSObject : AnyObject] = ["recipientName" as NSObject: (Recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (Recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (recipientID) as AnyObject, "voteString" as NSObject: "no vote" as AnyObject]
            
            let ref = FIRDatabase.database().reference().child("users").child(recipientID).child("receivedPolls").child(parentThreadID).child(pollID)
            let sentToRef = FIRDatabase.database().reference().child("polls").child(pollID).child("sentTo").child(recipientID)
            let voteRef = FIRDatabase.database().reference().child("polls").child(pollID).child("votes").child(recipientID)
            
            
            sentToRef.setValue(recipientDict)
            
            
            
            ref.setValue(self.dictPoll)
            ref.child("threadID").setValue(parentThreadID)
            ref.child("isThreadParent").setValue("false")
            
            if questionImageURL != "" {
            ref.child("questionImageURL").setValue(self.questionImageURL)
                
            }
            threadRef.child(pollID).child("sentTo").child(recipientID).setValue(recipientDict)
            threadRef.child(pollID).child("votes").child(recipientID).setValue(voter)
            voteRef.setValue(voter)
            
            
            
        }
        
        //currentuser references
        
        FIRDatabase.database().reference().child("polls").child(pollID).child("sentTo").child(currentUserID!).setValue(self.currentUserRecipientDict)
       
        FIRDatabase.database().reference().child("polls").child(pollID).child("votes").child(currentUserID!).setValue(self.currentUserVoterDict)
        
        FIRDatabase.database().reference().child("threads").child(parentThreadID).child(pollID).child("votes").child(currentUserID!).setValue(self.currentUserVoterDict)
        
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedPolls").child(parentThreadID).child(pollID).setValue(dictPoll)
       
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedPolls").child(parentThreadID).child(pollID).child("threadID").setValue(parentThreadID)

        FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedPolls").child(parentThreadID).child(pollID).child("isThreadParent").setValue("false")
        
        
        
        
        //set hasChildren to true for last poll in thread
    
        
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedPolls").child(parentThreadID).child((self.pollsInThread.first?.pollID)!).child("hasChildren").setValue("true")
        previousPollInThreadRef.child("hasChildren").setValue("true")
        threadRef.child((self.pollsInThread.last?.pollID)!).child("hasChildren").setValue("true")
        
        
        
        //thread data saved
        threadRef.child(pollID).child("isThreadParent").setValue("false")
        
        
        parentPollRef.child("hasChildren").setValue("true")

        pollRef.child("threadID").setValue(parentThreadID)
        pollRef.child("isThreadParent").setValue("false")
       
      
        
        self.performSegue(withIdentifier: "unwindToMenuAfterSendingThreadPoll", sender: self)

        
        
    }
    
    func delete(recipient: Recipient) {
        selectedRecipients = selectedRecipients.filter() {$0 !== recipient}
    }
    
    }

