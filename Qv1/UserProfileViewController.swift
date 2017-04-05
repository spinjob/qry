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

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

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
    var answeredPollIDs : [String] = []
    //var receivedPolls : [Poll] = []
    
    var liveDecisions : [Poll] = []
    
    var selectedButton : [Int : UIButton] = [:]
    let currentUserID = FIRAuth.auth()!.currentUser!.uid
    var askedPollSelected : Bool = true
    var pollForCell : Poll = Poll()
    var userFriendArray : [Recipient] = []
    var userGroupArray : [Recipient] = []
    var imagePicker = UIImagePickerController()
    
    
    let brightGreen = UIColor.init(hexString: "A8E855")
    let red = UIColor.init(hexString: "FF4E56")
    let actionGreen = UIColor.init(hexString: "00D1D5")
    let blue = UIColor.init(hexString: "004488")
    let grey = UIColor.init(hexString: "D8D8D8")
    let blueGrey = UIColor.init(hexString: "4B6184")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBarItems()
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
       
        let chartView = PieChartView()
        
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
        
        
        userRef.child("votes").observe(.childAdded, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let poll = Poll()

            poll.answer1String = snapshotValue["answerString"] as! String
            poll.pollID = snapshot.key
            
            if poll.answer1String != "no answer" {
              self.answeredPolls.append(poll)
            }


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
            
        
            FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
                
                snapshot in
                
                print("Snapshot \(snapshot.children)")
                
                poll.answer1Count = Int(snapshot.childrenCount)
                print("answer 1 count ON LOAD \(poll.answer1Count)")
                self.tableView.reloadData()
                
            })
           
            FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
                snapshot in
                
                poll.answer2Count = Int(snapshot.childrenCount)
                print("answer 2 count ON LOAD \(poll.answer1Count)")
                self.tableView.reloadData()
                
            })

            
            FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").queryOrdered(byChild: "voteString").queryEqual(toValue: "no vote").observe(.value, with: {
                snapshot in
                
                poll.undecidedCount = Int(snapshot.childrenCount)
                
                print("answer 2 count ON LOAD \(poll.answer1Count)")
                self.tableView.reloadData()
                
                
            })
            
            FIRDatabase.database().reference().child("polls").child(poll.pollID).child("votes").observe(.childAdded, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                let recipient = Recipient()
                
                recipient.recipientID = snapshotValue["recipientID"] as! String
                recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
                recipient.recipientName = snapshotValue["recipientName"] as! String
                recipient.vote = snapshotValue["voteString"] as! String
                
                
                if poll.groupMembers.contains(where: { $0.recipientID == recipient.recipientID})
                { print("group already added")
                    
                } else {
                    
                    poll.groupMembers.append(recipient)
                    print("poll group member count \(poll.groupMembers.count)")
                    poll.groupMembers = poll.groupMembers.sorted(by: {$0.vote < $1.vote})
                    self.tableView.reloadData()
                    
                }
                
            })

            
            if poll.minutesUntilExpiration > 0 {
                self.askedPolls.append(poll)
                self.askedPolls = self.askedPolls.sorted(by: {$0.minutesUntilExpiration < $1.minutesUntilExpiration})
                
                FIRDatabase.database().reference().child("users").child(self.currentUserID).child("receivedPolls").observe(.childAdded, with: {
                    snapshot in
                    
                    let receivedPollID = snapshot.key
                    
                    if poll.pollID == receivedPollID {
                        
                        self.askedPollsObserved.append(poll)
                        self.askedPollsObserved = self.askedPollsObserved.sorted(by: {$0.minutesUntilExpiration < $1.minutesUntilExpiration})
                        
                        print(self.askedPollsObserved)
                        
                     // self.tableView.reloadData()
                    }
                    
                })

                
            }
            
            if snapshotValue["expired"] as! String == "true" {
             //   self.expiredAskedPolls.append(poll)
              //  self.expiredAskedPolls = self.expiredAskedPolls.sorted(by: {$0.minutesUntilExpiration < $1.minutesUntilExpiration})
                
                print("expired conversation")
                
            }
            
            
            
 
        }
        
            self.numberOfAskedLabel.text = String(self.askedPolls.count)
