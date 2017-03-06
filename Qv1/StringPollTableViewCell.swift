//
//  StringPollTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 2/25/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit

class StringPollTableViewCell: UITableViewCell {
    @IBOutlet weak var conversationIconImageView: UIImageView!
    @IBOutlet weak var expiredIconImageView: UIImageView!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var senderFullNameLabel: UILabel!
    @IBOutlet weak var questionStringTextView: UITextView!
    @IBOutlet weak var groupMembersCollectionView: UICollectionView!
    
    @IBOutlet weak var threadTopLine: UIView!
    @IBOutlet weak var threadBottomLine: UIView!
    
    @IBOutlet weak var imageViewThread: UIImageView!
    
    @IBOutlet weak var pollImageView: UIImageView!
    @IBOutlet weak var answer1Button: UIButton!
    
    @IBOutlet weak var answer2Button: UIButton!
    
    @IBOutlet weak var timerView: UIView!
    
    @IBOutlet weak var answerSelectedView: UIView!
    
    @IBOutlet weak var answerSelectedTextLabel: UILabel!
    
    @IBOutlet weak var pollImageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var questionStringTextViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pieChartCenterView: UIView!
    @IBOutlet weak var timeLeftUnitLabel: UILabel!
    
    @IBOutlet weak var timeLeftNumberLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        
        groupMembersCollectionView.delegate = dataSourceDelegate
        groupMembersCollectionView.dataSource = dataSourceDelegate
        groupMembersCollectionView.reloadData()
    }
    
}
