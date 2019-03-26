//
//  MessagesController+handlers.swift
//  ChatApplication
//
//  Created by Peter Lizak on 13/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import Foundation
import Firebase

extension MessagesController {
    
    @objc func logOut(){
        do {
            try Auth.auth().signOut()
            let loginViewController = LoginViewController()
            loginViewController.messagesController = self
            present(loginViewController, animated: true, completion: nil)
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    @objc func newMessage(){
        let newMessageController = NewMessageController(self)
        let uiNavController = UINavigationController(rootViewController: newMessageController)
        present(uiNavController, animated: true,completion: nil)
    }
    
    @objc func showChatLogController(user:User) {
        let chatLogController = ChatLogController(user)
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func observeMessages(){
        messages.removeAll()
        messagesDictionary.removeAll()
        reloadTableView()
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let recipientUsersRef = Database.database().reference().child("user-messages").child(userID)
        recipientUsersRef.observe(.childAdded) { (recipientUserSnapshot) in
            let recipientUserID = recipientUserSnapshot.key
            let messagesRef = Database.database().reference().child("user-messages").child(userID).child(recipientUserID)
            messagesRef.observe(.childAdded, with: { messagesSnapshot in

                let messageKey = messagesSnapshot.key
                self.fetchMessageByMessageID(messageKey)
            })
        }
        
        recipientUsersRef.observe(.childRemoved) { (snapshot) in
            let key = snapshot.key
            self.messagesDictionary.removeValue(forKey: key)
            self.attemptToReloadTableAndSortMessagesArray()
        }
        
    }
    
    private func fetchMessageByMessageID(_ messageKey: String) {
        let messageRef = Database.database().reference().child("messages").child(messageKey)
        messageRef.observeSingleEvent(of: .value, with: { (messageSnapshot) in
            if let value = messageSnapshot.value as? [String:Any] {
                let message = Message(value)
                self.messages.append(message)
                
                if let recipientUserID = message.getRecipiantUserID(){
                    self.messagesDictionary[recipientUserID] = message
                }
                
                self.attemptToReloadTableAndSortMessagesArray()
            }
        })
    }
    
    func attemptToReloadTableAndSortMessagesArray() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return  message1.timeStamp!.intValue > message2.timeStamp!.intValue
        })
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.reloadTableView), userInfo: nil, repeats: false)
    }
    
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
