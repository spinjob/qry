//
//  ChooseProfilePictureViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/31/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Firebase

class ChooseProfilePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var chooseFromPhotosButton: UIButton!
    @IBOutlet weak var takeASelfieButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var orLabelVerticalConstraint: NSLayoutConstraint!
    
    
    var imagePicker = UIImagePickerController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        imagePicker.delegate = self
        
        imageView.isHidden = false
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.3
        imageView.layer.borderColor = UIColor(hexString: "004488").cgColor
        
    
        


    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageView.isHidden = false
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        //orLabelVerticalConstraint.constant = 81
            
        imagePicker.dismiss(animated: true, completion: nil)
        
    }

   
    
    
    @IBAction func chooseFromPhotosTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func takeASelfieTapped(_ sender: Any) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
        
    }

    @IBAction func finishTapped(_ sender: Any) {
        
        if imageView.image != nil {
        
        
            let profileImageData = UIImageJPEGRepresentation(imageView.image!, 0.4)
        
            FIRStorage.storage().reference().child("ProfileImages/\(FIRAuth.auth()?.currentUser!.uid)/profileImage.jpg").put(profileImageData!, metadata: nil){
            metadata, error in
            
            if error != nil {
                print("error \(error)")
            }
            else {
                let downloadURL = metadata?.downloadURL()?.absoluteString
                FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("profileImageURL").setValue(downloadURL)
                
                self.performSegue(withIdentifier: "signInFromRegisterSegue", sender: nil)
                
            }
            
            }

        }
    } 
}
