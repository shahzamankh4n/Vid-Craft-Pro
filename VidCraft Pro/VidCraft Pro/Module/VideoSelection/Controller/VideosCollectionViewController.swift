//
//  VideoScreenViewController.swift
//  VidCraft Pro
//
//  Created by Shahzaman Khan© on 07/11/23.
//

import UIKit
import AVKit
import Photos
import PhotosUI
//import Kingfisher
//import GoogleMobileAds


protocol ProFeaturesViewControllerDelegate {
    func didFinishProFeatures()
}


/// The view controller responsible for managing the video collections displaying and selection process.
class VideosCollectionViewController: UIViewController {
    
    // MARK: - Outlets for UI Components
    
    /// UIButton for triggering sorting-related actions.
    @IBOutlet weak var sortButton: UIButton!
    
    /// UICollectionView displaying video items.
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// UICollectionView for selected video items.
    @IBOutlet weak var selectedVideosCollectionView: UICollectionView!
    
    /// UIView containing video-related UI elements.
    @IBOutlet weak var videosContainerView: UIView!
    
    /// UIView containing sorting-related UI elements.
    @IBOutlet weak var sortContainerView: UIView!
    
    /// UIButton used for navigation or going for next screen.
    @IBOutlet weak var nextBttn: UIButton!
    
    /// UILabel displaying number of selected videos.
    @IBOutlet weak var selectedVideosLabel: UILabel!
    
    /// UIButton to show or selection folders.
    @IBOutlet weak var VideoFolderBtn: UIButton!
    
    /// UIButton to trigger drop-down or selection actions.
    @IBOutlet weak var dropDownBtn: UIButton!
    
    /// import media from file system of iOS
    @IBOutlet weak var folderButton: UIButton!
    
    @IBOutlet weak var adView: UIView!
    
    @IBOutlet weak var AddMediaBtn: UIButton!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var compressBtnView: UIView!
    
    @IBOutlet weak var sortBtnTrailingConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var importBtnTrailConstraint: NSLayoutConstraint!//-8
    
    @IBOutlet weak var videoSelectionWarningLabel: UILabel!
    
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var pleaseWaitLabel: UILabel!
    // MARK: - Arrays to Hold Video-Related Data
    
    /// Array containing VideoAsset objects representing video items.
    var videoItemsArray: [VideoAsset] = []
    
    /// Array holding selected VideoAsset objects.
    var selectedVideosArray: [VideoAsset] = []
    
    /// PHFetchResult of PHAsset representing video assets in the photo library.
    var videoAssets: PHFetchResult<PHAsset>?
    
    let imageManager = PHCachingImageManager()
    
    let imageTargetSize = CGSize(width: 120, height: 120) // Adjust to your cell size
    
    var videoFolders: [PHAssetCollection] = []
    
    var proFeaturesVC: UIViewController?
    
    var timer: Timer?
    
    var timerForRefreshVideos: Timer?
    
    var multiCompressorIsSelected: Bool = false
    
    var videoSelectionLimitExceeded: Bool = false
    
    var imageCompressorIsSelected: Bool = false
    
    var videoConverterIsSelected: Bool = false
    
    var audioConverterIsSelected: Bool = false
    
    var importedFile: Bool = false
    
    let localizedSortBy = NSLocalizedString("Sort By", comment: "Sort By")
    
    var localizedRecent = NSLocalizedString("Recent", comment: "Recent")
    var localizedOldest = NSLocalizedString("Oldest", comment: "Oldest")
    var localizedSmallest = NSLocalizedString("Smallest", comment: "Smallest")
    var localizedLargest = NSLocalizedString("Largest", comment: "Largest")
    
//    private var assets: [AssetModel] = []
    
    
    // MARK: - Overrides
    
