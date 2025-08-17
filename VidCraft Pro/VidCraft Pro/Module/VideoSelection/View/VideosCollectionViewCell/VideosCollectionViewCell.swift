//
//  VideosCollectionViewCell.swift
//  VidCraft Pro
//
//  Created by Shahzaman Khan on 07/11/23.
//

import UIKit
import Photos

/// A reusable collection view cell that displays a video asset.
class VideosCollectionViewCell: UICollectionViewCell {

    static let identifier = "VideosCollectionViewCell"
    
    /// The UIImageView that displays the video's thumbnail image.
    @IBOutlet weak var videoImage: UIImageView!

    /// The UIView that displays a badge indicating the video's selection status.
    @IBOutlet weak var badgeView: UIView!

    /// The UILabel that displays the video's selection number.
    @IBOutlet weak var selectedNumber: UILabel!

    /// The UIButton that triggers the video expansion action.
    @IBOutlet weak var expandButton: UIButton!
    
    /// The UILabel that displays the information related to video
    @IBOutlet weak var videoInfoLabel: UILabel!
    
    /// The UIView that provides a transparent Dark Background overlay to the cell's content.
    @IBOutlet weak var transparentView: UIView!
    
    @IBOutlet weak var videoInfoView: UIView!

    @IBOutlet weak var extensionLabel: UILabel!
    
    var playBtnTapped: (() -> Void)?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
   /* func configure(with model: AssetModel) {
        videoInfoLabel.text = model.sizeString ?? "Loading..."
        
        // Fetch thumbnail
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.isSynchronous = false
        
        PHImageManager.default().requestImage(for: model.asset,
                                              targetSize: CGSize(width: 100, height: 100),
                                              contentMode: .aspectFill,
                                              options: options) { image, _ in
            DispatchQueue.main.async {
                self.videoImage.image = image
            }
        }
    }*/
    
    override func prepareForReuse() {
          super.prepareForReuse()
          videoImage?.image = nil
          videoInfoLabel?.text = nil
          // Reset any other content properties
      }
    
    @IBAction func videoPlayButtonTapped(_ sender: UIButton) {
        playBtnTapped?()
    }
}
