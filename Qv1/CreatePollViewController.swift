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

class CreatePollViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, FeaturedAnswerCellDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    @IBOutlet weak var featuredAnswerTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
  
    @IBOutlet weak var expirationPicker: UIPickerView!

    var featuredAnswers : [String] = ["Attending","Not Attending", "👍","👎","Chyeah","Nah", "Going","Can't Go", "🔥","❄️"]
    var featuredAnswersDict : [String:String] = ["Attending":"Not Attending", "👍":"👎","Chyeah":"Nah", "Going":"Can't Go", "🔥":"❄️"]
    
    let pickerData : [String] = ["an hour", "a day", "a week"]
    
    let pollId = UUID().uuidString
    
    var dictPoll : [NSObject : AnyObject] = [:]
    
    var senderUserDict : [NSObject : AnyObject] = [:]
    
    var senderUser : User = User()
    
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
        
        expirationPicker.delegate = self
        expirationPicker.dataSource = self
        nextButton.alpha = 0

        
    
        
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
        self.view.endEditing(true)
        return false
    }
   
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        let selectedIndex = expirationPicker.selectedRow(inComponent: 0)
        
        let nextPoll : [NSObject : AnyObject] = ["question" as NSObject: questionTextField.text as AnyObject, "answer1" as NSObject: answer1TextField.text as AnyObject, "answer2" as NSObject: answer2TextField.text as AnyObject, "expiration" as NSObject: pickerData[selectedIndex] as AnyObject]
        
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("polls").child(pollId).setValue(nextPoll)

        
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
        

       let selectedIndex = expirationPicker.selectedRow(inComponent: 0)
       
        let dictPoll : [NSObject : AnyObject] = ["question" as NSObject: questionTextField.text as AnyObject, "answer1" as NSObject: answer1TextField.text as AnyObject, "answer2" as NSObject: answer2TextField.text as AnyObject, "expiration" as NSObject: pickerData[selectedIndex] as AnyObject, "senderUser" as NSObject: FIRAuth.auth()?.currentUser?.uid as AnyObject]
        
        
        let nextVC = segue.destination as! SelectRecipientsViewController

        
        nextVC.dictPoll = dictPoll
        nextVC.pollID = pollId

        
    
    }
    
    
    //        CIRCULAR BUTTON TO ALLOW USER TO CHANGE ANSWER BUTTON COLOR
    //        let redColorButton = UIButton(type: .custom)
    //        redColorButton.frame = CGRect(x: 160, y: 100, width: 10, height: 10)
    //        redColorButton.layer.cornerRadius = 0.5 * redColorButton.bounds.size.width
    //        redColorButton.clipsToBounds = true
    //        redColorButton.backgroundColor = UIColor.red
    //        redColorButton.addTarget(self, action: #selector(redColorButtonTapped), for: .touchUpInside)
    //        view.addSubview(redColorButton)
    //        

}
