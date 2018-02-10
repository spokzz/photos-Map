//
//  ImageDownloadService.swift
//  photos-Map
//
//  Created by Sakar Pokhrel on 2/5/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ImageDownloadService {
    
    static let instance = ImageDownloadService()
    
    private let apiKey = "9a32cd90688825e90a44423645386799"
    
    //FLICKR API:
    func flickrAPI(withAnnotation annotation: PinAnnotation) -> String {
        
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&per_page=40&page=5&format=json&nojsoncallback=1"
        
       return url
    }
    
    //DOWNLOAD IMAGES URL:
    func downloadImageURL(withflickrAPI api: String, completion: @escaping (_ sender: [String]) -> () ) {
        
        //URL : https://farm5.staticflickr.com/4715/39392069804_45ebf4e04f_z_d.jpg
        
        var imageDownloadUrl = [String]()
        
        Alamofire.request(api).responseJSON { (responseURL) in
            
            if responseURL.result.isSuccess {
                
               guard let json = responseURL.result.value as? Dictionary <String,AnyObject> else {return}
               guard let photos = json["photos"] as? Dictionary<String,AnyObject> else {return}
               guard let photo = photos["photo"] as? [Dictionary<String,AnyObject>] else { print("Unsuccessful") ; return}
               
                for flickrUserImages in photo {
                    
                    let downloadUrl = "https://farm5.staticflickr.com/\(flickrUserImages["server"]!)/\(flickrUserImages["id"]!)_\(flickrUserImages["secret"]!)_h_d.jpg"
                    imageDownloadUrl.append(downloadUrl)
                    
                }
                completion(imageDownloadUrl)
            }
        }
        
    }
    
    //DOWNLOAD IMAGES:
    func downloadImages(withURLArray urlArray: [String], completion: @escaping (_ sender: [UIImage]) -> ()) {
        
        var downloadedImageArray = [UIImage]()
        
        for url in urlArray {
            
            Alamofire.request(url).responseImage { (imageResponse) in
                if imageResponse.result.isSuccess {
                    
                    guard let downloadImage = imageResponse.result.value else {return}
                    downloadedImageArray.append(downloadImage)
                    completion(downloadedImageArray)
                }
            }
        }
        
        
    }
    
    //REMOVE ALL SESSION.
    func removeSession() {
        
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionData, uploadData, downloadData) in
            sessionData.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
        
    }
    
    
}






















