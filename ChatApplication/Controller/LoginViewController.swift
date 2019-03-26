//
//  LoginViewController.swift
//  ChatApplication
//
//  Created by Peter Lizak on 07/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var messagesController:MessagesController?
    var inputContainerViewHeightAnchor:NSLayoutConstraint?
    var usernameTextFieldHeightAnchor:NSLayoutConstraint?
    var emailTextFieldHeightAnchor:NSLayoutConstraint?
    var passwordTextFieldHeightAnchor:NSLayoutConstraint?

    lazy var profileImage:UIImageView =  {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile_image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let inputContainerView:UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    let usernameTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Name"
        return textField
    }()
    
    let usernameSeperatorView:UIView = {
       let view = UIView()
       view.backgroundColor = .gray
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()
    
    let emailTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email"
        return textField
    }()
    
    let emailSeperatorView:UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        return textField
    }()
    
    lazy var loginRegisterButton:UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hue: 0.8944, saturation: 0.13, brightness: 0.54, alpha: 1.0) /* #897783 */
        button.tintColor = .black
        button.layer.cornerRadius = 5
        button.setTitle("Register", for: .normal)
        
        button.addTarget(self, action: #selector(loginRegisterButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var loginRegisterSegmentedView: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.backgroundColor = UIColor(hue: 0.1083, saturation: 0.52, brightness: 0.86, alpha: 1.0) /* #dbb369 */
        
        sc.addTarget(self, action: #selector(handleLoginRegisterSegmentChange), for: .valueChanged)
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hue: 0.7028, saturation: 0, brightness: 0.91, alpha: 1.0) /* #e8e8e8 */
        view.addSubview(inputContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(loginRegisterSegmentedView)
        view.addSubview(profileImage)
        
        setupInputContainerView()
        setupLoginRegisterButton()
        setupLoginRegisterSegmentedView()
        setupLogo()
    }
    
    func segmentControllerLoginView() -> Void {
         inputContainerViewHeightAnchor?.constant = 100
        
         usernameTextFieldHeightAnchor?.isActive = false
         usernameTextFieldHeightAnchor = usernameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 0)
         usernameTextFieldHeightAnchor?.isActive = true
        
         emailTextFieldHeightAnchor?.isActive = false
         emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/2)
         emailTextFieldHeightAnchor?.isActive = true
        
         passwordTextFieldHeightAnchor?.isActive = false
         passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/2)
         passwordTextFieldHeightAnchor?.isActive = true

         usernameSeperatorView.isHidden = true
    }
    
    func segmentControllerRegisterView() -> Void {
        inputContainerViewHeightAnchor?.constant = 150
        
        usernameTextFieldHeightAnchor?.isActive = false
        usernameTextFieldHeightAnchor = usernameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        usernameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        usernameSeperatorView.isHidden = false
    }

    private func setupLoginRegisterSegmentedView() -> Void {
        loginRegisterSegmentedView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor,constant:-15).isActive = true
        loginRegisterSegmentedView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setupLoginRegisterButton(){
        loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor,constant:20).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor,multiplier:0.67).isActive = true
        loginRegisterButton.centerXAnchor.constraint(equalTo: inputContainerView.centerXAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setupInputContainerView(){
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerViewHeightAnchor?.isActive = true
        
        // Setup Username TextField with line below
        inputContainerView.addSubview(usernameTextField)
        usernameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        usernameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        usernameTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor,constant: 12).isActive = true
        usernameTextFieldHeightAnchor = usernameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        usernameTextFieldHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(usernameSeperatorView)
        usernameSeperatorView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor).isActive = true
        usernameSeperatorView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor).isActive = true
        usernameSeperatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        usernameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Setup Email TextField with line below
        inputContainerView.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(equalTo: usernameSeperatorView.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor,constant: 12).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        inputContainerView.addSubview(emailSeperatorView)
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Setup Password TextField
        inputContainerView.addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: emailSeperatorView.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        passwordTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor,constant: 12).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    private func setupLogo(){
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: loginRegisterSegmentedView.topAnchor,constant:-30).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
}
