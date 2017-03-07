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

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    @IBOutlet weak var friendsLabel: UILabel!
    
    @IBOutlet weak var numberOfAskedLabel: UILabel!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var pollViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var friendProfileFeedLabel: UILabel!
    var profileImageURL = ""
    var profileUserID = ""
    var askedPolls : [Poll] = []
    var expiredAskedPolls : [Poll] = []
    var askedPollsObserved : [Poll] = []
    var receivedPollIDs : [String] = []
    var answeredPolls : [Poll] = []
    //var receivedPolls : [Poll] = []
    var selectedButton : [Int : UIButton] = [:]
    let currentUserID = FIRAuth.auth()!.currentUser!.uid
    var askedPollSelected : Bool = true
    var pollForCell : Poll = Poll()
    var userFriendArray : [Recipient] = []
    var userGroupArray : [Recipient] = []
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBarItems()
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        tableView.isHidden = true
        
    
        imagePicker.delegate = self

        let userRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(profileUserID)
        let pollsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls")
        let receivedPollsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(profileUserID).child("receivedPolls")
        let currentUserRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(currentUserID)
    
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileImageTapped(sender:)))
    
        
        userProfileImageView.layer.cornerRadius =  userProfileImageView.layer.frame.size.width / 2
        userProfileImageView.layer.masksToBounds = true
        userProfileImageView.layer.borderColor = UIColor.init(hexString: "C8C7C9").cgColor
        userProfileImageView.layer.borderWidth = 0
        userProfileImageView.addGestureRecognizer(tapGestureRecognizer)
    
    
        friendsButton.isUserInteractionEnabled = false

    
        numberOfAskedLabel.layer.cornerRadius = 4
        numberOfAskedLabel.layer.masksToBounds = true

        
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
        
        self.numberOfFollowersLabel.text = String(snapshot.childrenCount)
        
        if snapshot.childrenCount != 0 {
            
            let poll = Poll()
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let calendar = Calendar.current
            let dateString = formatter.string(from: date)
            
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
            poll.dateCreated = snapshotValue["dateCreated"] as! String
            poll.dateExpired = snapshotValue["expirationDate"] as! String
            poll.expiration = snapshotValue["expiration"] as! String
            
            let pollForCellDateExpired = formatter.date(from: poll.dateExpired)
            let currentDate = formatter.date(from: dateString)
            let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateExpired!)
            poll.minutesUntilExpiration = minutesLeft.minute!
            
            
            
            
            if snapshotValue["expired"] as! String == "false" {
                self.askedPolls.append(poll)
                self.askedPolls = self.askedPolls.sorted(by: {$0.minutesUntilExpiration < $1.minutesUntilExpiration})
                
                FIRDatabase.database().reference().child("users").child(self.currentUserID).child("receivedPolls").observe(.childAdded, with: {
                    snapshot in
                    
                    let receivedPollID = snapshot.key
                    
                    if poll.pollID == receivedPollID {
                        
                        self.askedPollsObserved.append(poll)
                        self.askedPollsObserved = self.askedPollsObserved.sorted(by: {$0.minutesUntilExpiration < $1.minutesUntilExpiration})
                        
                      self.tableView.reloadData()
                    }
                    
                })

                
            }
            
            if snapshotValue["expired"] as! String == "true" {
                self.expiredAskedPolls.append(poll)
                self.expiredAskedPolls = self.expiredAskedPolls.sorted(by: {$0.minutesUntilExpiration < $1.minutesUntilExpiration})
                
            }
            
            
            
        }
        
            self.numberOfAskedLabel.text = String(self.askedPolls.count)
//            self.tableView.reloadData()
        })
        
    

        
