//
//  UserProfileViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 12/6/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var underlineImageView: UIImageView!
    @IBOutlet weak var answeredButton: UIButton!
    @IBOutlet weak var askedButton: UIButton!
    @IBOutlet weak var numberOfFriendsLabel: UILabel!
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var profileImageURL = ""
    var profileUserID = ""
    var askedPolls : [Poll] = []
    var answeredPolls : [Poll] = []
    //var receivedPolls : [Poll] = []
    var selectedButton : [Int : UIButton] = [:]
    let currentUserID = FIRAuth.auth()!.currentUser!.uid
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self

        let userRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(profileUserID)
        let pollsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls")
        let receivedPollsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(profileUserID).child("receivedPolls")
        let currentUserRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(currentUserID)
        
        userProfileImageView.layer.cornerRadius =  userProfileImageView.layer.frame.size.width / 2
        userProfileImageView.layer.masksToBounds = true
        userProfileImageView.layer.borderColor = UIColor.init(hexString: "C8C7C9").cgColor
        userProfileImageView.layer.borderWidth = 1.5

        
        userRef.observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            self.userProfileImageView.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
            self.userNameLabel.text = snapshotValue["fullName"] as! String
            
        })
    
    
    userRef.child("recipientList").queryOrdered(byChild: "tag").queryEqual(toValue: "user").observe(.value, with: {
       snapshot in
        
        self.numberOfFriendsLabel.text = String(snapshot.childrenCount)
    
    })
    
    
        pollsRef.queryOrdered(byChild: "senderUser").queryEqual(toValue: profileUserID).observe(.childAdded, with: {
            snapshot in
        
        if snapshot.childrenCount != 0 {
            
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
            poll.pollURL = snapshotValue["pollURL"] as! String
            
            self.askedPolls.append(poll)
            }
            
            self.tableView.reloadData()
        })
        
    //    receivedPollsRef.observe(.childAdded, with: {
    //        snapshot in
  
    //        if snapshot.childrenCount != 0 {
    //        let poll = Poll()
  
    //        let snapshotValue = snapshot.value as! NSDictionary
            
    //        poll.answer1String = snapshotValue["answer1"] as! String
    //        poll.answer2String = snapshotValue["answer2"] as! String
    //       poll.questionString = snapshotValue["question"] as! String
    //        poll.senderUser = snapshotValue["senderUser"] as! String
    //        poll.pollImageURL = snapshotValue["pollImageURL"] as! String
    //        poll.pollID = snapshot.key
    //        poll.pollImageDescription = snapshotValue["pollImageDescription"] as! String
    //        poll.pollImageTitle = snapshotValue["pollImageTitle"] as! String
            
    //    self.receivedPolls.append(poll)
    //        }
            
    //    })
        
        receivedPollsRef.queryOrdered(byChild: "vote").queryEqual(toValue: "answer1").observe(.childAdded, with: {
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
            
            self.answeredPolls.append(poll)
            
        })
        
         receivedPollsRef.queryOrdered(byChild: "vote").queryEqual(toValue: "answer2").observe(.childAdded, with: {
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
            
             self.answeredPolls.append(poll)
            
         })
    
    
    if currentUserID == profileUserID {

       self.followButton.setTitle("Edit", for: .normal)
       self.followButton.backgroundColor = UIColor.init(hexString: "004488")
        
    } else {
        
        currentUserRef.child("recipientList").queryOrdered(byChild: "recipientID").queryEqual(toValue: profileUserID).observe(.value, with: {
            snapshot in
            print(snapshot.childrenCount)
            
            if snapshot.childrenCount != 0 {
                self.followButton.setTitle("Friends", for: .normal)
                self.followButton.backgroundColor = UIColor.init(hexString: "A8E855")
            }
            
       })
    }
        //Follow Button
        followButton.layer.cornerRadius = 4
        followButton.layer.masksToBounds = true
    
    }
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if underlineImageView.center.x == answeredButton.center.x {
        return answeredPolls.count
    }
    return askedPolls.count
    
    
    }
    
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    
    if underlineImageView.center.x == answeredButton.center.x {
        if answeredPolls[indexPath.row].pollImageURL != "no image" {
                return 355
            } else {
            return 246
            }
        }
    
    if askedPolls[indexPath.row].pollImageURL != "no image" {
        return 355
    } else {
        return 246
    }
    
    
}
    
    
    

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cellIdentifier = "pollCellProfile"
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProfilePollTableViewCell
    
    var pollForCell = askedPolls[indexPath.row]
    
    if underlineImageView.center.x == answeredButton.center.x {
        pollForCell = answeredPolls[indexPath.row]
    }
    
    
    let linkViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.linkViewTapped(sender:)))
    
    let senderUserRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("users").child(pollForCell.senderUser)
    let sentToRecipientsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("sentTo")
    let pollVoteReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes")
    let myVoteReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!)
    let chatMemberRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("sentTo")
    
    
    var sentToRecipientsString : [String] = [""]
    var numberOfOtherRecipients : Int
    
    
    
    cell.answer1Button.tag = indexPath.row
    cell.answer2Button.tag = indexPath.row
    cell.viewPollResultsButton.tag = indexPath.row
    cell.conversationButton.tag = indexPath.row
    cell.noVotesButton.tag = indexPath.row
    cell.senderUserImageView.tag = indexPath.row
    cell.linkPreviewView.tag = indexPath.row
    
    cell.separatorImageView.isHidden = false
    
    
    cell.answer1Button.layer.borderWidth = 0.5
    cell.answer1Button.layer.cornerRadius = 3.5
    cell.answer1Button.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
    
    cell.answer2Button.layer.borderWidth = 0.5
    cell.answer2Button.layer.cornerRadius = 3.5
    cell.answer2Button.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
    
    cell.answer1Button.setTitle(pollForCell.answer1String, for: .normal);
    cell.answer2Button.setTitle(pollForCell.answer2String, for: .normal);
    cell.questionStringLabel.text = pollForCell.questionString
    cell.separatorImageView.layer.borderWidth = 0.2
    cell.separatorImageView.layer.borderColor = UIColor.init(hexString: "D8D8D8").cgColor
    
    cell.resultsView.isHidden = true
    cell.answer1Button.isHidden = false
    cell.answer2Button.isHidden = false
    cell.viewPollResultsButton.isSelected = false
    
    cell.pollImageView.layer.borderWidth = 0.5
    cell.pollImageView.layer.cornerRadius = 3.5
    cell.pollImageView.layer.masksToBounds = true
    cell.pollImageView.layer.borderColor = UIColor.white.cgColor
    cell.linkPreviewView.isHidden = true
    cell.linkPreviewView.layer.borderWidth = 0.2
    cell.linkPreviewView.layer.borderColor = UIColor.lightGray.cgColor
    cell.linkPreviewView.layer.cornerRadius = 3.5
    
    cell.resultViewVerticalConstraint.constant = 80
    cell.answerButton1VerticalConstraint.constant = 80
    cell.answerButton2VerticalConstraint.constant = 80
    
    
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
    cell.senderUserImageView.isUserInteractionEnabled = true
   // cell.senderUserImageView.addGestureRecognizer(tapGestureRecognizer)
    
    
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
    
    cell.answer2ResultBarImageView.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
    cell.answer2ResultBarImageView.layer.borderWidth = 0.2
    cell.answer2ResultBarImageView.layer.cornerRadius = 4
    cell.answer2ResultBarImageView.layer.masksToBounds = true
    
    cell.resultsView.isHidden = true
    cell.noVotesButton.isHidden = true
    
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
            cell.noVotesButton.isHidden = false
        }
        
    })
    
    myVoteReference.observe(.value, with: {
        snapshot in
        
        let snapshotValue = snapshot.value as? NSDictionary
        let myVote = snapshotValue!["voteString"] as! String
    
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
        } else {
            pollForCell.groupMembers.append(recipient)
        }
    })
    
    
    if askedPolls[indexPath.row].pollImageURL != "no image"  {
        cell.linkPreviewView.isHidden = false
        cell.resultViewVerticalConstraint.constant = 202
        cell.answerButton1VerticalConstraint.constant = 202
        cell.answerButton2VerticalConstraint.constant = 202
        cell.linkPreviewView.isUserInteractionEnabled = true
        cell.linkPreviewView.addGestureRecognizer(linkViewTapGestureRecognizer)
        
        //cell.questionTextVerticalConstraint.constant = 177
    }

    
    return cell
    
    }

    
    
