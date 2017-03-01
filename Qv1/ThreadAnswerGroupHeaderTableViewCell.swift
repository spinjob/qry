//
//  ThreadAnswerGroupHeaderTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/28/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class ThreadAnswerGroupHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var selectAnswerGroupButton: UIButton!

    @IBOutlet weak var staticAnsweredLabel: UILabel!
    @IBOutlet weak var answerStringLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
