//
//  LoginController+Handler.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 9/29/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


extension LoginController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func handelRegister() {
        guard let name = nameTF.text,let email = emailIdTF.text, let password = passwordTF.text else{
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
            if error != nil {
                print(error ?? "Not Trackable Error")
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let imageName = "my_profile_image_\(uid).png"
            // upload image
            let storageRef = Storage.storage().reference().child("Profile_images").child(imageName)
            //            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!)

            if let profileImage = self.profileImageView.image ,let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                    
                    if err != nil {
                        print(err ?? "not traceable error")
                        return
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        let values = ["name":name, "email":email,"profileImageUrl":profileImageUrl]
                        self.registerUserInDatabaseWithUid(uid: uid, values: values as [String : AnyObject])

                    }
                    /*
                    print(metadata ?? "no data") */
                })
            }
        })
    }
    
    private func registerUserInDatabaseWithUid(uid: String, values: [String:AnyObject]) {
        //  Firebasedatabse reference
//        let ref = FIRDatabase.database().reference(fromURL: "https://surya-chatbox.firebaseio.com/")
        let ref = Database.database().reference()
        let userRef = ref.child("users").child(uid) // this helps to separate user based on uid
        userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err ?? "Not Trackable Error")
                return
            }
            self.messagesController?.fetchUserAndSetNavBarTitle()
//            self.messagesController?.navigationController?.title = values["name"] as? String
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handelLogIn() {
        guard let email = emailIdTF.text, let password = passwordTF.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                return
            }
            // sucessfully logged in
            self.messagesController?.fetchUserAndSetNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handelLogInRegister() {
        if  logInRegisterSegControl.selectedSegmentIndex == 0{
            handelLogIn()
        }else {
            handelRegister()
        }
    }
    
    func handelSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("It cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        /*
        print(info)
         
         ["UIImagePickerControllerImageURL": file:///private/var/mobile/Containers/Data/Application/A031F19D-57DD-46F3-B547-ADF8638F4577/tmp/FCB0BFA1-BDC0-4158-8CEF-FB49B03B5370.jpeg, "UIImagePickerControllerMediaType": public.image, "UIImagePickerControllerReferenceURL": assets-library://asset/asset.HEIC?id=D23252FB-F4E4-4598-87DD-B2D1C885A05F&ext=HEIC, "UIImagePickerControllerOriginalImage": <UIImage: 0x1c40b1ee0> size {2320, 3088} orientation 3 scale 1.000000]
        */
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let origionalImage = info["UIImagePickerControllerOrigionalImage"] as? UIImage {
            selectedImageFromPicker = origionalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
            profileImageView.layer.cornerRadius = 40.0
            profileImageView.layer.masksToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
}






