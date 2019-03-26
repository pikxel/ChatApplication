//
//  MessageCell.swift
//  ChatApplication
//
//  Created by Peter Lizak on 11/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit
import Firebase

class ChatMessageCell: UICollectionViewCell {
    
    var recipientProfileImageUrl:String?
    var zoomDelegate:ChatMessageCellImageZoomDelegate?
    var backgroundBubbleViewWidthAnchor: NSLayoutConstraint?
    var backgroundBubbleViewLeadingAnchor: NSLayoutConstraint?
    var backgroundBubbleViewTrailingAnchor: NSLayoutConstraint?
    let bubbleViewBlueBackground = UIColor(hue: 0.5694, saturation: 0.53, brightness: 0.89, alpha: 1.0)
    let bubbleViewGrayBackground = UIColor.lightGray
    
    lazy var safeImageLoading = { (image : UIImage,_ downloadedImgURL:String) ->Void in
        if (downloadedImgURL == self.message?.imageUrl){
            self.imageView.image = image
        }
    }
    
    var message:Message?{
        didSet{
            
            if(message?.senderUserID == Auth.auth().currentUser?.uid) {
                self.backgroundBubbleViewLeadingAnchor?.isActive = false
                self.backgroundBubbleViewTrailingAnchor?.isActive = true
                recipientProfileImageView.isHidden = true
                self.backgroundBubbleView.backgroundColor = self.bubbleViewBlueBackground
            }else {
                self.backgroundBubbleViewTrailingAnchor?.isActive = false
                self.backgroundBubbleViewLeadingAnchor?.isActive = true
                recipientProfileImageView.isHidden = false
                self.backgroundBubbleView.backgroundColor = self.bubbleViewGrayBackground
                
                if let imageUrl = recipientProfileImageUrl {
                    recipientProfileImageView.loadImageAndCacheItUsingUrlString(imageUrl: imageUrl, safelyLoadImageWithClosure: nil)
                }
            }
            
            if let text = message?.text {
                self.imageView.image = nil
                textView.text = text
                let textViewIdealSize = textView.sizeThatFits(CGSize(width:200,height: 10000))
                self.imageView.isUserInteractionEnabled = false
                backgroundBubbleViewWidthAnchor?.constant = textViewIdealSize.width + 10
            } else if let imageUrl = message?.imageUrl {
                self.imageView.isUserInteractionEnabled = true
                self.imageView.loadImageAndCacheItUsingUrlString(imageUrl: imageUrl,safelyLoadImageWithClosure: safeImageLoading)
                backgroundBubbleViewWidthAnchor?.constant = 200
                self.backgroundBubbleView.backgroundColor = .clear
            }
            
            if message?.videoUrl != nil {
                videoPausePlayButton.isHidden = false
                addVideoPlayButton()
            }else {
                videoPausePlayButton.isHidden = true
            }
         }
    }

    lazy var backgroundBubbleView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = bubbleViewBlueBackground
        return view
    }()
    
    let textView: UITextView =  {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor.white
        textView.layer.cornerRadius = 20
        textView.backgroundColor = UIColor.clear
        textView.layer.masksToBounds = true
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped) ))
        return imageView
    }()
    
    let recipientProfileImageView: UIImageView =  {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var videoPausePlayButton:UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "play"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePlay), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        self.addSubview(backgroundBubbleView)
        self.addSubview(textView)
        self.addSubview(recipientProfileImageView)
        self.addSubview(imageView)
        
        backgroundBubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundBubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        backgroundBubbleViewWidthAnchor = backgroundBubbleView.widthAnchor.constraint(equalToConstant: 200)
        backgroundBubbleViewWidthAnchor?.isActive = true
        
        backgroundBubbleViewTrailingAnchor = backgroundBubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant:-8)
        backgroundBubbleViewLeadingAnchor = backgroundBubbleView.leadingAnchor.constraint(equalTo: self.recipientProfileImageView.trailingAnchor,constant: 8 )
        
        textView.topAnchor.constraint(equalTo: self.backgroundBubbleView.topAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.backgroundBubbleView.trailingAnchor,constant:-2).isActive = true
        textView.leadingAnchor.constraint(equalTo: self.backgroundBubbleView.leadingAnchor,constant:2).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.backgroundBubbleView.bottomAnchor).isActive = true
        
        recipientProfileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        recipientProfileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        recipientProfileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        recipientProfileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        imageView.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: textView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: textView.heightAnchor).isActive = true
    }
    
    private func addVideoPlayButton(){
        self.addSubview(videoPausePlayButton)
        
        videoPausePlayButton.centerYAnchor.constraint(equalTo: self.backgroundBubbleView.centerYAnchor).isActive = true
        videoPausePlayButton.centerXAnchor.constraint(equalTo: self.backgroundBubbleView.centerXAnchor).isActive = true
        videoPausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        videoPausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func imageViewTapped(){
        if self.message?.videoUrl != nil {
            return
        }
        
        if let imageZoomDelegate = self.zoomDelegate {
            imageZoomDelegate.zoomToImage(imageView:self.imageView)
        }
    }
    
    @objc func handlePlay() {
        if let imageZoomDelegate = self.zoomDelegate,let url = message?.videoUrl,let videoUrl = URL(string: url) {
            imageZoomDelegate.zoomToVideo(imageView:self.imageView,videoUrl:videoUrl)
        }
    }
    
}
