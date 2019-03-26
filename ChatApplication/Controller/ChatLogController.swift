//
//  ChatLogController.swift
//  ChatApplication
//
//  Created by Peter Lizak on 10/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChatMessageCellImageZoomDelegate, ChatInputContainerViewDelegate {    
    
    let cellID = "cellID"
    var recipientUser:User!
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    var timer: Timer?
    var startingFrame: CGRect!
    var imageViewWithZoomOn:UIImageView?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var videoIsPlaying:Bool = false
    var zoomedMessageCell:ChatMessageCellZoom?
    
    lazy var inputViewBottom: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.delegate = self
        return chatInputContainerView
    }()
    
    init(_ user1:User) {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.recipientUser = user1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return self.inputViewBottom
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        self.navigationItem.title = recipientUser.name
        
        collectionView.backgroundColor = .white
        
        collectionView?.keyboardDismissMode = .interactive

        observeMessages()
        
        setupKeyBoardObserver()
    }
    
    func setupKeyBoardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardDidShowNotification , object: nil)
    }
    
    @objc func handleKeyboardShow(){
        if self.messages.count > 0 {
            let numberOfItems = self.collectionView.numberOfItems(inSection: 0)
            self.collectionView.scrollToItem(at: IndexPath(item: numberOfItems-1, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        
        collectionItemCell.zoomDelegate = self
        collectionItemCell.recipientProfileImageUrl = self.recipientUser.profileImageURL
        collectionItemCell.message = messages[indexPath.row]
        return collectionItemCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        let width = UIScreen.main.bounds.width
        
        let message =  messages[indexPath.row]
        
        if let text = message.text {
            let chatMessageCell = ChatMessageCell()
            chatMessageCell.textView.text = text
            let textViewIdealSize = chatMessageCell.textView.sizeThatFits(CGSize(width:200,height: 10000))
            height = textViewIdealSize.height
        }else if let imageWidth = message.imageWidth as? CGFloat, let imageHeight = message.imageHeight as? CGFloat {
            height = CGFloat(imageHeight/imageWidth * 200)
        }
        
        
        return CGSize(width: width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    @objc func attachImageTapped() {
        let pickerViewController = UIImagePickerController()
        pickerViewController.mediaTypes = [kUTTypeImage,kUTTypeMovie] as [String]
        present(pickerViewController,animated: true,completion: nil)
        pickerViewController.delegate = self
        pickerViewController.allowsEditing = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:  nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
             handleVideoPicked(videoUrl)
        }else {
             handleImagePicked(info: info)
        }
       
        dismiss(animated: true, completion:  nil)
    }
    
    private func handleVideoPicked(_ videoUrl:URL){
        let uniqueIDForVideo = NSUUID().uuidString + ".mov"
        let storageRef = Storage.storage().reference().child("videos").child(uniqueIDForVideo)
        let uploadTask = storageRef.putFile(from: videoUrl, metadata: nil) { (storageMetaData, error) in
    
            if error != nil{
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    return
                }
                guard let videoDownloadUrl = url else { return }
                
                print(videoUrl)
                if let thumbnailImage = self.createThumbnailImageForVideo(videoUrl) {
                    
                    self.uploadImage(image: thumbnailImage, completion: { (thumbnailImageUrl) in
                        let imageWidth = thumbnailImage.size.width
                        let imageHeight = thumbnailImage.size.height
                        let dic = ["imageUrl":thumbnailImageUrl.absoluteString,"videoUrl":videoDownloadUrl.absoluteString,"imageHeight":imageHeight,"imageWidth":imageWidth] as [String : Any]
                        self.uploadMessage(dictionary: dic )
                        print("ImageUploaded")
                    })
                }else {
                }
            })
            
            self.navigationItem.title = self.recipientUser.name
        }
        
        uploadTask.observe(.progress) { (storageTaskSnapshot) in
            let completedPercentage = Float(storageTaskSnapshot.progress!.completedUnitCount) / Float(storageTaskSnapshot.progress!.totalUnitCount) * 100
            self.navigationItem.title = "Video upload: \(Int(completedPercentage))%"
        }
    }
    
    func createThumbnailImageForVideo(_ url:URL) -> UIImage?{
        let asset = AVAsset(url: url)
        let thumbnailImageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let cgImage = try thumbnailImageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
             return UIImage(cgImage: cgImage)
        } catch let err {
            print("Cutting error")
            print(err)
        }
       
        return nil
    }
    
    
    func handleImagePicked(info: [UIImagePickerController.InfoKey:Any]) {
        var image = UIImage()
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = originalImage
        }
        
        uploadImage(image: image) { (downloadUrl) in
            let imageHeight = image.size.height
            let imageWidth = image.size.width
            
            let messageBody = ["imageHeight":imageHeight,"imageWidth":imageWidth, "imageUrl":downloadUrl.absoluteString] as [String : Any]
            
            self.uploadMessage(dictionary: messageBody)
        }
        
        
    }
    
    func uploadImage(image:UIImage, completion:@escaping (_ downloadUrl:URL)->()){
        let uniqueIDForProfileImageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message_images").child(uniqueIDForProfileImageName)
        if let profileImage = image.jpegData(compressionQuality: 0.2) {
            storageRef.putData(profileImage, metadata: nil, completion:{  metaData, porfileImageUploadError in
                if(porfileImageUploadError != nil){
                    print(porfileImageUploadError ?? "")
                }
            
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Unable to access downloadURL
                        return
                    }
                    completion(downloadURL)
                }
            })
        }
    }
    
    func uploadImageMessage(imageUrl: String, imageHeight:CGFloat, imageWidth:CGFloat) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        if let senderUserID = Auth.auth().currentUser?.uid, let recipientUserID = self.recipientUser.id {
            let timeStamp = Int(Date().timeIntervalSince1970)
            childRef.updateChildValues(["imageHeight":imageHeight,"imageWidth":imageWidth, "imageUrl":imageUrl,"senderUserID": senderUserID,"recipientUserID":recipientUserID , "timeStamp":timeStamp]) { (error, databaseReference) in
                if(error != nil){
                    print("Unable to upload message to the database")
                    return
                }
                guard let messageReferenceKey = databaseReference.key else {return}
                self.createUserReferenceToMessage(senderUserID,recipientUserID, messageReferenceKey)
                self.createUserReferenceToMessage(recipientUserID,senderUserID,messageReferenceKey)
            }
        }
    }
    
    func uploadMessage(dictionary:[String:Any]){
        if let senderUserID = Auth.auth().currentUser?.uid, let recipientUserID = self.recipientUser.id {
            var messageBody = dictionary
            messageBody["recipientUserID"] = recipientUserID
            messageBody["senderUserID"] = senderUserID
            
            let timeStamp = Int(Date().timeIntervalSince1970)
            messageBody["timeStamp"] = timeStamp
            
            let ref = Database.database().reference().child("messages")
            let childRef = ref.childByAutoId()
            if let senderUserID = Auth.auth().currentUser?.uid, let recipientUserID = self.recipientUser.id {
                childRef.updateChildValues(messageBody) { (error, databaseReference) in
                    if(error != nil){
                        print("Unable to upload message to the database")
                        return
                    }
                    guard let messageReferenceKey = databaseReference.key else {return}
                    self.createUserReferenceToMessage(senderUserID,recipientUserID, messageReferenceKey)
                    self.createUserReferenceToMessage(recipientUserID,senderUserID,messageReferenceKey)
                }
            }
        }
    }
        
}
