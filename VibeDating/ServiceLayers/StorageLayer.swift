//
//  StorageLayer.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/4/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

class StorageLayer {
    static let shared = StorageLayer()
    
    func saveImage(folderPath: String, image: UIImage, completion: @escaping (String?, Error?) -> ()) {
        let uuid = UUID().uuidString
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else { return }
        Storage.storage().reference().child(folderPath).child(uuid).putData(uploadData, metadata: nil) { (metadata, error) in
            if let err = error {
                completion(nil, err)
                return
            }
            
            guard let downloadUrl = metadata?.downloadURL()?.absoluteString else { completion(nil, nil); return }
            completion(downloadUrl, nil)
            
        }
    }
    
    func saveVideo(folderPath: String, url: URL, completion: @escaping ([String : Any]?, Error?) -> ()) {
        let uuid = UUID().uuidString
        Storage.storage().reference().child(folderPath).child(uuid).putFile(from: url, metadata: nil) { (metadata, error) in
            if let err = error {
                print(err.localizedDescription)
                completion(nil, err)
                return
            }
            
            guard let storageUrl = metadata?.downloadURL()?.absoluteString else { return }
            if let thumbnailImage = self.thumbNailImageForVideo(videoUrl: url) {
                self.saveImage(folderPath: "message_images", image: thumbnailImage, completion: { (imageUrl, error) in
                    if let err = error {
                        completion(nil, err)
                        return
                    }
                    
                    guard let imageUrl = imageUrl else { return }
                    let dict: [String : Any] = ["videoUrl" : storageUrl as Any, "imageUrl" : imageUrl as Any, "imageWidth" : thumbnailImage.size.width as Any, "imageHeight" : thumbnailImage.size.height as Any]
                    completion(dict, nil)
                })
            }
        }
    }
    
    private func thumbNailImageForVideo(videoUrl: URL) -> UIImage?{
        let asset = AVAsset(url: videoUrl)
        let assetGenterator = AVAssetImageGenerator(asset: asset)
        do{
            let thumbnailCGImage = try assetGenterator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
            
        }catch let err{
            print(err.localizedDescription)
        }
        return nil
    }
    
}