//    receivedPollsRef.observe(.childAdded, with: {
//            snapshot in
//            
//        if snapshot.childrenCount != 0 {
//            
//            let poll = Poll()
//            let date = Date()
//            let formatter = DateFormatter()
//            formatter.dateStyle = .short
//            formatter.timeStyle = .short
//            let calendar = Calendar.current
//            let dateString = formatter.string(from: date)
//            
//            let snapshotValue = snapshot.value as! NSDictionary
//            
//            poll.answer1String = snapshotValue["answer1"] as! String
//            poll.answer2String = snapshotValue["answer2"] as! String
//            poll.questionString = snapshotValue["question"] as! String
//            poll.senderUser = snapshotValue["senderUser"] as! String
//            poll.pollImageURL = snapshotValue["pollImageURL"] as! String
//            poll.pollID = snapshot.key
//            poll.pollImageDescription = snapshotValue["pollImageDescription"] as! String
//            poll.pollImageTitle = snapshotValue["pollImageTitle"] as! String
//            poll.pollURL = snapshotValue["pollURL"] as! String
//            poll.dateCreated = snapshotValue["dateCreated"] as! String
//            poll.dateExpired = snapshotValue["expirationDate"] as! String
//            poll.expiration = snapshotValue["expiration"] as! String
//            
//            let pollForCellDateExpired = formatter.date(from: poll.dateExpired)
//            let currentDate = formatter.date(from: dateString)
//            let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateExpired!)
//            poll.minutesUntilExpiration = minutesLeft.minute!
//            
//            if snapshotValue["expired"] as! String == "false" {
//                self.answeredPolls.append(poll)
//                
//                self.answeredPolls = self.answeredPolls.filter {
//                    $0.senderUser != self.profileUserID
//                }
//                
//                self.answeredPolls = self.answeredPolls.sorted(by: {$0.minutesUntilExpiration < $1.minutesUntilExpiration})
//                
//            }
//            
//        }
//        
//        })
     
    
    if currentUserID == profileUserID {

        self.followButton.isHidden = true
        self.pollViewHeightConstraint.constant = 200
        userProfileImageView.isUserInteractionEnabled = true
        friendsButton.isUserInteractionEnabled = true
        friendsLabel.textColor = UIColor.init(hexString: "19C4C3")
        answeredButton.isUserInteractionEnabled = true
        friendProfileFeedLabel.isHidden = true
        numberOfAskedLabel.isHidden = false
        underlineImageView.isHidden = false
        
        
    } else {
        
        friendsLabel.textColor = UIColor.init(hexString: "999999")
        answeredButton.isUserInteractionEnabled = false
        answeredButton.isHidden = true
        askedButton.isHidden = true
        askedButton.isUserInteractionEnabled = false
        friendProfileFeedLabel.isHidden = false
        numberOfAskedLabel.isHidden = true
        underlineImageView.isHidden = true
        
        askedButton.setTitle("Your Live Chats", for: .normal)
        
        currentUserRef.child("recipientList").queryOrdered(byChild: "recipientID").queryEqual(toValue: profileUserID).observe(.value, with: {
            snapshot in
            print(snapshot.childrenCount)
            
            if snapshot.childrenCount != 0 {
                self.followButton.setTitle("Friends", for: .normal)
                self.followButton.backgroundColor = UIColor.init(hexString: "A8E855")
            }
            
       })
    }
    
    
    
    
    let friendAndGroupListReference : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(profileUserID).child("recipientList")
    
    
    friendAndGroupListReference.queryOrdered(byChild: "tag").queryEqual(toValue: "group").observe(.childAdded, with: {
        snapshot in
        
        var group : Recipient = Recipient ()
        
        let snapshotValue = snapshot.value as! NSDictionary
        
        group.recipientID = snapshotValue["recipientID"] as! String
        group.recipientName = snapshotValue["recipientName"] as! String
        group.imageURL1 = snapshotValue["recipientImageURL1"] as! String
        group.tag = snapshotValue["tag"] as! String
        
        self.userGroupArray.append(group)
        
    })
    
    friendAndGroupListReference.queryOrdered(byChild: "tag").queryEqual(toValue: "user").observe(.childAdded, with: {
        snapshot in
        
        var friend : Recipient = Recipient ()
        
        let snapshotValue = snapshot.value as! NSDictionary
        
        friend.imageURL1 = snapshotValue["recipientImageURL1"] as! String
        friend.recipientID = snapshotValue["recipientID"] as! String
        friend.recipientName = snapshotValue["recipientName"] as! String
        friend.tag = snapshotValue["tag"] as! String
        
        self.userFriendArray.append(friend)
        
    })

        //Follow Button
        followButton.layer.cornerRadius = 4
        followButton.layer.masksToBounds = true
    
    
    
    }
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    
//    if askedPollSelected == false, profileUserID == currentUserID {
//
//      return self.answeredPolls.count
//    }
//    
//    if askedPollSelected == true, profileUserID == currentUserID {
//        return askedPolls.count
//    }
//    
//    if askedPollSelected == true, profileUserID != currentUserID {
//        return askedPollsObserved.count
//    }
//    
//    

    return 10
    
    
    tableView.reloadData()
    
    }
    
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
//    
//    if askedPollSelected == false, profileUserID == currentUserID {
//        if answeredPolls[indexPath.row].pollImageURL != "no image" {
//                return 355
//        } else {
//            return 246
//        }
//        }
//    
//    if askedPollSelected == true, profileUserID == currentUserID {
//        if askedPolls[indexPath.row].pollImageURL != "no image" {
//            return 355
//        } else {
//            return 246
//        }
//    }
//    
//    if askedPollSelected == true, profileUserID != currentUserID {
//        if askedPollsObserved[indexPath.row].pollImageURL != "no image" {
//            return 355
//        } else {
//            return 246
//        }
//    }
//    
//
//    if askedPolls[indexPath.row].pollImageURL != "no image" {
//        return 355
//    } else {
//        return 246
//    }
    
    return 246
    
}
    
    

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cellIdentifier = "pollCellProfile"
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProfilePollTableViewCell
    var pollCell = Poll()
    