    /// Overrides the viewDidLoad method to set up the collection views and fetch video assets.
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCollectionView()
     
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(showAddButtonUI), userInfo: nil, repeats: true)
        timerForRefreshVideos = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(fetchVideoAssets), userInfo: nil, repeats: true)
        //   setUpSortButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            self.folderButton.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCompressButtonView()
        showSelectedVideosCollection()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
        self.collectionView?.reloadData()
    }
    
    // MARK: - Methods
    
    func setUpSortButton() {
            // Define valid actions for the menu
            
        let recent = UIAction(title: localizedRecent, image: UIImage(systemName: "clock.arrow.circlepath")) { action in
               // self.assets = self.assets.sortByLatestDate()
                self.collectionView.reloadData()
                print("Largest selected")
            }

        let oldest = UIAction(title: localizedOldest, image: UIImage(systemName: "clock")) { action in
              //  self.assets = self.assets.sortByOldestDate()
                self.collectionView.reloadData()
                print("Smallest selected")
            }
        
        let smallest = UIAction(title: localizedSmallest, image: UIImage(systemName: "arrow.down.square")) { action in
           // self.assets = self.assets.sortBySmallestSize()
            self.collectionView.reloadData()
            print("Recent selected")
         }

        let largest = UIAction(title: localizedLargest, image: UIImage(systemName: "arrow.up.square")) { action in
              //  self.assets = self.assets.sortByLargestSize()
                self.collectionView.reloadData()
                print("Oldest selected")
            }
        
            // Create a menu with the valid actions
            var menu = UIMenu()

            
//        if labelTitle.text == "Large Videos" || labelTitle.text == "Photos" {
//            menu = UIMenu(title: "Sort By", options: .displayInline, children: [largest, smallest, recent, oldest])
//        } else {
//            menu = UIMenu(title: "Sort By", options: .displayInline, children: [recent, oldest, largest, smallest])
//        }
        menu = UIMenu(title: localizedSortBy, options: .displayInline, children: [recent, oldest, largest, smallest])
            sortButton?.menu = menu
            sortButton?.showsMenuAsPrimaryAction = true // Show the menu when the button is tapped
        }
    
   /* func getMediaFromAssetDataManager() {
        if imageCompressorIsSelected {
            self.assets = AssetDataManager.shared.getImageAssets()
            let localizedFormat = NSLocalizedString("Images (%d)", comment: "Number of images")
            let localizedString = String(format: localizedFormat, self.assets.count)
            self.VideoFolderBtn?.setTitle(localizedString, for: .normal)
        } else {
            self.assets = AssetDataManager.shared.getVideoAssets()
            let localizedFormat = NSLocalizedString("Videos (%d)", comment: "Number of videos")
            let localizedString = String(format: localizedFormat, self.assets.count)
            self.VideoFolderBtn?.setTitle(localizedString, for: .normal)
        }
        
        self.collectionView.reloadData() // Reload collection view
        
        
        if assets.count > 0 {
            activityIndicator.stopAnimating()
            pleaseWaitLabel.isHidden = true
        }
        
        AssetDataManager.shared.onDataUpdated = { [weak self] newImageIndexPaths, newVideoIndexPaths in
            guard let self = self else { return }
            
            if imageCompressorIsSelected {
                self.assets = AssetDataManager.shared.getImageAssets()
            } else {
                self.assets = AssetDataManager.shared.getVideoAssets()
            }
            
            if assets.count > 0 {
                self.activityIndicator.stopAnimating()
                self.pleaseWaitLabel.isHidden = true
            }
            
            if imageCompressorIsSelected {
                // Reload only new items
                self.collectionView.performBatchUpdates {
                    self.sortingMediaWith(selectedName: self.sortButton.currentTitle ?? self.localizedRecent)
                            self.collectionView.insertItems(at: newImageIndexPaths)
                    
                        } completion: { _ in
                           // print("Batch update completed.")
                            self.sortingMediaWith(selectedName: self.sortButton.currentTitle ?? self.localizedRecent)
                            self.collectionView.reloadItems(at: newImageIndexPaths)
                }
                let localizedFormat = NSLocalizedString("Images (%d)", comment: "Number of images")
                let localizedString = String(format: localizedFormat, self.assets.count)
                self.VideoFolderBtn?.setTitle(localizedString, for: .normal)
                
            } else {
                self.collectionView.performBatchUpdates {
                    self.sortingMediaWith(selectedName: self.sortButton.currentTitle ?? "      Recent")
                        self.collectionView.insertItems(at: newVideoIndexPaths)
                        } completion: { _ in
                          //  print("Batch update completed.")
                            self.sortingMediaWith(selectedName: self.sortButton.currentTitle ?? "      Recent")
                            self.collectionView.reloadItems(at: newVideoIndexPaths)
                        }
                let localizedFormat = NSLocalizedString("Videos (%d)", comment: "Number of videos")
                let localizedString = String(format: localizedFormat, self.assets.count)
                self.VideoFolderBtn?.setTitle(localizedString, for: .normal)
            }
        }
    }
    
    func sortingMediaWith(selectedName: String) {
        switch selectedName {
        case self.localizedRecent:
                self.assets = assets.sortByLatestDate()
        case self.localizedOldest:
                self.assets = assets.sortByOldestDate()
        case localizedSmallest:
                self.assets = assets.sortBySmallestSize()
            default:
                self.assets = assets.sortByLargestSize()
        }
    }*/
    
    func setupCompressButtonView() {
        self.compressBtnView?.isHidden = true
        
        self.compressBtnView?.layer.shadowColor = UIColor.black.cgColor
        self.compressBtnView?.layer.shadowOpacity = 8.0
        self.compressBtnView?.layer.shadowRadius = 18
        self.compressBtnView?.layer.shadowOffset = CGSize(width: 0.5, height: 5.2)
        self.compressBtnView?.layer.cornerRadius = 8
        
       /* if IAPManager.shared.proDialgueAvailable {
            
        } else {
            
            proFeaturesVC = self.storyboard?.instantiateViewController(withIdentifier: "ProFeaturesViewController") as? ProFeaturesViewController
            
            IAPManager.shared.checkSubscriptionStatus { premiumUser in
                if premiumUser || !NetworkManager.shared.available{
                    self.adView?.isHidden = true
                    print("Premium User")
                } else {
                    self.adView?.isHidden = true
                    //self.adView?.isHidden = false
                    //   AdManager.loadCollapsibleBannerAd(for: self)
                    if let proVC = self.proFeaturesVC {
                        AdManager.loadRewardedAd(for: proVC)
                    }
                }
            }
        }*/
    }
    
    func fetchVideoFolders() {
        // Fetch smart albums that contain videos
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil)
        
        // Fetch user-created albums that may contain videos (optional, uncomment if needed)
        // let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        // Combine all fetched albums into a single array
        let allAlbums = [smartAlbums] // Add userAlbums here if needed
        
        for album in allAlbums {
            album.enumerateObjects { collection, _, _ in
                // Filter out empty folders or folders without videos
                let fetchOptions = PHFetchOptions()
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
                let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                
                // Check if the album contains videos
                if assets.count > 0 {
                    self.videoFolders.append(collection)
                    print("Video Folder:", collection.localizedTitle ?? "N/A", "Number of Videos:", assets.count)
                    
                }
            }
        }
    }
    
    /// Only Sets up the collection views and their delegates, registers cell nibs.
    func setUpCollectionView() {
        // Set data source and delegate for the main video collection view
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView.allowsMultipleSelection = true
        // Register the VideosCollectionViewCell nib for reuse
        collectionView?.register(UINib(nibName: VideosCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: VideosCollectionViewCell.identifier)
        
        selectedVideosCollectionView?.register(UINib(nibName: SelectedVideosCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: SelectedVideosCollectionViewCell.identifier)
        
        // Set initial state for the next button and selected videos collection view
        compressBtnView?.isHidden = true
        videosContainerView?.isHidden = true
        folderButton.setBackgroundImage(UIImage(systemName: "folder.fill.badge.plus"), for: .normal)
        selectedVideosCollectionView?.dataSource = self
        selectedVideosCollectionView?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        if self.imageCompressorIsSelected {
            let localizedString = NSLocalizedString("You can only select up to 5 images", comment: "Selected 5 Images")
            self.videoSelectionWarningLabel.text = localizedString
            
            //self.loadingStackView.isHidden = false
            //self.activityIndicator.startAnimating()
            
            // Initially hide the collectionView
            //collectionView.alpha = 0
            //collectionView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

            
          //  DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
                //self.showCollectionViewWithAnimation()
         //   }
            
        } else {
            let localizedString = NSLocalizedString("You can only select up to 5 videos", comment: "Selected 5 videos")
            self.videoSelectionWarningLabel.text = localizedString
        }
        
        self.nextBttn.isHidden = true
        self.collectionView?.reloadData()
    }
    
    
    func showCollectionViewWithAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.collectionView.alpha = 1
            //self.collectionView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    /// Manages the visibility of the selected videos collection view and related UI elements.
    /// Updates the label to show the count of selected videos.
    
    func showSelectedVideosCollection() {
        // Show videos container view and next button if selected videos are present
        if self.multiCompressorIsSelected, let containerView = videosContainerView, containerView.isHidden, selectedVideosArray.count > 0 {
            
            UIView.animate(withDuration: 0.3) {
                self.videosContainerView?.alpha = 1.0
                self.compressBtnView?.alpha = 1.0
                self.nextBttn?.alpha = 1.0
                self.videosContainerView?.isHidden = false
                self.compressBtnView?.isHidden = false
                self.nextBttn?.isHidden = false
            }
            
            
        } else if selectedVideosArray.count == 0 {
            // Hide videos container view and next button if no selected videos
            UIView.animate(withDuration: 0.3, animations: {
                self.videosContainerView?.alpha = 0.0
                self.compressBtnView?.alpha = 0.0
                self.nextBttn?.alpha = 0.0
            }) { _ in
                self.videosContainerView?.isHidden = true
                self.compressBtnView?.isHidden = true
                self.nextBttn?.isHidden = true
            }
        }
        
        // Update label to show the count of selected videos
        if imageCompressorIsSelected {
            selectedVideosLabel?.text = String(format: NSLocalizedString("Selected %d Image", comment: "selected 2 image"), selectedVideosArray.count)
        } else {
            selectedVideosLabel?.text = String(format: NSLocalizedString("Selected %d Video", comment: "selected 2 video"), selectedVideosArray.count)

        }
        
        //self.collectionView?.reloadData()
    }
    
    /// Fetches video assets from the user's photo library and populates the videoAssets array.
    /// Checks the authorization status to access the photo library and retrieves video assets accordingly.
    /// The videoAssets array is populated with PHAsset objects representing videos, and the videoItemsArray is filled with VideoAsset instances.
    ///
    @objc func fetchVideoAssets() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            // Access granted, fetch video assets
            if imageCompressorIsSelected {
                fetchImages()
            } else {
                fetchVideos()
            }
            
         //   self.videoItemsArray = self.videoItemsArray.sortByLatestDate()
            self.collectionView.reloadData()
            
        } else if status == .notDetermined {
            // Permission not determined, request authorization
        } else {
            // Access denied or restricted, prompt the user to grant permission
            showPermissionErrorAlert()
            print("Permission denial or restricted access")
        }
    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
    
    @available(iOS 14, *)
    func checkLimitedVideosAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .limited:
                DispatchQueue.main.async {
                    //self.folderBtn.isHidden = false
                }
            case .authorized:
                // Full access granted
                break
            case .denied, .restricted:
                // Handle restricted or denied access
                break
            case .notDetermined:
                print("Unable To Detect App Permission")
            @unknown default:
                // Handle unknown authorization status
                break
            }
        }
    }
    
    private func fetchVideos() {
        let fetchOptions = PHFetchOptions()
        
        // Filter for only video media type
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        
        // Sort videos by creation date in ascending order
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Fetch videos with the specified options
        videoAssets = PHAsset.fetchAssets(with: fetchOptions)
        
        // Populate videoItemsArray with VideoAsset instances for each video
        guard let assets = videoAssets else { return }
        for itm in 0..<assets.count {
            let videoAsset = VideoAsset()
            videoAsset.video = assets[itm]
            videoItemsArray.append(videoAsset)
        }
        
        //timerForRefreshVideos?.invalidate()
        //timerForRefreshVideos = nil
        
        if self.videoItemsArray.count > 0 {
                    timerForRefreshVideos?.invalidate()
                    timerForRefreshVideos = nil
                }
        
        DispatchQueue.main.async {
            let localizedString = NSLocalizedString("Videos", comment: "Videos")
            self.VideoFolderBtn?.setTitle("\(localizedString) (\(self.videoItemsArray.count))", for: .normal)
         //   self.videoItemsArray = self.videoItemsArray.sortByLatestDate()
            self.collectionView.reloadData()
        }
    }
    
    /**
     Presents an alert notifying the user about the required photo library permission.
     */
    private func showPermissionErrorAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Permission Error", comment: "Permission Error"), message: NSLocalizedString("Please Allow Photos Permission to the App", comment: "User Information For Access Photos"), preferredStyle: .alert)
        let ok = UIAlertAction(title: "Settings", style: .default) { _ in
            self.openAppSettings()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive)
        alertController.addAction(cancel)
        alertController.addAction(ok)
        timerForRefreshVideos?.invalidate()
        timerForRefreshVideos = nil
        present(alertController, animated: true)
    }
    
    /**
     Converts bytes to megabytes and returns a string representation with one decimal place.
     
     - Parameter bytes: The size in bytes to convert to megabytes.
     - Returns: A string representing the size in megabytes.
     */
    func bytesToMegabytes(_ bytes: Int64) -> Double {
        let megabytes = Double(bytes) / 1_048_576.0
        return megabytes//String(format: "%.1f", megabytes)
    }
    
    
    func checkforVideoSize(from selectedVideos: [VideoAsset]) -> Bool {
        var requirePremiumPlan = false
        
        for videoAsset in selectedVideos {
            if videoAsset.size >= Double(200) {//Double(IAPManager.shared.videoCompressSizeLimit) {
                requirePremiumPlan = true
                break
            }
        }
        return requirePremiumPlan
    }
    
    /**
     Retrieves the size and Image of the video asset and updates relevant information.
     
     - Parameter video: The PHAsset representing the video.
     */
    func getVideoSizeAndThumbnail(from videoAsset: VideoAsset, for cell: VideosCollectionViewCell) {
        let imageManager = PHImageManager.default()
        let concurrentQueue = DispatchQueue(label: "com.videoProcessing", attributes: .concurrent)
        
        // Asynchronously request AVAsset for the video
        concurrentQueue.async {
            imageManager.requestAVAsset(forVideo: videoAsset.video, options: nil) { (avAsset, _, _) in
                guard let avAsset = avAsset as? AVURLAsset else {
                    return
                }
                
                // Get video URL and calculate video size
                let videoURL = avAsset.url
                let videoSize = try? FileManager.default.attributesOfItem(atPath: videoURL.path)[FileAttributeKey.size] as? Int64
                
                // Calculate video duration in minutes and seconds
                let durationInSeconds = CMTimeGetSeconds(avAsset.duration)
                let minutes = Int(durationInSeconds / 60)
                let seconds = Int(durationInSeconds.truncatingRemainder(dividingBy: 60))
                
                // Update videoAsset properties on the main thread
                DispatchQueue.main.async {
                    if let videoSize = videoSize {
                        videoAsset.size = Double(videoSize) / 1048576.0//String(format: "%.2f", self.bytesToMegabytes(videoSize))
                        let videoResolution = CGSize(width: videoAsset.video.pixelWidth, height: videoAsset.video.pixelHeight)
                        videoAsset.resolution = "\(Int(videoResolution.width))x\(Int(videoResolution.height))"
                        videoAsset.duration = String(format: "%02d:%02d", minutes, seconds)
                        videoAsset.url = videoURL
                        
                        imageManager.requestImage(for: videoAsset.video, targetSize: self.imageTargetSize, contentMode: .aspectFill, options: nil) { (image, _) in
                            DispatchQueue.main.async {
                                cell.videoImage?.image = image // Update the cell's image on the main thread
                                //cell.videoInfoLabel?.text = "\(videoAsset.duration)"
                                cell.videoInfoLabel?.text = "\(String(format: "%.2f", videoAsset.size)) MB | \(videoAsset.duration)"
                                cell.extensionLabel.text = avAsset.url.pathExtension.lowercased()
                                videoAsset.thumbnail = image ?? UIImage()
                            }
                        }
                    } else {
                        print("Video Size: N/A")
                    }
                }
            }
        }
    }
    
    
    func getImageSizeAndThumbnail(from imageAsset: VideoAsset, at indexPath: IndexPath) {
        //let targetSize = CGSize(width: cell.contentView.frame.size.width - 50, height: cell.contentView.frame.size.width - 50)
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true

        DispatchQueue.global(qos: .userInitiated).async {
            
            //let imageTargetSize = CGSize(width: 80,  height: 70)
        // Asynchronously request the image URL
            self.imageManager.requestImage(for: imageAsset.video, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions) { (image, _) in
            if let image = image, let cell = self.collectionView.cellForItem(at: indexPath) as? VideosCollectionViewCell {
                self.getImageFileSize(asset: imageAsset.video) { fileSize in
                    let sizeText = String(format: "%.2f MB", fileSize)
                    DispatchQueue.main.async {
                        //cell.configure(with: image, sizeText: sizeText)
                        cell.videoImage.image = image
                        cell.videoInfoLabel.text = sizeText
                        
                        imageAsset.thumbnail = image
                        imageAsset.size = fileSize
                    }
                }
            }
        }
    }
}

    private func getImageFileSize(asset: PHAsset, completion: @escaping (Double) -> Void) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        PHImageManager.default().requestImageData(for: asset, options: options) { (data, notsafe, _, _) in
            guard let data = data else {
                completion(0.0)
                return
            }
            
            let fileSize = Double(data.count) / (1024 * 1024) // Convert bytes to MB
            completion(fileSize)
        }
    }
    
    
    func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else { return nil }

        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        return UIImage(cgImage: downsampledImage)
    }
    
    func getImageURLSizeAndResolution(for asset: PHAsset, completion: @escaping (UIImage?, URL?, Double?, String?) -> Void) {
        // Request options for content editing input
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true // Allow network access for iCloud photos

        // Dispatch the task to a background queue
        DispatchQueue.global(qos: .userInitiated).async {
            // Request the content editing input for the asset
            asset.requestContentEditingInput(with: options) { (contentEditingInput, info) in
                // Ensure this part of the code runs on a background queue
                DispatchQueue.global(qos: .background).async {
                    // Check if we got a valid URL
                    if let url = contentEditingInput?.fullSizeImageURL {
                        // Get the file size
                        do {
                            let fileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[FileAttributeKey.size] as? Int64
                            //let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
                            let imageSize = Double(fileSize ?? 0) / 1048576.0 // Convert bytes to MB

                            // Load the image to get its resolution
                            if let image = UIImage(contentsOfFile: url.path) {
                                let resolution = "\(Int(image.size.width))x\(Int(image.size.height))"

                                // Ensure completion handler is called on the main thread
                                DispatchQueue.main.async {
                                    completion(image, url, imageSize, resolution)
                                }
                            } else {
                                // If image loading fails
                                DispatchQueue.main.async {
                                    completion(nil, url, imageSize, nil)
                                }
                            }
                        } catch {
                            // If file attributes retrieval fails
                            DispatchQueue.main.async {
                                completion(nil, url, nil, nil)
                            }
                        }
                    } else {
                        // If URL retrieval fails
                        DispatchQueue.main.async {
                            completion(nil, nil, nil, nil)
                        }
                    }
                }
            }
        }
    }
