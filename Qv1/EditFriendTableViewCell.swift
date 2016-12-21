//
//  EditFriendTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 12/21/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class EditFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var actionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var actionButtonHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionButtonTapped(_ sender: Any) {
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
    }
    
    
}
