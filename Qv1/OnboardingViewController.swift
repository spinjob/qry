//
//  OnboardingViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 3/13/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import paper_onboarding


class OnboardingViewController: UIViewController, PaperOnboardingDataSource {
    
    @IBOutlet weak var onboarding: UIView!
    
    //brand colors
    
    let brightGreen = UIColor.init(hexString: "A8E855")
    let red = UIColor.init(hexString: "FF4E56")
    let actionGreen = UIColor.init(hexString: "00D1D5")
    let blue = UIColor.init(hexString: "004488")
    let grey = UIColor.init(hexString: "D8D8D8")
    
    
    //fonts
    
    let textFont : UIFont = UIFont(name: "ProximaNovaSoft-Bold", size: 24)!
    let descriptionFont : UIFont = UIFont(name: "Proxima Nova Soft", size: 24)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let onboardingView = PaperOnboarding(itemsCount: 4)
        onboardingView.dataSource = self
        onboardingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboardingView)
        
        // add constraints
        for attribute: NSLayoutAttribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboardingView,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        
        
    }
        
    }

    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        return [
            
            ("onboarding1PollImage", "Ask a question", "Start planning by asking a question, providing two quick-responses, and picking an expiration", "askQuestionIcon", blue, UIColor.white, UIColor.white, textFont, descriptionFont),
            ("collectImage", "Collect responses", "Use quick-responses to get rapid feedback and headcounts", "collectIcon", actionGreen, UIColor.white, UIColor.white, textFont, descriptionFont),
            ("discussOnboardingImage", "Hop into the group chat", "Talk with sub-groups based on their response", "discussOnboardingIcon", red, UIColor.white, UIColor.white, textFont, descriptionFont),
            ("launchImage", "Organize and follow up", "Link related discussions to organize your plans and filter out friends by answer", "launchImage", brightGreen, UIColor.white, UIColor.white, textFont, descriptionFont)][index]
    }
    
    
    func onboardingItemsCount() -> Int {
        return 4
    }

    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {

    }

}
