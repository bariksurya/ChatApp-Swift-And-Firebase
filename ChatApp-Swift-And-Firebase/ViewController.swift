//
//  ViewController.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 9/26/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Logout", style: .plain, target: self, action: #selector(handelLogOut))
    }
    
    func handelLogOut() {
        let logInController = LoginController()
        present(logInController, animated: true, completion: nil)
    }

}

