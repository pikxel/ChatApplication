//
//  ViewController.swift
//  ChatApplication
//
//  Created by Peter Lizak on 07/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    var timer: Timer?
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(MessagesController.logOut))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(MessagesController.newMessage))

        checkIfUserIsLoggedIn()
        
        self.tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid =  Auth.auth().currentUser?.uid else {return}
        if let recipientUserID = messages[indexPath.row].recipientUserID{
            Database.database().reference().child("user-messages").child(uid).child(recipientUserID).removeValue { (err, ref) in
                
                if err != nil {
                    return
                }
                
                if let key = ref.key {
                    self.messagesDictionary.removeValue(forKey: key)
                    self.attemptToReloadTableAndSortMessagesArray()
                }
            }
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if(Auth.auth().currentUser?.uid == nil){
            perform(#selector(logOut), with: nil, afterDelay: 0)
        } else {
            initiateViewAndFetchMessages()
        }
    }
    
    func initiateViewAndFetchMessages(){
        fetchUserAndSetupNavigationBar()
        observeMessages()
    }
    
    func fetchUserAndSetupNavigationBar(){
        if let uid = Auth.auth().currentUser?.uid{
            print(uid)
            let databaseRef = Database.database().reference()
            databaseRef.child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
                if let dictionary = snapshot.value as? [String:Any]{
                    let user = User(uid, dictionary)
                    self.setupNavigationBar(user)
                }else {
                    self.logOut()
                }
            }
        }
    }
    
    func setupNavigationBar(_ user:User){
        let button = UIButton()
        button.setTitle(user.name, for: .normal)
        button.tintColor = UIColor.black
        button.setTitleColor(UIColor.black, for: .normal)
        
        self.navigationItem.titleView = button
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        
        cell.message = messages[indexPath.row]
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let recipiantUserID = messages[indexPath.row].getRecipiantUserID() {
            let databaseRef = Database.database().reference()
            databaseRef.child("users").child(recipiantUserID).observeSingleEvent(of: .value) { snapshot in
                if let dictionary = snapshot.value as? [String:Any]{
                    let user = User(recipiantUserID, dictionary)
                    self.showChatLogController(user: user)
                }
            }
        }
    }
    
}

