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
import SDWebImage


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var askButton: UIButton!
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
    let currentUserRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
    let pollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls")
    let newPollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls")
    let sentPollsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("polls")
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setUpNavigationBarItems()
        
        separatorView.backgroundColor = UIColor.init(hexString: "D8D8D8")
        
        
        //pulling data from Firebase
        
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

        
        pollRef.queryOrdered(byChild: "expirationDate").observe(.childAdded, with: {
            snapshot in
            
            
            let poll = Poll()
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let calendar = Calendar.current
            let dateString = formatter.string(from: date)
            
           // print("DATE STRING \(dateString)")
            
            let snapshotValue = snapshot.value as! NSDictionary
           

            
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
            
            //print("EXPIRATION DATE \(snapshotValue["expirationDate"] as! String)")
        
            
            let pollForCellDateExpired = formatter.date(from: poll.dateExpired)
            let currentDate = formatter.date(from: dateString)
            let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateExpired!)
            poll.minutesUntilExpiration = minutesLeft.minute!
            
            if snapshotValue["expired"] as! String == "true" {
                poll.isExpired = true
                
            }
            
    
            self.receivedPolls.append(poll)
            self.receivedPolls = self.receivedPolls.sorted(by: {$0.minutesUntilExpiration > $1.minutesUntilExpiration})
        
            self.tableView.reloadData()
            
            
        })
        
        //tableView delegates
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //self.receivedPolls = receivedPolls.sorted(by: {$0.minutesUntilExpiration < $1.minutesUntilExpiration})
        
        tableView.reloadData()
        

    }
    

    func setUpNavigationBarItems () {
       
        let titleImageView = UIImageView(image: UIImage(named: "Logo"))

        titleImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        titleImageView.contentMode = .scaleAspectFit
        
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
       
       
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
              

    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedPolls.count
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? PollTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "pollCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PollTableViewCell
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.userImageTapped(sender:)))
        let linkViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.linkViewTapped(sender:)))
        
        //determining amount of time until the poll expires
        let pollForCell = receivedPolls[indexPath.row]
        print("minutes Remaining \(pollForCell.minutesUntilExpiration)")
        
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
        
        print("minutes TOTAL\(minutesTotalDouble)")
        
        let percentageLeft : Double = (minutesLeftDouble / minutesTotalDouble)*100
        
        let senderUserRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("users").child(receivedPolls[indexPath.row].senderUser)
        let sentToRecipientsRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[indexPath.row].pollID).child("sentTo")
        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[indexPath.row].pollID).child("votes")
        let myVoteReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[indexPath.row].pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!)
        let chatMemberRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[indexPath.row].pollID).child("sentTo")

        var sentToRecipientsString : [String] = [""]
        var numberOfOtherRecipients : Int
        
        if hoursLeft.hour! < 1 {
            cell.timeUntilExpirationLabel.text = "\(minutesLeft.minute!) minutes left"
        }
        
        
        if daysLeft.day! > 1 {
            cell.timeUntilExpirationLabel.text = "\(daysLeft.day!) days left"
        }
        
        
        if daysLeft.day! == 1 {
            cell.timeUntilExpirationLabel.text = "\(daysLeft.day!) day left"
        }
        
        if hoursLeft.hour! > 1, daysLeft.day! < 1 {
            cell.timeUntilExpirationLabel.text = "\(hoursLeft.hour!) hours left"
        }
        
        if hoursLeft.hour! == 1 {
            cell.timeUntilExpirationLabel.text = "\(hoursLeft.hour!) hour left"
        }
        
        
        
        cell.timerView.isHidden = true

        if minutesLeft.minute! > 0, pollForCell.isExpired == false {
            
        print(percentageLeft)
        cell.timerView.isHidden = false
        let chartView = PieChartView()
        
        chartView.frame = CGRect(x: 0, y: 0, width: cell.timerView.frame.size.width, height: 62)
        
        if percentageLeft < 10 {
                chartView.segments = [
                    Segment(color: UIColor.init(hexString: "FFFFFF"), value: CGFloat(100 - percentageLeft)),
                    Segment(color: UIColor.init(hexString: "FF4E56"), value: CGFloat(percentageLeft))
                    
                ]
                
        } else {
            
                chartView.segments = [
            
                    Segment(color: UIColor.init(hexString: "FFFFFF"), value: CGFloat(100 - percentageLeft)),
                    Segment(color: UIColor.init(hexString: "004488"), value: CGFloat(percentageLeft))
                    
                ]
            
        }
            
        cell.timerView.addSubview(chartView)
        
        
        }
        
        //formatting for expired polls
        
        if minutesLeft.minute == 0 {
            //cell.timeUntilExpirationLabel.text = "Expired"
            cell.timeUntilExpirationLabel.isHidden = true
            cell.resultsView.isHidden = true
            cell.answer1Button.titleLabel?.textColor = UIColor.init(hexString: "9B9B9B")
            cell.answer2Button.titleLabel?.textColor = UIColor.init(hexString: "9B9B9B")
            cell.expiredIconImageView.isHidden = false

            let mainPollRef = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID)
            
            pollRef.child(pollForCell.pollID).child("expired").setValue("true")
            mainPollRef.child("expired").setValue("true")
            
        }
        
        
        
        if minutesLeft.minute! < 0 {
            //cell.timeUntilExpirationLabel.text = "Expired"
            cell.timeUntilExpirationLabel.isHidden = true
            cell.answer1Button.titleLabel?.textColor = UIColor.init(hexString: "9B9B9B")
            cell.answer2Button.titleLabel?.textColor = UIColor.init(hexString: "9B9B9B")
            cell.questionStringLabel.alpha = 0.5
            cell.expiredIconImageView.isHidden = false
            
            let mainPollRef = FIRDatabase.database().reference().child("polls").child(pollForCell.pollID)
            
            pollRef.child(pollForCell.pollID).child("expired").setValue("true")
            mainPollRef.child("expired").setValue("true")
            
            
              cell.resultsView.isHidden = true
              cell.answer2Button.isHidden = false
              cell.answer1Button.isHidden = false
            
            
        } else {
            cell.resultsView.isHidden = true
            cell.answer1Button.isHidden = false
            cell.answer2Button.isHidden = false
            cell.answer1Button.isUserInteractionEnabled = true
            cell.answer2Button.isUserInteractionEnabled = true
            cell.expiredIconImageView.isHidden = true
            cell.answer1Button.alpha = 1
            cell.answer2Button.alpha = 1
            cell.viewPollResultsButton.isHidden = false
            cell.answer2ResultBarImageView.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
            cell.answer1ResultBarImageView.layer.borderColor = UIColor.init(hexString: "00CDCE").cgColor
            cell.senderUserImageView.alpha = 1
            cell.questionStringLabel.alpha = 1
            cell.timeUntilExpirationLabel.isHidden = false
            
        }

        
        
        cell.answer1Button.tag = indexPath.row
        cell.answer2Button.tag = indexPath.row
        cell.viewPollResultsButton.tag = indexPath.row
        cell.conversationButton.tag = indexPath.row
        cell.noVotesButton.tag = indexPath.row
        cell.senderUserImageView.tag = indexPath.row
        cell.linkPreviewView.tag = indexPath.row
        cell.senderUserImageView.alpha = 1
        
        cell.separatorImageView.isHidden = false
        
        
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
        
        if cell.questionStringLabel.text == (receivedPolls.last?.questionString){
            cell.separatorImageView.isHidden = true
        }
        

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
        cell.senderUserImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
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
        
        cell.answer1ResultBarImageView.layer.borderWidth = 0.5
        cell.answer1ResultBarImageView.layer.cornerRadius = 4
        cell.answer1ResultBarImageView.layer.masksToBounds = true
        
        cell.answer2ResultBarImageView.layer.borderWidth = 0.5
        cell.answer2ResultBarImageView.layer.cornerRadius = 4
        cell.answer2ResultBarImageView.layer.masksToBounds = true
        
        cell.noVotesButton.addTarget(self, action: #selector(self.reloadResultsButtonTapped(sender:)), for: .touchUpInside)

       
        cell.noVotesButton.isHidden = true
        
        //imagepollviews
        cell.imagePollView.isHidden = true
        cell.imagePollView.layer.borderWidth = 0.2
        cell.imagePollView.layer.borderColor = UIColor.lightGray.cgColor
        cell.imagePollView.layer.cornerRadius = 3.5
        cell.imagePollView.layer.masksToBounds = true
        
    
        if pollForCell.pollQuestionImageURL != "no question image", cell.linkPreviewView.isHidden == true {
            cell.imagePollImageView.sd_setImage(with: URL(string: pollForCell.pollQuestionImageURL))
            cell.imagePollView?.isHidden = false

            cell.resultViewVerticalConstraint.constant = 438
            cell.answerButton1VerticalConstraint.constant = 442
            cell.answerButton2VerticalConstraint.constant = 442
            cell.imagePollViewRightConstraint.constant = 16
            cell.imagePollViewWidthConstraint.constant = 343
            cell.imagePollViewHeightConstraint.constant = 343
            
    
        }
    
        
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

            
                
                if Int(answer1Count!) > 0{
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.answer1ResultBarImageView.frame = answer1frame
                    })
                }
 
                if Int(answer2Count) > 0 {
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.answer2ResultBarImageView.frame = answer2frame
                    })
                }
 
        if pollForCell.isExpired == false {
           
            if answer1Count == 0, Int(answer2Count) > 0 {
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer2TextLabel.textColor = UIColor.white
                cell.answer2PercentageTextLabel.textColor = UIColor.white
                cell.answer1ResultBarImageView.frame = CGRect(x: cell.answer1ResultBarImageView.frame.origin.x, y: cell.answer1ResultBarImageView.frame.origin.y, width: 0, height: cell.answer1ResultBarImageView.frame.height)
            }
            
            if answer2Count == 0, Int(answer1Count!) > 0 {
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer1TextLabel.textColor = UIColor.white
                cell.answer1PercentageTextLabel.textColor = UIColor.white
                cell.answer2ResultBarImageView.frame = CGRect(x: cell.answer2ResultBarImageView.frame.origin.x, y: cell.answer2ResultBarImageView.frame.origin.y, width: 0, height: cell.answer1ResultBarImageView.frame.height)
            }
            
            if Int(answer1Count!) < Int(answer2Count) {
                
               cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
               cell.answer1ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground.png")
               cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
               cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
            }
            
            if Int(answer1Count!) == Int(answer2Count) {
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1ResultBarImageView.isHidden = false
                cell.answer2ResultBarImageView.isHidden = false
                cell.answer1ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground.png")
                cell.answer2ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground.png")
                cell.answer1TextLabel.textColor = UIColor.white
                cell.answer1PercentageTextLabel.textColor = UIColor.white
            }
       
        }
                
                
        }
            
            
            if total == 0 {
                cell.viewPollResultsButton.isHidden = true
                cell.noVotesButton.isHidden = false
            }
    
        })

        myVoteReference.observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let myVote = snapshotValue["voteString"] as! String
            
            if myVote == "answer1" {
              
                if pollForCell.isExpired == false {
                
                cell.answer1Button.isSelected = true
                cell.answer1Button.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
                cell.answer2Button.isSelected = false
                cell.answer2Button.layer.backgroundColor = UIColor.white.cgColor
                }
                
                if pollForCell.isExpired == true {
                    
                   
                    cell.answer1Button.isUserInteractionEnabled = false
                    cell.answer1Button.layer.backgroundColor = UIColor.init(hexString: "EFF0F1").cgColor
                    cell.answer1Button.layer.borderColor = UIColor.init(hexString: "EFF0F1").cgColor
                    cell.answer1Button.titleLabel!.textColor = UIColor.gray
                    cell.answer1Button.alpha = 0.8
                    
                    cell.answer2Button.titleLabel!.textColor = UIColor.gray
                    cell.answer2Button.layer.borderColor = UIColor.init(hexString: "D4D4D4").cgColor
                    cell.answer2Button.layer.backgroundColor = UIColor.white.cgColor
                    cell.answer2Button.isUserInteractionEnabled = false
                    cell.answer2Button.alpha = 0.8
                    //cell.answer1Button.titleLabel?.textColor = UIColor.init(hexString: "9B9B9B")

                    
                    
                }
      
            }
            
            if myVote == "answer2" {
                
                if pollForCell.isExpired == false {
                    
                cell.answer2Button.isSelected = true
                cell.answer2Button.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
                cell.answer1Button.isSelected = false
                cell.answer1Button.layer.backgroundColor = UIColor.white.cgColor
                
                }
                if pollForCell.isExpired == true {
                    
                    cell.answer1Button.isUserInteractionEnabled = false
                    cell.answer1Button.layer.borderColor = UIColor.init(hexString: "D4D4D4").cgColor
                    cell.answer1Button.titleLabel!.textColor = UIColor.gray
                    cell.answer1Button.layer.backgroundColor = UIColor.white.cgColor
                    cell.answer1Button.alpha = 0.8
                    
                    cell.answer2Button.isUserInteractionEnabled = false
                    cell.answer2Button.layer.backgroundColor = UIColor.init(hexString: "EFF0F1").cgColor
                    cell.answer2Button.layer.borderColor = UIColor.init(hexString: "EFF0F1").cgColor
                    cell.answer2Button.titleLabel!.textColor = UIColor.gray
                    cell.answer2Button.alpha = 0.8
                
                    
                }
        
            }
            
            if myVote == "no vote" {
                
                if pollForCell.isExpired == false {
                    
                cell.answer1Button.isSelected = false
                cell.answer2Button.isSelected = false
                cell.answer1Button.layer.backgroundColor = UIColor.white.cgColor
                cell.answer2Button.layer.backgroundColor = UIColor.white.cgColor
                
                }
                
                if pollForCell.isExpired == true {
                    
                    cell.answer1Button.alpha = 0.5
                    cell.answer2Button.alpha = 0.5
                    cell.answer2Button.isUserInteractionEnabled = false
                    cell.answer1Button.isUserInteractionEnabled = false
                    
                }
                
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

        
        if pollForCell.pollURL != "no url"  {
            cell.linkPreviewView.isHidden = false
            cell.resultViewVerticalConstraint.constant = 202
            cell.answerButton1VerticalConstraint.constant = 202
            cell.answerButton2VerticalConstraint.constant = 202
            cell.linkPreviewView.isUserInteractionEnabled = true
            cell.linkPreviewView.addGestureRecognizer(linkViewTapGestureRecognizer)
           
                        }
        
        cell.updateConstraintsIfNeeded()
        
        return cell

    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if receivedPolls[indexPath.row].pollURL != "no url" {
                return 355
            } else if receivedPolls[indexPath.row].pollQuestionImageURL != "no question image" {
                return 615
            }
            return 246
        
        
    }
    
    func tableView( _ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
        {
            let footerView = UIView()
        
            return footerView
        }
    
    func tableView( _ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return 100
        }
   
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let pollToLeave = receivedPolls[indexPath.row]
        print(pollToLeave.pollID)
        
        let delete = UITableViewRowAction(style: .normal, title: "Leave") { action, index in
            print("delete group tapped")
            
        let ref : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls").child(pollToLeave.pollID)
            
        ref.removeValue()
            
        self.deletePoll(poll: pollToLeave)
            
        tableView.reloadData()
            
        UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
            
            
        }
        
        delete.backgroundColor = UIColor.init(hexString: "FF4E56")
        
        
        return [delete]
        
        
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    
        return true
        
    }
    

    func deletePoll(poll: Poll) {
        
        receivedPolls = receivedPolls.filter() {$0 !== poll}
        
    }

    
    
    
 func linkViewTapped (sender : UITapGestureRecognizer) {
    
    
       let linkPreview = sender.view! as UIView

       let url = URL(string: receivedPolls[linkPreview.tag].pollURL)
    
       if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
      }
    }
    
    
    func userImageTapped (sender : UITapGestureRecognizer) {
        
        let imgView = sender.view as! UIImageView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        let transition:CATransition = CATransition()
        
        controller.profileUserID = receivedPolls[imgView.tag].senderUser
    
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

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return receivedPolls[collectionView.tag].groupMembers.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.isHidden = true
        collectionView.showsHorizontalScrollIndicator = false
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pollGroupMemberCell", for: indexPath) as! PollGroupMemberCollectionViewCell
        
        
        cell.groupMemberImage.sd_setImage(with: URL(string : receivedPolls[collectionView.tag].groupMembers[indexPath.item].imageURL1))
    
        cell.groupMemberImage.layer.cornerRadius = cell.groupMemberImage.layer.frame.size.width / 2
        cell.groupMemberImage.layer.masksToBounds = true
        
        return cell
        
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        
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
    
    
    
 func answerButton1Tapped (sender : UIButton){
        sender.isSelected = !sender.isSelected;
    
        let pollAnsweredRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!).child("voteString")
    
        let pollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID)
    
        let answeredPollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls").child(receivedPolls[sender.tag].pollID).child("vote")
        
        let senderUserRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("users").child(receivedPolls[sender.tag].senderUser)
        let buttonIndexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: buttonIndexPath) as! PollTableViewCell

        
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
            
          //  answeredPollRef.setValue("answer1")
            
            
        } else {
            pollAnsweredRef.setValue("no vote")
           // answeredPollRef.setValue("no vote")
        }
        
        
        senderUserRef.observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            cell.senderUserImageView.sd_setImage(with: URL(string : snapshotValue["profileImageURL"] as! String))
            cell.senderUserLabel.text = snapshotValue["fullName"] as! String
            
        })

    }
    
    
