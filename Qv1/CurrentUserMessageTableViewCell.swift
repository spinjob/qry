//
//  CurrentUserMessageTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 11/11/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class CurrentUserMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var currentUserName: UILabel!
    @IBOutlet weak var currentUserImage: UIImageView!
    @IBOutlet weak var answerIndicator: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var leftMessageConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    

}
