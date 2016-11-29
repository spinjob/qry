//
//  HomeViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/18/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var currentUserID = ""
    var receivedPolls : [Poll] = []
    var selectedButton : [Int : UIButton] = [:]
    var viewResults : Bool = false
    var senderUser : User = User()
    var answer1Users : [String] = []
    var answer2Users : [String] = []
    
    

    let ref : FIRDatabaseReference = FIRDatabase.database().reference().child("users")
    let pollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls")
    let sentPollsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("polls")
  
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont(name: "Proxima Nova", size: 20)!]
        navigationController?.navigationBar.backItem?.backBarButtonItem!.title = "X"

        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        var newRecipient : [NSObject : AnyObject] = [ : ]
        var recipientID = ""
    
        
        ref.observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as? NSDictionary
            
            newRecipient = ["recipientName" as NSObject: (snapshotValue?["fullName"] as! String) as AnyObject, "recipientImageURL1" as NSObject: (snapshotValue?["profileImageURL"] as! String) as AnyObject, "recipientID" as NSObject: (snapshotValue?["uID"] as! String) as AnyObject, "tag" as NSObject: "user" as AnyObject]
            
            recipientID = snapshotValue?["uID"] as! String
            
            let recipientListRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientID)
            
            recipientListRef.setValue(newRecipient)

        
            })

        
        
        pollRef.observe(.childAdded, with: {
            snapshot in
            
            
            let poll = Poll()

            let snapshotValue = snapshot.value as! NSDictionary
           
            
            poll.answer1String = snapshotValue["answer1"] as! String
            poll.answer2String = snapshotValue["answer2"] as! String
            poll.questionString = snapshotValue["question"] as! String
            poll.senderUser = snapshotValue["senderUser"] as! String
            poll.pollImageURL = snapshotValue["pollImageURL"] as! String
            poll.pollID = snapshot.key
            poll.pollImageDescription = snapshotValue["pollImageDescription"] as! String
            poll.pollImageTitle = snapshotValue["pollImageTitle"] as! String
            
            
            self.receivedPolls.append(poll)
            
            self.tableView.reloadData()
            
            
        })
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        print(receivedPolls)
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedPolls.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "pollCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PollTableViewCell
        
        cell.prepareForReuse()
        
        let pollForCell = receivedPolls[indexPath.row]
        
        let senderUserRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("users").child(receivedPolls[indexPath.row].senderUser)
        let sentToRecipientsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[indexPath.row].pollID).child("sentTo")
        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[indexPath.row].pollID).child("votes")
        let myVoteReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[indexPath.row].pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!)
        let chatMemberRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[indexPath.row].pollID).child("sentTo")

        var sentToRecipientsString : [String] = [""]
        var numberOfOtherRecipients : Int
        
        
        
        print(pollForCell.pollImageURL)
        
        sentToRecipientsRef.observe(.childAdded, with: {
        
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let userName = snapshotValue["recipientName"] as! String

            sentToRecipientsString.append(userName)
            

            if sentToRecipientsString.count == 2 {
            cell.toUserNameLabel.text = "to \(sentToRecipientsString[1])"
            }
            
            if sentToRecipientsString.count == 3 {
                cell.toUserNameLabel.text = "to \(sentToRecipientsString[1]) & \(sentToRecipientsString[2])"
            }
            
            if sentToRecipientsString.count == 4 {
                cell.toUserNameLabel.text = "to \(sentToRecipientsString[1]) & \(sentToRecipientsString[2]) & 1 other"
            }
            
            if sentToRecipientsString.count > 4 {
                cell.toUserNameLabel.text = "to \(sentToRecipientsString[1]) & \(sentToRecipientsString[2]) & \((sentToRecipientsString.count - 3)) others"
            }

            
        })
    
        cell.answer1Button.tag = indexPath.row
        cell.answer2Button.tag = indexPath.row
        cell.viewPollResultsButton.tag = indexPath.row
        cell.conversationButton.tag = indexPath.row
        cell.reloadResultsButton.tag = indexPath.row
        
        
        cell.answer1Button.layer.borderWidth = 0.5
        cell.answer1Button.layer.cornerRadius = 3.5
        cell.answer1Button.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
        
        cell.answer2Button.layer.borderWidth = 0.5
        cell.answer2Button.layer.cornerRadius = 3.5
        cell.answer2Button.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
        
        cell.answer1Button.setTitle(receivedPolls[indexPath.row].answer1String, for: .normal);
        cell.answer2Button.setTitle(receivedPolls[indexPath.row].answer2String, for: .normal);
        cell.questionStringLabel.text = receivedPolls[indexPath.row].questionString
        cell.separatorImageView.layer.borderWidth = 0.2
        cell.separatorImageView.layer.borderColor = UIColor.init(hexString: "D8D8D8").cgColor
        
        cell.resultsView.isHidden = true
        cell.answer1Button.isHidden = false
        cell.answer2Button.isHidden = false
        cell.viewPollResultsButton.isSelected = false
        
        cell.pollImageView.layer.borderWidth = 0.5
        cell.pollImageView.layer.cornerRadius = 3.5
        cell.pollImageView.layer.masksToBounds = true
        cell.pollImageView.layer.borderColor = UIColor.lightGray.cgColor
        cell.pollImageView.isHidden = true
        cell.imageHeadlineTextLabel.isHidden = true
        cell.imageDescriptionTextView.isHidden = true
        cell.resultViewVerticalConstraint.constant = 130
        cell.questionTextVerticalConstraint.constant = 72
    
        
        senderUserRef.observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            cell.senderUserImageView.sd_setImage(with: URL(string : snapshotValue["profileImageURL"] as! String))
            cell.senderUserLabel.text = snapshotValue["fullName"] as! String
    
        })
        
        
        cell.senderUserImageView.layer.cornerRadius =  cell.senderUserImageView.layer.frame.size.width / 2
        cell.senderUserImageView.layer.masksToBounds = true
        cell.senderUserImageView.layer.borderWidth = 0.2
        cell.senderUserImageView.layer.borderColor = UIColor.init(hexString: "506688").cgColor
        cell.pollImageView.sd_setImage(with: URL(string: pollForCell.pollImageURL))
        cell.imageHeadlineTextLabel.text = pollForCell.pollImageTitle
        cell.imageDescriptionTextView.text = pollForCell.pollImageDescription
        
        
        cell.answer1Button.addTarget(self, action: #selector(self.answerButton1Tapped(sender:)), for: .touchUpInside)
        cell.answer2Button.addTarget(self, action: #selector(self.answerButton2Tapped(sender:)), for: .touchUpInside)
        cell.conversationButton.addTarget(self, action: #selector(self.chatButtonTapped(sender:)), for: .touchUpInside)
        
        
        cell.viewPollResultsButton.addTarget(self, action: #selector(self.viewPollResultsButtonTapped(sender:)), for: .touchUpInside)
        cell.viewPollResultsButton.setImage(UIImage(named: "selectedResultsICon.png"), for: .selected)
        cell.viewPollResultsButton.setImage(UIImage(named: "De-selectedResultsIcon.png"), for: .normal)
        cell.viewPollResultsButton.isSelected = false
        cell.answer2TextLabel.text = cell.answer2Button.titleLabel!.text
        cell.answer1TextLabel.text = cell.answer1Button.titleLabel!.text
        cell.answer1ResultBarImageView.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
        cell.answer1ResultBarImageView.layer.borderWidth = 0.2
        cell.answer1ResultBarImageView.layer.cornerRadius = 4
        cell.answer1ResultBarImageView.layer.masksToBounds = true
        
        cell.reloadResultsButton.addTarget(self, action: #selector(self.reloadResultsButtonTapped(sender:)), for: .touchUpInside)
        
        cell.answer2ResultBarImageView.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
        cell.answer2ResultBarImageView.layer.borderWidth = 0.2
        cell.answer2ResultBarImageView.layer.cornerRadius = 4
        cell.answer2ResultBarImageView.layer.masksToBounds = true
        
        cell.resultsView.isHidden = true
        cell.reloadResultsButton.isHidden = true
        cell.noVotesTextLabel.isHidden = true
        
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
            snapshot in
            
            cell.answer1PercentageTextLabel.text = String(snapshot.childrenCount)
            
        })
        
        //calculating the poll results and displaying the bar chart
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
            snapshot in
            
            cell.answer2PercentageTextLabel.text = String(snapshot.childrenCount)
            
            let answer1Count = Double(cell.answer1PercentageTextLabel.text!)
            let answer2Count = Double(snapshot.childrenCount)
            let total = answer1Count! + answer2Count
            
            
            if total > 0 {
            let answer1frame : CGRect = CGRect(x: cell.answer1ResultBarImageView.frame.origin.x, y: cell.answer1ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer1Count!/total)), height: cell.answer1ResultBarImageView.frame.height)
            
            let answer2frame : CGRect = CGRect(x: cell.answer2ResultBarImageView.frame.origin.x, y: cell.answer2ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer2Count/total)), height: cell.answer1ResultBarImageView.frame.height)
            
            print("ANSWER 2 COUNT \(530*(answer2Count/total))")
            print("ANSWER 1 COUNT \(530*(answer1Count!/total))")
            
                
            UIView.animate(withDuration: 0.5, animations: {
                    cell.answer1ResultBarImageView.frame = answer1frame
                    cell.answer2ResultBarImageView.frame = answer2frame
                })
        
            
            if answer1Count == 0, Int(answer2Count) > 0 {
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer2TextLabel.textColor = UIColor.white
                cell.answer2PercentageTextLabel.textColor = UIColor.white
            }
            
            if answer2Count == 0, Int(answer1Count!) > 0 {
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer1TextLabel.textColor = UIColor.white
                cell.answer1PercentageTextLabel.textColor = UIColor.white
            }
            
            if Int(answer1Count!) < Int(answer2Count) {
                
               cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
               cell.answer1ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground.png")
               cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
               cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
            }
                
        }
           
            if total == 0 {
                cell.viewPollResultsButton.isHidden = true
                cell.reloadResultsButton.isHidden = false
                cell.noVotesTextLabel.isHidden = false
            }
            
            print(cell.answer1ResultBarImageView.frame)
            
            
        })

        myVoteReference.observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let myVote = snapshotValue["voteString"] as! String
            
            if myVote == "answer1" {
                cell.answer1Button.isSelected = true
                cell.answer1Button.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
                cell.answer2Button.isSelected = false
                cell.answer2Button.layer.backgroundColor = UIColor.white.cgColor
            }
            
            if myVote == "answer2" {
                cell.answer2Button.isSelected = true
                cell.answer2Button.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
                cell.answer1Button.isSelected = false
                cell.answer1Button.layer.backgroundColor = UIColor.white.cgColor
            }
            
            if myVote == "no vote" {
                cell.answer1Button.isSelected = false
                cell.answer2Button.isSelected = false
                cell.answer1Button.layer.backgroundColor = UIColor.white.cgColor
                cell.answer2Button.layer.backgroundColor = UIColor.white.cgColor
            }
        })
        
        
        
        chatMemberRef.observe(.childAdded, with: {
            snapshot in
            let recipient : Recipient = Recipient()
            let snapshotValue = snapshot.value as! NSDictionary
            
            recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            recipient.recipientID = snapshotValue["recipientID"] as! String
            recipient.recipientName = snapshotValue["recipientName"] as! String

            if pollForCell.groupMembers.contains(where: { $0.recipientID == recipient.recipientID }) {
             print("group member already added")
            } else {
                pollForCell.groupMembers.append(recipient)
            }
        })

        
        if receivedPolls[indexPath.row].pollImageURL != "no image"  {
            cell.pollImageView.isHidden = false
            cell.imageDescriptionTextView.isHidden = false
            cell.imageHeadlineTextLabel.isHidden = false
            cell.resultViewVerticalConstraint.constant = 304
            cell.questionTextVerticalConstraint.constant = 246
                   }
        
        return cell

    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         if receivedPolls[indexPath.row].pollImageURL != "no image" {
            return 456
        } else {
            return 282
        }
        
    }
    
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        
        do {
            try FIRAuth.auth()?.signOut()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginOrSignUpViewController") as! LoginOrSignUpViewController
            present(vc, animated: true, completion: nil)
            print("You logged out")
            
        } catch let error as Error {
            print("\(error)")
        }
        
    }
    
    
    
    
    
    func answerButton1Tapped (sender : UIButton){
        sender.isSelected = !sender.isSelected;

        let pollAnsweredRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!).child("voteString")
        
        
        if selectedButton[sender.tag] != nil {
            if selectedButton[sender.tag] != sender {
                selectedButton[sender.tag]?.isSelected = false
                selectedButton[sender.tag]?.layer.backgroundColor = UIColor.white.cgColor
                
                selectedButton.updateValue(sender, forKey: sender.tag)
                sender.isSelected = true
                sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
            } else {
                selectedButton.removeValue(forKey: sender.tag)
                sender.isSelected = false
                sender.layer.backgroundColor = UIColor.white.cgColor
                pollAnsweredRef.setValue("no vote")
            }
        } else {
            
            selectedButton.updateValue(sender, forKey: sender.tag)
            sender.isSelected = true
            sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
        }
        
        if selectedButton[sender.tag]?.isSelected == true {
            
            pollAnsweredRef.setValue("answer1")
            
        } else {
            pollAnsweredRef.setValue("no vote")
        }
        
    
        print(selectedButton[sender.tag]?.titleLabel?.text!)
    }
    
    
    func answerButton2Tapped (sender : UIButton){
        
        sender.isSelected = !sender.isSelected;
        
        let buttonIndexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: buttonIndexPath) as! PollTableViewCell
        
        
        let pollAnsweredRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!).child("voteString")
        
        if selectedButton.first != nil {
    
            if selectedButton[sender.tag] != sender {
                selectedButton[sender.tag]?.isSelected = false
                selectedButton[sender.tag]?.layer.backgroundColor = UIColor.white.cgColor
                
                selectedButton.updateValue(sender, forKey: sender.tag)
                sender.isSelected = true
                sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
            } else {
                selectedButton.removeValue(forKey: sender.tag)
                sender.isSelected = false
                sender.layer.backgroundColor = UIColor.white.cgColor
                pollAnsweredRef.setValue("no vote")
            }
        } else {
            
            selectedButton.updateValue(sender, forKey: sender.tag)
            sender.isSelected = true
            sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
        }
        
        if selectedButton[sender.tag]?.isSelected == true {
            
            pollAnsweredRef.setValue("answer2")

            
        } else {
            
            pollAnsweredRef.setValue("no vote")
        }
        
        
        print(selectedButton[sender.tag]?.titleLabel?.text!)
        
    }
    
    
    