//    print("CURRENT USER ID \(currentUserID)")
//    
//    if profileUserID != currentUserID {
//        pollCell = askedPolls[indexPath.row]
//    }
//    
//    if askedPollSelected == false, profileUserID == currentUserID {
//        pollCell = self.answeredPolls[indexPath.row]
//    }
//    
//    if askedPollSelected == true, profileUserID == currentUserID {
//        pollCell = askedPolls[indexPath.row]
//    }
//    
//    if askedPollSelected == true, profileUserID != currentUserID {
//        pollCell = askedPollsObserved[indexPath.row]
//    }
//
//    
//    let date = Date()
//    let formatter = DateFormatter()
//    let calendar = Calendar.current
//    
//    
//    formatter.dateStyle = .short
//    formatter.timeStyle = .short
//    let dateString = formatter.string(from: date)
//    
//    
//    let pollForCellDateExpired = formatter.date(from: pollCell.dateExpired)
//    let pollForCellDateCreated = formatter.date(from: pollCell.dateCreated)
//    let currentDate = formatter.date(from: dateString)
//    
//    let hoursLeft = calendar.dateComponents([.hour], from: currentDate!, to: pollForCellDateExpired!)
//    let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateExpired!)
//    let daysLeft = calendar.dateComponents([.day], from: currentDate!, to: pollForCellDateExpired!)
//    let minutesTotal = calendar.dateComponents([.minute], from: pollForCellDateCreated!, to:pollForCellDateExpired! )
//    let minutesLeftDouble : Double = Double(pollCell.minutesUntilExpiration)
//    let minutesTotalDouble : Double = Double(minutesTotal.minute!)
//    
//    let percentageLeft : Double = (minutesLeftDouble / minutesTotalDouble)*100
//    
//  
//    
//    let linkViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.linkViewTapped(sender:)))
//    
//    let senderUserRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("users").child(pollCell.senderUser)
//    let sentToRecipientsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollCell.pollID).child("sentTo")
//    let pollVoteReference = FIRDatabase.database().reference().child("polls").child(pollCell.pollID).child("votes")
//    let myVoteReference : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollCell.pollID).child("votes").child(currentUserID)
//    let chatMemberRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollCell.pollID).child("sentTo")
//    
//    
//    var sentToRecipientsString : [String] = [""]
//    var numberOfOtherRecipients : Int
//    
//   
//    if hoursLeft.hour! < 1 {
//        cell.timeLeftLabel.text = "\(minutesLeft.minute!) minutes left"
//    }
//    
//    if daysLeft.day! > 1 {
//        cell.timeLeftLabel.text = "\(daysLeft.day!) days left"
//    }
//    
//    if daysLeft.day! == 1 {
//        cell.timeLeftLabel.text = "\(daysLeft.day!) day left"
//    }
//  
//    if hoursLeft.hour! > 1, daysLeft.day! < 1 {
//        cell.timeLeftLabel.text = "\(hoursLeft.hour!) hours left"
//    }
//    
//    if hoursLeft.hour! == 1 {
//        cell.timeLeftLabel.text = "\(hoursLeft.hour!) hour left"
//    }
//    
//    cell.timerView.isHidden = true
//    cell.expiredIconImageView.isHidden = true
//    
//    if minutesLeft.minute! > 0, pollCell.isExpired == false {
//        cell.timerView.isHidden = false
//        cell.expiredIconImageView.isHidden = true
//        let chartView = PieChartView()
//        
//        chartView.frame = CGRect(x: 0, y: 0, width: cell.timerView.frame.size.width, height: 62)
//        
//        if percentageLeft < 10 {
//            chartView.segments = [
//                Segment(color: UIColor.init(hexString: "FFFFFF"), value: CGFloat(100 - percentageLeft)),
//                Segment(color: UIColor.init(hexString: "FF4E56"), value: CGFloat(percentageLeft))
//            ]
//        } else {
//            
//            chartView.segments = [
//                Segment(color: UIColor.init(hexString: "FFFFFF"), value: CGFloat(100 - percentageLeft)),
//                Segment(color: UIColor.init(hexString: "004488"), value: CGFloat(percentageLeft))
//            ]
//            
//        }
//        
//        cell.timerView.addSubview(chartView)
//        
//    }
//
//    cell.answer1Button.tag = indexPath.row
//    cell.answer2Button.tag = indexPath.row
//    cell.viewPollResultsButton.tag = indexPath.row
//    cell.conversationButton.tag = indexPath.row
//    cell.noVotesButton.tag = indexPath.row
//    cell.senderUserImageView.tag = indexPath.row
//    cell.linkPreviewView.tag = indexPath.row
//    
//    cell.separatorImageView.isHidden = false
//    
//    
//    cell.answer1Button.layer.borderWidth = 0.5
//    cell.answer1Button.layer.cornerRadius = 3.5
//    cell.answer1Button.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
//    
//    cell.answer2Button.layer.borderWidth = 0.5
//    cell.answer2Button.layer.cornerRadius = 3.5
//    cell.answer2Button.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
//    
//    cell.answer1Button.setTitle(pollCell.answer1String, for: .normal);
//    cell.answer2Button.setTitle(pollCell.answer2String, for: .normal);
//    cell.questionStringLabel.text = pollCell.questionString
//    cell.separatorImageView.layer.borderWidth = 0.2
//    cell.separatorImageView.layer.borderColor = UIColor.init(hexString: "D8D8D8").cgColor
//    
//    cell.resultsView.isHidden = true
//    cell.answer1Button.isHidden = false
//    cell.answer2Button.isHidden = false
//    cell.viewPollResultsButton.isSelected = false
//    
//    cell.pollImageView.layer.borderWidth = 0.5
//    cell.pollImageView.layer.cornerRadius = 3.5
//    cell.pollImageView.layer.masksToBounds = true
//    cell.pollImageView.layer.borderColor = UIColor.white.cgColor
//    cell.linkPreviewView.isHidden = true
//    cell.linkPreviewView.layer.borderWidth = 0.2
//    cell.linkPreviewView.layer.borderColor = UIColor.lightGray.cgColor
//    cell.linkPreviewView.layer.cornerRadius = 3.5
//    
//    cell.resultViewVerticalConstraint.constant = 80
//    cell.answerButton1VerticalConstraint.constant = 80
//    cell.answerButton2VerticalConstraint.constant = 80
//    
//    
//    senderUserRef.observe(.value, with: {
//        snapshot in
//        
//        let snapshotValue = snapshot.value as! NSDictionary
//        
//        cell.senderUserImageView.sd_setImage(with: URL(string : snapshotValue["profileImageURL"] as! String))
//        cell.senderUserLabel.text = snapshotValue["fullName"] as! String
//        
//    })
//    
//    cell.senderUserImageView.layer.cornerRadius =  cell.senderUserImageView.layer.frame.size.width / 2
//    cell.senderUserImageView.layer.masksToBounds = true
//    cell.senderUserImageView.layer.borderWidth = 0.2
//    cell.senderUserImageView.layer.borderColor = UIColor.init(hexString: "506688").cgColor
//    cell.senderUserImageView.isUserInteractionEnabled = true
//    
//    
//    cell.pollImageView.sd_setImage(with: URL(string: pollCell.pollImageURL))
//    cell.imageHeadlineTextLabel.text = pollCell.pollImageTitle
//    cell.imageDescriptionTextView.text = pollCell.pollImageDescription
//    
//    
//    cell.answer1Button.addTarget(self, action: #selector(self.answerButton1Tapped(sender:)), for: .touchUpInside)
//    cell.answer2Button.addTarget(self, action: #selector(self.answerButton2Tapped(sender:)), for: .touchUpInside)
//    cell.conversationButton.addTarget(self, action: #selector(self.chatButtonTapped(sender:)), for: .touchUpInside)
//    
//    
//    cell.viewPollResultsButton.addTarget(self, action: #selector(self.viewPollResultsButtonTapped(sender:)), for: .touchUpInside)
//    cell.viewPollResultsButton.setImage(UIImage(named: "selectedResultsICon.png"), for: .selected)
//    cell.viewPollResultsButton.setImage(UIImage(named: "De-selectedResultsIcon.png"), for: .normal)
//    cell.viewPollResultsButton.isSelected = false
//    cell.answer2TextLabel.text = cell.answer2Button.titleLabel!.text
//    cell.answer1TextLabel.text = cell.answer1Button.titleLabel!.text
//    cell.answer1ResultBarImageView.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
//    cell.answer1ResultBarImageView.layer.borderWidth = 0.2
//    cell.answer1ResultBarImageView.layer.cornerRadius = 4
//    cell.answer1ResultBarImageView.layer.masksToBounds = true
//    
//    cell.answer2ResultBarImageView.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
//    cell.answer2ResultBarImageView.layer.borderWidth = 0.2
//    cell.answer2ResultBarImageView.layer.cornerRadius = 4
//    cell.answer2ResultBarImageView.layer.masksToBounds = true
//    
//    cell.resultsView.isHidden = true
//    cell.noVotesButton.isHidden = true
//    
//    pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
//        snapshot in
//        
//        cell.answer1PercentageTextLabel.text = String(snapshot.childrenCount)
//        
//    })
//    
//    //calculating the poll results and displaying the bar chart
//    
//    pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
//        snapshot in
//        
//        cell.answer2PercentageTextLabel.text = String(snapshot.childrenCount)
//        
//        let answer1Count = Double(cell.answer1PercentageTextLabel.text!)
//        let answer2Count = Double(snapshot.childrenCount)
//        let total = answer1Count! + answer2Count
//        
//        
//        if total > 0 {
//            let answer1frame : CGRect = CGRect(x: cell.answer1ResultBarImageView.frame.origin.x, y: cell.answer1ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer1Count!/total)), height: cell.answer1ResultBarImageView.frame.height)
//            
//            let answer2frame : CGRect = CGRect(x: cell.answer2ResultBarImageView.frame.origin.x, y: cell.answer2ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer2Count/total)), height: cell.answer1ResultBarImageView.frame.height)
//            
//            
//            UIView.animate(withDuration: 0.5, animations: {
//                cell.answer1ResultBarImageView.frame = answer1frame
//                cell.answer2ResultBarImageView.frame = answer2frame
//            })
//            
//            
//            if answer1Count == 0, Int(answer2Count) > 0 {
//                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
//                cell.answer2TextLabel.textColor = UIColor.white
//                cell.answer2PercentageTextLabel.textColor = UIColor.white
//            }
//            
//            if answer2Count == 0, Int(answer1Count!) > 0 {
//                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                cell.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                cell.answer1ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
//                cell.answer1TextLabel.textColor = UIColor.white
//                cell.answer1PercentageTextLabel.textColor = UIColor.white
//            }
//            
//            if Int(answer1Count!) < Int(answer2Count) {
//                
//                cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
//                cell.answer1ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground.png")
//                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
//            }
//            
//        }
//        
//        if total == 0 {
//            cell.viewPollResultsButton.isHidden = true
//            cell.noVotesButton.isHidden = false
//        }
//        
//    })
//    
//    myVoteReference.observe(.value, with: {
//        snapshot in
//        
//        print(snapshot)
//        let snapshotValue = snapshot.value as? NSDictionary
//        let myVote = snapshotValue!["voteString"] as! String
//    
//        if myVote == "answer1" {
//            
//            print("answer1")
//            cell.answer1Button.isSelected = true
//            cell.answer1Button.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
//            cell.answer2Button.isSelected = false
//            cell.answer2Button.layer.backgroundColor = UIColor.white.cgColor
//        }
//    
//        if myVote == "answer2" {
//            
//            print("answer2")
//            cell.answer2Button.isSelected = true
//            cell.answer2Button.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
//            cell.answer1Button.isSelected = false
//            cell.answer1Button.layer.backgroundColor = UIColor.white.cgColor
//        }
//    
//        if myVote == "no vote" {
//            print("no vote")
//            cell.answer1Button.isSelected = false
//            cell.answer2Button.isSelected = false
//            cell.answer1Button.layer.backgroundColor = UIColor.white.cgColor
//            cell.answer2Button.layer.backgroundColor = UIColor.white.cgColor
//        }
//    })
//    
//    
//    chatMemberRef.observe(.childAdded, with: {
//        snapshot in
//        let recipient : Recipient = Recipient()
//        let snapshotValue = snapshot.value as! NSDictionary
//        
//        recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
//        recipient.recipientID = snapshotValue["recipientID"] as! String
//        recipient.recipientName = snapshotValue["recipientName"] as! String
//        
//        if pollCell.groupMembers.contains(where: { $0.recipientID == recipient.recipientID }) {
//        } else {
//            pollCell.groupMembers.append(recipient)
//        }
//    })
//    
//
//    if pollCell.pollImageURL != "no image"  {
//        cell.linkPreviewView.isHidden = false
//        cell.resultViewVerticalConstraint.constant = 202
//        cell.answerButton1VerticalConstraint.constant = 202
//        cell.answerButton2VerticalConstraint.constant = 202
//        cell.linkPreviewView.isUserInteractionEnabled = true
//        cell.linkPreviewView.addGestureRecognizer(linkViewTapGestureRecognizer)
//        
//        //cell.questionTextVerticalConstraint.constant = 177
//    }

    
    return cell
    
    }

    
    
