//
//  Extension.swift
//  ChatApp-Swift-And-Firebase
//
//  Created by Surya on 9/29/17.
//  Copyright © 2017 Surya. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    func loadImagesUsingCacheWithUrlString(urlString:String){
        
        // check cache for image first
        
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cacheImage
            return
        }
        
        let url = NSURL(string: urlString)
        let urlRequest = URLRequest.init(url: url! as URL)
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage.init(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject )
                    self.image = downloadedImage
                }
//                self.image = UIImage.init(data: data!)
            }
        }).resume()
    }
}