/*
    /// googleAds
    func presentPremiumFeaturesViewController(selection limitExceeded: Bool = false,
                                              size limitExceed: Bool = false, videoConverterIsSelected: Bool = false) {
        if let proVC = self.storyboard?.instantiateViewController(identifier: "ProFeaturesViewController") as? ProFeaturesViewController {
            proVC.modalPresentationStyle = .overCurrentContext
            proVC.delegate = self
            //proVC.rewardedAdDelegate = self
            proVC.presenterViewController = self
            proVC.videoSelectedMoreThanLimit = limitExceeded
            proVC.videoSelectedSizeMoreThanLimit = limitExceed
            proVC.imageCompressorIsSelected = imageCompressorIsSelected
            proVC.videoMP4ConverterIsSelected = videoConverterIsSelected
            // Set the background color of ProFeatureViewController's view to transparent
            proVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.8) // Transparent black color
            
            // Create a container view to hold the content
            let containerView = UIView(frame: proVC.view.bounds)
            containerView.backgroundColor = .clear // Transparent background color
            containerView.isUserInteractionEnabled = false // Disable user interaction
            proVC.view.addSubview(containerView)
            //self.removeAllSelectedVideos()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.present(proVC, animated: true, completion: nil)
            }
        }
    }
    
    func presentProDialgueViewController(selection limitExceeded: Bool = false,
                                         size limitExceed: Bool = false, videoConverterIsSelected: Bool = false) {
        if let proVC = self.storyboard?.instantiateViewController(withIdentifier: "ProDialogueViewController") as? ProDialogueViewController {
            proVC.modalPresentationStyle = .overCurrentContext
            proVC.delegate = self
            //proVC.rewardedAdDelegate = self
            proVC.presenterViewController = self
            proVC.videoSelectedMoreThanLimit = limitExceeded
            proVC.videoSelectedSizeMoreThanLimit = limitExceed
            proVC.videoMP4ConverterIsSelected = videoConverterIsSelected
            proVC.imageCompressorIsSelected = imageCompressorIsSelected
            // Set the background color of ProFeatureViewController's view to transparent
            proVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.8) // Transparent black color
            
            // Create a container view to hold the content
            let containerView = UIView(frame: proVC.view.bounds)
            containerView.backgroundColor = .clear // Transparent background color
            containerView.isUserInteractionEnabled = false // Disable user interaction
            proVC.view.addSubview(containerView)
            //self.removeAllSelectedVideos()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.present(proVC, animated: true, completion: nil)
            }
        }
    }*/
    
    @objc func showAddButtonUI() {
        
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                
                switch status {
                case .authorized:
                // print("authorized")
                    self.timer?.invalidate()
                    self.timer = nil
                    break
                case .limited:
                    //showLimittedAccessUI()
                    DispatchQueue.main.async {
                        self.AddMediaBtn?.isHidden = false
                        self.importBtnTrailConstraint.constant = 6
                        self.sortBtnTrailingConstraints.constant = 65
                    }
                    //print("limited")
                    break
                case .restricted:
                    //showRestrictedAccessUI()
                    DispatchQueue.main.async {
                        self.AddMediaBtn?.isHidden = false
                        self.importBtnTrailConstraint.constant = -10
                        self.sortBtnTrailingConstraints.constant = 65
                    }
                    //print("restricted")
                    break
                case .denied:
                    //showAccessDeniedUI()
                    DispatchQueue.main.async {
                        self.AddMediaBtn?.isHidden = false
                        self.importBtnTrailConstraint.constant = -10
                        self.sortBtnTrailingConstraints.constant = 65
                    }
                    //print("denied")
                    break
                case .notDetermined:
                    DispatchQueue.main.async {
                        self.AddMediaBtn?.isHidden = false
                        self.importBtnTrailConstraint.constant = -10
                        self.sortBtnTrailingConstraints.constant = 65
                    }
                    //print("notDetermined")
                    break
                    
                @unknown default:
                    self.timer?.invalidate()
                    self.timer = nil
                    break
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
//        if IAPManager.shared.premiumUser || !NetworkManager.shared.available || (AdManager.daysPassedAfterFirsLaunch() < 50){
            
            self.adView?.isHidden = true
            self.collectionViewBottomConstraint?.constant = 0
//        } else {
//            self.adView?.isHidden = false
//            self.collectionViewBottomConstraint?.constant = 46
//        }
    }
    
    func removeAllSelectedVideos() {
        if selectedVideosArray.count > 0 {
            for video in selectedVideosArray {
                video.isSelected = false
            }
            
            for video in videoItemsArray {
                video.isSelected = false
            }
            
//            for index in assets.indices {
//                assets[index].isSelected = false
//            }

            self.selectedVideosArray.removeAll()
        }
        collectionView.reloadData()
        selectedVideosCollectionView.reloadData()
    }
    
    private func fetchImages() {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            DispatchQueue.global(qos: .userInitiated).async {
                let imageAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

                var imageItemsArray = [PHAsset]()
                imageAssets.enumerateObjects { (asset, index, stop) in
                    imageItemsArray.append(asset)
                }

                DispatchQueue.main.async {
                    let localizedString = NSLocalizedString("Images", comment: "Images")
                    self.VideoFolderBtn?.setTitle("\(localizedString) (\(imageItemsArray.count))", for: .normal)
                }

                var newVideoItemsArray = [VideoAsset]()
                for item in 0..<imageAssets.count {
                    let imageAsset = VideoAsset()
                    imageAsset.video = imageAssets[item]
                    newVideoItemsArray.append(imageAsset)
                }

                DispatchQueue.main.async {
                    self.videoItemsArray.append(contentsOf: newVideoItemsArray)
                    self.collectionView.reloadData()
                }
                self.timerForRefreshVideos?.invalidate()
                self.timerForRefreshVideos = nil
            }
        }
    
    /**
     Retrieves the size and Image of the image asset and updates relevant information.
     
     - Parameter imageAsset: The PHAsset representing the image.
     */
    
    func getImageMetadata(from imageAsset: VideoAsset, for cell: VideosCollectionViewCell, at indexPath: IndexPath, collectionView: UICollectionView) {
        /*let imageManager = PHImageManager.default()
        
        // Check if the low-resolution image is already cached
        if let cachedImage = ImageCache.shared.object(forKey: "\(imageAsset.video.localIdentifier)-low" as NSString) {
            cell.videoImage?.image = cachedImage
            imageAsset.thumbnail = cachedImage
            cell.videoInfoLabel?.text = "\(String(format: "%.2f", imageAsset.size)) MB"
        } else {
            // Fetch low-resolution image for UI
            //fetchLowResolutionImage(for: imageAsset, at: indexPath, collectionView: collectionView)
        }*/
        
        // Fetch original image data asynchronously only if necessary
        //fetchOriginalImageDataIfNeeded(for: imageAsset, for: cell, at: indexPath, collectionView: collectionView)
        
        self.getImageURLSizeAndResolution(for: imageAsset.video) {image, url, size, resolution in
            if let image = image,
               let imageURL = url,
               let imageSize = size,
               let imageResolution = resolution {
                DispatchQueue.main.async {
                    imageAsset.thumbnail = image
                    imageAsset.url = imageURL
                    imageAsset.size = imageSize
                    imageAsset.resolution = imageResolution
                }
            }
        }
        
    }
    
    private func fetchLowResolutionImage(for imageAsset: VideoAsset, at indexPath: IndexPath, collectionView: UICollectionView) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .fastFormat
        requestOptions.isNetworkAccessAllowed = true // Allow network access for iCloud photos
        
        imageManager.requestImage(for: imageAsset.video, targetSize: self.imageTargetSize, contentMode: .aspectFill, options: requestOptions) { (image, anyTypeConstant) in
            if let image = image {
                // Cache the low-resolution image
                //ImageCache.shared.setObject(image, forKey: "\(imageAsset.video.localIdentifier)-low" as NSString)
                
                // Update the cell's image on the main thread
                DispatchQueue.main.async {
                    // Ensure the cell is still visible before updating UI
                    if let visibleCell = collectionView.cellForItem(at: indexPath) as? VideosCollectionViewCell {
                        visibleCell.videoImage?.image = image
                        //imageAsset.thumbnail = image
                        //visibleCell.videoInfoLabel?.text = "\(String(format: "%.2f", imageAsset.size)) MB"
                    }
                }
            }
        }
    }
      
    
    private func fetchOriginalImageDataIfNeeded(for imageAsset: VideoAsset, for cell: VideosCollectionViewCell, at indexPath: IndexPath, collectionView: UICollectionView) {
        // Check if the size is already set, skip fetching if it is
        if imageAsset.size > 0 {
            DispatchQueue.main.async {
                cell.videoImage.image = imageAsset.thumbnail
                cell.videoInfoLabel?.text = "\(String(format: "%.2f", imageAsset.size)) MB"
            }
            return
        }

        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true // Allow network access for iCloud photos

        // Request a 100x100 pixel image for the imageView
        imageManager.requestImage(for: imageAsset.video, targetSize: self.imageTargetSize, contentMode: .aspectFill, options: requestOptions) { (image, _) in
            DispatchQueue.main.async {
                if let image = image {
                    // Update the cell's imageView with the 100x100 image
                        cell.videoImage.image = image
                        imageAsset.thumbnail = image
                        //ImageCache.shared.setObject(image, forKey: "\(imageAsset.video.localIdentifier)-low" as NSString)
                }
            }
        }

        
        /*let concurrentQueue = DispatchQueue(label: "com.imageProcessing", attributes: .concurrent)
        concurrentQueue.async {
            imageManager.requestImageDataAndOrientation(for: imageAsset.video, options: requestOptions) { (data, dataUTI, orientation, info) in
                guard let imageData = data else {
                    print("Failed to get image data.")
                    return
                }

                // Calculate image size in MB
                let imageSize = Double(imageData.count) / 1048576.0

                // Create UIImage to get resolution
                if let image = UIImage(data: imageData) {
                    let resolution = CGSize(width: image.size.width, height: image.size.height)

                    // Request URL separately
                    imageAsset.video.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (contentEditingInput, _) in
                        guard let imageURL = contentEditingInput?.fullSizeImageURL else {
                            print("Failed to get image URL.")
                            return
                        }

                        // Update imageAsset properties on the main thread
                        DispatchQueue.main.async {
                            imageAsset.size = imageSize
                            imageAsset.resolution = "\(Int(resolution.width))x\(Int(resolution.height))"
                            imageAsset.url = imageURL
                            //imageAsset.thumbnail = image

                            // Update UI with the full-resolution image data
                            if let visibleCell = collectionView.cellForItem(at: indexPath) as? VideosCollectionViewCell {
                                visibleCell.videoInfoLabel?.text = "\(String(format: "%.2f", imageAsset.size)) MB"
                            }
                        }
                    }
                }
            }
        }*/
    }
    
    // MARK: - IBActions
    
    /**
     Handles the action when the 'Next' button is pressed.
     Navigates to the CompressorViewController and passes selectedVideoAssets.
     
     - Parameter bttn: The UIButton triggering the action.
     */
    @IBAction func nextBtnPressed(_ bttn: UIButton) {
        if videoConverterIsSelected {
            
        } else {
           // goToCompressorScreen()
        }
    }
    
    func goToCompressorScreen() {
///           user is not premium               |             any video should be selected             |                any selected video size should be less than 200 MB
        if selectedVideosArray.count > 0, self.checkforVideoSize(from: selectedVideosArray) {
            
                let compressorVC = UIStoryboard(name: "EditScreen", bundle: nil).instantiateViewController(withIdentifier: "VideoInfoViewController") //as! VideoInfoViewController
                //compressorVC.videoAsset = selectedVideosArray[0]
              //  compressorVC.imageCompressorIsSelected = self.imageCompressorIsSelected
                
               // compressorVC.fileImported = self.importedFile
                self.removeAllSelectedVideos()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.collectionView?.reloadData()
                    self.navigationController?.pushViewController(compressorVC, animated: true)
                }
            }
    }
    
    /*func goToMP4ConverterScreen(with videoAsset: VideoAsset?) {
        ///           user is not premium               |             any video should be selected             |                any selected video size should be less than 200 MB
        if !AppVariables.isPremium && selectedVideosArray.count > 0, self.checkforVideoSize(from: selectedVideosArray) {
            
            if IAPManager.shared.proDialgueAvailable {
                self.presentProDialgueViewController(selection: false, size: true, videoConverterIsSelected: true)
            } else {
                let compressorVC = UIStoryboard(name: "EditScreen", bundle: nil).instantiateViewController(withIdentifier: "VideoInfoViewController") as! VideoInfoViewController
                    compressorVC.videoAsset = videoAsset
                    compressorVC.fileImported = self.importedFile
                    compressorVC.audioConverterIsSelected = true
                    self.removeAllSelectedVideos()
                    self.navigationController?.pushViewController(compressorVC, animated: true)
            }
        } else {
                
            let compressorVC = UIStoryboard(name: "EditScreen", bundle: nil).instantiateViewController(withIdentifier: "VideoInfoViewController") as! VideoInfoViewController
                compressorVC.videoAsset = videoAsset
                compressorVC.fileImported = self.importedFile
                compressorVC.audioConverterIsSelected = true
                self.removeAllSelectedVideos()
                self.navigationController?.pushViewController(compressorVC, animated: true)
            }
    }*/
    
    @IBAction func sortBtnTapped(_ sender: UIButton) {
    }
    /**
     Handles the action when the 'Back' button is pressed.
     Pops the current view controller to navigate back.
     
     - Parameter bttn: The UIButton triggering the action.
     */
    @IBAction func backBtnPressed(_ bttn: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /**
     Handles the action when the 'Sort' button is pressed.
     Toggles the visibility of the sort container view and updates button state accordingly.
     
     - Parameter bttn: The UIButton triggering the action.
     */
    @IBAction func sortBtnPressed(_ bttn: UIButton) {
        if sortContainerView.isHidden {
            sortContainerView.isHidden = false
           // sortBttn.isSelected = false
        } else {
            sortContainerView.isHidden = true
         //   sortBttn.isSelected = true
        }
    }
    
    /**
     Handles the action when the 'Video List' button is pressed.
     Toggles the visibility of the folders list container view and updates button state accordingly.
     
     - Parameter bttn: The UIButton triggering the action.
     */
    @IBAction func importMediaBtnTapped(_ bttn: UIButton) {
            presentDocumentPicker()
    }
    
    @IBAction func addMediaBtnTapped(_ bttn: UIButton) {
        //        PHPhotoLibrary.requestAuthorization { status in
        //            if status == .authorized {
        //                // Access granted, proceed to present image picker
        //                DispatchQueue.main.async {
        //                    self.presentVideoPicker()
        //                }
        //            } else {
        //                // Handle restricted access
        //            }
        //        }
        
        let photoAccessVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAccessViewController") as! PhotoAccessViewController
        photoAccessVC.modalPresentationStyle = .overCurrentContext
        
        // Set the background color of RenameViewController's view to transparent
        photoAccessVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.8) // Transparent black color
        
        // Create a container view to hold the content
        let containerView = UIView(frame: photoAccessVC.view.bounds)
        containerView.backgroundColor = .clear // Transparent background color
        containerView.isUserInteractionEnabled = false // Disable user interaction
        photoAccessVC.view.addSubview(containerView)
        
        self.present(photoAccessVC, animated: true, completion: nil)
        
    }
    
    /**
     Handles the action when the remove button is tapped within a selected video cell.
     
     - Parameter sender: The UIButton that triggered the action.
     */
    @objc func removeButtonTapped(_ sender: UIButton) {
        // Get the cell and its corresponding indexPath where the remove button was tapped
        guard let cell = sender.superview?.superview as? SelectedVideosCollectionViewCell,
              let indexPath = selectedVideosCollectionView.indexPath(for: cell) else {
            return
        }
        
        // Handle removing the selected video asset from arrays and reload collection views
        
        if let index = videoItemsArray.firstIndex(where: { $0.video.localIdentifier == selectedVideosArray[indexPath.item].video.localIdentifier }) {
            videoItemsArray[index].isSelected = false
            collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
        
        selectedVideosArray.remove(at: indexPath.row)
        
        if selectedVideosArray.count == 5 {
            videoSelectionWarningLabel.isHidden = false
        } else {
            videoSelectionWarningLabel.isHidden = true
        }
        
        selectedVideosCollectionView.reloadData()
        showSelectedVideosCollection()
    }
    
    @objc func playVideoFromAsset(_ asset: PHAsset) {
        let options = PHVideoRequestOptions()
        options.version = .original
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            guard let avAsset = avAsset else {
                print("unable to fetch AVAsset")
                return
            }
            
            DispatchQueue.main.async {
                let playerItem = AVPlayerItem(asset: avAsset)
                let player = AVPlayer(playerItem: playerItem)
                
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                // Present the AVPlayerViewController to play the video
                self.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            }
        }
    }
    
    func imagePreviewButtonTapped(_ imageURL: URL) {
        
       /* let imagePreviewVC = self.storyboard?.instantiateViewController(identifier: "ImagePreviewViewController") as! ImagePreviewViewController
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            imagePreviewVC.imageURL = imageURL
            self.present(imagePreviewVC, animated: true)
        }*/
    }
}

