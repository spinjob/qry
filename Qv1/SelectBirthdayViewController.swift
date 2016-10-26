//
//  SelectBirthdayViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 10/22/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class SelectBirthdayViewController: UIViewController {

    
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var pickerView: UIDatePicker!
    @IBOutlet weak var nextButton: UIButton!
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.addTarget(self, action: #selector(SelectBirthdayViewController.datePickerChanged(datePicker:)), for: UIControlEvents.valueChanged)
        
        pickerView.setValue(UIColor.gray, forKeyPath: "textColor")
        pickerView.maximumDate = Date()
  

        
        
        let backButton = UIBarButtonItem(title: "<", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        

    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        var dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        var strDate = dateFormatter.string(from: datePicker.date)
        birthdayLabel.text = strDate
        
    }

    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
    }
    
}