@IBAction func followButtonTapped(_ sender: Any) {
    
    
    }
    

func linkViewTapped (sender : UITapGestureRecognizer) {
    
//    let linkPreview = sender.view! as UIView
//
//    pollForCell = askedPolls[linkPreview.tag]
//    
//    if askedPollSelected == false, profileUserID == currentUserID {
//        pollForCell = answeredPolls[linkPreview.tag]
//    }
//    
//    if askedPollSelected == true, profileUserID == currentUserID {
//        pollForCell = askedPolls[linkPreview.tag]
//    }
//    
//    if askedPollSelected == false, profileUserID != currentUserID {
//        pollForCell = askedPollsObserved[linkPreview.tag]
//
//    }
//    
//    let url = URL(string: pollForCell.pollURL)
//        
//        if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url!)
//        }
    }
    
    
    
@IBAction func askedButtonTapped(_ sender: Any) {
    
        answeredButton.titleLabel?.textColor = UIColor.init(hexString: "D8D8D8")
        numberOfAskedLabel.backgroundColor = UIColor.init(hexString: "043176")
        UIView.animate(withDuration: 0.3, animations: {
           self.view.layoutIfNeeded()
           self.underlineImageView.center.x = (self.askedButton.center.x + 13)
        })
    askedPollSelected = true
    tableView.reloadData()
    tableView.updateConstraints()
        
    }
    
    
