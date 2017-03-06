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

class UserHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerPreviewingDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    var userPollsThreaded : [Poll] = []
    
    var threads : [String] = []
    
    var threadDict : [String : [Poll]] = ["":[]]
    
    var threadCountDict : [String: Int] = ["": 0]

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        setUpNavigationBarItems()
        
        
        if( traitCollection.forceTouchCapability == .available){
            
            registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: view)
            
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 181
        tableView.rowHeight = UITableViewAutomaticDimension
        
        threadDict.removeAll()
    
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedPolls").observe(.childAdded, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let threadID = snapshot.key
            let threadCount = Int(snapshot.childrenCount)
            
            self.threadCountDict[threadID] = threadCount
            
            self.threads.append(threadID)
            
            FIRDatabase.database().reference().child("threads").child(threadID).observe(.childAdded, with: {
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
                poll.pollImageDescription = snapshotValue["pollImageDescription"] as! String
                poll.pollImageTitle = snapshotValue["pollImageTitle"] as! String
                poll.pollQuestionImageURL = snapshotValue["questionImageURL"] as! String
                poll.dateExpired = snapshotValue["expirationDate"] as! String
                poll.dateCreated = snapshotValue["dateCreated"] as! String
                
                let formatter = DateFormatter()
                let calendar = Calendar.current
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                
                poll.createdDate = formatter.date(from: poll.dateCreated)!

                if snapshotValue["hasChildren"] as! String == "true" {
                    poll.hasChildren = true
                    
                } else {
                    poll.hasChildren = false
                }

                
                if snapshotValue["expired"] as! String == "true" {
                    poll.isExpired = true
                }else {
                    poll.isExpired = false
                }

                if snapshotValue["isThreadParent"] as! String == "true" {
                    poll.isThreadParent = true
                } else {
                    poll.isThreadParent = false
                }
                
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
                        poll.groupMembers = poll.groupMembers.sorted(by: {$0.vote < $1.vote})
                        self.tableView.reloadData()
                        
                    }
                    
                })
                
                
                if self.threadDict[threadID] == nil {
                    self.threadDict[threadID] = [poll]
                    //self.tableView.reloadData()
                } else {
                    self.threadDict[threadID]!.append(poll)
                    self.threadDict[threadID]! = self.threadDict[threadID]!.sorted(by: {$0.createdDate < $1.createdDate})
                   // self.tableView.reloadData()
                    
                }
                
                print("THREADS Dictionary \(self.threadDict)")
                
            })
            
            print("THREADS ARRAY \(self.threads)")
            
            print("THREADS Dictionary \(self.threadDict[threadID]))")
        
            

        })
        
        
