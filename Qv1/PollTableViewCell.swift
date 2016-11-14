//
//  PollTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 11/7/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class PollTableViewCell: UITableViewCell {

    @IBOutlet weak var senderUserLabel: UILabel!
    @IBOutlet weak var senderUserImageView: UIImageView!
    @IBOutlet weak var questionStringLabel: UILabel!
    @IBOutlet weak var answer1Button: UIButton!
    @IBOutlet weak var answer2Button: UIButton!
    @IBOutlet weak var conversationButton: UIButton!
    @IBOutlet weak var toUserNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
