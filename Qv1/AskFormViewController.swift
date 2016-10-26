//
//  AskFormViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/24/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class AskFormViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var questionStringTextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    
    @IBOutlet weak var thumbsUpButton: UIButton!
    @IBOutlet weak var thumbsDownButton: UIButton!
    @IBOutlet weak var attendingButton: UIButton!
    @IBOutlet weak var notAttendingButton: UIButton!
    
    @IBOutlet weak var chyeaButton: UIButton!
    @IBOutlet weak var nahButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        CIRCULAR BUTTON TO ALLOW USER TO CHANGE ANSWER BUTTON COLOR
//        let redColorButton = UIButton(type: .custom)
//        redColorButton.frame = CGRect(x: 160, y: 100, width: 10, height: 10)
//        redColorButton.layer.cornerRadius = 0.5 * redColorButton.bounds.size.width
//        redColorButton.clipsToBounds = true
//        redColorButton.backgroundColor = UIColor.red
//        redColorButton.addTarget(self, action: #selector(redColorButtonTapped), for: .touchUpInside)
//        view.addSubview(redColorButton)
//        
        
        questionStringTextField.delegate = self

        answer1TextField.layer.cornerRadius = 3.5
        answer2TextField.layer.cornerRadius = 3.5
        
        nextButton.isEnabled = false
        nextButton.isUserInteractionEnabled = false
        

        //AnswerOption Buttons
        
        thumbsUpButton.layer.borderWidth = 0.1
        thumbsUpButton.layer.cornerRadius = 3.5
        thumbsUpButton.layer.borderColor = UIColor.lightGray.cgColor
        
        thumbsDownButton.layer.borderWidth = 0.1
        thumbsDownButton.layer.cornerRadius = 3.5
        thumbsDownButton.layer.borderColor = UIColor.lightGray.cgColor
        
        attendingButton.layer.borderWidth = 0.1
        attendingButton.layer.cornerRadius = 3.5
        attendingButton.layer.borderColor = UIColor.lightGray.cgColor
        
        notAttendingButton.layer.borderWidth = 0.1
        notAttendingButton.layer.cornerRadius = 3.5
        notAttendingButton.layer.borderColor = UIColor.lightGray.cgColor
        
        chyeaButton.layer.borderWidth = 0.1
        chyeaButton.layer.cornerRadius = 3.5
        chyeaButton.layer.borderColor = UIColor.lightGray.cgColor
        
        nahButton.layer.borderWidth = 0.1
        nahButton.layer.cornerRadius = 3.5
        nahButton.layer.borderColor = UIColor.lightGray.cgColor
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nextButton.isEnabled = true
        nextButton.isUserInteractionEnabled = true
        nextButton.alpha = 1.0
    }

    @IBAction func thumbsUpTapped(_ sender: AnyObject) {
        
        answer1TextField.text = thumbsUpButton.titleLabel?.text
    }
    
    @IBAction func thumbsDownTapped(_ sender: AnyObject) {
        answer2TextField.text = thumbsDownButton.titleLabel?.text
    }

    @IBAction func attendingTapped(_ sender: AnyObject) {
        
        answer1TextField.text = attendingButton.titleLabel?.text
    }
    
    @IBAction func notAttendingTapped(_ sender: AnyObject) {
        answer2TextField.text = notAttendingButton.titleLabel?.text
    }
    
    @IBAction func chyeaTapped(_ sender: AnyObject) {
        answer1TextField.text = chyeaButton.titleLabel?.text
    }
    
    @IBAction func nahTapped(_ sender: AnyObject) {
        answer2TextField.text = nahButton.titleLabel?.text
    }
    
    func redColorButtonTapped () {
        answer1TextField.layer.backgroundColor = UIColor.red.cgColor
    }
    
    
}
