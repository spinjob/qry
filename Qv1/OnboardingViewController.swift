//
//  OnboardingViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 3/13/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import paper_onboarding
import FirebaseAuth
import FirebaseDatabase


class OnboardingViewController: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {
    
    @IBOutlet weak var onboarding: UIView!
    
    //brand colors
    
    let brightGreen = UIColor.init(hexString: "A8E855")
    let red = UIColor.init(hexString: "FF4E56")
    let actionGreen = UIColor.init(hexString: "00D1D5")
    let blue = UIColor.init(hexString: "004488")
    let grey = UIColor.init(hexString: "D8D8D8")
    
    var userName : String = ""
    let currentUserID = FIRAuth.auth()?.currentUser?.uid
    var isFromLogin : Bool = false
    
    
    //fonts
    
    let textFont : UIFont = UIFont(name: "ProximaNovaSoft-Bold", size: 24)!
    let descriptionFont : UIFont = UIFont(name: "Proxima Nova Soft", size: 24)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBarItems()
        
        let onboardingView = PaperOnboarding(itemsCount: 5)
        onboardingView.dataSource = self
        onboardingView.delegate = self
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
            
          ("onboarding1PollImage", "Ask a group", "Start a group chat with a question and two responses", "askQuestionIcon", blue, UIColor.white, UIColor.white, textFont, descriptionFont),
            ("collectImage", "Get answers", "Collect opinions or get a headcount", "collectIcon", actionGreen, UIColor.white, UIColor.white, textFont, descriptionFont),
            ("discussOnboardingImage", "Message by response", "Chat with the entire group or filter by answer", "discussOnboardingIcon", red, UIColor.white, UIColor.white, textFont, descriptionFont), ("threadOnboardingImage", "Create targeted groups", "Create new group chats from poll answer groups", "Launch Image", UIColor.white, blue, blue, textFont, descriptionFont), ("nextIcon", "Let's do it", "Tap above to login", "launchImage", UIColor.white, blue, blue, textFont, descriptionFont)][index]
        
    }
    
    
    func onboardingItemsCount() -> Int {
        
        if isFromLogin == true {
            return 4
        }
        return 5
    }

    
    func onboardingWillTransitonToIndex(_ index: Int) {
        
    }
    
    
    func onboardingDidTransitonToIndex(_ index: Int) {

        
    }
    
    
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
        if index == 4, isFromLogin == false {
            
            let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.performSegue(sender:)))
            view.addGestureRecognizer(tapGesture)

        }
        

    }

    
    func performSegue (sender: UITapGestureRecognizer) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FindFriendsViewController") as! FindFriendsViewController
        let transition:CATransition = CATransition()
        
        
        controller.onboarding = true
        
        
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)

        
    }

    
    func setUpNavigationBarItems () {
        
       // navigationController?.navigationBar.backgroundColor = UIColor.white
       // navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backItem?.hidesBackButton = true
        
    }

}
