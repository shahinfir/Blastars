//
//  StorageService.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/30/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import FirebaseStorage
import Foundation

let STORAGE_BASE = Storage.storage().reference()

class StorageService {
    
    private init() {}
    static let shared = StorageService()
    
    private var _REF_PICS = STORAGE_BASE.child("pics")
    
    var REF_PICS: StorageReference {
        return _REF_PICS
    }
    
    func getVideo(completion: @escaping () -> Void) {
        let url = "https://firebasestorage.googleapis.com/v0/b/ar-cloud-pong.appspot.com/o/Video%2Finstructions.mp4?alt=media&token=a508e729-a2d2-4bbf-b953-6a2944177721"
        let ref = Storage.storage().reference(forURL: url)
        ref.getData(maxSize: 8 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("Unable to download video from firebase storage")
            } else {
                if let imgData = data {
                    if let img = UIImage(data: imgData) {
                        let userImage = img
                        completion()
                    }
                }
            }
        })
    }
    
    
}
