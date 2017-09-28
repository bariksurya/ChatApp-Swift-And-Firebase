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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
}

class UserCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
