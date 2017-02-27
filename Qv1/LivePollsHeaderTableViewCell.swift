//
//  LivePollsHeaderTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/27/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class LivePollsHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var livePollsIconView: UIView!
    @IBOutlet weak var barrierView: UIView!

    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var sectionTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