func answerButton2Tapped (sender : UIButton){
        
        sender.isSelected = !sender.isSelected;
    
        
        let buttonIndexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: buttonIndexPath) as! PollTableViewCell
    
        print("Answer 2 button selected: \(cell.answer2Button.isSelected)")
        
        let pollAnsweredRef : FIRDatabaseReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID).child("votes").child((FIRAuth.auth()?.currentUser?.uid)!).child("voteString")
        let answeredPollRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("receivedPolls").child(receivedPolls[sender.tag].pollID).child("vote")
        let senderUserRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("users").child(receivedPolls[sender.tag].senderUser)
        
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
                //answeredPollRef.setValue("no vote")
            }
        } else {
            
            selectedButton.updateValue(sender, forKey: sender.tag)
            sender.isSelected = true
            sender.layer.backgroundColor = UIColor.init(hexString: "00CDCE").cgColor
        }
        
        if selectedButton[sender.tag]?.isSelected == true {
            
            pollAnsweredRef.setValue("answer2")
            //answeredPollRef.setValue("answer2")

            
        } else {
            
            pollAnsweredRef.setValue("no vote")
            //answeredPollRef.setValue("no vote")
        }
        
        senderUserRef.observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            cell.senderUserImageView.sd_setImage(with: URL(string : snapshotValue["profileImageURL"] as! String))
            cell.senderUserLabel.text = snapshotValue["fullName"] as! String
            
        })
    
    
        
    }
    

    
