//
//  NewMessageController.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 9/28/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    var messageController = MessageController()
    
    let cellID = "CellID"
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(handelCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        fetchUser()
    }
    
    func handelCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject]{
                let user = User()
                user.id = snapshot.key
                // bellow might crash when Class Property name dont match with Dictionary Key name , safer way to do . user.name = dict["name"]
                user.setValuesForKeys(dict)
                self.users.append(user)
                
                // this will crash because of background thread , so lets use dispatch_thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImagesUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true){
            let selecteUser = self.users[indexPath.row]
            self.messageController.showChatControllerForUser(user: selecteUser)
        }
    }
}

class UserCell: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y-2, width: textLabel!.frame.size.width, height: textLabel!.frame.size.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y+2, width: detailTextLabel!.frame.size.width, height: detailTextLabel!.frame.size.height)
    }
    
    let profileImageView : UIImageView = {
       let imgView = UIImageView()
       imgView.image = UIImage.init(named: "user")
       imgView.translatesAutoresizingMaskIntoConstraints = false
       imgView.layer.cornerRadius = 24
       imgView.layer.masksToBounds = true
       imgView.contentMode = .scaleAspectFill
       return imgView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