@IBAction func followButtonTapped(_ sender: Any) {
    
    
    }
    

func linkViewTapped (sender : UITapGestureRecognizer) {
        
        
        let linkPreview = sender.view! as UIView
    
    
        let url = URL(string: askedPolls[linkPreview.tag].pollURL)
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    
    
    
@IBAction func askedButtonTapped(_ sender: Any) {
    
        answeredButton.titleLabel?.textColor = UIColor.init(hexString: "D8D8D8")
        UIView.animate(withDuration: 0.3, animations: {
           self.view.layoutIfNeeded()
           self.underlineImageView.center.x = self.askedButton.center.x
        })
        
        
    }
    
    
@IBAction func answeredButtonTapped(_ sender: Any) {
        askedButton.titleLabel?.textColor = UIColor.init(hexString: "D8D8D8")
        
        answeredButton.titleLabel?.textColor = UIColor.init(hexString: "043176")
    
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.underlineImageView.center.x = self.answeredButton.center.x
        })
        
    }
   
    
func answerButton1Tapped (sender : UIButton){
        sender.isSelected = !sender.isSelected;
        
        let pollAnsweredRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(askedPolls[sender.tag].pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!).child("voteString")
        
        let answeredPollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls").child(askedPolls[sender.tag].pollID).child("vote")
        
        
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
                answeredPollRef.setValue("no vote")
            }
        } else {
            
            selectedButton.updateValue(sender, forKey: sender.tag)
            sender.isSelected = true
            sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
        }
        
        if selectedButton[sender.tag]?.isSelected == true {
            
            pollAnsweredRef.setValue("answer1")
            answeredPollRef.setValue("answer1")
            
        } else {
            pollAnsweredRef.setValue("no vote")
            answeredPollRef.setValue("no vote")
        }
        
    }
    
    