@IBAction func answeredButtonTapped(_ sender: Any) {
        askedPollSelected = false
    
        print(self.answeredPolls)
        print(askedPollSelected)
    
        askedButton.titleLabel?.textColor = UIColor.init(hexString: "D8D8D8")
        numberOfAskedLabel.backgroundColor = UIColor.init(hexString: "D8D8D8")
        
        answeredButton.titleLabel?.textColor = UIColor.init(hexString: "043176")
    
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.underlineImageView.center.x = self.answeredButton.center.x
        })
    
    
       tableView.reloadData()
       tableView.updateConstraints()
    
    }
   
    
func answerButton1Tapped (sender : UIButton){
        sender.isSelected = !sender.isSelected;
    
//    
//    pollForCell = askedPolls[sender.tag]
//    
//    if askedPollSelected == false, profileUserID == currentUserID {
//        pollForCell = answeredPolls[sender.tag]
//    }
//    
//    if askedPollSelected == true, profileUserID == currentUserID {
//        pollForCell = askedPolls[sender.tag]
//    }
//    
//    if askedPollSelected == false, profileUserID != currentUserID {
//        pollForCell = askedPollsObserved[sender.tag]
//    }
//    
//    
//        let pollAnsweredRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes").child(currentUserID).child("voteString")
//        
//        let answeredPollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(currentUserID).child("receivedPolls").child(pollForCell.pollID).child("vote")
//        
//    
//        if selectedButton[sender.tag] != nil {
//            if selectedButton[sender.tag] != sender {
//                selectedButton[sender.tag]?.isSelected = false
//                selectedButton[sender.tag]?.layer.backgroundColor = UIColor.white.cgColor
//                
//                selectedButton.updateValue(sender, forKey: sender.tag)
//                sender.isSelected = true
//                sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
//            } else {
//                selectedButton.removeValue(forKey: sender.tag)
//                sender.isSelected = false
//                sender.layer.backgroundColor = UIColor.white.cgColor
//                pollAnsweredRef.setValue("no vote")
//                //answeredPollRef.setValue("no vote")
//            }
//        } else {
//            
//            selectedButton.updateValue(sender, forKey: sender.tag)
//            sender.isSelected = true
//            sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
//        }
//        
//        if selectedButton[sender.tag]?.isSelected == true {
//            
//            pollAnsweredRef.setValue("answer1")
//            //answeredPollRef.setValue("answer1")
//            
//        } else {
//            pollAnsweredRef.setValue("no vote")
//            //answeredPollRef.setValue("no vote")
//        }
    
    }
    
    