//        let vc1 = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
//        vc1.profileUserID = (FIRAuth.auth()?.currentUser?.uid)!
//        
//        var frame1 = vc1.view.frame
//        frame1.origin.x = self.view.frame.size.width
//        vc1.view.frame = frame1
//        
//        self.addChildViewController(vc1)
//        self.scrollView.addSubview(vc1.view)
//        vc1.didMove(toParentViewController: self)
//        
//        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * 2, height: self.view.frame.size.height-66)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(threads)
        
        let threadID = threads[section]

     //   return self.threadDict[threadID]!.count
        
       return self.threadCountDict[threadID]!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
  
        print("NUMBER OF SECTIONs \(threads.count)")
        
        return threads.count
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//       // return sectionTitles[section]
//        return threads[section]
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let threadID = threads[indexPath.section]
        let pollArrayForThread = self.threadDict[threadID]
        
        let pollForCell : Poll = pollArrayForThread![indexPath.row]
        
        let pollForCellRef = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID)
        let senderUserRef = FIRDatabase.database().reference().child("users").child(pollForCell.senderUser)
        
        let binaryStringCell = tableView.dequeueReusableCell(withIdentifier: "binaryStringPollCell", for: indexPath) as! StringPollTableViewCell
        
        let currentUserVoteRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes").child(currentUserID!)
        
        
        binaryStringCell.contentView.tag = indexPath.section
        
        print("CONTENT VIEW TAG \(binaryStringCell.contentView.tag)")

        //Binary String Cell
        
        //Question Text
        binaryStringCell.questionStringTextView.textContainerInset = UIEdgeInsets.zero
        binaryStringCell.questionStringTextView.textContainer.lineFragmentPadding = 0
        binaryStringCell.questionStringTextView.text = pollForCell.questionString
        
        //pollImage
        
        binaryStringCell.pollImageView.layer.cornerRadius = 4
        binaryStringCell.pollImageView.layer.masksToBounds = true
        binaryStringCell.pollImageView.alpha = 0.8
        binaryStringCell.groupMembersCollectionView.isHidden = false
        
        //Threading Formatting
        
        
        if pollForCell.isThreadParent == false {
            binaryStringCell.senderImageView.isHidden = true
            binaryStringCell.imageViewThread.isHidden = false
            binaryStringCell.threadTopLine.isHidden = false
            binaryStringCell.senderFullNameLabel.isHidden = true
        } else {
            binaryStringCell.senderImageView.isHidden = false
            binaryStringCell.imageViewThread.isHidden = true
            binaryStringCell.threadTopLine.isHidden = true
            binaryStringCell.threadBottomLine.isHidden = false
            binaryStringCell.senderFullNameLabel.isHidden = false
            
        }
        
        if pollForCell.hasChildren == false {
            binaryStringCell.threadBottomLine.isHidden = true
        } else {
            binaryStringCell.threadBottomLine.isHidden = false
        }
        
        
        binaryStringCell.imageViewThread.layer.cornerRadius = binaryStringCell.imageViewThread.layer.frame.width / 2
        binaryStringCell.imageViewThread.layer.backgroundColor = grey.cgColor
        binaryStringCell.imageViewThread.layer.masksToBounds = true
        
        
        if pollForCell.pollQuestionImageURL == "no question image" {
            binaryStringCell.pollImageView.isHidden = true
            binaryStringCell.pollImageViewHeight.constant = 48
            
        } else {
        
        binaryStringCell.pollImageView.isHidden = false
        binaryStringCell.pollImageViewHeight.constant = 124
        binaryStringCell.pollImageView.sd_setImage(with: URL(string: pollForCell.pollQuestionImageURL))
            
        }


        
        
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
            binaryStringCell.answerSelectedView.backgroundColor = actionGreen
            binaryStringCell.expiredIconImageView.isHidden = true
            binaryStringCell.timerView.isHidden = false
            binaryStringCell.conversationIconImageView.image = #imageLiteral(resourceName: "pollConversationIcon")
            
        } else{
            
            binaryStringCell.answerSelectedView.isUserInteractionEnabled = false
            binaryStringCell.answerSelectedView.backgroundColor = grey
            binaryStringCell.answerSelectedView.isHidden = false
            binaryStringCell.conversationIconImageView.isHidden = false
            binaryStringCell.answer1Button.isHidden = true
            binaryStringCell.answer2Button.isHidden = true
            binaryStringCell.expiredIconImageView.isHidden = false
            binaryStringCell.timerView.isHidden = true
            binaryStringCell.conversationIconImageView.image = #imageLiteral(resourceName: "pollConversationIconInactive")
            
      
        }
  
        
        currentUserVoteRef.observe(.value, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let vote = snapshotValue["voteString"] as! String
            
            print(vote)
            
        //user vote based formatting
            if vote == "no vote", pollForCell.isExpired == false {
                binaryStringCell.answer1Button.isHidden = false
                binaryStringCell.answer2Button.isHidden = false
                binaryStringCell.answerSelectedView.isHidden = true
                binaryStringCell.conversationIconImageView.isHidden = true
                
                
            } else if vote == "no vote", pollForCell.isExpired == true {
                binaryStringCell.answer1Button.isHidden = true
                binaryStringCell.answer2Button.isHidden = true
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.conversationIconImageView.isHidden = false
                binaryStringCell.answerSelectedTextLabel.text = "You didn't answer."
                
                
            } else if vote == "answer1", pollForCell.isExpired == false {
                
                binaryStringCell.answer1Button.isHidden = true
                binaryStringCell.answer2Button.isHidden = true
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.conversationIconImageView.isHidden = false
                binaryStringCell.answerSelectedTextLabel.text = "Answered \(pollForCell.answer1String)"
                
            } else if vote == "answer1", pollForCell.isExpired == true {
                
                binaryStringCell.answerSelectedView.isUserInteractionEnabled = false
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.conversationIconImageView.isHidden = false
                binaryStringCell.answerSelectedTextLabel.text = "Answered \(pollForCell.answer1String)"
                
            } else if vote == "answer2", pollForCell.isExpired == false {
                
                binaryStringCell.answer1Button.isHidden = true
                binaryStringCell.answer2Button.isHidden = true
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.conversationIconImageView.isHidden = false
                binaryStringCell.answerSelectedTextLabel.text = "Answered \(pollForCell.answer2String)"
                
            } else if vote == "answer2", pollForCell.isExpired == true {
                
                binaryStringCell.answerSelectedView.isUserInteractionEnabled = false
                binaryStringCell.answerSelectedView.isHidden = false
                binaryStringCell.conversationIconImageView.isHidden = false
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
            FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedPolls").child(threads[indexPath.section]).child(pollForCell.pollID).child("expired").setValue("true")
        FIRDatabase.database().reference().child("threads").child(threads[indexPath.section]).child(pollForCell.pollID).child("expired").setValue("true")
            
            //tableView.reloadData()
            
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let threadID = threads[indexPath.section]
        let pollArrayForThread = threadDict[threadID]!
        let pollForCell : Poll = pollArrayForThread[indexPath.row]

        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
    
        
        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID).child("votes")
        
        
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
        
        myVC.poll = pollForCell
        myVC.chatMembers = pollForCell.groupMembers
        
        
        navigationController?.pushViewController(myVC, animated: true)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let tableViewSection = collectionView.superview!.tag
        let thread = threads[collectionView.superview!.tag]
        let pollArrayForThread = threadDict[thread]!
        let pollForCell = pollArrayForThread[collectionView.tag]
        
        
    
        print("COLLECTION VIEW ITEMS COUNT \(threadDict[threads[collectionView.superview!.tag]]!.count)")
        print("COLLECTION VIEW RECIPIENT COUNT \(pollForCell.groupMembers.count)")

        return pollForCell.groupMembers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let tableViewSection = collectionView.superview!.tag
        let tableViewRow = collectionView.tag
        let thread = threads[collectionView.superview!.tag]
        let pollArrayForThread = threadDict[thread]!
        let pollForCell = pollArrayForThread[collectionView.tag]
        let recipientForCollectionCell = pollForCell.groupMembers[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newGroupMemberCollectionViewCell", for: indexPath) as! PollRecipientCollectionViewCell

        print(recipientForCollectionCell.recipientName)
     
        cell.answerIndicatorImageView.layer.borderWidth = 0.8
        cell.answerIndicatorImageView.layer.borderColor = UIColor.white.cgColor
        cell.recipientImageView.layer.borderWidth = 1
        cell.recipientImageView.layer.borderColor = UIColor.white.cgColor


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
        
        tableView.reloadData()
        
        let tableViewSection = sender.superview!.tag
        let tableViewRow = sender.tag
        let thread = threads[sender.superview!.tag]
        let pollArrayForThread = threadDict[thread]!
        let pollForRow = pollArrayForThread[sender.tag]
        
        
        let buttonIndexPath = IndexPath(row: tableViewRow, section: tableViewSection)
        let binaryStringCell = tableView.cellForRow(at: buttonIndexPath) as! StringPollTableViewCell
        
        UIView.animate(withDuration: 0.2, animations: {
            binaryStringCell.answer2Button.alpha = 0
            binaryStringCell.answer2Button.isHidden = true
            binaryStringCell.answer1Button.alpha = 0
            binaryStringCell.answer1Button.isHidden = true
            
             binaryStringCell.answerSelectedTextLabel.text = "Answered \(pollForRow.answer1String))"
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
        
        
        FIRDatabase.database().reference().child("polls").child(pollForRow.pollID).child("votes").child(currentUserID!).child("voteString").setValue("answer1")
            FIRDatabase.database().reference().child("threads").child(thread).child(pollForRow.pollID).child("votes").child(currentUserID!).child("voteString").setValue("answer1")
        
            binaryStringCell.groupMembersCollectionView.reloadData()
       
        
          }
    
    func answer2ButtonTapped (sender: UIButton) {
       
        let tableViewSection = sender.superview!.tag
        let tableViewRow = sender.tag
        let thread = threads[sender.superview!.tag]
        let pollArrayForThread = threadDict[thread]!
        let pollForRow = pollArrayForThread[sender.tag]
        
        
        let buttonIndexPath = IndexPath(row: tableViewRow, section: tableViewSection)
        let binaryStringCell = tableView.cellForRow(at: buttonIndexPath) as! StringPollTableViewCell
        
        
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
        FIRDatabase.database().reference().child("threads").child(thread).child(pollForRow.pollID).child("votes").child(currentUserID!).child("voteString").setValue("answer2")
        
        
    }
    
    func answeredViewTapped (sender: UITapGestureRecognizer) {
        
        let tableViewSection = sender.view?.superview?.tag
        
        let tableViewRow = sender.view?.tag

        let buttonIndexPath = IndexPath(row: tableViewRow!, section: tableViewSection!)

        let binaryStringCell = tableView.cellForRow(at: buttonIndexPath) as! StringPollTableViewCell
        
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
        
        
        let newDecisionIconImageView = UIImageView()
        let newDecisionIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.newDecisionIconTapped(sender:)))
        
        newDecisionIconImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        newDecisionIconImageView.addGestureRecognizer(newDecisionIconTapGesture)
        
        newDecisionIconImageView.image = #imageLiteral(resourceName: "newDecisionIcon")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newDecisionIconImageView)
        

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
    
    func myProfileImageTapped (sender : UITapGestureRecognizer) {
        
        let imgView = sender.view as! UIImageView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
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
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else {return nil}
        guard let cell = tableView.cellForRow(at: indexPath) else {return nil}
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "PollImageDetailViewController") as? PollImageDetailViewController else { return nil }
        
        let thread = threads[indexPath.section]
        
        let pollArrayForThread = threadDict[thread]
        
        let pollForCell = pollArrayForThread?[indexPath.row]
        
        let photoURL =  pollForCell?.pollQuestionImageURL
        
        
        detailVC.photoURL = photoURL!
        detailVC.preferredContentSize = CGSize(width: 300, height: 300)
        previewingContext.sourceRect = cell.frame
        
        
        if photoURL == "no question image" {return nil}
        
        
        return detailVC
        
        
    }
    

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
        
    }
    
    
    
    @IBAction func unwindToMenuAfterSendingThreadPoll(segue: UIStoryboardSegue){
        
       // tableView.reloadData()
        tableView.updateConstraints()
        
        
    }

    
    
    
}