// MARK: -                  UICollectionView Delegate & DataSource Methods

extension VideosCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return videoItemsArray.count
          //  return assets.count
        } else {
            return selectedVideosArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideosCollectionViewCell.identifier, for: indexPath) as! VideosCollectionViewCell
            
            let videoAsset = videoItemsArray[indexPath.item]
            
            if imageCompressorIsSelected {
                
                self.getImageSizeAndThumbnail(from: videoAsset, at: indexPath)
                cell.videoImage?.image = videoAsset.thumbnail
                cell.videoInfoLabel?.text = "\(String(format: "%.2f", videoAsset.size)) MB"
                cell.expandButton.isHidden = true
                
                /*cell.videoInfoView.isHidden = true
                cell.expandButton.setBackgroundImage(UIImage(named: "Expand"), for: .normal)
                
                cell.playBtnTapped = {
                    if let imageURL = videoAsset.url {
                        self.imagePreviewButtonTapped(imageURL)
                    }
                }*/
    
            } else {
                
                getVideoSizeAndThumbnail(from: videoAsset, for: cell)
                
                DispatchQueue.main.async {
                    cell.videoImage?.image = videoAsset.thumbnail
                    cell.videoInfoLabel.text = "\(videoAsset.duration)"
                    
                    cell.playBtnTapped = {
                        // Play fullScreen Video when button is tapped
                        self.playVideoFromAsset(videoAsset.video)
                    }
                }
            }
            
            if videoAsset.isSelected {
                cell.badgeView.isHidden = false
                cell.transparentView.isHidden = false
                //cell.selectedNumber.text = "\(videoAsset.selectedNumber)"
            } else {
                cell.badgeView.isHidden = true
                cell.transparentView.isHidden = true
            }
            return cell
