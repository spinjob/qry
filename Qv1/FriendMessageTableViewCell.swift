//
//  FriendMessageTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 11/11/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class FriendMessageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var rightMessageConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var answerIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
