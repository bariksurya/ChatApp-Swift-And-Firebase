//
//  LoginController.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 9/27/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import Firebase

extension UIColor {
    convenience init(r:CGFloat,g:CGFloat,b:CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

class LoginController: UIViewController,UITextFieldDelegate {

    var messagesController: MessageController?
    
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var logInRegisterButton: UIButton = {
        let button = UIButton.init(type: .system)
        button.backgroundColor = UIColor.init(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(handelLogInRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTF: UITextField = {
       let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
       return tf
    }()
    
    let nameSeparatorView: UIView = {
        let spView = UIView()
        spView.backgroundColor = UIColor.init(r: 220, g: 220, b: 220)
        spView.translatesAutoresizingMaskIntoConstraints = false
        return spView
    }()
    
    let emailIdTF: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email Id"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailIDSeparatorView: UIView = {
        let spView = UIView()
        spView.backgroundColor = UIColor.init(r: 220, g: 220, b: 220)
        spView.translatesAutoresizingMaskIntoConstraints = false
        return spView
    }()
    
    let passwordTF: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var profileImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage.init(named: "user")
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        imgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handelSelectProfileImageView)))
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    
    lazy var logInRegisterSegControl: UISegmentedControl = {
        let sc = UISegmentedControl.init(items: ["LogIn","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(segControlValueChanged), for: .valueChanged)
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(r: 61, g: 91, b: 151)
        view.addSubview(inputContainerView)
        view.addSubview(logInRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(logInRegisterSegControl)

        setUpInputContainerView()
        setUpLogInRegisterView()
        setUpProfileImageView()
        setUpLogInRegisterSegControl()
        
        nameTF.delegate = self
        passwordTF.delegate = self
        emailIdTF.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUpProfileImageView() {
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: logInRegisterSegControl.topAnchor, constant: -12).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    var inputContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?

    func setUpInputContainerView() {
        
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerViewHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(nameTF)
        inputContainerView.addSubview(nameSeparatorView)
        inputContainerView.addSubview(emailIdTF)
        inputContainerView.addSubview(emailIDSeparatorView)
        inputContainerView.addSubview(passwordTF)
        
        nameTF.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        nameTF.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTF.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTF.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true;
        
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTF.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        emailIdTF.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        emailIdTF.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive = true
        emailIdTF.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailIdTF.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true;

        
        emailIDSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailIDSeparatorView.topAnchor.constraint(equalTo: emailIdTF.bottomAnchor).isActive = true
        emailIDSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailIDSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        passwordTF.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 12).isActive = true
        passwordTF.topAnchor.constraint(equalTo: emailIDSeparatorView.bottomAnchor).isActive = true
        passwordTF.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTF.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true;
    }
    
    func setUpLogInRegisterView() {
        logInRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logInRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 8).isActive = true
        logInRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        logInRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setUpLogInRegisterSegControl(){
        logInRegisterSegControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logInRegisterSegControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12).isActive = true
        logInRegisterSegControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        logInRegisterSegControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    func segControlValueChanged(){
        let segControlTitle = logInRegisterSegControl.titleForSegment(at: logInRegisterSegControl.selectedSegmentIndex)
        logInRegisterButton.setTitle(segControlTitle, for: .normal)
        
        // change inputContainerView height
        inputContainerViewHeightAnchor?.constant = logInRegisterSegControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // change nameTF Height
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTF.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: logInRegisterSegControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        // change emailTF Height
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailIdTF.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: logInRegisterSegControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true

        // change emailTF Height
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTF.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: logInRegisterSegControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        let hideProfileImageView: Bool!
        hideProfileImageView = logInRegisterSegControl.selectedSegmentIndex == 0 ? true : false
        profileImageView.isHidden = hideProfileImageView
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
