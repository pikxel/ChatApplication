//
//  LoginViewController+handlers.swift
//  ChatApplication
//
//  Created by Peter Lizak on 09/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @objc func handleSelectProfileImageView(){
        let pickerViewController = UIImagePickerController()
        present(pickerViewController,animated: true,completion: nil)
        pickerViewController.delegate = self
        pickerViewController.allowsEditing = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:  nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profileImage.image = editedImage
        } else if let profileImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImage.image = profileImage
        }
        
        dismiss(animated: true, completion:  nil) 
    }
    
    
    @objc func handleRegister() -> Void {
        guard let email = emailTextField.text,let password = passwordTextField.text, let username = usernameTextField.text else {
            print("Error not all field is filled out")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, creatingUserError in
            
            if(creatingUserError !=  nil){
                print("Unable to create user")
                print(creatingUserError ?? " ")
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            // Upload user profileImage to database
            let uniqueIDForProfileImageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profileImages").child(uniqueIDForProfileImageName)
            if let profileImage = self.profileImage.image?.jpegData(compressionQuality: 0.2) {
                storageRef.putData(profileImage, metadata: nil, completion:{  metaData, porfileImageUploadError in
                    if(porfileImageUploadError != nil){
                        print(porfileImageUploadError ?? "")
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            return
                        }
                        
                        let data = ["name":username, "email":email,"profileImageURL":downloadURL.absoluteString] as [String : Any]
                        self.saveUserToDatabase(uid:uid, data: data)
                    }
                })
            }
        }
    }
    
    func saveUserToDatabase(uid:String, data:[String: Any]){
            let ref: DatabaseReference = Database.database().reference()
            let userReference = ref.child("users").child(uid)
            
            userReference.updateChildValues(data, withCompletionBlock: { (err, response) in
                if(err != nil){
                    print("Error saving user to database")
                    return
                }
                if let uid = response.key {
                    let user = User(uid ,data)
                    self.messagesController?.setupNavigationBar(user)
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            })
    }
    
    @objc func handleLogin() -> Void {
        guard let email = emailTextField.text,let password = passwordTextField.text else {
            print("Error not all fields are filled out")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil {
                print("Unable to login")
                return
            }
            
            self.messagesController?.initiateViewAndFetchMessages()
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func loginRegisterButtonPressed() ->Void {
        if(loginRegisterSegmentedView.selectedSegmentIndex == 0){
            handleLogin()
        }else {
            handleRegister()
        }
    }
    
    @objc func handleLoginRegisterSegmentChange() -> Void {
        if(loginRegisterSegmentedView.selectedSegmentIndex == 0){
            self.segmentControllerLoginView()
        }else {
            self.segmentControllerRegisterView()
        }
        
        let title = loginRegisterSegmentedView.titleForSegment(at: loginRegisterSegmentedView.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal )
    }
}