func chatButtonTapped (sender : UIButton){

        let myVC = storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        let pollVoteReference = FIRDatabase.database().reference().child("polls").child(receivedPolls[sender.tag].pollID).child("votes")
    

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
        cell.viewPollResultsButton.isSelected = !cell.viewPollResultsButton.isSelected;
        
        if cell.viewPollResultsButton.isSelected == true {
            cell.resultsView.isHidden = false
            cell.answer2Button.isHidden = true
            cell.answer1Button.isHidden = true
        }
        
        if cell.viewPollResultsButton.isSelected == false {
            
            cell.resultsView.isHidden = true
            cell.answer2Button.isHidden = false
            cell.answer1Button.isHidden = false

            
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

        if total > 0, self.receivedPolls[sender.tag].isExpired == false {
            
            print(self.receivedPolls[sender.tag].isExpired)
            
            let answer1frame : CGRect = CGRect(x: cell.answer1ResultBarImageView.frame.origin.x, y: cell.answer1ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer1Count!/total)), height: cell.answer1ResultBarImageView.frame.height)
            
           let answer2frame : CGRect = CGRect(x: cell.answer2ResultBarImageView.frame.origin.x, y: cell.answer2ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer2Count/total)), height: cell.answer1ResultBarImageView.frame.height)
            
            cell.answer1ResultBarImageView.frame = answer1frame
            cell.answer2ResultBarImageView.frame = answer2frame
            
            if answer1Count == 0 {
                
             cell.answer1ResultBarImageView.isHidden = true
                
            }
            
            if answer2Count == 0 {
                
                cell.answer2ResultBarImageView.isHidden = true
                
            }
            
            if answer1Count == 0, Int(answer2Count) > 0 {
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1ResultBarImageView.isHidden = true
                
                cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground")
                cell.answer2TextLabel.textColor = UIColor.white
                cell.answer2PercentageTextLabel.textColor = UIColor.white
                cell.answer2ResultBarImageView.isHidden = false
                
            }
            
            if answer2Count == 0, Int(answer1Count!) > 0 {
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2ResultBarImageView.isHidden = false
                cell.answer1ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground")
                cell.answer1TextLabel.textColor = UIColor.white
                cell.answer1PercentageTextLabel.textColor = UIColor.white
                cell.answer1ResultBarImageView.isHidden = false
            }
            
            if Int(answer1Count!) < Int(answer2Count) {
                
                cell.answer2ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground")
                cell.answer1ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground")
                cell.answer2TextLabel.textColor = UIColor.white
                cell.answer2PercentageTextLabel.textColor = UIColor.white
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                
            }
            
            if Int(answer2Count) < Int(answer1Count!) {
                
                cell.answer1ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground")
                cell.answer2ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground")
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1TextLabel.textColor = UIColor.white
                cell.answer1PercentageTextLabel.textColor = UIColor.white
            }
            
            if Int(answer1Count!) == Int(answer2Count) {
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "00CDCE")
                cell.answer1ResultBarImageView.image = UIImage(named: "MostVotesAnswerBackground")
                cell.answer2ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground")
                cell.answer1TextLabel.textColor = UIColor.white
                cell.answer1PercentageTextLabel.textColor = UIColor.white
            }
            
        
        }
            
        if total > 0, self.receivedPolls[sender.tag].isExpired == true {
            print(self.receivedPolls[sender.tag].isExpired)
                
            let answer1frame : CGRect = CGRect(x: cell.answer1ResultBarImageView.frame.origin.x, y: cell.answer1ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer1Count!/total)), height: cell.answer1ResultBarImageView.frame.height)
                
            let answer2frame : CGRect = CGRect(x: cell.answer2ResultBarImageView.frame.origin.x, y: cell.answer2ResultBarImageView.frame.origin.y, width: CGFloat(334*(answer2Count/total)), height: cell.answer1ResultBarImageView.frame.height)
                
            cell.answer1ResultBarImageView.frame = answer1frame
            cell.answer2ResultBarImageView.frame = answer2frame
            cell.answer1ResultBarImageView.layer.borderColor = UIColor.init(hexString: "DEDEDE").cgColor
            cell.answer2ResultBarImageView.layer.borderColor = UIColor.init(hexString: "DEDEDE").cgColor
                
            if answer1Count == 0, Int(answer2Count) > 0 {
                
                cell.answer1ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground")
                cell.answer1ResultBarImageView.isHidden = true
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                //cell.answer1ResultBarImageView.frame = CGRect(x: cell.answer1ResultBarImageView.frame.origin.x, y: cell.answer1ResultBarImageView.frame.origin.y, width: 0, height: cell.answer1ResultBarImageView.frame.height)
                
                cell.answer2ResultBarImageView.image = UIImage(named: "ExpiredVotesBackground")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                
            }
            
            if answer2Count == 0, Int(answer1Count!) > 0 {
                
                cell.answer1ResultBarImageView.image = UIImage(named: "ExpiredVotesBackground")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "9B9B9B")

                
                cell.answer2ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground")
                cell.answer2ResultBarImageView.isHidden = true
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                //cell.answer2ResultBarImageView.frame = CGRect(x: cell.answer2ResultBarImageView.frame.origin.x, y: cell.answer2ResultBarImageView.frame.origin.y, width: 0, height: cell.answer1ResultBarImageView.frame.height)
            }
            
            if Int(answer1Count!) < Int(answer2Count), answer1Count != 0 {
               
                cell.answer1ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground")
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer1ResultBarImageView.isHidden = false
                
                cell.answer2ResultBarImageView.image = UIImage(named: "ExpiredVotesBackground")
                cell.answer2ResultBarImageView.isHidden = false
                
                
            }
            
            if Int(answer2Count) < Int(answer1Count!), answer2Count != 0 {
                
                cell.answer1ResultBarImageView.image = UIImage(named: "ExpiredVotesBackground")
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer1ResultBarImageView.isHidden = false
                
                
                cell.answer2ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground")
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer2ResultBarImageView.isHidden = false
                
            }
            
            
            if Int(answer1Count!) == Int(answer2Count) {
                cell.answer2ResultBarImageView.image = UIImage(named: "LeastVotesAnswerBackground")
                cell.answer1ResultBarImageView.image = UIImage(named: "ExpiredVotesBackground")
                cell.answer2PercentageTextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer2TextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer1TextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer1PercentageTextLabel.textColor = UIColor.init(hexString: "9B9B9B")
                cell.answer1ResultBarImageView.isHidden = false
                cell.answer1ResultBarImageView.isHidden = false
            }
            
        }
            
            if total == 0 {
                
                cell.noVotesButton.isHidden = false
                cell.resultsView.isHidden = true
                cell.answer1Button.isHidden = false
                cell.answer2Button.isHidden = false
                cell.viewPollResultsButton.isHidden = true
                
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(cgPoint: CGPoint(x: cell.noVotesButton.center.x - 10, y: cell.noVotesButton.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: cell.noVotesButton.center.x + 10, y: cell.noVotesButton.center.y))
                cell.noVotesButton.layer.add(animation, forKey: "position")
                
            }

        
        })
    
    self.view.reloadInputViews()
    
    UIView.animate(withDuration: 0.2) {
        self.view.layoutIfNeeded()
        
        }
    }

    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue){
        
        tableView.reloadData()
        tableView.updateConstraints()
        
    }
    
    @IBAction func unwindToMenuAfterSending(segue: UIStoryboardSegue){
        
        tableView.reloadData()
        tableView.updateConstraints()
        
    
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
            
                
                if cell.noVotesButton.isHidden == false {
                        cell.noVotesButton.isHidden = true
                        cell.viewPollResultsButton.isSelected = false
                        cell.viewPollResultsButton.isHidden = false
                
                    }
            
                
    
            } else {
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                animation.fromValue = NSValue(cgPoint: CGPoint(x: cell.noVotesButton.center.x - 10, y: cell.noVotesButton.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: cell.noVotesButton.center.x + 10, y: cell.noVotesButton.center.y))
                cell.noVotesButton.layer.add(animation, forKey: "position")
            }
            
            
            
            
            
        })
            
    }
  
    

    

}
