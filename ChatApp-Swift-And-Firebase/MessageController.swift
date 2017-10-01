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

    var messages = [Message]()
    let CellID = "CellID"
    var MessagesDict = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Sign out", style: .plain, target: self, action: #selector(handelLogOut))
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "edit-message"), style: .plain, target: self, action: #selector(handelNewMessage))
        checkUserIsLoggedIn()
//        observeMessages()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: CellID)
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
             }
             */
            print(snapshot)
            
            if let userInfoDict = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.setValuesForKeys(userInfoDict)
                self.setUpNavBarWithUser(user)
            }
            
        }, withCancel: nil)
    }
    
    func setUpNavBarWithUser(_ user:User){
        messages.removeAll()
        MessagesDict.removeAll()
        tableView.reloadData() 
        observeUserMessages()

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
        newMessageController.messageController = self
        present(navController, animated: true, completion: nil)
    }
    
    func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func observeUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesReference.observeSingleEvent(of:.value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.setValuesForKeys(dict)
                    //                self.messages.append(message)
                    
                    if let toId = message.toId {
                        self.MessagesDict[toId] = message
                        self.messages = Array(self.MessagesDict.values)
                        
                        
                        self.messages =  self.messages.sorted(by: { (message1, message2) -> Bool in
                            return Date.init(timeIntervalSince1970: message1.timeStamp!.doubleValue) > Date.init(timeIntervalSince1970: message2.timeStamp!.doubleValue)
                        })
                    }
                    
                    // this will crash because of background thread , so lets use dispatch_thread
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func observeMessages() {
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dict)
//                self.messages.append(message)
                
                if let toId = message.toId {
                    self.MessagesDict[toId] = message
                    self.messages = Array(self.MessagesDict.values)
                    
                    
                   self.messages =  self.messages.sorted(by: { (message1, message2) -> Bool in
                        return Date.init(timeIntervalSince1970: message1.timeStamp!.doubleValue) > Date.init(timeIntervalSince1970: message2.timeStamp!.doubleValue)
                    })
                }
                
                // this will crash because of background thread , so lets use dispatch_thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            }
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as? UserCell
        let message = messages[indexPath.row]
        cell?.message = message
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let chartPartnerId = message.chatPartnerId()
    
        let ref = FIRDatabase.database().reference().child("users").child(chartPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let dictionary = snapshot.value as? [String: AnyObject] else {
            return
        }
        
        let user = User()
        user.id = chartPartnerId
        user.setValuesForKeys(dictionary)  
        self.showChatControllerForUser(user: user)
        
    }, withCancel: nil)
    
    }
}
