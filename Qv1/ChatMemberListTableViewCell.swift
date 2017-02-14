//
//  ChatMemberListTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/14/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class ChatMemberListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var answerGroupMemberImageView: UIImageView!
    @IBOutlet weak var answerGroupMemberNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
