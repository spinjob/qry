//
//  EmailAddressViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/13/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class EmailAddressViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var andEmailTextLabel: UILabel!
    @IBOutlet weak var emailAddressTextLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    @IBOutlet weak var checkMarkLabel: UILabel!
    
    
    var firstName = ""
    var lastName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailAddressTextField.delegate = self
        checkMarkLabel.isHidden = true
        nextButton.isHidden = true
    
        UIView.animate(withDuration: 0.8, animations:{
            self.andEmailTextLabel.alpha = 0
            self.emailAddressTextLabel.alpha = 0
            self.andEmailTextLabel.alpha = 1
            self.emailAddressTextLabel.alpha = 1

        })
        
    }

    func isValidEmail(testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
       
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(EmailAddressViewController.getHintsFromTextField), object: textField)
        
        self.perform(#selector(EmailAddressViewController.getHintsFromTextField), with: textField, afterDelay: 0.5)
        
        return true
    }
    
    func getHintsFromTextField(textField: UITextField) {
        
                
        if self.isValidEmail(testStr: textField.text!) == true {
                
                UIView.animate(withDuration: 0.5, animations: {
                        
                    self.checkMarkLabel.alpha = 0
                    self.checkMarkLabel.text = "✓"
                    self.checkMarkLabel.textColor = UIColor.init(hexString: "A8E855")
                    self.checkMarkLabel.isHidden = false
                    self.checkMarkLabel.alpha = 1
        
                    self.nextButton.alpha = 0
                    self.nextButton.isHidden = false
                    self.nextButton.alpha = 1
                })
                
        }
    

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        let nextVC = segue.destination as! PhoneNumberViewController
        
        nextVC.firstName = firstName
        nextVC.lastName = lastName
        nextVC.emailAddress = emailAddressTextField.text!
        
    }

}
