//
//  SelectedVideosCollectionViewCell.swift
//  VidCraft Pro
//
//  Created by Shahzaman Khan on 08/11/23.
//

import UIKit
import Photos

/// Selected Videos collection view cell that displays a selected video.
class SelectedVideosCollectionViewCell: UICollectionViewCell {

    static let identifier = "SelectedVideosCollectionViewCell"
    
    @IBOutlet weak var crossBttn: UIButton!
    /// The UIButton that triggers the video removal action.

    @IBOutlet weak var videoImage: UIImageView!
    /// The UIImageView that displays the video's thumbnail image.

    override func awakeFromNib() {
        super.awakeFromNib()
        // Additional setup or configuration can be performed here if needed.
        // This method is called after the cell is loaded from the storyboard or nib file.
    }
    
    func configure(with videoAsset: VideoAsset) {
        //videoInfoLabel.text = model.sizeString ?? "Loading..."
        
        // Fetch thumbnail
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.isSynchronous = false
        
        PHImageManager.default().requestImage(for: videoAsset.video,
                                              targetSize: CGSize(width: 100, height: 100),
                                              contentMode: .aspectFill,
                                              options: options) { rawImage, _ in
            DispatchQueue.main.async {
                if let image = rawImage {
                    self.videoImage.image = image
                    videoAsset.thumbnail = image
                }
            }
        }
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        // Access the cell's index path within the collection view
        guard let collectionView = superview as? UICollectionView,
            let indexPath = collectionView.indexPath(for: self) else {
                return
        }

        // Perform operations specific to the selected cell using its indexPath
        // Example: Print the selected cell's indexPath.row
        print("Selected Cell at Row: \(indexPath.row)")

        // You can perform other operations based on the indexPath here
    }
}