//            self.tableView.reloadData()
        })
        
    

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
    
    
override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    
    
    }
    
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    if profileUserID == currentUserID {
    
    if askedPollSelected == false {
        
        return answeredPolls.count
        
    }
        
         return askedPolls.count
    }
   
    return askedPollsObserved.count
    
 }
    
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

    
    return UITableViewAutomaticDimension
    //return 100
    
}
    
  

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cellIdentifier = "liveDecisionCell"
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProfileLiveDecisionTableViewCell
    let answerCell = tableView.dequeueReusableCell(withIdentifier: "answeredDecisionCell", for: indexPath) as! ProfileAnsweredTableViewCell
    var pollForCell = Poll()
    var answeredPollForCell = Poll()
    
    if askedPollSelected == true{
        
        if profileUserID != currentUserID {
            
            pollForCell = askedPollsObserved[indexPath.row]
            
        } else {
           
            pollForCell = askedPolls[indexPath.row]
            
        }
        
        
        cell.questionTextView.text = pollForCell.questionString
        
        cell.pieChartCenterView.layer.cornerRadius =  cell.pieChartCenterView.layer.frame.width / 2
        cell.pieChartCenterView.layer.masksToBounds = true
        
        cell.timerView.layer.cornerRadius =  cell.timerView.layer.frame.width / 2
        cell.timerView.layer.masksToBounds = true
        
        cell.answerPieChartView.layer.cornerRadius =  cell.answerPieChartView.layer.frame.width / 2
        cell.answerPieChartView.layer.masksToBounds = true
        
        cell.timerViewCenterView.layer.cornerRadius =  cell.timerViewCenterView.layer.frame.width / 2
        cell.timerViewCenterView.layer.masksToBounds = true
        
        cell.groupCollectionView.tag = indexPath.row
        
        print("Poll \(pollForCell.questionString)")
        print("Answer 1 Count \(pollForCell.answer1Count)")
        print("Answer 2 Count \(pollForCell.answer2Count)")
        
        
        let chartView = PieChartView()
        chartView.frame = CGRect(x: 0, y: 0, width: cell.answerPieChartView.frame.size.width, height: 62)
        
        let pollVoteReference : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes")
        
        
        chartView.segments = [
            
            Segment(color: UIColor.init(hexString: "A8E855"), value: CGFloat(pollForCell.answer1Count)),
            Segment(color: UIColor.init(hexString: "FF4E56"), value: CGFloat(pollForCell.answer2Count)),
            Segment(color: UIColor.init(hexString: "D8D8D8"), value: CGFloat(pollForCell.undecidedCount))
        ]
        
        cell.answerPieChartView.addSubview(chartView)
        
        let date = Date()
        let formatter = DateFormatter()
        let timeFormatter = DateFormatter()
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        
        let pollForCellDateExpired = formatter.date(from: pollForCell.dateExpired)
        let pollForCellDateCreated = formatter.date(from: pollForCell.dateCreated)
        
        let dateString = formatter.string(from: date)
        let onlyTimeString = timeFormatter.string(from: pollForCellDateCreated!)
        let onlyDateString = dateFormatter.string(from: pollForCellDateCreated!)
        
        
        
        let currentDate = formatter.date(from: dateString)
        
        
        //time from when the poll was sent
        let hoursSince = calendar.dateComponents([.hour], from: currentDate!, to: pollForCellDateCreated!)
        let minutesSince = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateCreated!)
        let daysSince = calendar.dateComponents([.day], from: currentDate!, to: pollForCellDateCreated!)
        
        if hoursSince.hour! > 24 {
            cell.timeOrDateLabel.text = onlyDateString
        } else {
            cell.timeOrDateLabel.text = onlyTimeString
        }
        
        
        //time left until expiration
        
        let hoursLeft = calendar.dateComponents([.hour], from: currentDate!, to: pollForCellDateExpired!)
        let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateExpired!)
        let daysLeft = calendar.dateComponents([.day], from: currentDate!, to: pollForCellDateExpired!)
        let minutesTotal = calendar.dateComponents([.minute], from: pollForCellDateCreated!, to:pollForCellDateExpired! )
        let minutesLeftDouble : Double = Double(pollForCell.minutesUntilExpiration)
        let minutesTotalDouble : Double = Double(minutesTotal.minute!)
        
        let percentageLeft : Double = (minutesLeftDouble / minutesTotalDouble)*100
        
        if minutesLeft.minute! > 0 {
            
            let timerChartView = PieChartView()
            
            timerChartView.frame = CGRect(x: 0, y: 0, width: 52, height: 52)
            
            
            if hoursLeft.hour! < 1 {
                
                cell.timeLeftAmountLabel.text = "\(minutesLeft.minute!)"
                
                if hoursLeft.hour! == 1{
                    cell.timeLeftUnitLabel.text = "min"
                }
                
                cell.timeLeftUnitLabel.text = "mins"
                
            }
            
            
            if daysLeft.day! > 1 {
                cell.timeLeftAmountLabel.text = "\(daysLeft.day!)"
                
                cell.timeLeftUnitLabel.text = "days"
                
            }
            
            if daysLeft.day! == 1 {
                cell.timeLeftAmountLabel.text = "\(daysLeft.day!)"
                
                cell.timeLeftUnitLabel.text = "day"
                
            }
            
            if hoursLeft.hour! > 1, daysLeft.day! < 1 {
                
                cell.timeLeftAmountLabel.text = "\(hoursLeft.hour!)"
                
                cell.timeLeftUnitLabel.text = "hours"
            }
            
            if hoursLeft.hour! == 1 {
                cell.timeLeftAmountLabel.text = "\(hoursLeft.hour!)"
                
                
                cell.timeLeftUnitLabel.text = "hour"
                
                
            }
            
            
            if percentageLeft < 10 {
                timerChartView.segments = [
                    Segment(color: UIColor.init(hexString: "FFFFFF"), value: CGFloat(100 - percentageLeft)),
                    Segment(color: red , value: CGFloat(percentageLeft))
                    
                ]
                
                cell.timerView.addSubview(timerChartView)
                
                
            } else {
                
                timerChartView.segments = [
                    
                    Segment(color: UIColor.init(hexString: "FFFFFF"), value: CGFloat(100 - percentageLeft)),
                    Segment(color: blue, value: CGFloat(percentageLeft))
                    
                ]
                cell.timerView.addSubview(timerChartView)
            }
            
        }
        
        
    } else {
        
        answeredPollForCell = answeredPolls[indexPath.row]
        answerCell.answerLabel.text = answeredPollForCell.answer1String
        answerCell.answerView.layer.cornerRadius = 4
        answerCell.answerView.layer.borderColor = grey.cgColor
        answerCell.answerView.layer.borderWidth = 1
        answerCell.senderImageView.layer.cornerRadius = answerCell.senderImageView.layer.frame.width / 2
        answerCell.senderImageView.layer.masksToBounds = true

        answerCell.questionTextView.textContainerInset = UIEdgeInsets.zero
        answerCell.questionTextView.textContainer.lineFragmentPadding = 0

        
        FIRDatabase.database().reference().child("polls").child(answeredPollForCell.pollID).observe(.value, with: {
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            answeredPollForCell.senderUser = snapshotValue["senderUser"] as! String
            answeredPollForCell.questionString = snapshotValue["question"] as! String
            
            
            answerCell.questionTextView.text = answeredPollForCell.questionString
            
            FIRDatabase.database().reference().child("users").child(answeredPollForCell.senderUser).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                let profileImageURL = snapshotValue["profileImageURL"] as! String
                
                answerCell.senderNameLabel.text = snapshotValue["fullName"] as! String
                
                answerCell.senderImageView.sd_setImage(with: URL(string: profileImageURL))
                
            })
        })
        
        
        return answerCell
        
    }
    

    return cell
    
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      
        if currentUserID == profileUserID, askedPollSelected == true {
            return true
        }
        
        return false
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
        
        
        let pollForRow = askedPolls[indexPath.row]
        
        print("\(pollForRow.pollID)")
    
        let end = UITableViewRowAction(style: .normal, title: "End") { action, index in
            print("end poll tapped")
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let calendar = Calendar.current
            let dateString = formatter.string(from: date)
         
            self.expirePoll(pollID: pollForRow.pollID)
            
            FIRDatabase.database().reference().child("polls").child(pollForRow.pollID).child("expired").setValue("true")
            FIRDatabase.database().reference().child("polls").child(pollForRow.pollID).child("expirationDate").setValue(dateString)
            

            pollForRow.isExpired = true
            
           
            
            UIView.animate(withDuration: 0.1) {
                
                self.view.layoutIfNeeded()
            }
            
            
        }
        
      return [end]
    }
    
    func expirePoll (pollID : String) {
        
        FIRDatabase.database().reference().child("polls").child(pollID).child("expired").setValue("true")
        
        
        tableView.reloadData()
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let pollForCell = askedPolls[collectionView.tag]
        
        return pollForCell.groupMembers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let tableViewRow = collectionView.tag

        let pollForCell = askedPolls[tableViewRow]
        
        let groupMemberForCell = pollForCell.groupMembers[indexPath.item]
        
        print("GROUP MEMBER COUNT \(pollForCell.groupMembers.count)")
        print("GROUP MEMBER ID \(groupMemberForCell.recipientID)")
        
        
        let groupMemberRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child(groupMemberForCell.recipientID)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileGroupMemberCollectionViewCell", for: indexPath) as! ProfileGroupMemberCollectionViewCell
        
        cell.groupMemberImageView.layer.cornerRadius = cell.groupMemberImageView.layer.frame.width / 2
        cell.groupMemberImageView.layer.masksToBounds = true
        cell.groupMemberImageView.sd_setImage(with: URL(string: groupMemberForCell.imageURL1))
    
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? ProfileLiveDecisionTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        tableViewCell.isUserInteractionEnabled = true
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if askedPollSelected == true {
        let pollForRow = askedPolls[indexPath.row]
        let myVC = storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        
        myVC.poll = pollForRow
        myVC.chatMembers = pollForRow.groupMembers
        myVC.showEverybody = true
    
  
        navigationController?.pushViewController(myVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        }
        
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
   

    @IBAction func friendsButtonTapped(_ sender: Any) {
        
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "FriendsViewController") as! FriendsViewController
        
        myVC.profileUserID = currentUserID
        
        navigationController?.pushViewController(myVC, animated: true)
        
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
    
    func setUpNavigationBarItems() {
        
        let logoutIconImageView = UIImageView()
        let logoutIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.logout(sender:)))
        
        logoutIconImageView.frame = CGRect(x: 0, y: 0, width: 38, height: 18)
        logoutIconImageView.addGestureRecognizer(logoutIconTapGesture)
        logoutIconImageView.image = UIImage(named: "logout icon")
        
        let backHomeIconImageView = UIImageView()
        backHomeIconImageView.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        let backHomeIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.backHome(sender:)))
        backHomeIconImageView.addGestureRecognizer(backHomeIconTapGesture)
        backHomeIconImageView.image = #imageLiteral(resourceName: "backIcon")
        
        
        
        if profileUserID == currentUserID {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoutIconImageView)
            
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backHomeIconImageView)
            
            
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
    }
    
    func backHome (sender: UITapGestureRecognizer) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateViewController(withIdentifier: "UserHomeViewController") as! UserHomeViewController
        let transition:CATransition = CATransition()
    
        
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight

        
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)

        
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




