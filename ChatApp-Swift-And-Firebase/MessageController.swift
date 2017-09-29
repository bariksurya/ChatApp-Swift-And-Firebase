//
//  ViewController.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 9/26/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Sign out", style: .plain, target: self, action: #selector(handelLogOut))
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "edit-message"), style: .plain, target: self, action: #selector(handelNewMessage))
        checkUserIsLoggedIn()
    }
    
    func checkUserIsLoggedIn(){
        // user not logged in
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handelLogOut), with: self, afterDelay: 0)
        }else {
            fetchUserAndSetNavBarTitle()
        }
    }
    
    func fetchUserAndSetNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            /*
             print(snapshot)
             Snap (8LSZQPE5O0NqT0IcpDBdkVYBrNu1) {
             email = "X@X.com";
             name = X;
             password = xxxxxx;
             }
             */
            
            if let userInfoDict = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.setValuesForKeys(userInfoDict)
                self.setUpNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    func setUpNavBarWithUser(_ user:User){
        self.navigationController?.title = user.name
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImagesUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)

        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        nameLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        nameLabel.heightAnchor.constraint(equalTo:profileImageView.heightAnchor).isActive = true

        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        self.navigationItem.titleView = titleView
    }
    
    func handelLogOut() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let logInController = LoginController()
        logInController.messagesController = self
        present(logInController, animated: true, completion: nil)
    }
    
    func handelNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController.init(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
}

