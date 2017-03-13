//
//  PollProfileViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 3/8/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage


class PollProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePieChartView: UIView!
    @IBOutlet weak var profilePictureImageVIew: UIImageView!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    var imagePicker = UIImagePickerController()
    
    var answer1Count : Int = 0
    var answer2Count : Int = 0
    var askedCount : Int = 0
    var noAnswerCount : Int = 0
    
    let brightGreen = UIColor.init(hexString: "A8E855")
    let red = UIColor.init(hexString: "FF4E56")
    let actionGreen = UIColor.init(hexString: "00D1D5")
    let blue = UIColor.init(hexString: "004488")

    
    var profileUserID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileImageTapped(sender:)))
    
        profilePictureImageVIew.addGestureRecognizer(tapGestureRecognizer)
        
        profilePictureImageVIew.isUserInteractionEnabled = true
        
        profilePictureImageVIew.layer.cornerRadius = profilePictureImageVIew.layer.frame.width / 2
        profilePictureImageVIew.layer.masksToBounds = true
        
        profilePieChartView.isHidden = false
 
        let userRef = FIRDatabase.database().reference().child("users").child(profileUserID)
    
        userRef.observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            self.profilePictureImageVIew.sd_setImage(with: URL(string: snapshotValue["profileImageURL"] as! String))
            self.userNameLabel.text = snapshotValue["fullName"] as! String
            
        })
        
        FIRDatabase.database().reference().child("users").child(profileUserID).child("votes").queryOrdered(byChild: "answerChoice").queryEqual(toValue: "answer1").observe(.childAdded, with: {
            snapshot in
            
            self.answer1Count = Int(snapshot.childrenCount)
            
            FIRDatabase.database().reference().child("users").child(self.profileUserID).child("votes").queryOrdered(byChild: "answerChoice").queryEqual(toValue: "answer2").observe(.childAdded, with: {
                snapshot in
                
                self.answer2Count = Int(snapshot.childrenCount)
                
                FIRDatabase.database().reference().child("users").child(self.profileUserID).child("votes").queryOrdered(byChild: "answerChoice").queryEqual(toValue: "no answer").observe(.childAdded, with: {
                    snapshot in
                    
                    self.noAnswerCount = Int(snapshot.childrenCount)
                    
                    FIRDatabase.database().reference().child("polls").queryOrdered(byChild: "senderUser").queryEqual(toValue: self.profileUserID).observe(.value, with: {
                        snapshot in
                        self.askedCount = Int(snapshot.childrenCount)
                        
                        let chartView = PieChartView()
                        
                        chartView.frame = CGRect(x: 0, y: 0, width: self.profilePieChartView.frame.width, height: 220)
                        
                        chartView.segments = [
                            Segment(color: self.brightGreen, value: CGFloat(self.answer1Count)),
                            Segment(color: self.red, value: CGFloat(self.answer2Count)),
                            Segment(color: self.blue, value: CGFloat(self.noAnswerCount)),
                            Segment(color: self.actionGreen, value: CGFloat(self.askedCount))
                        ]
                        
                        self.profilePieChartView.addSubview(chartView)
                        
                    })
                    
                })
                
            })
            
        })

        
    }

    @IBAction func logoutButtonTapped(_ sender: Any) {
       
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


    @IBAction func editFriendsButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FriendsViewController") as! FriendsViewController
        let transition:CATransition = CATransition()
        
        controller.profileUserID = profileUserID

        
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        profilePictureImageVIew.image = image
        
        
        let profileImageData = UIImageJPEGRepresentation(profilePictureImageVIew.image!, 0.4)
        
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
  
    func profileImageTapped (sender: UITapGestureRecognizer) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    

}