func answerButton2Tapped (sender : UIButton){
        
//        sender.isSelected = !sender.isSelected;
//    
//    
//    print(pollForCell.pollID)
//    
//    pollForCell = askedPolls[sender.tag]
//    
//    if askedPollSelected == false, profileUserID == currentUserID {
//        pollForCell = answeredPolls[sender.tag]
//    }
//    
//    if askedPollSelected == true, profileUserID == currentUserID {
//        pollForCell = askedPolls[sender.tag]
//    }
//    
//    if askedPollSelected == false, profileUserID != currentUserID {
//        pollForCell = askedPollsObserved[sender.tag]
//    }
//    
//    
//        viewPollResultsButtonTapped(sender: sender)
//        
//        let buttonIndexPath = IndexPath(row: sender.tag, section: 0)
//        let cell = tableView.cellForRow(at: buttonIndexPath) as! ProfilePollTableViewCell
//    
//        
//        let pollAnsweredRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!).child("voteString")
//        let answeredPollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(currentUserID).child("receivedPolls").child(pollForCell.pollID).child("vote")
//        
//    
//    
//        if selectedButton.first != nil {
//            
//            if selectedButton[sender.tag] != sender {
//                selectedButton[sender.tag]?.isSelected = false
//                selectedButton[sender.tag]?.layer.backgroundColor = UIColor.white.cgColor
//                
//                selectedButton.updateValue(sender, forKey: sender.tag)
//                sender.isSelected = true
//                sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
//            } else {
//                selectedButton.removeValue(forKey: sender.tag)
//                sender.isSelected = false
//                sender.layer.backgroundColor = UIColor.white.cgColor
//                pollAnsweredRef.setValue("no vote")
//              //  answeredPollRef.setValue("no vote")
//            }
//        } else {
//            
//            selectedButton.updateValue(sender, forKey: sender.tag)
//            sender.isSelected = true
//            sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
//        }
//        
//        if selectedButton[sender.tag]?.isSelected == true {
//            
//            pollAnsweredRef.setValue("answer2")
//           // answeredPollRef.setValue("answer2")
//            
//            
//        } else {
//            
//            pollAnsweredRef.setValue("no vote")
//           // answeredPollRef.setValue("no vote")
//        }
//        
    
    }
    

    
