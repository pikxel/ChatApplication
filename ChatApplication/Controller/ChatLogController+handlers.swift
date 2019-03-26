//
//  ChatLogController+handlers.swift
//  ChatApplication
//
//  Created by Peter Lizak on 13/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import AVFoundation

extension ChatLogController {
    
    func handleSend() {
        if let message = inputViewBottom.inputTextField.text{
            if message.isEmpty{
                return
            }
            let ref = Database.database().reference().child("messages")
            let childRef = ref.childByAutoId()
            if let senderUserID = Auth.auth().currentUser?.uid, let recipientUserID = self.recipientUser.id {
                let timeStamp = Int(Date().timeIntervalSince1970)
                childRef.updateChildValues(["text":message,"senderUserID": senderUserID,"recipientUserID":recipientUserID , "timeStamp":timeStamp]) { (error, databaseReference) in
                    if(error != nil){
                        print("Unable to upload message to the database")
                        return
                    }
                    guard let messageReferenceKey = databaseReference.key else {return}
                    self.createUserReferenceToMessage(senderUserID,recipientUserID, messageReferenceKey)
                    self.createUserReferenceToMessage(recipientUserID,senderUserID,messageReferenceKey)
                    
                    self.inputViewBottom.inputTextField.text = ""
                }
            }
        }
    }
        
    func createUserReferenceToMessage(_ userID:String,_ recipiantUserID:String, _ messageReference:String) {
        let userMessageRef = Database.database().reference().child("user-messages").child(userID).child(recipiantUserID)
        let userMessageVal = [messageReference:1]
        userMessageRef.updateChildValues(userMessageVal, withCompletionBlock: { (userMessageErr, userMessageDatabaseResponse) in
            if(userMessageErr != nil){
                print("Error creating user-messages")
            }
        })
    }
    
    
    func observeMessages(){
        self.messages.removeAll()
        self.messagesDictionary.removeAll()
        
        guard let userID = Auth.auth().currentUser?.uid, let recipientUserID = self.recipientUser.id else { return }
        let userMessagesRef = Database.database().reference().child("user-messages").child(userID).child(recipientUserID)
        userMessagesRef.observe(.childAdded) { (snapshot) in
            let messageKey = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageKey)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String:Any] {
                    
                    let message = Message(value)
                    self.messages.append(message)

                    self.attemptToReloadTableAndSortMessagesArray()
                }
            })
        }
    }
    
    private func attemptToReloadTableAndSortMessagesArray() {        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.reloadCollectionViewAndScrollToBottom), userInfo: nil, repeats: false)
    }
    
    @objc func reloadCollectionViewAndScrollToBottom() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView?.scrollToItem(at: IndexPath(item: self.messages.count-1, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
        }
    }
    
    func zoomToImage(imageView:UIImageView) {
        if let keyWindow = UIApplication.shared.keyWindow {
            zoomedMessageCell = ChatMessageCellZoom(imageView: imageView,frame:keyWindow.frame)
            if let zoomedCell = self.zoomedMessageCell {
                zoomedCell.delegate = self
                zoomedCell.animate(videoAnimation:false)
                keyWindow.addSubview(zoomedCell)
                self.inputViewBottom.isHidden = true
            }
        }
    }
    
    
    
    func zoomToVideo(imageView:UIImageView,videoUrl:URL) {
        if let keyWindow = UIApplication.shared.keyWindow {
            zoomedMessageCell = ChatMessageCellZoom(imageView: imageView,frame:keyWindow.frame)
            
            if let zommedCell = self.zoomedMessageCell {
                zommedCell.delegate = self
                zommedCell.animate(videoAnimation:true)
                keyWindow.addSubview(zommedCell)
                self.inputViewBottom.isHidden = true
                
                self.videoIsPlaying = true
                
                
                self.player = AVPlayer(url: videoUrl)
                self.player?.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
                self.playerLayer = AVPlayerLayer(player: player)
                
                self.playerLayer?.frame = zommedCell.zoomedImageView.bounds
                zommedCell.zoomedImageView.layer.addSublayer(playerLayer!)
                
                self.player?.play()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if player?.status == .readyToPlay {
            if let zoomedCell = self.zoomedMessageCell {
                zoomedCell.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func dismissZoom() {
        self.inputViewBottom.isHidden = false
        
        if(videoIsPlaying) {
            self.player?.pause()
        }
    }
}
