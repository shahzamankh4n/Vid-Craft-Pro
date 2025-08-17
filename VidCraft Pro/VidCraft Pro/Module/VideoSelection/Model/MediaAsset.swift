//
//  Model.swift
//  VidCraft Pro
//
//  Created by Shahzaman Khan on 09/11/23.
//

import UIKit
import Photos

/// Represents a video asset that can be selected and managed.
class VideoAsset {
    
    /// Indicates whether the video asset is selected.
    var isSelected: Bool = false
    
    /// The selection number of the video asset.
    var selectedNumber: Int = 0
    
    /// The size of the video file in human-readable format (e.g., "20.5 MB").
    var size: Double = 0.0
    
    /// The PHAsset object representing the video asset from the Photos App.
    var video: PHAsset = PHAsset()
    
    /// The duration of the video file formatted as a time string (e.g., "0:35" for 35 seconds).
    var duration: String = ""
    
    /// The thumbnail image representing the video asset.
    var thumbnail: UIImage = UIImage(named: "ic_placeholder_image")!
    
    /// The resolution of the video file in human-readable format (e.g., "1920x1080").
    var resolution: String = ""
    
    /// URL of the Video, Indicates Where the video File is actually located in iPhone File System
    var url: URL?
}

/// Represents an image asset that can be selected and managed.
class ImageAsset {
    
    /// Indicates whether the image asset is selected.
    var isSelected: Bool = false
    
    /// The selection number of the image asset.
    var selectedNumber: Int = 0
    
    /// The PHAsset object representing the image asset from the Photos App.
    var asset: PHAsset
    
    /// The size of the image file in human-readable format (e.g., "20.5 MB").
    var size: Double = 0.0
    
    /// The thumbnail image representing the image asset.
    var thumbnail: UIImage = UIImage(named: "ic_placeholder_image")!
    
    /// The resolution of the image file in human-readable format (e.g., "1920x1080").
    var resolution: String = ""
    
    /// URL of the image, Indicates Where the image File is actually located in iPhone File System
    var url: URL?
    
    
    init(asset: PHAsset) {
          self.asset = asset
      }
    
}


class StudioFile {
    var url: URL?
    var thumbnail: UIImage = UIImage()
    var titleName: String = "N/A"
    var fileType: String = "N/A"
    var fileSize: String = "N/A"
    var resolution: String = "N/A"
    var duration: String = "N/A"
    var phAsset: PHAsset = PHAsset()
    
        init(url: URL) {
        self.url = url
        self.titleName = url.lastPathComponent
    }
}


public extension PHAsset {
    /// Actual file size in local storage
    /// (precision level up to 2 decimal places)
    var fileSize: Float {
        let resource = PHAssetResource.assetResources(for: self)
        let imageSizeByte = resource.first?.value(forKey: "fileSize") as? Float ?? 0.0
        let imageSizeMB = imageSizeByte / (1024.0 * 1024.0)
        let addAverageDeficit = imageSizeMB / 10
        // Calculate size with average size
        // ** {real_image_size} + {real_image_size + ({real_image_size} / 10})}
        // ** ----------------------------------------------------------------- **
        // **                                  2                                **
        return (imageSizeMB + (imageSizeMB + addAverageDeficit)) / 2
    }
    
    
    /// Asynchronously fetches the URL for the PHAsset.
    /// - Parameter completion: A completion handler with the URL or an error.
    func getURL(completion: @escaping (URL?) -> Void) {
        let resource = PHAssetResource.assetResources(for: self)
        guard let assetResource = resource.first else {
            completion(nil)
            return
        }

        // Check if the asset has a local file URL
        if assetResource.type == .photo || assetResource.type == .video {
            let fileURL = assetResource.value(forKey: "privateFileURL") as? URL
            completion(fileURL)
        } else {
            // Fetch the URL using content editing input
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            self.requestContentEditingInput(with: options) { (input, _) in
                completion(input?.fullSizeImageURL)
            }
        }
    }
}
