//
//  ChatLogController.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 9/29/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    let cellId = "CellID"
    var messages = [Message]()
    
    var user : Person? {
        didSet {
            navigationItem.title = user?.name
            observeMessage()
        }
    }
    
    lazy var containerview: UIView = {
        let cView = UIView()
        cView.backgroundColor = UIColor.white
        return cView
    }()
    
    lazy var inputTextField: UITextField = {
        let inputTf = UITextField()
        inputTf.placeholder = "Enter Message ....."
        inputTf.translatesAutoresizingMaskIntoConstraints = false
        inputTf.delegate = self
        inputTf.backgroundColor = UIColor.clear
        return inputTf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        self.setUpInputComponents()
        setUpKeyboardObservers()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerview
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var containerViewBottomAncher: NSLayoutConstraint?
    
    func setUpInputComponents() {
        
        containerview.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 50)

        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage.init(named: "upload-image")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handelUploadTap)))
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        containerview.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: containerview.leftAnchor, constant: 10).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.lightGray
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerview.addSubview(separatorView)
        
        
        separatorView.leftAnchor.constraint(equalTo: containerview.leftAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: containerview.rightAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerview.topAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(checkTFisEmpty), for: .touchUpInside)
        containerview.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerview.rightAnchor, constant: -20).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: sendButton.intrinsicContentSize.width).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerview.heightAnchor).isActive = true
        
        containerview.addSubview(inputTextField)

        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor , constant: 10).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerview.centerYAnchor).isActive = true
//        inputTf.widthAnchor.constraint(equalToConstant: containerview.frame.size.width - sendButton.frame.size.width).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -10).isActive = true
        inputTextField.heightAnchor.constraint(lessThanOrEqualTo: containerview.heightAnchor).isActive = true
    }
    
    func checkTFisEmpty() {
        if inputTextField.text == ""{
            return
        }else {
           handelSend()
        }
    }
    
    
    func handelSend() {
        sendMessageWithProperty(["text":inputTextField.text! as AnyObject])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkTFisEmpty()
        textField.resignFirstResponder()
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let messages = self.messages[indexPath.item]
        cell.message = messages
        cell.textView.text = messages.text
        setUpCell(cell: cell, messages: messages)
        
        if let text = messages.text {
            cell.bubbleWidthAnchor?.constant = estimatedHeightBasedOnText(text: text).width + 32
            cell.textView.isHidden = false
        } else if messages.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        /*
        if messages.videoUrl != nil {
            cell.playButton.isHidden = false
        }else {
            cell.playButton.isHidden = true
        } */
        
        cell.playButton.isHidden = messages.videoUrl == nil
        
        return cell
    }
    
    private func setUpCell(cell: ChatMessageCell, messages: Message){
        
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImagesUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if messages.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = UIColor.init(r: 0, g: 137, b: 249)
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }else {
            cell.bubbleView.backgroundColor = UIColor.init(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = messages.imageUrl {
            cell.messageImageView.loadImagesUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.row]
        if let text = message.text {
            height = estimatedHeightBasedOnText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue , let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        return CGSize.init(width: view.frame.width, height: height)
    }
    
    private func estimatedHeightBasedOnText(text: String) -> CGRect{
       let size = CGSize.init(width: 200, height: 1000)
       let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
       return NSString.init(string: text).boundingRect(with: size, options: option, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func observeMessage() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message()
                message.setValuesForKeys(dict)
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        let indexpath = NSIndexPath.init(item: self.messages.count-1, section: 0)
                        self.collectionView?.scrollToItem(at: indexpath as IndexPath, at: .bottom, animated: true)
                    }
            }, withCancel: nil)
        }, withCancel: nil)
    }

    func setUpKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handelKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handelKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handelKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    func handelKeyboardDidShow() {
        if messages.count > 0 {
            let indexpath = NSIndexPath.init(item: self.messages.count-1, section: 0)
            self.collectionView?.scrollToItem(at: indexpath as IndexPath, at: .top, animated: true)
        }
    }
    
    func handelKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        containerViewBottomAncher?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handelKeyboardWillHide(notification: NSNotification){
//        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        containerViewBottomAncher?.constant = 0
        let keyboardDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handelUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            handelSelectedVideoForUrl(videoURL: videoURL)
            /*
            print(videoURL)
             file:///private/var/mobile/Containers/Data/Application/981B1C06-2E35-4B2B-9611-E3C1ACC3DB5C/tmp/6CBE4C45-B19F-4267-A7E4-B332FD974683.MOV
             */
        } else {
            handelSelectedImageForInfo(info: info as [String : AnyObject])
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func handelSelectedVideoForUrl(videoURL: URL) {
        let fileName = NSUUID().uuidString+".mov"
        let uploadTask = Storage.storage().reference().child("message_videos").child(fileName).putFile(from: videoURL, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("Failed to upload the video:", error!)
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumnailImageForPrivateVideoUrl(videoUrl: videoURL){
                    self.uploadToFirebaseStorage(thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl":imageUrl,"imageWidth":thumbnailImage.size.width , "imageHeight":thumbnailImage.size.height,"videoUrl": videoUrl] as [String: AnyObject]
                        self.sendMessageWithProperty(properties)
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress?.completedUnitCount ?? " ")
        }
    }
    
    private func thumnailImageForPrivateVideoUrl(videoUrl: URL) -> UIImage?{
        let asset = AVAsset.init(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator.init(asset: asset)
        
        do {
            let thumbanailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage.init(cgImage: thumbanailCGImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    private func handelSelectedImageForInfo(info: [String: AnyObject]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let origionalImage = info["UIImagePickerControllerOrigionalImage"] as? UIImage {
            selectedImageFromPicker = origionalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
//            uploadToFirebaseStorage(selectedImage)
            uploadToFirebaseStorage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl, selectedImage)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorage(_ image: UIImage, completion:@escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed to Upload Image:",error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
        }
    }
    
    private func sendMessageWithImageUrl(_ imageUrl: String , _ image: UIImage){
        sendMessageWithProperty(["imageUrl":imageUrl,"imageWidth":image.size.width , "imageHeight":image.size.height] as [String: AnyObject])
    }
    
    private func sendMessageWithProperty(_ property: [String: AnyObject]){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = NSNumber.init(value: Date().timeIntervalSince1970)
        var values: [String : AnyObject] = ["toId":toId as AnyObject, "fromId":fromId as AnyObject, "timeStamp":timeStamp]
        
        values = values.merged(with: property)
 
        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            self.inputTextField.text = nil
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipentUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipentUserMessageRef.updateChildValues([messageId: 1])
        }

    }
    
    var startingFrame: CGRect?
    var backBackgroundView: UIView?
    var startingImageView: UIImageView?
    func performZoomInForStartingImageVIew(startingImageView: UIImageView) {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomingImageView = UIImageView.init(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handelZoomOut)))
        zoomingImageView.isUserInteractionEnabled = true
        
        if let keyWindow =  UIApplication.shared.keyWindow {
  
            backBackgroundView = UIView.init(frame: keyWindow.frame)
            if let backBackgroundView = backBackgroundView {
                backBackgroundView.backgroundColor = UIColor.black
                backBackgroundView.alpha = 0
                keyWindow.addSubview(backBackgroundView)
            }
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.backBackgroundView!.alpha = 1
                self.inputAccessoryView?.alpha = 0
                // calculate heright h2/w2 = h1/w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect.init(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    func handelZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.backBackgroundView?.alpha = 0
                self.inputAccessoryView?.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
            
            /*
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.backBackgroundView?.alpha = 0
            }, completion: { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
            }) */
        }
    }
}

extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}

