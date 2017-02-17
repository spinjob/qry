//
//  MessageNotificationTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/16/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class MessageNotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageNotificationIconImageView: UIImageView!
    @IBOutlet weak var newMessagesStaticLabel: UILabel!
    @IBOutlet weak var conversationIndicatorImageView: UIImageView!
  
    @IBOutlet weak var pollQuestionStringLabel: UILabel!
    
    @IBOutlet weak var recentMessageView: UIView!
    
    @IBOutlet weak var recentMessageStringTextView: UITextView!
    
    @IBOutlet weak var messageSenderUserName: UILabel!
    
    @IBOutlet weak var messageSenderUserImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