func chatButtonTapped (sender : UIButton){
        
        let chatMemberRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID).child("sentTo")
        let myVC = storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        var chatMembers : [Recipient] = []
        
        myVC.poll = receivedPolls[sender.tag]
        myVC.chatMembers = receivedPolls[sender.tag].groupMembers
        
        navigationController?.pushViewController(myVC, animated: true)
        
    }
    
    
    
func viewPollResultsButtonTapped (sender : UIButton){
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! PollTableViewCell
        let sentToRecipientsReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID).child("sentTo")
        var sentToRecipientIDs : [String] = []
       
       
       //hide/show buttons when results view button is tapped
        sender.isSelected = !sender.isSelected;
        
        if sender.isSelected == true {
            cell.resultsView.isHidden = false
            cell.answer2Button.isHidden = true
            cell.answer1Button.isHidden = true
            cell.reloadResultsButton.isHidden = false
        }
        
        if sender.isSelected == false {
            
            cell.resultsView.isHidden = true
            cell.answer2Button.isHidden = false
            cell.answer1Button.isHidden = false
            cell.reloadResultsButton.isHidden = true
            
        }
        
       //get votes and calculate poll results from Firebase
        
         let pollVoteReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID).child("votes")
        
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
            snapshot in
            
            cell.answer1PercentageTextLabel.text = String(snapshot.childrenCount)

        })
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
            snapshot in
            
            cell.answer2PercentageTextLabel.text = String(snapshot.childrenCount)
            
            let answer1Count = Double(cell.answer1PercentageTextLabel.text!)
            let answer2Count = Double(snapshot.childrenCount)
            let total = answer1Count! + answer2Count

        if total > 0 {
            
            let answer1frame : CGRect = CGRect(x: cell.answer1ResultBarImageView.frame.origin.x, y: cell.answer1ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer1Count!/total)), height: cell.answer1ResultBarImageView.frame.height)
            
           let answer2frame : CGRect = CGRect(x: cell.answer2ResultBarImageView.frame.origin.x, y: cell.answer2ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer2Count/total)), height: cell.answer1ResultBarImageView.frame.height)
            
            cell.answer1ResultBarImageView.frame = answer1frame
            cell.answer2ResultBarImageView.frame = answer2frame
            
            if answer1Count == 0, Int(answer2Count) > 0 {
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer2TextLabel.textColor = UIColor.white
                cell.answer2PercentageTextLabel.textColor = UIColor.white
            }
            
            if answer2Count == 0, Int(answer1Count!) > 0 {
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer1TextLabel.textColor = UIColor.white
                cell.answer1PercentageTextLabel.textColor = UIColor.white
            }
            
            if Int(answer1Count!) < Int(answer2Count) {
                
                cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer1ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground.png")
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
            }
            
        
        } else {
            cell.viewPollResultsButton.isHidden = true
            cell.noVotesTextLabel.isHidden = false
            cell.answer1Button.isHidden = false
            cell.answer2Button.isHidden = false
            cell.resultsView.isHidden = true
            
            }
            
        
        })
       
      
    }
    
