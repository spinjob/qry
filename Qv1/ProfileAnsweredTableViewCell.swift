//
//  ProfileAnsweredTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 4/3/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class ProfileAnsweredTableViewCell: UITableViewCell {

    @IBOutlet weak var questionTextView: UITextView!
    
    @IBOutlet weak var answerView: UIView!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var senderNameLabel: UILabel!
    
    @IBOutlet weak var senderImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