//        }
//        else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedVideosCollectionViewCell.identifier, for: indexPath) as! SelectedVideosCollectionViewCell
//            
//            if selectedVideosArray.count > 0 {
//                let video = selectedVideosArray[indexPath.item]
//                cell.videoImage.image = video.thumbnail
//                cell.crossBttn.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
//            }
//            return cell
  //      }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            
            var videoAsset = videoItemsArray[indexPath.item]
            
            if collectionView == self.collectionView {
                if !videoAsset.isSelected {
                    ///
                    videoAsset.isSelected = true
                    selectedVideosArray.append(videoAsset)
   //                 self.selectedVideosCollectionView.reloadData()
                
                    collectionView.reloadItems(at: [indexPath])
                    // Handling navigation logic
                    
                    //if videoConverterIsSelected {
      //              DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    //        if self.selectedVideosArray.count > 0 {
                   /// ******             self.goToMP4ConverterScreen(with: self.selectedVideosArray.first)
           //                 }
                  //      }
                        
          //          }
                    
                } else {
                    if let index = selectedVideosArray.firstIndex(where: { $0 === videoAsset}) {
                        videoAsset.isSelected = false
                        selectedVideosArray.remove(at: index)
                        
                        // Update selectedNumbers for remaining videos
                        for (index, selectedVideo) in selectedVideosArray.enumerated() {
                            selectedVideo.selectedNumber = index + 1
                        }
                        if selectedVideosArray.count < 5 {
                            videoSelectionWarningLabel.isHidden = true
                        }
                        //self.selectedVideosCollectionView.reloadData()
                        //collectionView.reloadData()
                        collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
            //            else {
            // Handle other collection views if required
            //        }
            

        }
    }

    // MARK: -                 UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {/// Calculating the size for each cell to fit 3 cells in a row
            let cellWidth = collectionView.frame.width / 3
            let cellHeight = collectionView.frame.height / 6
            return CGSize(width: cellWidth, height: cellHeight)
        } else {
            let cellWidth = (selectedVideosCollectionView.frame.width - 16) / 4 /// Adjust as needed
            let cellHeight = selectedVideosCollectionView.frame.height /// The height remains the same
            return CGSize(width: cellWidth, height: cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6 /// spacing between rows
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == selectedVideosCollectionView {
            return 4
        } else {
            return 0 ///  spacing between cells in a row
        }
    }
}