func reloadResultsButtonTapped (sender : UIButton){
        
        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID).child("votes")
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! PollTableViewCell
        let sentToRecipientsReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID).child("sentTo")
        var sentToRecipientIDs : [String] = []

        
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
            snapshot in
            
            cell.answer1PercentageTextLabel.text = String(snapshot.childrenCount)
            
        })
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
            snapshot in
            
            cell.answer2PercentageTextLabel.text = String(snapshot.childrenCount)
            
            let answer1Count = Double(cell.answer1PercentageTextLabel.text!)
            let answer2Count = Double(snapshot.childrenCount)
            let total = answer1Count! + answer2Count
            
            let answer1frame : CGRect = CGRect(x: cell.answer1ResultBarImageView.frame.origin.x, y: cell.answer1ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer1Count!/total)), height: cell.answer1ResultBarImageView.frame.height)
            
            let answer2frame : CGRect = CGRect(x: cell.answer2ResultBarImageView.frame.origin.x, y: cell.answer2ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer2Count/total)), height: cell.answer1ResultBarImageView.frame.height)
        
            if total > 0 {
            cell.answer1ResultBarImageView.frame = answer1frame
            cell.answer2ResultBarImageView.frame = answer2frame
            
            if answer1Count == 0, Int(answer2Count) > 0 {
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer2TextLabel.textColor = UIColor.white
                cell.answer2PercentageTextLabel.textColor = UIColor.white

            }
            
            if answer2Count == 0, Int(answer1Count!) > 0 {
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer1TextLabel.textColor = UIColor.white
                cell.answer1PercentageTextLabel.textColor = UIColor.white
            }
            
            if Int(answer1Count!) < Int(answer2Count) {
                
                cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer1ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground.png")
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
            }
            
                
                if cell.noVotesTextLabel.isHidden == false {
                        cell.noVotesTextLabel.isHidden = true
                        cell.viewPollResultsButton.isSelected = false
                        cell.viewPollResultsButton.isHidden = false
                
                    }
            
                if cell.answer1Button.isHidden == false {
                        cell.reloadResultsButton.isHidden = true
                    }
                
    
            } else {
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(cgPoint: CGPoint(x: cell.noVotesTextLabel.center.x - 10, y: cell.noVotesTextLabel.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: cell.noVotesTextLabel.center.x + 10, y: cell.noVotesTextLabel.center.y))
                cell.noVotesTextLabel.layer.add(animation, forKey: "position")
            }
            
            print(cell.answer1ResultBarImageView.frame)
            
            
            
            
        })
            
    }
   
}
