//
//  GlobalPollTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 5/2/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class GlobalPollTableViewCell: UITableViewCell {
    
    //Common Poll Elements
    @IBOutlet weak var questionStringTextView: UITextView!
    
    @IBOutlet weak var senderImageView: UIImageView!
    
    //Poll Results View
    @IBOutlet weak var answerResultsView: UIView!
    
    @IBOutlet weak var answer1ResultsView: UIView!
    
    @IBOutlet weak var answer1Label: UILabel!
    
    @IBOutlet weak var answer1ResultsViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var answer2ResultsView: UIView!
    
    @IBOutlet weak var answer2Label: UILabel!
    
    
    //Unanswered Poll View
    
    @IBOutlet weak var answer1Button: UIButton!
    
    @IBOutlet weak var answer2Button: UIButton!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
