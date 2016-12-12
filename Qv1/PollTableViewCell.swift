//
//  PollTableViewCell.swift
//  Qv1
//
//  Created by Spencer Johnson on 11/7/16.
//  Copyright © 2016 Spencer Johnson. All rights reserved.
//

import UIKit

class PollTableViewCell: UITableViewCell {

    //ResultsView
    @IBOutlet weak var answer2PercentageTextLabel: UILabel!
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var answer1PercentageTextLabel: UILabel!
    @IBOutlet weak var answer1ResultBarImageView: UIImageView!
    @IBOutlet weak var answer2ResultBarImageView: UIImageView!
    @IBOutlet weak var answer2TextLabel: UILabel!
    @IBOutlet weak var answer1TextLabel: UILabel!
    @IBOutlet weak var senderUserLabel: UILabel!
    @IBOutlet weak var senderUserImageView: UIImageView!
    @IBOutlet weak var questionStringLabel: UILabel!
    @IBOutlet weak var answer1Button: UIButton!
    @IBOutlet weak var answer2Button: UIButton!
    @IBOutlet weak var conversationButton: UIButton!
    @IBOutlet weak var viewPollResultsButton: UIButton!
    @IBOutlet weak var separatorImageView: UIImageView!
    @IBOutlet weak var pollImageView: UIImageView!
    @IBOutlet weak var resultViewVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeadlineTextLabel: UILabel!
    @IBOutlet weak var imageDescriptionTextView: UITextView!
    @IBOutlet weak var linkPreviewView: UIView!
    
    @IBOutlet weak var answerButton1VerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var answerButton2VerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var groupMemberCollectionView: UICollectionView!
    
    @IBOutlet weak var noVotesButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        groupMemberCollectionView.showsHorizontalScrollIndicator = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        
        groupMemberCollectionView.delegate = dataSourceDelegate
        groupMemberCollectionView.dataSource = dataSourceDelegate
        groupMemberCollectionView.tag = row
        groupMemberCollectionView.reloadData()
    }

}
