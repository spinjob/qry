//
//  ChoosePictureViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/13/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ChoosePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var lastlyChooseYourFaceLabel: UILabel!

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var snapAPictureButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
   
   
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        doneButton.isHidden = true
        profileImageView.layer.cornerRadius = profileImageView.layer.frame.size.width / 2
        profileImageView.layer.borderColor = UIColor.init(hexString: "00D1D5").cgColor
        profileImageView.layer.borderWidth = 0.2
        profileImageView.layer.masksToBounds = true
        profileImageView.backgroundColor = UIColor.clear

        
        
        UIView.animate(withDuration: 0.8, animations:{
            self.profileImageView.alpha = 0
            self.galleryButton.alpha = 0
            self.snapAPictureButton.alpha = 0
            
            self.profileImageView.alpha = 1
            self.galleryButton.alpha = 1
            self.snapAPictureButton.alpha = 1
        })

        
    }

    
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        profileImageView.image = image
    
    
        imagePicker.dismiss(animated: true, completion: nil)
    
        doneButton.isHidden = false
    
    

        
    }
    
    @IBAction func galleryButtonTapped(_ sender: Any) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    
    @IBAction func snapAPictureButtonTapped(_ sender: Any) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        if profileImageView.image != nil {
            
            let profileImageData = UIImageJPEGRepresentation(profileImageView.image!, 0.4)
            let userDefaults = UserDefaults.standard
            
            FIRStorage.storage().reference().child("ProfileImages/\(FIRAuth.auth()?.currentUser!.uid)/profileImage.jpg").put(profileImageData!, metadata: nil){
                metadata, error in
                
                if error != nil {
                    print("error \(error)")
                }
                else {
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("profileImageURL").setValue(downloadURL)
                    
                    if userDefaults.string(forKey: "email") != nil {
                        
                        let email = userDefaults.string(forKey: "email")
                        
                        let password = userDefaults.string(forKey: "password")
                        
                    }
                    
                    self.performSegue(withIdentifier: "signUpSignInSegue", sender: nil)
                    
                    
                   // let storyboard = UIStoryboard(name: "Main", bundle: nil)
                   // let controller = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                   // let transition:CATransition = CATransition()
                    
                   // controller.currentUserID = (FIRAuth.auth()?.currentUser?.uid)!
                    
                   // transition.duration = 0.3
                    //transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                   // transition.type = kCATransitionMoveIn
                   // transition.subtype = kCATransitionFromLeft
                    
                    //  self.present(controller, animated: true, completion: nil)
                    
                    //self.navigationController!.view.layer.add(transition, forKey: kCATransition)
                    //self.navigationController?.pushViewController(controller, animated: false)
                    
                }
                
            }
            
        }
    }
    
 

}
