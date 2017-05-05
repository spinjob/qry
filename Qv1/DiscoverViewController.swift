//
//  DiscoverViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 5/2/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class DiscoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    var globalPolls : [Poll] = []
    
    let globalPollsRef = FIRDatabase.database().reference().child("globalPolls")
    
    let debateIDArray : [String] = []
    
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        globalPollsRef.child("debates").observe(.childAdded, with: {
            snapshot in
            if snapshot.exists() == false {
                
           
            } else {
                
               let debateID = snapshot.key
                
               
                
            }
        })

        globalPollsRef.observe(.childAdded, with: {
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
            poll.pollQuestionImageURL = snapshotValue["questionImageURL"] as! String
            poll.dateExpired = snapshotValue["expirationDate"] as! String
            poll.dateCreated = snapshotValue["dateCreated"] as! String
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let calendar = Calendar.current
            let dateString = formatter.string(from: date)
            
            let pollForCellDateExpired = formatter.date(from: poll.dateExpired)
            let currentDate = formatter.date(from: dateString)
            let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateExpired!)
            poll.minutesUntilExpiration = minutesLeft.minute!
            
            poll.createdDate = formatter.date(from: poll.dateCreated)!
            
            if snapshotValue["expired"] as! String == "true" {
                poll.isExpired = true
            }else {
                poll.isExpired = false
                
            }
            
            self.globalPollsRef.child(poll.pollID).child("votes").observe(.value, with: {
                snapshot in
                
                if snapshot.exists() == true {
                
                poll.voteCount = Int(snapshot.childrenCount)
                
                
                self.globalPollsRef.child(poll.pollID).child("votes").queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
                    snapshot in
                    
                    poll.answer1Count = Int(snapshot.childrenCount)
                    
                    if (self.globalPolls.contains(where: { $0.pollID == poll.pollID}))
                    { print("poll already added")
                        
                    } else {
                    self.globalPolls.append(poll)
                    self.globalPolls.sort(by: {$1.createdDate > $0.createdDate})
                    self.tableView.reloadData()
                    }
                })
                
                    
                } else {
   
                    if (self.globalPolls.contains(where: { $0.pollID == poll.pollID}))
                    { print("poll already added")
                        
                    } else {
                        poll.voteCount = 0
                        self.globalPolls.append(poll)
                        self.globalPolls.sort(by: {$1.createdDate > $0.createdDate})
                        self.tableView.reloadData()
                    }
                    
                }
                
                
            })
            
            
            

            
        })
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalPolls.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let pollForCell : Poll = globalPolls[indexPath.row]
 
        let cell = tableView.dequeueReusableCell(withIdentifier: "globalPollCell", for: indexPath) as! GlobalPollTableViewCell
        
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("globalVotes").queryOrderedByKey().queryEqual(toValue: pollForCell.pollID).observe(.value, with: {
            snapshot in
            
            if snapshot.exists() == true {
                
                print("snapshot exists")
                print(snapshot)
                
                let answer1Percentage : Double = Double(pollForCell.answer1Count) / Double(pollForCell.voteCount)
                let answer2Percentage : Double = 1 - answer1Percentage
                
                cell.answer1Label.text = ("\(pollForCell.answer1String) (\(Int(answer1Percentage * 100))%)")
                cell.answer2Label.text = ("\(pollForCell.answer2String) (\(Int(answer2Percentage * 100))%)")
                
                let resultsViewWidth : Double = Double(cell.answerResultsView.frame.width)
                
                let answer1ViewWidth = resultsViewWidth * answer1Percentage
                
                cell.answer1Button.isHidden = true
                cell.answer2Button.isHidden = true
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    cell.answerResultsView.isHidden = false
                    cell.answer1ResultsViewWidthConstraint.constant = CGFloat(answer1ViewWidth)
                    
               
                })
                

            } else {
                
                print("snapshot DOES NOTE exist")
                
                cell.answer1Button.isHidden = false
                cell.answer2Button.isHidden = false
                cell.answerResultsView.isHidden = true
                
                
            }
        })
    
        cell.answer1Button.setTitle(pollForCell.answer1String, for: .normal)
        cell.answer2Button.setTitle(pollForCell.answer2String, for: .normal)
       
        cell.answerResultsView.layer.cornerRadius = 4
        cell.answerResultsView.layer.masksToBounds = true
        
        cell.answer1Button.layer.cornerRadius = 4
        cell.answer1Button.layer.masksToBounds = true
        cell.answer1Button.addTarget(self, action: #selector(self.answer1ButtonTapped(sender:)), for: .touchUpInside)
        
        cell.answer2Button.layer.cornerRadius = 4
        cell.answer2Button.layer.masksToBounds = true
         cell.answer2Button.addTarget(self, action: #selector(self.answer2ButtonTapped(sender:)), for: .touchUpInside)
        
        cell.answer1Button.tag = indexPath.row
        cell.answer2Button.tag = indexPath.row
        
        
        
        cell.questionStringTextView.text = pollForCell.questionString
        
        

        return cell
        
    
//        let answeredCell = tableView.dequeueReusableCell(withIdentifier: "globalPollCell", for: indexPath) as! GlobalPollTableViewCell
//        
//        answeredCell.answer1Button.isHidden = true
//        answeredCell.answer2Button.isHidden = true
//        answeredCell.answerResultsView.isHidden = false
//        answeredCell.questionStringTextView.text = pollForCell.questionString
//        answeredCell.answer1Label.text = pollForCell.answer1String
//        answeredCell.answer2Label.text = pollForCell.answer2String
////        
//        if pollForCell.voteCount > 0 {
//            let answer1Percentage = pollForCell.answer1Count / pollForCell.voteCount
//            let resultsViewWidth = Int(answeredCell.answerResultsView.layer.frame.width)
//            
//            let answer1ViewWidth = resultsViewWidth * answer1Percentage
//            
//            answeredCell.answer1ResultsViewWidthConstraint.constant = CGFloat(answer1ViewWidth)
//            
//            
//        }
    
        
     
    }
    
    func answer1ButtonTapped (sender: UIButton) {
        
        let tableViewSection = 0
        let tableViewRow = sender.tag
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let pollForRow = globalPolls[sender.tag]
        
        
        print("IndexPath.row = \(sender.tag)")
        print(pollForRow.pollID)
        
        let buttonIndexPath = IndexPath(row: tableViewRow, section: tableViewSection)
        let cell = tableView.cellForRow(at: buttonIndexPath) as! GlobalPollTableViewCell
        
        UIView.animate(withDuration: 0.5, animations: {
            
            cell.answer1Button.alpha = 0
            cell.answer1Button.isHidden = true
            cell.answer2Button.alpha = 0
            cell.answer2Button.isHidden = true
            
            cell.answerResultsView.alpha = 0
            cell.answerResultsView.isHidden = false
            cell.answerResultsView.alpha = 1

        })
        
        FIRDatabase.database().reference().child("globalPolls").child(pollForRow.pollID).child("votes").child(currentUserID!).child("voteString").setValue("answer1")
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("globalVotes").child(pollForRow.pollID).child("answerChoice").setValue("answer1")
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("globalVotes").child(pollForRow.pollID).child("answerString").setValue(pollForRow.answer1String)
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let pollForRow = globalPolls[indexPath.row]
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        
        
        let pollVoteReference = FIRDatabase.database().reference().child("globalPolls").child(pollForRow.pollID).child("votes")
        
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.value, with: {
            snapshot in
            
            myVC.answer1Count = Int(snapshot.childrenCount)
            
        })
        
        pollVoteReference.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.value, with: {
            snapshot in
            
            myVC.answer2Count = Int(snapshot.childrenCount)
            
        })
        
        
        myVC.undecidedCount = 0
        myVC.poll = pollForRow
       // myVC.chatMembers = pollForRow.groupMembers
        myVC.showEverybody = true
        
        navigationController?.pushViewController(myVC, animated: true)
        
        
    }
    
    
    func answer2ButtonTapped (sender: UIButton) {
        
        let tableViewSection = 0
        let tableViewRow = sender.tag
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let pollForRow = globalPolls[sender.tag]
        
        print("IndexPath.row = \(sender.tag)")
        print(pollForRow.pollID)
        
        let buttonIndexPath = IndexPath(row: tableViewRow, section: tableViewSection)
        let cell = tableView.cellForRow(at: buttonIndexPath) as! GlobalPollTableViewCell
        

        UIView.animate(withDuration: 0.5, animations: {
            
            cell.answer1Button.alpha = 0
            cell.answer1Button.isHidden = true
            cell.answer2Button.alpha = 0
            cell.answer2Button.isHidden = true
            
            
            cell.answerResultsView.alpha = 0
            cell.answerResultsView.isHidden = false
            cell.answerResultsView.alpha = 1


        })
        
        FIRDatabase.database().reference().child("globalPolls").child(pollForRow.pollID).child("votes").child(currentUserID!).child("voteString").setValue("answer2")
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("globalVotes").child(pollForRow.pollID).child("answerChoice").setValue("answer2")
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("globalVotes").child(pollForRow.pollID).child("answerString").setValue(pollForRow.answer2String)
        
    }

}
