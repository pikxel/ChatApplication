//
//  ChatInputContainerView.swift
//  ChatApplication
//
//  Created by Peter Lizak on 25/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import Foundation
import UIKit

class ChatInputContainerView: UIView,UITextFieldDelegate {
    
    weak var delegate:ChatInputContainerViewDelegate? {
        didSet {
            attachmentImage.addGestureRecognizer(UITapGestureRecognizer(target: delegate, action: #selector(delegate?.attachImageTapped)))
        }
    }
    
    lazy var sendButton:UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        button.addTarget(delegate, action: #selector(delegate?.handleSend), for: .touchUpInside)
        return button
    }()

    lazy var inputTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Type message..."
        textField.delegate = self
        return textField
    }()
    
    lazy var attachmentImage:UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "upload_image_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: delegate, action: #selector(delegate?.attachImageTapped)))
        return imageView
    }()
    
    let bottomViewGrayLine:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    
        self.backgroundColor = .white
        
        addSubview(sendButton)
        addSubview(bottomViewGrayLine)
        addSubview(inputTextField)
        addSubview(attachmentImage)
        
        sendButton.trailingAnchor.constraint(equalTo: trailingAnchor,constant:-10).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        inputTextField.leadingAnchor.constraint(equalTo: attachmentImage.trailingAnchor,constant:3).isActive = true
        inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        bottomViewGrayLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        bottomViewGrayLine.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        bottomViewGrayLine.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
        bottomViewGrayLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        attachmentImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        attachmentImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        attachmentImage.widthAnchor.constraint(equalToConstant: 44).isActive = true
        attachmentImage.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.handleSend()
        return true
    }
}
