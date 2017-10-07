//
//  ChatMessageCell.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 10/1/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController: ChatLogController?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aIV = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        aIV.translatesAutoresizingMaskIntoConstraints = false
        aIV.hidesWhenStopped = true
        return aIV
    }()
    
    var message: Message?
    
    lazy var playButton: UIButton = {
        let button = UIButton.init(type: .system)
//        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(handelVideoPlay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.init(named: "play"), for: .normal)
        button.tintColor = UIColor.white
        return button
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
//        tv.textAlignment = .right
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(r: 0, g: 137, b: 249)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage.init(named: "user")
        profileImageView.layer.cornerRadius = 16
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        return profileImageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handelZoomTap)))
        return imageView
    }()
    
    func handelZoomTap(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            return
        }
        if let imgVIew = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInForStartingImageVIew(startingImageView: imgVIew)
        }
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true

        bubbleView.addSubview(playButton)
        
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20)
        bubbleViewRightAnchor?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleViewLeftAnchor?.isActive = false
        
//        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
//        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func handelVideoPlay() {
        if let videoUrlString = message?.videoUrl , let url = URL.init(string: videoUrlString)  {
            player = AVPlayer.init(url: url)
            playerLayer = AVPlayerLayer.init(layer: player!)
            playerLayer?.frame = bubbleView.bounds
            if let playerLayer = playerLayer {
                bubbleView.layer.addSublayer(playerLayer)
            }
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
}
