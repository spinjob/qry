//
//  CreatePollViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/28/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftLinkPreview
import SDWebImage

class CreatePollViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, FeaturedAnswerCellDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    @IBOutlet weak var featuredAnswerTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
  
    @IBOutlet weak var expirationPicker: UIPickerView!

    @IBOutlet weak var pollImageView: UIImageView!
    
    @IBOutlet weak var hyperLinkButton: UIButton!
    
    @IBOutlet weak var questionFieldVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linkDescriptionTextView: UITextView!
    
    @IBOutlet weak var linkHeadlineTextLabel: UILabel!
    
    @IBOutlet weak var linkPreviewView: UIView!
    
    @IBOutlet weak var answer1TextFieldVerticalConstraint: NSLayoutConstraint!

    @IBOutlet weak var answer2TextFieldVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takePictureButton: UIButton!
    
    @IBOutlet weak var uploadPictureButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    var featuredAnswers : [String] = ["Attending","Not Attending", "👍","👎","Chyeah","Nah", "Going","Can't Go", "🔥","❄️"]
    var featuredAnswersDict : [String:String] = ["Attending":"Not Attending", "👍":"👎","Chyeah":"Nah", "Going":"Can't Go", "🔥":"❄️"]
    
    let pickerData : [String] = ["an hour", "a day", "a week"]
    
    let pollId = UUID().uuidString
    
    var dictPoll : [NSObject : AnyObject] = [:]
    
    let poll = Poll()
    
    var senderUserDict : [NSObject : AnyObject] = [:]
    
    let slp = SwiftLinkPreview()
    
    var pollURL : String = "no url"
    
    var pollImage : String = "no image"
    
    var pollImageTitle : String = "no image title"
    
    var pollImageDescription : String = "no image description"
    
    var questionImageURL : String = "no question image"
    
    var questionImage : UIImage = UIImage()
    
    
    var imagePicker = UIImagePickerController()

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       
       navigationController?.navigationBar.barTintColor = UIColor.white
       navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont(name: "Proxima Nova", size: 20)!]
       navigationController?.navigationBar.backItem?.backBarButtonItem!.title = "X"
        
       self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
       self.navigationController?.navigationBar.shadowImage = UIImage()

        featuredAnswerTableView.delegate = self
        featuredAnswerTableView.dataSource = self
        questionTextField.delegate = self
        answer1TextField.delegate = self
        answer2TextField.delegate = self
        
        answer1TextField.layer.cornerRadius = 3.5
        answer2TextField.layer.cornerRadius = 3.5
        pollImageView.layer.borderWidth = 0.2
        pollImageView.layer.borderColor = UIColor.lightGray.cgColor
        pollImageView.layer.cornerRadius = 3.5
        pollImageView.layer.masksToBounds = true
        linkPreviewView.layer.borderWidth = 0.2
        linkPreviewView.layer.borderColor = UIColor.lightGray.cgColor
        linkPreviewView.layer.cornerRadius = 3.5
        linkPreviewView.isHidden = true
        hyperLinkButton.isHidden = true
        
        expirationPicker.delegate = self
        expirationPicker.dataSource = self
        nextButton.alpha = 0
        
        imageView.isHidden = true
        imageView.layer.borderWidth = 0.2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.cornerRadius = 3.5
        imageView.layer.masksToBounds = true
        
        imagePicker.delegate = self

        self.hideKeyboard()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        questionImage = image
        print(image)
        
        if linkPreviewView.isHidden == false {
            pollImageView.image = image
            imageView.isHidden = true
        } else {
        
        
        imageView.image = image
        questionFieldVerticalConstraint.constant = 139
        answer1TextFieldVerticalConstraint.constant = 175
        answer2TextFieldVerticalConstraint.constant = 175
        imageView.isHidden = false
        
        imageView.backgroundColor = UIColor.clear
        
            
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }

        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        expirationPicker.subviews[1].isHidden = true
        expirationPicker.subviews[2].isHidden = true
        
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor(hexString: "00D1D5")
        pickerLabel.text = pickerData[row]
        pickerLabel.font = UIFont(name: "ProximaNovaSoft-Medium", size: 20)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FeaturedAnswerOptionPairCell"
        let cell = featuredAnswerTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SuggestedAnswerOptionTableViewCell
        cell.delegate = self
        
        let featuredAnswer1Array = ["Attending", "👍","Chyeah","Going","🔥"]
        let featuredAnswer2Array = ["Not Attending", "👎","Nah","Can't Go","❄️"]
    
        
        cell.featuredAnswer1Button.layer.borderWidth = 0.1
        cell.featuredAnswer1Button.layer.cornerRadius = 3.5
        cell.featuredAnswer1Button.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.featuredAnswer2Button.layer.borderWidth = 0.1
        cell.featuredAnswer2Button.layer.cornerRadius = 3.5
        cell.featuredAnswer2Button.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.featuredAnswer1Button.setTitle(featuredAnswer1Array[indexPath.row], for: .normal);
        cell.featuredAnswer2Button.setTitle(featuredAnswer2Array[indexPath.row], for: .normal);
    
        
        return cell
        
    }
    
    func answer2ButtonTapped(customCell: SuggestedAnswerOptionTableViewCell) {
        
        answer2TextField.text = customCell.featuredAnswer2Button.titleLabel?.text
        
    }
    
    func answer1ButtonTapped(customCell: SuggestedAnswerOptionTableViewCell) {
        answer1TextField.text = customCell.featuredAnswer1Button.titleLabel?.text
    }
    
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nextButton.isEnabled = true
        nextButton.isUserInteractionEnabled = true
        nextButton.alpha = 1.0
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let input = textField.text
        print(verifyUrl(urlString: input))
        if verifyUrl(urlString: input) == true {
            hyperLinkButton.isHidden = false
        } else {
            hyperLinkButton.isHidden = true
        }
        
        if (input?.contains("going"))! {
            answer1TextField.text = "Going"
            answer2TextField.text = "Can't Go"
        }

        
        self.view.endEditing(true)
        
        return false
    }
    

   func verifyUrl (urlString: String?) -> Bool {
        let types: NSTextCheckingResult.CheckingType = .link
        
        let detector = try? NSDataDetector(types: types.rawValue)
        
        let matches = detector?.matches(in: urlString!, options: .reportCompletion, range: NSMakeRange(0, (urlString?.characters.count)!))
        
        if matches?.count != 0 {
            return true
        }
            else {
                return false
        }

    }
    
   
    @IBAction func nextButtonTapped(_ sender: Any) {
       
        
        print(imageView.image)
        
       // let selectedIndex = expirationPicker.selectedRow(inComponent: 0)
        
       // let nextPoll : [NSObject : AnyObject] = ["question" as NSObject: questionTextField.text as AnyObject, "answer1" as NSObject: answer1TextField.text as AnyObject, "answer2" as NSObject: answer2TextField.text as AnyObject, "expiration" as NSObject: pickerData[selectedIndex] as AnyObject, "senderUser" as NSObject: FIRAuth.auth()?.currentUser?.uid as AnyObject]
        
       // FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("polls").child(pollId).setValue(nextPoll)
      //  FIRDatabase.database().reference().child("polls").child(pollId).setValue(nextPoll)
        
      //  if pollURL != nil {
            
      //      FIRDatabase.database().reference().child("polls").child(pollId).child("pollURL").setValue(pollURL)
        
      //  }
        
      //  if pollImage != nil {
            
      //      FIRDatabase.database().reference().child("polls").child(pollId).child("pollImageURL").setValue(pollImage)
            
      //  }
        
      //  if pollImageDescription != nil {
            
      //      FIRDatabase.database().reference().child("polls").child(pollId).child("pollImageDescription").setValue(pollImageDescription)
            
       // }
        
      //  if pollImageTitle != nil {
            
      //      FIRDatabase.database().reference().child("polls").child(pollId).child("pollImageTitle").setValue(pollImageTitle)
            
      //  }

        
      // if pickerData[selectedIndex] == "an hour" {
      //  poll.expiration = Timer(timeInterval: 3600, target: self.poll, selector: "pollTimer", userInfo: nil, repeats: false)
      //  }
        
      // if pickerData[selectedIndex] == "a day" {
      //     poll.expiration = Timer(timeInterval: 86400, target: self.poll, selector: "pollTimer", userInfo: nil, repeats: false)
      //  }
        
      //  if pickerData[selectedIndex] == "a week" {
      //      poll.expiration = Timer(timeInterval: 432000, target: self.poll, selector: "pollTimer", userInfo: nil, repeats: false)
      //  }

            performSegue(withIdentifier: "selectRecipientsSegue", sender: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "selectRecipientsSegue" {
       let nextVC = segue.destination as! SelectRecipientsViewController

       let selectedIndex = expirationPicker.selectedRow(inComponent: 0)
    
            
        let dictPoll : [NSObject : AnyObject]  = ["question" as NSObject: questionTextField.text as AnyObject, "answer1" as NSObject: answer1TextField.text as AnyObject, "answer2" as NSObject: answer2TextField.text as AnyObject, "expiration" as NSObject: pickerData[selectedIndex] as AnyObject, "senderUser" as NSObject: FIRAuth.auth()?.currentUser?.uid as AnyObject, "pollImageURL" as NSObject: self.pollImage as AnyObject, "pollURL" as NSObject: self.pollURL as AnyObject, "pollImageDescription" as NSObject: self.pollImageDescription as AnyObject, "pollImageTitle" as NSObject: self.pollImageTitle as AnyObject, "questionImageURL" as NSObject: self.questionImageURL as AnyObject]
            
            
        
        nextVC.poll.answer1String = answer1TextField.text!
        nextVC.poll.answer2String = answer2TextField.text!
        nextVC.poll.questionString = questionTextField.text!
        nextVC.poll.expiration = pickerData[selectedIndex]
        nextVC.poll.pollImageDescription = pollImageDescription
        nextVC.poll.pollImageTitle = pollImageTitle
        nextVC.poll.pollURL = pollURL
        nextVC.poll.pollImageURL = pollImageTitle
        nextVC.poll.senderUser = (FIRAuth.auth()?.currentUser?.uid)!
        nextVC.poll.pollID = pollId
        nextVC.questionImage = questionImage

        
        nextVC.dictPoll = dictPoll
        nextVC.pollID = pollId
            
        }

    
    }
    
    
    @IBAction func takePictureButtonTapped(_ sender: Any) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }

    
    @IBAction func addPhotoFromGalleryButtonTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    

    @IBAction func hyperLinkButtonTapped(_ sender: Any) {
        
        let input = questionTextField.text
        
        slp.preview(input, onSuccess: {
            
            result in
            let imageURL = URL(string: result["image"] as! String)
            self.pollImage = result["image"] as! String
            self.pollImageView.sd_setImage(with: imageURL)
            self.linkHeadlineTextLabel.text = result["title"] as! String
            self.linkDescriptionTextView.text = result["description"] as! String
            self.pollURL = result["url"] as! String
            self.pollImageTitle = result["title"] as! String
            self.pollImageDescription = result["description"] as! String
            self.questionFieldVerticalConstraint.constant = 164
            self.answer1TextFieldVerticalConstraint.constant = 133
            self.answer2TextFieldVerticalConstraint.constant = 133
            self.linkPreviewView.isHidden = false
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            
            self.questionTextField.text = ""
           
            
        }, onError: {
            error in
            
            
            print("\(error)")
            
            
        })

        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMenuCancel", sender: self)
        
        
    }
    
    func hideKeyboard () {
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }

}
