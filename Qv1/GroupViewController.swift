//
//  GroupViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 12/29/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var editPictureView: UIView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var imagePicker = UIImagePickerController()
    var groupMembers : [Recipient] = []
    var groupImageURL : String = ""
    var groupName : String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupImageView.isHidden = false
        groupImageView.layer.cornerRadius = 3
        groupImageView.layer.borderWidth = 0.3
        groupImageView.layer.borderColor = UIColor(hexString: "004488").cgColor
        groupImageView.layer.masksToBounds = true
        groupImageView.sd_setImage(with: URL(string: groupImageURL))
        
        groupNameTextField.text = groupName
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.delegate = self
        editPictureView.addGestureRecognizer(tap)
        
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        groupImageView.isHidden = false
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        groupImageView.image = image
        groupImageView.backgroundColor = UIColor.clear

        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func handleTap(sender: UITapGestureRecognizer) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addFriendButtonTapped(_ sender: Any) {
    }


}