// MARK: -              Premium Features Delegate Methods


extension VideosCollectionViewController: UIDocumentPickerDelegate {
    func presentDocumentPicker() {
        
        var picker: UIDocumentPickerViewController?
        
        if imageCompressorIsSelected {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .bmp, .heic], asCopy: true)
        } else {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.video, .mpeg4Movie, .quickTimeMovie, .avi, .movie, .mpeg, .mpeg2Video], asCopy: true)
        }
        
         // Create a document picker for video files
        

        picker?.delegate = self
        picker?.allowsMultipleSelection = self.multiCompressorIsSelected
        present(picker!, animated: true)
     }
    
    // Delegate method when a document is selected
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Selected file URL: \(urls)")
        for itmURL in urls {
            if imageCompressorIsSelected {
                let imageAsset = VideoAsset()
                imageAsset.url = itmURL
                self.selectedVideosArray.append(imageAsset)
            } else {
                handleSelectedFile(at: itmURL)
            }
            
        }
        self.importedFile = true
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
           // self.goToCompressorScreen()
        }
    }
    
    // Delegate method when the picker is canceled
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.importedFile = false
        print("Document picker was canceled")
    }
    
    // Handle the selected file URL
    private func handleSelectedFile(at url: URL) {
        // Perform operations with the video file URL
        let videoAsset = VideoAsset()
        let avAsset = AVAsset(url: url)
        if self.checkforVideoSize(from: self.selectedVideosArray) {
                videoItemsArray.removeAll()
        } else {
            let videoSize = try? FileManager.default.attributesOfItem(atPath: url.path)[FileAttributeKey.size] as? Int64
            // Calculate video duration in minutes and seconds
            let durationInSeconds = CMTimeGetSeconds(avAsset.duration)
            let minutes = Int(durationInSeconds / 60)
            let seconds = Int(durationInSeconds.truncatingRemainder(dividingBy: 60))
            
            // Update videoAsset properties on the main thread
            DispatchQueue.main.async {
                if let videoSize = videoSize {
                    videoAsset.size = Double(videoSize) / 1048576.0//String(format: "%.2f", self.bytesTØoMegabytes(videoSize))
                    let videoResolution = CGSize(width: videoAsset.video.pixelWidth, height: videoAsset.video.pixelHeight)
                    videoAsset.resolution = "\(Int(videoResolution.width))x\(Int(videoResolution.height))"
                    videoAsset.duration = String(format: "%02d:%02d", minutes, seconds)
                    videoAsset.url = url
                    
                    let generator = AVAssetImageGenerator(asset: avAsset)
                    generator.appliesPreferredTrackTransform = true
                    // Get a thumbnail at the 5th second (adjust as needed)
                    let time = CMTimeMake(value: 5, timescale: 1)
                    generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, _, _ in
                        if let cgImage = image {
                            let thumbnail = UIImage(cgImage: cgImage)
                            DispatchQueue.main.async {
                                videoAsset.thumbnail = thumbnail
                            }
                        }
                        
                        avAsset.loadValuesAsynchronously(forKeys: ["tracks"]) {
                            
                            var videoSize: CGSize = .zero
                            var videoResolution: String = "Unknown"
                            
                            // Check if the tracks loaded successfully
                            var error: NSError?
                            let status = avAsset.statusOfValue(forKey: "tracks", error: &error)
                            
                            if status == .loaded {
                                if let videoTrack = avAsset.tracks(withMediaType: .video).first {
                                    // Get video size
                                    let naturalSize = videoTrack.naturalSize
                                    videoSize = CGSize(width: abs(naturalSize.width), height: abs(naturalSize.height))
                                    
                                    // Get video resolution
                                    let size = videoSize
                                    let width = Int(size.width)
                                    let height = Int(size.height)
                                    videoResolution = "\(width)x\(height)"
                                    videoAsset.resolution = videoResolution
                                }
                            }
                        }
                    }
                    self.selectedVideosArray.append(videoAsset)
                }
            }
        }
        print("File URL: \(url)")
    }
}

