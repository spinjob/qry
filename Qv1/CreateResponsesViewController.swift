//
//  CreateResponsesViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 3/15/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import Gifu
import SwiftLinkPreview
import SDWebImage

class CreateResponsesViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var answer1View: UIView!

    @IBOutlet weak var questionTextField: UITextField!
    
    @IBOutlet weak var answer1ViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var answer1TextField: UITextField!

    @IBOutlet weak var answer1ImageView: FLAnimatedImageView!
    
    
    @IBOutlet weak var answer1ImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var answer2View: UIView!
    
    
    @IBOutlet weak var answer2ViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var answer2TextField: UITextField!
    
    @IBOutlet weak var answer2ImageView: FLAnimatedImageView!
    
    @IBOutlet weak var answer2ImageViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var giphyButton: UIButton!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var imagePicker = UIImagePickerController()
    
    let pickerData : [String] = ["5 mins","an hour", "a day", "a week"]
    
    
    let date = Date()
    var expirationDate = Date()
    var calendar = Calendar.current
    let formatter = DateFormatter()
    let myLocale = Locale(identifier: "bg_BG")
    
    let g = Giphy(apiKey: Giphy.PublicBetaAPIKey)

    
    let slp = SwiftLinkPreview()
    
    var answer1GifURL = ""
    var answer2GifURL = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        answer1View.layer.cornerRadius = 4
        answer1View.layer.masksToBounds = true
    
        
        answer2View.layer.cornerRadius = 4
        answer2View.layer.masksToBounds = true
        
        
        answer1ViewHeightConstraint.constant = 46
        answer1ImageViewHeightConstraint.constant = 0
    
         answer2ViewHeightConstraint.constant = 46
        answer2ImageViewHeightConstraint.constant = 0
        
        answer1TextField.delegate = self
        answer2TextField.delegate = self
        questionTextField.delegate = self
        
        pickerView.delegate = self
        pickerView.dataSource = self

    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        pickerView.subviews[1].isHidden = true
        pickerView.subviews[2].isHidden = true
        
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor(hexString: "00D1D5")
        pickerLabel.text = pickerData[row]
        pickerLabel.font = UIFont(name: "ProximaNovaSoft-Medium", size: 20)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    

    
    @IBAction func giphyButtonTapped(_ sender: Any) {
 
        
        
        if answer1ViewHeightConstraint.constant == 46 {
        answer1ViewHeightConstraint.constant = 150
        answer1ImageViewHeightConstraint.constant = 104
        
        answer2ViewHeightConstraint.constant = 150
        answer2ImageViewHeightConstraint.constant = 104
            
            
            g.translate(answer1TextField.text!, rating: nil, completionHandler: {
                gif, err in
                
               let gifID = gif!.id
               let gifURLString = "http://i.giphy.com/\(gifID).gif"
               let gifURL = URL(string: gifURLString)
                
                self.answer1ImageView.sd_setImage(with: gifURL)

                self.answer1GifURL = gifURLString
                
            })
            
            
            g.translate(answer2TextField.text!, rating: nil, completionHandler: {
                gif, err in
              
                let gifID = gif!.id
                let gifURLString = "http://i.giphy.com/\(gifID).gif"
                let gifURL = URL(string: gifURLString)
                
                
                self.answer2ImageView.sd_setImage(with: gifURL)
                self.answer2GifURL = gifURLString
                
                
            })
            
            
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        } else {
            
            
            g.translate(answer1TextField.text!, rating: nil, completionHandler: {
                gif, err in
                
                let gifID = gif!.id
                let gifURLString = "http://i.giphy.com/\(gifID).gif"
                let gifURL = URL(string: gifURLString)
                
                self.answer1ImageView.sd_setImage(with: gifURL)
                
                self.answer1GifURL = gifURLString
                
            })
            
            
            g.translate(answer2TextField.text!, rating: nil, completionHandler: {
                gif, err in
                
                let gifID = gif!.id
                let gifURLString = "http://i.giphy.com/\(gifID).gif"
                let gifURL = URL(string: gifURLString)
                
                
                self.answer2ImageView.sd_setImage(with: gifURL)
                self.answer2GifURL = gifURLString
                
                
            })
        }
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(CreateResponsesViewController.getHintsFromTextField),
            object: textField)
        self.perform(
            #selector(CreateResponsesViewController.getHintsFromTextField),
            with: textField,
            afterDelay: 0.5)
        return true
    }
    
    
    func getHintsFromTextField(textField: UITextField) {
        
        if textField == answer1TextField, textField.text == "" {
//            answer1ViewHeightConstraint.constant = 46
//            answer1ImageViewHeightConstraint.constant = 0
//            
            giphyButton.titleLabel?.textColor = UIColor.gray
            giphyButton.isEnabled = false
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        
            
        }
        
        if textField == answer2TextField, textField.text == "" {
//            answer2ViewHeightConstraint.constant = 46
//            answer2ImageViewHeightConstraint.constant = 0
//            
            giphyButton.titleLabel?.textColor = UIColor.gray
            giphyButton.isEnabled = false
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            
            
        }
        
        
        if textField == answer1TextField, textField.text != "" {
            

            giphyButton.titleLabel?.textColor = UIColor.purple
            giphyButton.isEnabled = true
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
        }
        
        if textField == answer2TextField, textField.text != ""  {
            
            giphyButton.titleLabel?.textColor = UIColor.purple
            giphyButton.isEnabled = true
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
        }
        
        
        
    }
    
    
    
    func hideKeyboard () {
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
}
