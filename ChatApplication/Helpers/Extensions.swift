//
//  Extensions.swift
//  ChatApplication
//
//  Created by Peter Lizak on 09/03/2019.
//  Copyright © 2019 peterlizak. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString,AnyObject>()

extension UIImageView {
    func loadImageAndCacheItUsingUrlString(imageUrl:String, safelyLoadImageWithClosure : ((_ image : UIImage,_ downloadedImgURL:String) ->Void)? )  {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: imageUrl as NSString) as? UIImage {
            if let completion = safelyLoadImageWithClosure {
                completion(cachedImage,imageUrl)
            }else {
                self.image = cachedImage
            }
            return
        }
        
        let url = URL(string: imageUrl)
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if (error != nil){
                return
            }
            
            if let downloadedImage = UIImage(data: data!) {
                imageCache.setObject(downloadedImage, forKey: imageUrl as NSString)
                DispatchQueue.main.async {
                    if let completion = safelyLoadImageWithClosure {
                        completion(downloadedImage,imageUrl)
                    }else {
                        self.image = downloadedImage
                    }
                }
            }
        }.resume()
    }
}
