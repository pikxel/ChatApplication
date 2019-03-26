//
//  ChatMessageCellZoom.swift
//  ChatApplication
//
//  Created by Peter Lizak on 26/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//
import Foundation
import UIKit

class ChatMessageCellZoom:UIView {

    var imageViewStartingFrame: CGRect?
    var imageViewWithZoomOn:UIImageView?
    var delegate:ChatMessageCellImageZoomDelegate?
    
    lazy var backgroundView:UIView = {
        var view = UIView()
        if let keyWindow = UIApplication.shared.keyWindow {
            view =  UIView(frame: keyWindow.frame)
            view.backgroundColor = .black
            view.alpha = 0
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissZoomedImageView)))
        }
        return view
    }()
    
    var zoomedImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    var activityIndicatorView:UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.hidesWhenStopped = true
        return activityView
    }()
    
    
    init(imageView:UIImageView,frame:CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        imageViewWithZoomOn = imageView

        self.imageViewStartingFrame = imageView.superview?.convert(imageView.frame, to: nil)

        zoomedImageView.image = imageView.image
        
        if let frame = self.imageViewStartingFrame {
            zoomedImageView.frame = frame
        }
    
        self.addSubview(backgroundView)
        self.addSubview(zoomedImageView)
        
        self.imageViewWithZoomOn?.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate(videoAnimation:Bool){
        UIView.animate(withDuration: 1, animations: {
            self.backgroundView.alpha = 1
            let height = (self.zoomedImageView.frame.height/self.zoomedImageView.frame.width) * self.frame.width
            self.zoomedImageView.frame = CGRect(x: self.zoomedImageView.frame.minX, y: self.zoomedImageView.frame.minY, width: self.frame.width, height: height)
            self.zoomedImageView.center = self.center
        }) { animationCompleted in
            if(videoAnimation){
               self.addActivityIndicatorView()
            }
        }
    }
    
    @objc func dismissZoomedImageView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.backgroundView.alpha = 0
            self.zoomedImageView.layer.cornerRadius = 16
            if let frame = self.imageViewStartingFrame {
                self.zoomedImageView.frame =  frame
            }
        }, completion: { (completed) in
            self.imageViewWithZoomOn?.isHidden = false
            self.removeFromSuperview()
            self.delegate?.dismissZoom()
        })
    }
    
    func addActivityIndicatorView(){
        self.addSubview(activityIndicatorView)
        
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.backgroundView.centerYAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.backgroundView.centerXAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        activityIndicatorView.startAnimating()
    }
}
