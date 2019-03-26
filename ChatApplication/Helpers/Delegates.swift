//
//  Delegates.swift
//  ChatApplication
//
//  Created by Peter Lizak on 23/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import Foundation
import UIKit

protocol ChatMessageCellImageZoomDelegate{
    func zoomToImage(imageView:UIImageView)
    func zoomToVideo(imageView:UIImageView,videoUrl:URL)
    func dismissZoom()
}

@objc protocol ChatInputContainerViewDelegate {
    func handleSend()
    func attachImageTapped()
}
