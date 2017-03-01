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
    
    var pollID = ""
    var threadID = ""
    
    var sectionTitles : [String] = [""]
    var answer1Group : [Recipient] = []
    var answer2Group : [Recipient] = []
    var noanswerGroup : [Recipient] = []
    
    var selectedRecipients : [Recipient] = []
    var selectedUserCells : [ThreadAnswerGroupUserTableViewCell] = []
    
    let brightGreen = UIColor.init(hexString: "A8E855")
    let red = UIColor.init(hexString: "FF4E56")
    let actionGreen = UIColor.init(hexString: "00D1D5")
    let blue = UIColor.init(hexString: "004488")
    let grey = UIColor.init(hexString: "D8D8D8")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let pollRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("polls").child(pollID)
        let pollVoteRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("polls").child(pollID).child("votes")
    
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
        

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let items = [answer1Group, answer2Group, noanswerGroup]
        
        return items[section].count
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
    
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
        
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = [answer1Group, answer2Group, noanswerGroup]
        
        let userForCell = items[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "answerGroupMember") as! ThreadAnswerGroupUserTableViewCell
        
        
        cell.answerGroupMemberImageView.layer.cornerRadius = cell.answerGroupMemberImageView.layer.frame.width / 2
        cell.answerGroupMemberImageView.layer.masksToBounds = true
        cell.answerGroupMemberImageView.sd_setImage(with: URL(string: userForCell.imageURL1))
        cell.answerGroupMemberNameLabel.text = userForCell.recipientName
        cell.selectAnswerGroupMemberButton.layer.cornerRadius = cell.selectAnswerGroupMemberButton.layer.frame.width / 2
        cell.selectAnswerGroupMemberButton.layer.masksToBounds = true
    
        
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = tableView.dequeueReusableCell(withIdentifier: "answerGroupHeader") as! ThreadAnswerGroupHeaderTableViewCell
        
        view.answerStringLabel.text = self.sectionTitles[section]
        view.selectAnswerGroupButton.layer.cornerRadius = view.selectAnswerGroupButton.layer.frame.width / 2
        view.selectAnswerGroupButton.layer.backgroundColor = UIColor.white.cgColor
        view.selectAnswerGroupButton.layer.borderWidth = 0.2
        view.selectAnswerGroupButton.setTitle("+", for: .normal)
        view.selectAnswerGroupButton.layer.masksToBounds = true
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.headerViewTapped(sender:)))
        view.selectAnswerGroupButton.addGestureRecognizer(viewTapGesture)
        
        view.selectAnswerGroupButton.tag = section
        view.isUserInteractionEnabled = true
        //view.backgroundColor = grey
        
        if section == 2 {
            view.staticAnsweredLabel.text = "DIDN'T ANSWER"
            view.answerStringLabel.isHidden = true
        }

        return view
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let items = [answer1Group, answer2Group, noanswerGroup]
        let selectedCell = tableView.cellForRow(at: indexPath)! as! ThreadAnswerGroupUserTableViewCell
        selectedCell.contentView.backgroundColor = UIColor.white

        let selectedRecipient = items[indexPath.section][indexPath.row]
        selectedRecipients.append(selectedRecipient)
        selectedUserCells.append(selectedCell)
        
        selectedCell.selectAnswerGroupMemberButton.setTitle("✓", for: .normal)
        selectedCell.selectAnswerGroupMemberButton.setTitleColor(UIColor.white, for: .normal)
        selectedCell.selectAnswerGroupMemberButton.backgroundColor = actionGreen

        
        if selectedUserCells.count > 1 {
        
        }
        
    
        if selectedRecipients.count > 0 {
    
        }
    
        if selectedRecipients.count == 1 {
 
        }
    
    
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
            print(selectedRecipients)

        }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let deSelectedCell = tableView.cellForRow(at: indexPath)! as! ThreadAnswerGroupUserTableViewCell
        
        let items = [answer1Group, answer2Group, noanswerGroup]
        
        let deSelectedRecipient = items[indexPath.section][indexPath.row]
        
        removeCell(cell: deSelectedCell)
        delete(recipient: deSelectedRecipient)
        
        deSelectedCell.selectAnswerGroupMemberButton.setTitle("+", for: .normal)
        deSelectedCell.selectAnswerGroupMemberButton.setTitleColor(grey, for: .normal)
        deSelectedCell.selectAnswerGroupMemberButton.backgroundColor = UIColor.white
            
        if selectedRecipients.count < 2 {
           
                
        }
    }
    
    func removeCell (cell: UITableViewCell) {
        
        selectedUserCells = selectedUserCells.filter() {$0 !== cell}
    }
    
    func delete(recipient: Recipient) {
        selectedRecipients = selectedRecipients.filter() {$0 !== recipient}
    }
    
    func headerViewTapped (sender: UITapGestureRecognizer) {
        let section = (sender.view?.tag)!
        let totalRows = tableView.numberOfRows(inSection: section)
        
        for row in 0..<totalRows {
            
            let indexPath = IndexPath(row: row, section: section )
        
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
    }

        
    }

