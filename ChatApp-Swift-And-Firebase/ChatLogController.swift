//
//  ChatLogController.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 9/29/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController,UITextFieldDelegate {

    var user : User? {
        didSet {
            navigationItem.title = user?.name
        }
    }
    
    lazy var inputTextField: UITextField = {
        let inputTf = UITextField()
        inputTf.placeholder = "Enter Message ....."
        inputTf.translatesAutoresizingMaskIntoConstraints = false
        inputTf.delegate = self
        return inputTf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        setUpInputComponents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpInputComponents() {
        let containerview = UIView()
        containerview.translatesAutoresizingMaskIntoConstraints = false
        containerview.backgroundColor = UIColor.white
        view.addSubview(containerview)
        
        containerview.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerview.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        containerview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerview.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        containerview.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerview.rightAnchor, constant: -20).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: sendButton.intrinsicContentSize.width).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerview.heightAnchor).isActive = true
        
        containerview.addSubview(inputTextField)

        inputTextField.leftAnchor.constraint(equalTo: containerview.leftAnchor).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
//        inputTf.widthAnchor.constraint(equalToConstant: containerview.frame.size.width - sendButton.frame.size.width).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 10).isActive = true
        inputTextField.heightAnchor.constraint(lessThanOrEqualTo: containerview.heightAnchor).isActive = true

        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.gray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerview.addSubview(separatorView)
        
        separatorView.leftAnchor.constraint(equalTo: containerview.leftAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: containerview.rightAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerview.topAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = false
    }
    
    func handelSend() {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timeStamp = NSNumber.init(value: Date().timeIntervalSince1970)
        let values = ["text":inputTextField.text!, "toId":toId, "fromId":fromId, "timeStamp":timeStamp] as [String : Any]
        childRef.updateChildValues(values)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handelSend()
        textField.resignFirstResponder()
        return true
    }
    

}
