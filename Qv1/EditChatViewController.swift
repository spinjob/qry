//
//  EditChatViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/14/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class EditChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var sectionTitles : [String] = [""]
    var answerColors : [String] = [""]
    var answer1Group : [Recipient] = []
    var answer2Group : [Recipient] = []
    var noanswerGroup : [Recipient] = []
    var pollID : String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBarItems()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        let pollRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("polls").child(pollID)
        let pollVoteRef : FIRDatabaseReference =  FIRDatabase.database().reference().child("polls").child(pollID).child("votes")
        let userRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users")

        
        pollVoteRef.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer1").observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let answer1GroupMember : Recipient = Recipient()
            answer1GroupMember.recipientID = snapshotValue["recipientID"] as! String
            answer1GroupMember.recipientName = snapshotValue["recipientName"] as! String
            
            userRef.child(answer1GroupMember.recipientID).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                answer1GroupMember.imageURL1 = snapshotValue["profileImageURL"] as! String
                
                self.answer1Group.append(answer1GroupMember)
                print("Answer 1 Group \(self.answer1Group)")
                self.tableView.reloadData()
                
                
            })
            

            
        })

        pollVoteRef.queryOrdered(byChild: "voteString").queryEqual(toValue: "answer2").observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let answer2GroupMember : Recipient = Recipient()
            answer2GroupMember.recipientID = snapshotValue["recipientID"] as! String
            answer2GroupMember.recipientName = snapshotValue["recipientName"] as! String
            
            userRef.child(answer2GroupMember.recipientID).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                answer2GroupMember.imageURL1 = snapshotValue["profileImageURL"] as! String
                
                self.answer2Group.append(answer2GroupMember)
                print("Answer 2 Group \(self.answer2Group)")
                self.tableView.reloadData()
                
            })
            
            
            
            
        })
        
        pollVoteRef.queryOrdered(byChild: "voteString").queryEqual(toValue: "no vote").observe(.childAdded, with: {
            
            snapshot in
            let snapshotValue = snapshot.value as! NSDictionary
            let noAnswerGroupMember : Recipient = Recipient()
    
            noAnswerGroupMember.recipientID = snapshotValue["recipientID"] as! String
            noAnswerGroupMember.recipientName = snapshotValue["recipientName"] as! String
            
            userRef.child(noAnswerGroupMember.recipientID).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                noAnswerGroupMember.imageURL1 = snapshotValue["profileImageURL"] as! String
                
                self.noanswerGroup.append(noAnswerGroupMember)
                print("No Answer Group \(self.noanswerGroup)")
                self.tableView.reloadData()
                
            })
            
            
            
        })

    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        print("Section TITLES \(self.sectionTitles)")
        return self.sectionTitles.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        let items = [answer1Group, answer2Group, noanswerGroup]
        
        return items[section].count

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = tableView.dequeueReusableCell(withIdentifier: "header") as! ChatListViewHeaderTableViewCell
        view.answerGroupLabel.text = self.sectionTitles[section]
        
        if section == 0 {
            view.answeredStaticLabel.text = "\(answer1Group.count) Answered"
        }
        
        if section == 1 {
            view.answeredStaticLabel.text = "\(answer2Group.count) Answered"
        }
        
        if section == 2 {
            view.answeredStaticLabel.text = "\(noanswerGroup.count) Didn't Answer"
            view.answerGroupLabel.isHidden = true
        }
        view.answerColorIndicatorView.layer.cornerRadius = view.answerColorIndicatorView.layer.frame.width / 2
        view.answerColorIndicatorView.layer.masksToBounds = true
        view.answerColorIndicatorView.backgroundColor = UIColor.init(hexString: self.answerColors[section])
        view.answerColorIndicatorView.isHidden = true
        view.separatorView.backgroundColor = UIColor.init(hexString: self.answerColors[section])
        
        return view
        
    }
   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 0 {
            return 50
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = [answer1Group, answer2Group, noanswerGroup]
        print(items)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMemberListTableViewCell", for: indexPath) as! ChatMemberListTableViewCell
        
        cell.answerGroupMemberImageView.layer.cornerRadius = cell.answerGroupMemberImageView.layer.frame.width / 2
        cell.answerGroupMemberImageView.layer.masksToBounds = true
        
        
        cell.answerGroupMemberImageView.sd_setImage(with: URL(string: items[indexPath.section][indexPath.row].imageURL1))
            
        cell.answerGroupMemberNameLabel.text = items[indexPath.section][indexPath.row].recipientName

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     
        return 60
        
    }
    
    func setUpNavigationBarItems() {
        
        let pageTitle : UILabel = UILabel()
        
        pageTitle.text = "Breakdown"
        
        
        pageTitle.textColor = UIColor.init(hexString: "4B6184")
        
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 35))
        
        pageTitle.frame = titleView.bounds
        titleView.addSubview(pageTitle)
        
        self.navigationItem.titleView = titleView
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
        
        
    }
    



}
