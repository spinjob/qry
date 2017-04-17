//
//  SelectRecipientsViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/29/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import AddressBook
import Contacts
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseMessaging
import SDWebImage


class SelectRecipientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var poll : Poll = Poll()
    var pollID = ""
    var dictPoll : [NSObject : AnyObject] = [:]
    var recipientList : [Recipient] = []
    var groupRecipientList : [Recipient] = []
    var users : [User] = []
    var selectedRecipients  : [Recipient] = []
    var selectedUserCells : [UITableViewCell] = []
    var selectedGroupCells : [UITableViewCell] = []
    var questionImage : UIImage = UIImage()
    var questionImageURL : String = "no question image"
    var contactStore = CNContactStore()
    var currentUserRecipientDict : [NSObject : AnyObject] = [:]
    var currentUserVoterDict : [NSObject : AnyObject] = [:]
    let currentUserID : String = (FIRAuth.auth()?.currentUser!.uid)!
    var currentUserName : String = ""
    let threadID : String = UUID().uuidString

    var groupToEdit : Recipient = Recipient()
    var groupMembers : [Recipient] = []
    
    var pollRecipientList : [Recipient] = []

    
    let sectionTitles = ["Threads","Lists", "Friends"]
    
    let brightGreen = UIColor.init(hexString: "A8E855")
    let red = UIColor.init(hexString: "FF4E56")
    let actionGreen = UIColor.init(hexString: "00D1D5")
    let blue = UIColor.init(hexString: "004488")
    let grey = UIColor.init(hexString: "D8D8D8")
    
    
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
        
    }()
    
    
    
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var createGroupButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var sendButtonHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dictPoll)
        print(poll.pollID)
        print("View Did Load Question Image \(questionImage)")
        
        
        let pollRef = FIRDatabase.database().reference().child("polls").child(pollID)
        let userRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList")
        let currentUserRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont(name: "Proxima Nova", size: 20)!]
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    
        sendButtonHeightConstraint.constant = 0
        createGroupButtonHeightConstraint.constant = 0
        
        print("Current User ID \(currentUserID)")
        
        FIRDatabase.database().reference().child("polls").queryOrdered(byChild: "senderUser").queryEqual(toValue: currentUserID).observe(.childAdded, with: {
            snapshot in

            print("MY LIVE POLLS SNAPSHOT \(snapshot)")
            
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let recipient = Recipient()
            
            recipient.recipientName = snapshotValue["question"] as! String
            recipient.recipientID = snapshot.key as! String
            recipient.imageURL1 = snapshotValue["expirationDate"] as! String
            recipient.imageURL2 = snapshotValue["dateCreated"] as! String
            recipient.imageURL3 = snapshotValue["expired"] as! String
            recipient.imageURL4 = snapshotValue["answer1"] as! String
            recipient.tag = snapshotValue["answer2"] as! String
            recipient.phoneNumber = snapshotValue["isThreadParent"] as! String
            recipient.vote = snapshotValue["threadID"] as! String
            
            let date = Date()
            let formatter = DateFormatter()
            
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            let calendar = Calendar.current
            let dateString = formatter.string(from: date)
            let dateOfExpiration = formatter.date(from: recipient.imageURL1)
            let currentDate = formatter.date(from: dateString)
            let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: dateOfExpiration!)
            
            
            recipient.minutesToExpiration = minutesLeft.minute!
            
            print(recipient)
            print(recipient.phoneNumber)
            
            if recipient.minutesToExpiration > 0 {
                self.pollRecipientList.append(recipient)
                self.pollRecipientList = self.pollRecipientList.sorted(by: {$0.imageURL1 < $1.imageURL1})
                self.tableView.reloadData()
                
            }
            
        })
        
        
        currentUserRef.observe(.value, with: {
            
            snapshot in
            let recipient = Recipient()
            let snapshotValue = snapshot.value as! NSDictionary
            recipient.recipientName = snapshotValue["fullName"] as! String
            self.currentUserName = recipient.recipientName
            recipient.imageURL1 = snapshotValue["profileImageURL"] as! String
            recipient.recipientID = snapshotValue["uID"] as! String
        
            
            
            self.currentUserRecipientDict = ["recipientName" as NSObject: (recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (recipient.recipientID) as AnyObject, "tag" as NSObject: "user" as AnyObject, "hasLeft" as NSObject: "0" as AnyObject]
            
            self.currentUserVoterDict = ["recipientName" as NSObject: (recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (recipient.recipientID) as AnyObject, "voteString" as NSObject: "no vote" as AnyObject]
            
            
            
        })
     
        userRef.queryOrdered(byChild: "tag").queryEqual(toValue: "group").observe(.childAdded, with: {
            
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            var group : Recipient = Recipient()
            
            group.recipientName = snapshotValue["recipientName"] as! String
            group.recipientID = snapshotValue["recipientID"] as! String
            group.tag = snapshotValue["tag"] as! String
            group.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            
            self.groupRecipientList.append(group)
            
        })
        
        userRef.queryOrdered(byChild: "tag").queryEqual(toValue: "user").observe(FIRDataEventType.childAdded, with: {(snapshot) in
            print(snapshot)
            
            
            let recipient = Recipient()
            
            let snapshotvalue = snapshot.value as! NSDictionary
            
            recipient.recipientName = snapshotvalue["recipientName"] as! String
            recipient.recipientID = snapshotvalue["recipientID"] as! String
            recipient.tag = snapshotvalue["tag"] as! String
            //recipient.imageURL1 = snapshotvalue["recipientImageURL1"] as! String
            recipient.phoneNumber = snapshotvalue["phoneNumber"] as! String
            
            FIRDatabase.database().reference().child("users").child(recipient.recipientID).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                
                recipient.imageURL1 = snapshotValue["profileImageURL"] as! String
               
                if recipient.recipientID == self.currentUserID {
                    
                    print("current user")
                } else if self.searchForContactUsingPhoneNumber(phoneNumber: recipient.phoneNumber).count > 0 {
                    
                    self.recipientList.append(recipient)
                    self.recipientList.sort(by: {$0.recipientName > $1.recipientName})
                }
                
                self.tableView.reloadData()
                

                
            })
        
    })

        
    }
    
    func editGroupScreen (sender : UIButton!) {
        
        groupToEdit = groupRecipientList[sender.tag]
        
        performSegue(withIdentifier: "editGroupSegue", sender: groupToEdit)
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let items = [pollRecipientList, groupRecipientList, recipientList]
        
        if items[indexPath.section][indexPath.row].tag == "group" {
            return 80
        }
        
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = [pollRecipientList, groupRecipientList, recipientList]
        
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      let items = [pollRecipientList, groupRecipientList, recipientList]
        
      let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
        
      cell.tag = indexPath.row
        
      cell.userProfileImageView.layer.cornerRadius =  cell.userProfileImageView.layer.frame.size.width / 2
      cell.userProfileImageView.layer.masksToBounds = true
        
      let recipientForCell = items[indexPath.section][indexPath.row]
        

      cell.userNameLabel.text = recipientForCell.recipientName
        
      cell.userProfileImageView.sd_setImage(with: URL(string : recipientForCell.imageURL1))
       
    //group cell
        
      let groupCell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as! GroupTableViewCell
        
        
      groupCell.groupMember1ImageView.sd_setImage(with: URL(string : recipientForCell.imageURL1))
      groupCell.groupMember1ImageView.layer.cornerRadius = 4
      groupCell.groupMember1ImageView.layer.masksToBounds = true
      
      groupCell.groupNameLabel.text = recipientForCell.recipientName
      groupCell.tag = indexPath.row
      groupCell.groupMemberCollectionView.tag = indexPath.row
      groupCell.groupMemberCollectionView.isHidden = true
        
      groupCell.editButton.tag = indexPath.row
      groupCell.editButton.addTarget(self, action: #selector(self.editGroupScreen(sender:)), for: .touchUpInside)
    
    
    //poll cell
        
        let pollCell = tableView.dequeueReusableCell(withIdentifier: "selectThreadCell") as! SelectThreadTableViewCell
        
        pollCell.questionLabel.text = recipientForCell.recipientName
        pollCell.pieChartCenterView.layer.cornerRadius =  pollCell.pieChartCenterView.layer.frame.width / 2
        pollCell.timerView.layer.cornerRadius =  pollCell.timerView.layer.frame.width / 2

        
if indexPath.section == 0 {
    
        let date = Date()
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: date)
        
        let pollForCellDateExpired = formatter.date(from: recipientForCell.imageURL1)
        let pollForCellDateCreated = formatter.date(from: recipientForCell.imageURL2)
        let currentDate = formatter.date(from: dateString)
        
        let hoursLeft = calendar.dateComponents([.hour], from: currentDate!, to: pollForCellDateExpired!)
        let minutesLeft = calendar.dateComponents([.minute], from: currentDate!, to: pollForCellDateExpired!)
        let daysLeft = calendar.dateComponents([.day], from: currentDate!, to: pollForCellDateExpired!)
        let minutesTotal = calendar.dateComponents([.minute], from: pollForCellDateCreated!, to:pollForCellDateExpired! )
        let minutesLeftDouble : Double = Double(recipientForCell.minutesToExpiration)
        let minutesTotalDouble : Double = Double(minutesTotal.minute!)
        
        let percentageLeft : Double = (minutesLeftDouble / minutesTotalDouble)*100
        
        if hoursLeft.hour! < 1 {
            pollCell.timeLeftNumberLabel.text = "\(minutesLeft.minute!)"
            
            if hoursLeft.hour! == 1{
                pollCell.timeLeftUnitLabel.text = "minute"
            }
            
            pollCell.timeLeftUnitLabel.text = "minutes"
            
        }
        
        
        if daysLeft.day! > 1 {
            pollCell.timeLeftNumberLabel.text = "\(daysLeft.day!)"
            
            pollCell.timeLeftUnitLabel.text = "days"
            
        }
        
        if daysLeft.day! == 1 {
            pollCell.timeLeftNumberLabel.text = "\(daysLeft.day!)"
            
            pollCell.timeLeftUnitLabel.text = "day"
            
        }
        
        if hoursLeft.hour! > 1, daysLeft.day! < 1 {
            
            pollCell.timeLeftNumberLabel.text = "\(hoursLeft.hour!)"
            
            pollCell.timeLeftUnitLabel.text = "hours"
        }
        
        if hoursLeft.hour! == 1 {
            pollCell.timeLeftNumberLabel.text = "\(hoursLeft.hour!)"
            
            pollCell.timeLeftUnitLabel.text = "hour"

        }
        
        let chartView = PieChartView()
        
        chartView.frame = CGRect(x: 0, y: 0, width: pollCell.timerView.frame.size.width, height: 46)
        
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
        
        pollCell.timerView.addSubview(chartView)

        return pollCell
       
    } else if indexPath.section == 1{
        return groupCell
    }
       
    else {
        
        return cell
        
        }
    
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let view = tableView.dequeueReusableCell(withIdentifier: "sendToHeaderCell") as! SendToHeaderTableViewCell
        
        view.backgroundColor = UIColor.white
        view.contentView.backgroundColor = UIColor.white
        
        if section == 0 {
            view.sectionTitleLabel.text = "FROM POLL RESPONSES"
            view.sectionImageView.image = #imageLiteral(resourceName: "addToDecisionThreadIcon")
        }
        if section == 1 {
            view.sectionTitleLabel.text = "QUICK GROUPS"
            view.sectionImageView.image = #imageLiteral(resourceName: "quickLists")
        }
        
        if section == 2 {
            view.sectionTitleLabel.text = "FRIENDS"
            view.sectionImageView.image = #imageLiteral(resourceName: "friendsIcon")
        }

        
        return view.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }

    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientList[collectionView.tag].recipientID).child("groupMembers")
    
        var collectionViewCellCount : Int = 2
        ref.observe(.childAdded, with: {
            
            snapshot in
            collectionViewCellCount = Int(snapshot.childrenCount)

        })
        
        
        return collectionViewCellCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   
        let items = [groupRecipientList, recipientList]
        
        let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(items[indexPath.section][indexPath.row].recipientID).child("groupMembers")
        
        collectionView.showsHorizontalScrollIndicator = false
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pollGroupMemberCell", for: indexPath) as! GroupMemberCollectionViewCell
        
        cell.groupMemberImageView.layer.cornerRadius = cell.groupMemberImageView.layer.frame.size.width / 2
        cell.groupMemberImageView.layer.masksToBounds = true
        
        var listMembers : [Recipient] = []
        
        ref.observe(.childAdded, with: {
            snapshot in
        
            
            
            let recipient = Recipient()
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            recipient.recipientName = snapshotValue["recipientName"] as! String
            recipient.recipientID = snapshotValue["recipientID"] as! String
            recipient.tag = snapshotValue["tag"] as! String
            recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
            
            listMembers.append(recipient)
            
            cell.groupMemberImageView.sd_setImage(with: URL(string:listMembers[collectionView.tag].imageURL1))
        
        })
        
        
        
        return cell
        
    }
 
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.white
        
        let items = [pollRecipientList, groupRecipientList, recipientList]
        
        if indexPath.section == 2 {
        
        

        let selectedRecipient = items[indexPath.section][indexPath.row]
        selectedRecipients.append(selectedRecipient)
        selectedUserCells.append(selectedCell)
        
            if selectedUserCells.count > 1 {
                createGroupButtonHeightConstraint.constant = 50
                createGroupButton.isHidden = false
            }
            
            
            print("PRINTED Selected Recipients from USER CELL \(selectedRecipients)")
            
        }

        if selectedRecipients.count > 0 {
            sendButtonHeightConstraint.constant = 50
        }
        
        if selectedRecipients.count == 1 {
           createGroupButton.isHidden = true
        }
        

        

        if indexPath.section == 1 {
   
            selectedGroupCells.append(selectedCell)
            
           
            let ref = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(items[indexPath.section][indexPath.row].recipientID).child("groupMembers")
            
            ref.observe(FIRDataEventType.childAdded, with: {(snapshot) in
                
                let recipient = Recipient()
                
                let snapshotValue = snapshot.value as! NSDictionary
                
                recipient.recipientName = snapshotValue["recipientName"] as! String
                recipient.recipientID = snapshotValue["recipientID"] as! String
                recipient.tag = snapshotValue["tag"] as! String
                recipient.imageURL1 = snapshotValue["recipientImageURL1"] as! String
                
                self.groupMembers.append(recipient)
                
                self.groupMembers.forEach { (Recipient) in
                    
                    let indexToDisable = self.recipientList.index(where: { $0.recipientID.contains(Recipient.recipientID) == true})
                    let indexPathForGroupMember = NSIndexPath(row: indexToDisable!, section: 2)
                    
                    
                    tableView.cellForRow(at: indexPathForGroupMember as IndexPath)?.isUserInteractionEnabled = false
                    tableView.cellForRow(at: indexPathForGroupMember as IndexPath)?.alpha = 0.5
                    
                    if self.selectedRecipients.contains(where: { $0.recipientID == Recipient.recipientID}) {
                        
                        print("already selected")
                        
                    }  else {
                        
                        self.selectedRecipients.append(Recipient)
                        print(self.selectedRecipients)
                    
                        if self.selectedRecipients.count > 0 {
                            self.sendButtonHeightConstraint.constant = 50
                            self.createGroupButton.isHidden = true
                        }
                        
    
                    }
                }
                
            self.groupMembers.removeAll(keepingCapacity: true)
            
            })

            print("PRINTED Selected Recipients from GROUP CELL \(selectedRecipients)")
            }
        
        if indexPath.section == 0 {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SendToThreadViewController") as! SendToThreadViewController
            let transition:CATransition = CATransition()
            let pollParentID : String = pollRecipientList[indexPath.row].recipientID
            
            
            
            FIRDatabase.database().reference().child("polls").child(pollParentID).observe(.value, with: {
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                print(snapshot)
                
                controller.parentThreadID = snapshotValue["threadID"] as! String
                controller.poll = self.poll
                
                print(snapshotValue["threadID"] as! String)
                
            })
            
            
            
            controller.dictPoll = dictPoll
            controller.pollID = pollID
            controller.parentPollID = pollRecipientList[indexPath.row].recipientID
            controller.answer1String = pollRecipientList[indexPath.row].imageURL4
            controller.answer2String = pollRecipientList[indexPath.row].tag
            controller.questionString = pollRecipientList[indexPath.row].recipientName
            controller.sectionTitles = [pollRecipientList[indexPath.row].imageURL4, pollRecipientList[indexPath.row].tag, "No Answer"]
            
            
            controller.parentThreadID = pollRecipientList[indexPath.row].vote
            
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn
            transition.subtype = kCATransitionFromRight
            self.navigationController!.view.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(controller, animated: false)
            
        }
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
            self.updateViewConstraints()
        }
        
    }
  
    func removeCell (cell: UITableViewCell) {
        selectedUserCells = selectedUserCells.filter() {$0 !== cell}
    }
    
    func removeGroupCell (cell: UITableViewCell) {
        selectedGroupCells = selectedUserCells.filter() {$0 !== cell}
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        let deSelectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        let items = [pollRecipientList, groupRecipientList, recipientList]
        
        let deSelectedRecipient = items[indexPath.section][indexPath.row]
        
        if indexPath.section == 2 {
            removeCell(cell: deSelectedCell)
            delete(recipient: items[indexPath.section][indexPath.row])
            
           if selectedRecipients.count < 2 {
                
            createGroupButtonHeightConstraint.constant = 0
            createGroupButton.isHidden = true
                
            }
        }
        
        if indexPath.section == 1 {
            
            removeGroupCell(cell: deSelectedCell)
            
            if selectedGroupCells.count == 0 {
                selectedRecipients.removeAll()
            }
            
            let groupRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser!.uid)!).child("recipientList").child(items[indexPath.section][indexPath.row].recipientID).child("groupMembers")
            
            groupRef.observe(.childAdded, with: {
                
                snapshot in
                let snapshotValue = snapshot.value as! NSDictionary
                var groupMember : Recipient = Recipient()
                
                groupMember.recipientName = snapshotValue["recipientName"] as! String
                groupMember.recipientID = snapshotValue["recipientID"] as! String
                groupMember.tag = snapshotValue["tag"] as! String
                groupMember.imageURL1 = snapshotValue["recipientImageURL1"] as! String
                
                let indexToEnable = self.recipientList.index(where: { $0.recipientID.contains(groupMember.recipientID) == true})
                let indexPathForGroupMember = NSIndexPath(row: indexToEnable!, section: 2)
                
                
                tableView.cellForRow(at: indexPathForGroupMember as IndexPath)?.isUserInteractionEnabled = true
                tableView.cellForRow(at: indexPathForGroupMember as IndexPath)?.alpha = 1
                tableView.deselectRow(at: indexPathForGroupMember as IndexPath, animated: true)
                
                self.selectedRecipients = self.selectedRecipients.filter() {$0 !== groupMember}

            
            })
            
            
        }

        
        if selectedRecipients.count < 1 {
            sendButtonHeightConstraint.constant = 0
        }
        
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
        print(self.selectedRecipients)
    }
    
    
    @IBAction func createListButtonTapped(_ sender: Any) {
        
        
        var newRecipient : [NSObject : AnyObject] = [ : ]
        
        
        let selectedRecipientNames = selectedRecipients.map { $0.recipientName}
        print(selectedRecipientNames)
        
        let selectedRecipientIDs = selectedRecipients.map { $0.recipientID}
        print(selectedRecipientIDs)
        
        let selectedRecipientNamesString = selectedRecipientNames.joined(separator: ", ")
        print(selectedRecipientNamesString)
        
        let selectedRecipientIDString = selectedRecipientIDs.joined(separator: "+")
        print(selectedRecipientIDString)
        
        let recipientID = UUID().uuidString
        
        
        let ref : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList")
        
        newRecipient = ["recipientName" as NSObject: (selectedRecipientNamesString) as AnyObject, "recipientImageURL1" as NSObject: (selectedRecipients.first!.imageURL1 ) as AnyObject,"recipientImageURL2" as NSObject : (selectedRecipients[1].imageURL1 as AnyObject), "recipientID" as NSObject: (recipientID ) as AnyObject, "tag" as NSObject: "group" as AnyObject]
        
        
        print(newRecipient)
        
        
        let recipientListRef : FIRDatabaseReference = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("recipientList").child(recipientID)
        
        recipientListRef.setValue(newRecipient)
        
        selectedRecipients.forEach { (Recipient) in
            
            let groupMember = ["recipientName" as NSObject: (Recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (Recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (Recipient.recipientID) as AnyObject, "tag" as NSObject: "user" as AnyObject]
            
            recipientListRef.child("groupMembers").child(Recipient.recipientID).setValue(groupMember)
            
        }
        
        selectedRecipients.removeAll()
        
        tableView.reloadData()
        

    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        let pollRef = FIRDatabase.database().reference().child("polls").child(pollID)
        let currentUserID = FIRAuth.auth()?.currentUser?.uid
        let threadRef = FIRDatabase.database().reference().child("threads").child(threadID)
        
        let currentDate = Date()
        var expirationDate = Date()
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        
        print("POLL DICTIONARY \(dictPoll)")
        print("THREAD ID \(threadID)")
        print("CURRENT USER \(currentUserID)")
        
        
        
        pollRef.setValue(dictPoll)
        pollRef.child("threadID").setValue(threadID)
        pollRef.child("isThreadParent").setValue("true")
       
        threadRef.child(pollID).setValue(dictPoll) 
        threadRef.child(pollID).child("isThreadParent").setValue("true")
        
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: currentDate)
        
        
        self.selectedRecipients.forEach { (Recipient) in
        
            
        //notifications
        let notificationID = UUID().uuidString
        let notificationRef = FIRDatabase.database().reference().child("notifications").child(notificationID)
            
        let notificationDict : [NSObject : AnyObject]  = ["recipientID" as NSObject: Recipient.recipientID as AnyObject, "senderID" as NSObject: currentUserID as AnyObject, "activity type" as NSObject: "poll received" as AnyObject, "time sent" as NSObject: dateString as AnyObject, "is unread" as NSObject: "true" as AnyObject, "pollID" as NSObject: pollID as AnyObject, "messageID" as NSObject: "NA" as AnyObject]
        
        notificationRef.setValue(notificationDict)
            
        sendNotificationToUser(user: Recipient.recipientID, message: poll.questionString, name: currentUserName, answer1: poll.answer1String, answer2: poll.answer2String, pollID: poll.pollID)
            
            
        //add each selected user to sentTo and votes Arrays
            
        let recipientID = Recipient.recipientID
        print(recipientID)
            
        let recipientDict : [NSObject : AnyObject] = ["recipientName" as NSObject: (Recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (Recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (recipientID) as AnyObject, "tag" as NSObject: "user" as AnyObject, "hasLeft" as NSObject: "0" as AnyObject]
       
        let voter : [NSObject : AnyObject] = ["recipientName" as NSObject: (Recipient.recipientName) as AnyObject, "recipientImageURL1" as NSObject: (Recipient.imageURL1) as AnyObject, "recipientID" as NSObject: (recipientID) as AnyObject, "voteString" as NSObject: "no vote" as AnyObject]
        
        let ref = FIRDatabase.database().reference().child("users").child(recipientID).child("receivedThreads").child(threadID).child(pollID)
        let receivedPollRef = FIRDatabase.database().reference().child("users").child(recipientID).child("receivedPolls").child(pollID)
        let sentToRef = FIRDatabase.database().reference().child("polls").child(pollID).child("sentTo").child(recipientID)
        let voteRef = FIRDatabase.database().reference().child("polls").child(pollID).child("votes").child(recipientID)
            
        
        sentToRef.setValue(recipientDict)
        voteRef.setValue(voter)
        threadRef.child(pollID).child("threadID").setValue(threadID)
        threadRef.child(pollID).child("sentTo").child(recipientID).setValue(recipientDict)
        threadRef.child(pollID).child("votes").child(recipientID).setValue(voter)

        ref.setValue(self.dictPoll)
        ref.child("threadID").setValue(threadID)
        ref.child("isThreadParent").setValue("true")
        ref.child("questionImageURL").setValue(self.questionImageURL)
            
        receivedPollRef.setValue(self.dictPoll)
        receivedPollRef.child("questionImageURL").setValue(self.questionImageURL)
            
            FIRDatabase.database().reference().child("users").child(recipientID).child("votes").child(pollID).child("answerChoice").setValue("no answer")
            FIRDatabase.database().reference().child("users").child(recipientID).child("votes").child(pollID).child("answerString").setValue("no answer")
            

     }
        
        //currentuser references
    
    
       FIRDatabase.database().reference().child("polls").child(pollID).child("sentTo").child(currentUserID!).setValue(self.currentUserRecipientDict)
       FIRDatabase.database().reference().child("polls").child(pollID).child("votes").child(currentUserID!).setValue(self.currentUserVoterDict)
    
        FIRDatabase.database().reference().child("threads").child(threadID).child(pollID).child("votes").child(currentUserID!).setValue(self.currentUserVoterDict)
        FIRDatabase.database().reference().child("threads").child(threadID).child(pollID).child("sentTo").child(currentUserID!).setValue(self.currentUserRecipientDict)
        
        
     FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedPolls").child(pollID).setValue(dictPoll)
        
       FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedThreads").child(threadID).child(pollID).setValue(dictPoll)
       FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedThreads").child(threadID).child(pollID).child("threadID").setValue(threadID)
       FIRDatabase.database().reference().child("users").child(currentUserID!).child("receivedThreads").child(threadID).child(pollID).child("isThreadParent").setValue("true")
        
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("votes").child(pollID).child("answerChoice").setValue("no answer")
        FIRDatabase.database().reference().child("users").child(currentUserID!).child("votes").child(pollID).child("answerString").setValue("no answer")
        
    
    
        
       
      self.performSegue(withIdentifier: "unwindToMenuAfterSendingNewThreadPoll", sender: self)
    
    }

    
    @IBAction func unwindAfterEditing(segue: UIStoryboardSegue){
    
        tableView.reloadData()
    
    
    }

    
    func delete(recipient: Recipient) {
        selectedRecipients = selectedRecipients.filter() {$0 !== recipient}
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGroupSegue" {
        let nextVC = segue.destination as! EditGroupViewController
        nextVC.group = sender as! Recipient
            
        
        print(nextVC.group)
    
            }
        }
    
    
    func searchForContactUsingPhoneNumber(phoneNumber: String) -> [CNContact] {
        
        
        let recipient = Recipient()
        var matchingRecipient = Recipient()
        var result: [CNContact] = []
        
        for contact in self.contacts {
            
            if (!contact.phoneNumbers.isEmpty) {
                
                let phoneNumberToCompareAgainst = phoneNumber.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                for phoneNumber in contact.phoneNumbers {
                    if let phoneNumberStruct = phoneNumber.value as? CNPhoneNumber {
                        let phoneNumberString = phoneNumberStruct.stringValue
                        let phoneNumberToCompare = phoneNumberString.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                        
                        if phoneNumberToCompare == phoneNumberToCompareAgainst {
                            
                            recipient.recipientName = "\(contact.givenName) \(contact.familyName)"
                            recipient.phoneNumber = phoneNumberToCompare
                            
                            matchingRecipient = recipient
                            
                            print("CONTACT MATCH FOUND \(matchingRecipient)")
                            result.append(contact)
                        } else if phoneNumberToCompare == "1\(phoneNumberToCompareAgainst)" {
                            recipient.recipientName = "\(contact.givenName) \(contact.familyName)"
                            recipient.phoneNumber = phoneNumberToCompare
                            
                            matchingRecipient = recipient
                            
                            print("CONTACT MATCH FOUND \(matchingRecipient.recipientName)")
                            result.append(contact)
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    
    
    func sendNotificationToUser(user: String, message: String, name: String, answer1: String, answer2: String, pollID : String) {
        
        let ref = FIRDatabase.database().reference()
        
        let notificationRequestsRef = ref.child("notificationRequests")
        let notificationRequestID = UUID().uuidString
        
        let notificationRequestDict : [NSObject : AnyObject]  = ["username" as NSObject: user as AnyObject, "message" as NSObject: message as AnyObject, "sender" as NSObject: name as AnyObject, "answer1" as NSObject: answer1 as AnyObject, "answer2" as NSObject: answer2 as AnyObject, "pollID" as NSObject: pollID as AnyObject]
        
        
        FIRDatabase.database().reference().child("notificationRequests").child(notificationRequestID).setValue(notificationRequestDict)
        
        FIRDatabase.database().reference().child("notificationRequestsCopy").child(notificationRequestID).setValue(notificationRequestDict)
        

        print(notificationRequestDict)
    
        
    }
    


}
    



