//
//  NewMessageController.swift
//  ChatApplication
//
//  Created by Peter Lizak on 08/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    var messagesControllerRef:MessagesController!
    let cellID  = "cellID"
    var users = [User]()
    
    init(_ messagesController:MessagesController) {
        super.init(nibName: nil, bundle: nil)
        messagesControllerRef = messagesController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target:self , action: #selector(cancelPressed))
        navigationItem.title = "New Message"
    
        fetchUsers()
    }
    
    private func fetchUsers() {
        let databaseRef = Database.database().reference()
        databaseRef.child("users").observe(.childAdded) { snapShot in
            if let dictionary = snapShot.value as? [String:AnyObject]{
                let uid = snapShot.key
                if(Auth.auth().currentUser?.uid != uid){
                    let user = User(uid, dictionary)
                    user.id = snapShot.key
                    self.users.append(user)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func cancelPressed(){
        dismiss(animated: true,completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].email
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        self.dismiss(animated: true) {
            self.messagesControllerRef.showChatLogController(user: user)
        }
    }
}