@IBAction func friendsButtonTapped(_ sender: Any) {

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "FriendsViewController") as! FriendsViewController
    let transition:CATransition = CATransition()
    
    controller.profileUserID = profileUserID
//    controller.groupArray = self.userGroupArray
//    controller.friendArray = self.userFriendArray
//    controller.items = [self.userFriendArray, self.userGroupArray]
    
    transition.duration = 0.3
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    transition.type = kCATransitionMoveIn
    transition.subtype = kCATransitionFromRight
    self.navigationController!.view.layer.add(transition, forKey: kCATransition)
    self.navigationController?.pushViewController(controller, animated: false)
    
    
    
    }
    
    
func chatButtonTapped (sender : UIButton){
    
//        
//    pollForCell = askedPolls[sender.tag]
//    
//    if askedPollSelected == false, profileUserID == currentUserID {
//        pollForCell = answeredPolls[sender.tag]
//    }
//    
//    if askedPollSelected == true, profileUserID == currentUserID {
//        pollForCell = askedPolls[sender.tag]
//    }
//    
//    if askedPollSelected == true, profileUserID != currentUserID {
//        pollForCell = askedPollsObserved[sender.tag]
//    }
//    
//        print(pollForCell.groupMembers)
//
//        let chatMemberRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("sentTo")
//        
//    
//        let myVC = storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
//        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes")
//       
//        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
//            snapshot in
//            
//            myVC.answer1Count = Int(snapshot.childrenCount)
//            
//            
//            
//        })
//        
//        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
//            snapshot in
//            
//            myVC.answer2Count = Int(snapshot.childrenCount)
//            
//            
//        })
//        
//        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "no vote").observe(.value, with: {
//            snapshot in
//            
//            myVC.undecidedCount = Int(snapshot.childrenCount)
//            
//            
//        })
//        
//        
//        var chatMembers : [Recipient] = []
//        
//        
//        myVC.poll = pollForCell
//        myVC.chatMembers = pollForCell.groupMembers
//       
//        
//        
//        navigationController?.pushViewController(myVC, animated: true)
    
    }
    
    
    func profileImageTapped (sender: UITapGestureRecognizer) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        userProfileImageView.image = image
        
        
        let profileImageData = UIImageJPEGRepresentation(userProfileImageView.image!, 0.4)
        
        FIRStorage.storage().reference().child("ProfileImages/\(FIRAuth.auth()?.currentUser!.uid)/profileImage.jpg").put(profileImageData!, metadata: nil){
                metadata, error in
                
                if error != nil {
                    print("error \(error)")
                }
                else {
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("profileImageURL").setValue(downloadURL)
        
                    
                }
                
            }
            
        
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
func viewPollResultsButtonTapped (sender : UIButton){
//        
//        let indexPath = IndexPath(row: sender.tag, section: 0)
//        let cell = tableView.cellForRow(at: indexPath) as! ProfilePollTableViewCell
//        
//        pollForCell = askedPolls[sender.tag]
//        
//        if askedPollSelected == false, profileUserID == currentUserID {
//            pollForCell = answeredPolls[sender.tag]
//        }
//        
//        if askedPollSelected == true, profileUserID == currentUserID {
//            pollForCell = askedPolls[sender.tag]
//        }
//    
//        if askedPollSelected == false, profileUserID != currentUserID {
//            pollForCell = askedPollsObserved[sender.tag]
//        }
//
//    
//        let sentToRecipientsReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("sentTo")
//        var sentToRecipientIDs : [String] = []
//        
//     
//        
//        //hide/show buttons when results view button is tapped
//        sender.isSelected = !sender.isSelected;
//        
//        if sender.isSelected == true {
//            cell.resultsView.isHidden = false
//            cell.answer2Button.isHidden = true
//            cell.answer1Button.isHidden = true
//        }
//        
//        if sender.isSelected == false {
//            
//            cell.resultsView.isHidden = true
//            cell.answer2Button.isHidden = false
//            cell.answer1Button.isHidden = false
//            
//            
//        }
//        
//        //get votes and calculate poll results from Firebase
//        
//        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes")
//        
//        
//        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
//            snapshot in
//            
//            cell.answer1PercentageTextLabel.text = String(snapshot.childrenCount)
//            
//        })
//        
//        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
//            snapshot in
//            
//            cell.answer2PercentageTextLabel.text = String(snapshot.childrenCount)
//            
//            let answer1Count = Double(cell.answer1PercentageTextLabel.text!)
//            let answer2Count = Double(snapshot.childrenCount)
//            let total = answer1Count! + answer2Count
//            
//            if total > 0 {
//                
//                let answer1frame : CGRect = CGRect(x: cell.answer1ResultBarImageView.frame.origin.x, y: cell.answer1ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer1Count!/total)), height: cell.answer1ResultBarImageView.frame.height)
//                
//                let answer2frame : CGRect = CGRect(x: cell.answer2ResultBarImageView.frame.origin.x, y: cell.answer2ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer2Count/total)), height: cell.answer1ResultBarImageView.frame.height)
//                
//                cell.answer1ResultBarImageView.frame = answer1frame
//                cell.answer2ResultBarImageView.frame = answer2frame
//                
//                if answer1Count == 0, Int(answer2Count) > 0 {
//                    cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                    cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                    cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
//                    cell.answer2TextLabel.textColor = UIColor.white
//                    cell.answer2PercentageTextLabel.textColor = UIColor.white
//                }
//                
//                if answer2Count == 0, Int(answer1Count!) > 0 {
//                    cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                    cell.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                    cell.answer1ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
//                    cell.answer1TextLabel.textColor = UIColor.white
//                    cell.answer1PercentageTextLabel.textColor = UIColor.white
//                }
//                
//                if Int(answer1Count!) < Int(answer2Count) {
//                    
//                    cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
//                    cell.answer1ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground.png")
//                    cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                    cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
//                }
//                
//                
//            } else {
//                cell.viewPollResultsButton.isHidden = true
//                cell.noVotesButton.isHidden = false
//                cell.answer1Button.isHidden = false
//                cell.answer2Button.isHidden = false
//                cell.resultsView.isHidden = true
//                
//            }
//            
//            
//        })
//        
    
    }
    
    func setUpNavigationBarItems() {
        
        let logoutIconImageView = UIImageView()
        let logoutIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.logout(sender:)))
        
        logoutIconImageView.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        logoutIconImageView.addGestureRecognizer(logoutIconTapGesture)
        logoutIconImageView.image = UIImage(named: "logout icon")
        
        
        if profileUserID == currentUserID {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoutIconImageView)
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
    }
    
    func logout(sender: UITapGestureRecognizer) {
        
        print("logout")
        let userDefaults = UserDefaults.standard
        
        do {
            try FIRAuth.auth()?.signOut()
            if userDefaults.string(forKey: "email") != nil {
                
                userDefaults.removeObject(forKey: "email")
                userDefaults.removeObject(forKey: "password")
                
                
            }
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginOrRegisterViewController") as! LoginOrRegisterViewController
            present(vc, animated: true, completion: nil)
            print("You logged out")
            
        } catch let error as Error {
            print("\(error)")
        }
 
        
    }
    

}




