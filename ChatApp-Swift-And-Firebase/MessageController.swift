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
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observe(.value, with: { (snapshot) in
                /*
                     print(snapshot)
                     Snap (8LSZQPE5O0NqT0IcpDBdkVYBrNu1) {
                     email = "X@X.com";
                     name = X;
                     password = xxxxxx;
                     }
                 */
                
                if let userInfoDict = snapshot.value as? [String : AnyObject] {
                    self.navigationItem.title = userInfoDict["name"] as? String
                }
           
            }, withCancel: nil)
        }
    }
    
    func handelLogOut() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let logInController = LoginController()
        present(logInController, animated: true, completion: nil)
    }
    
    func handelNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController.init(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
}

