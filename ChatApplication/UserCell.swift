//
//  UserCell.swift
//  ChatApplication
//
//  Created by Peter Lizak on 11/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message:Message?{
        didSet {
            if let recipientUserID = message?.getRecipiantUserID() {
                let ref = Database.database().reference().child("users").child(recipientUserID)
                ref.observeSingleEvent(of: .value) { (snapshot) in
                    if let dictionary = snapshot.value as? [String:AnyObject] {
                        self.textLabel?.text = dictionary["name"] as? String
                        self.profileImageView.loadImageAndCacheItUsingUrlString(imageUrl: dictionary["profileImageURL"] as! String, safelyLoadImageWithClosure: nil)
                    }
                }
            }
        
            if let seconds = self.message?.timeStamp?.doubleValue {
                let date = NSDate.init(timeIntervalSince1970: seconds)
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "hh:mm:ss a"
                self.timeLabel.text = dateFormater.string(from: date as Date)
            }
            
            if let text = self.message?.text {
                self.detailTextLabel?.text = text
            }
        }
    }
    
    var profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var timeLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:UITableViewCell.CellStyle.value1,reuseIdentifier:reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant:10).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(timeLabel)
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor,constant:20).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        
        detailTextLabel!.font = detailTextLabel!.font.withSize(12)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let textLabelOriginX = textLabel!.frame.origin.x
        let textLabelOriginY = textLabel!.frame.origin.y
        
        detailTextLabel?.removeConstraints(detailTextLabel!.constraints)
        
        textLabel?.frame = CGRect(x: textLabelOriginX + 50 , y:  textLabelOriginY - 10, width:  textLabel!.frame.width, height:  textLabel!.frame.height )
        
        detailTextLabel?.frame = CGRect(x: textLabelOriginX + 50 , y:  textLabelOriginY + 15, width:  detailTextLabel!.frame.width, height:   detailTextLabel!.frame.height )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