/*extension VideosCollectionViewController: RewardedAdWatchedDelegate {
    func referralPointsFinished() {
        DispatchQueue.main.async {
          //  IAPManager.shared.presentAlert(title: "Failed!", message: "You Don't have sufficient points to proceed")
        }
    }
    
    func watchedCompleteAd() {
        
        if selectedVideosArray.count > 0 {
            
            let compressorVC = UIStoryboard(name: "EditScreen", bundle: nil).instantiateViewController(withIdentifier: "VideoInfoViewController") as! VideoInfoViewController
                compressorVC.videoAsset = selectedVideosArray.first
                compressorVC.fileImported = self.importedFile
                compressorVC.audioConverterIsSelected = true
                self.removeAllSelectedVideos()
                self.navigationController?.pushViewController(compressorVC, animated: true)
            
        } else {
            
           /* let compressorVC = self.storyboard?.instantiateViewController(withIdentifier: "CompressorViewController") as! CompressorViewController
            compressorVC.videoAssets = selectedVideosArray
            compressorVC.imageCompressorIsSelected = self.imageCompressorIsSelected
            self.removeAllSelectedVideos()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.navigationController?.pushViewController(compressorVC, animated: true)
            }*/
        }
    }
    
    func didNotWatchedAd() {
        self.removeAllSelectedVideos()
        self.selectedVideosCollectionView?.reloadData()
        self.collectionView?.reloadData()
        self.showSelectedVideosCollection()
    }
}*/


extension VideosCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.navigationController?.viewControllers.count ?? 0 > 1
    }
}
