//
//  ScrollViewController.swift
//  Qv1
//
//  Created by Spencer Johnson on 3/5/17.
//  Copyright © 2017 Spencer Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBarItems()
        
        let vc0 = storyboard?.instantiateViewController(withIdentifier: "UserHomeViewController") as! UserHomeViewController
       
        self.addChildViewController(vc0)
        self.scrollView.addSubview(vc0.view)
        vc0.didMove(toParentViewController: self)

     
        let vc1 = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc1.profileUserID = (FIRAuth.auth()?.currentUser?.uid)!
        
        var frame1 = vc1.view.frame
        frame1.origin.x = self.view.frame.size.width
        vc1.view.frame = frame1
        
        self.addChildViewController(vc1)
        self.scrollView.addSubview(vc1.view)
        vc1.didMove(toParentViewController: self)
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * 2, height: self.view.frame.size.height-66)
        
        
        // Do any additional setup after loading the view.
    }

    
    
    func setUpNavigationBarItems () {
        
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "Profile Image Border"))
        
        titleImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        titleImageView.contentMode = .scaleAspectFit
        // let titleImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.logoTapped(sender:)))
        // titleImageView.addGestureRecognizer(titleImageViewTapGesture)
        titleImageView.isUserInteractionEnabled = true
        
        navigationItem.titleView = titleImageView
        
        let profileIconImageView = UIImageView()
        //let profileIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.myProfileImageTapped(sender:)))
        
        profileIconImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        profileIconImageView.layer.cornerRadius = profileIconImageView.frame.size.width / 2
        profileIconImageView.layer.borderWidth = 1
        profileIconImageView.layer.borderColor = UIColor.init(hexString: "004488").cgColor
        profileIconImageView.layer.masksToBounds = true
        //  profileIconImageView.addGestureRecognizer(profileIconTapGesture)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileIconImageView)
        
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).observe(.value, with: {
            snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            let profileImageURLString = snapshotValue["profileImageURL"] as! String
            let profileImageURL = URL(string: profileImageURLString)
            
            profileIconImageView.sd_setImage(with: profileImageURL)
            
        })
        
        
        let notificationIconImageView = UIImageView()
        // let notificationIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.notificationIconTapped(sender:)))
        
        notificationIconImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        //   notificationIconImageView.addGestureRecognizer(notificationIconTapGesture)
        
        notificationIconImageView.image = #imageLiteral(resourceName: "new message notification icon")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationIconImageView)
        
        
        
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        
        UIView.animate(withDuration: 1, animations: {
            
            profileIconImageView.alpha = 0
            profileIconImageView.alpha = 1
        })
        
    }


}