func answerButton2Tapped (sender : UIButton){
        
        sender.isSelected = !sender.isSelected;
    
        viewPollResultsButtonTapped(sender: sender)
        
        let buttonIndexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: buttonIndexPath) as! ProfilePollTableViewCell
        
        
        let pollAnsweredRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(askedPolls[sender.tag].pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!).child("voteString")
        let answeredPollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls").child(askedPolls[sender.tag].pollID).child("vote")
        
    
    
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
                answeredPollRef.setValue("no vote")
            }
        } else {
            
            selectedButton.updateValue(sender, forKey: sender.tag)
            sender.isSelected = true
            sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
        }
        
        if selectedButton[sender.tag]?.isSelected == true {
            
            pollAnsweredRef.setValue("answer2")
            answeredPollRef.setValue("answer2")
            
            
        } else {
            
            pollAnsweredRef.setValue("no vote")
            answeredPollRef.setValue("no vote")
        }
        
        
    }
    
    
    
    func chatButtonTapped (sender : UIButton){
        
        var pollForButton : Poll = askedPolls[sender.tag]
        
        if underlineImageView.center.x == answeredButton.center.x {
            pollForButton = answeredPolls[sender.tag]
        } else if underlineImageView.center.x == askedButton.center.x {
            pollForButton = askedPolls[sender.tag]
        }
        
        let chatMemberRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForButton.pollID).child("sentTo")
        
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(pollForButton.pollID).child("votes")
       
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
        
        var chatMembers : [Recipient] = []
        
        
        myVC.poll = pollForButton
        myVC.chatMembers = pollForButton.groupMembers
       
        
        
        navigationController?.pushViewController(myVC, animated: true)
        
    }
    
    
    
    func viewPollResultsButtonTapped (sender : UIButton){
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! ProfilePollTableViewCell
        let sentToRecipientsReference = FIRDatabase.database().reference().child("polls").child(askedPolls[sender.tag].pollID).child("sentTo")
        var sentToRecipientIDs : [String] = []
        
        
        //hide/show buttons when results view button is tapped
        sender.isSelected = !sender.isSelected;
        
        if sender.isSelected == true {
            cell.resultsView.isHidden = false
            cell.answer2Button.isHidden = true
            cell.answer1Button.isHidden = true
        }
        
        if sender.isSelected == false {
            
            cell.resultsView.isHidden = true
            cell.answer2Button.isHidden = false
            cell.answer1Button.isHidden = false
            
            
        }
        
        //get votes and calculate poll results from Firebase
        
        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(askedPolls[sender.tag].pollID).child("votes")
        
        
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
                cell.noVotesButton.isHidden = false
                cell.answer1Button.isHidden = false
                cell.answer2Button.isHidden = false
                cell.resultsView.isHidden = true
                
            }
            
            
        })
        
        
    }
    
    
    
    
}




