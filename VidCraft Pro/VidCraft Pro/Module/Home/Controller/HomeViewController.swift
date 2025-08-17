//
//  HomeViewController.swift
//  VidCraft Pro
//
//  Created by Shahzaman Khan on 16/07/25.
//

import UIKit
import Photos

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var galleryLabel: UILabel!
    @IBOutlet weak var filesLabel: UILabel!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var recentFilesView: UIView!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var seeAllFilesBtn: UIButton!
    @IBOutlet weak var convertBtn: UIButton!
    @IBOutlet weak var noFilesInfoImageView: UIImageView!
    
    @IBOutlet weak var fromGalleryBtn: UIButton!
    @IBOutlet weak var fromFilesBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    
    
    /// Array holding selected VideoAsset objects.
    var selectedVideosArray: [VideoAsset] = []
    var audioURLs: [URL] = []
    var importedFile: Bool = false
    let fileManager = FileManager.default
    let numberOfItemsPerRow: CGFloat = 3
    let numberOfRows: CGFloat = 2
    let spacing: CGFloat = 8
    var destinationURLWithExtension: URL?
    let userDefaults = UserDefaults.standard
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpUI()
        requestAuthorization()
    }
    
    func setUpUI() {
        // Add some regular text
        let attributedString = NSMutableAttributedString()

        // Regular Text (default font use)
        let regularFontAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17) //
        ]
        let regularText = NSAttributedString(string: "From ", attributes: regularFontAttribute)
        attributedString.append(regularText)

        // Bold Text
        let boldFontAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.sfProDisplay(.semibold, size: 17)
        ]
        let boldText = NSAttributedString(string: "Gallery", attributes: boldFontAttribute)
        attributedString.append(boldText)

        galleryLabel.attributedText = attributedString

        // -------- For Files Label --------
        let filesAttributedString = NSMutableAttributedString()
        filesAttributedString.append(NSAttributedString(string: "From ", attributes: regularFontAttribute))
        let boldFilesText = NSAttributedString(string: "Files", attributes: boldFontAttribute)
        filesAttributedString.append(boldFilesText)

        filesLabel.attributedText = filesAttributedString

        // App Name Label
        appNameLabel.font = UIFont.sfProDisplay(.bold, size: 24)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func requestAuthorization() {
       if #available(iOS 14, *) {
           PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
               switch status {
               case .authorized:
                   // User has granted Limited Photos access (or full access)
                   //AssetDataManager.shared.fetchAssetsInBackground(batchSize: 6) // Start loading assets
                   print("Limited Photos access granted.")
                   // Handle access here (e.g., display limited photos)
                   break
               case .limited:
                   // User has granted Limited Photos access (specific selection)
                   print("Limited Photos access granted (limited selection).")
                   //AssetDataManager.shared.fetchAssetsInBackground(batchSize: 6) // Start loading assets
                   // Handle limited access here (e.g., inform user)
                   break
               case .denied:
                   // User has denied access
                   print("Photo library access denied.")
                   // Handle denial here (e.g., show permission request screen)
                   break
               case .notDetermined:
                   // User hasn't made a decision yet
                   print("Photo library access not determined.")
                   break
               case .restricted:
                   // Device restrictions prevent access
                   print("Photo library access restricted.")
                   // Handle restriction here (e.g., inform user)
                   break
               @unknown default:
                   print("Unknown authorization status")
               }
           }
       } else {
           // Fallback on earlier versions
       }
        //self.requestAppTrackers()
    }
    
    func goToCompressorScreen() {
///           user is not premium               |             any video should be selected             |                any selected video size should be less than 200 MB
        if selectedVideosArray.count > 0 {
            
            let compressorVC = UIStoryboard(name: "EditScreen", bundle: nil).instantiateViewController(withIdentifier: "VideoInfoViewController")// as! VideoInfoViewController
            //compressorVC.videoAsset = selectedVideosArray[0]
            //compressorVC.audioConverterIsSelected = true
                //compressorVC.fileImported = self.importedFile
            self.selectedVideosArray = []
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
               // self.collectionView?.reloadData()
                self.navigationController?.pushViewController(compressorVC, animated: true)
            }
        }
    }
    
    
    @IBAction func photosBtnTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideosCollectionViewController") as? VideosCollectionViewController {
            //vc.audioConverterIsSelected = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            print("No viewController found")
        }
    }
    
    @IBAction func importFileBtnTapped(_ sender: UIButton) {
        presentDocumentPicker()
    }
    
}


extension HomeViewController: UIDocumentPickerDelegate {
    
    func presentDocumentPicker() {
        
           let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.video, .mpeg4Movie, .quickTimeMovie, .avi, .movie, .mpeg, .mpeg2Video], asCopy: true)
        

        picker.delegate = self
        picker.modalPresentationStyle = .overFullScreen
      //  picker?.allowsMultipleSelection = self.multiCompressorIsSelected
        present(picker, animated: true)
     }
    
    // Delegate method when a document is selected
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("Selected file URL: \(urls)")
        for itmURL in urls {
            handleSelectedFile(at: itmURL)
            break
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
        let avAsset = AVURLAsset(url: url)
    
            let videoSize = try? FileManager.default.attributesOfItem(atPath: url.path)[FileAttributeKey.size] as? Int64
            // Calculate video duration in minutes and seconds
            let durationInSeconds = CMTimeGetSeconds(avAsset.duration)
            let minutes = Int(durationInSeconds / 60)
            let seconds = Int(durationInSeconds.truncatingRemainder(dividingBy: 60))
            
            // Update videoAsset properties on the main thread
            DispatchQueue.main.async {
                if let videoSize = videoSize {
                    videoAsset.size = Double(videoSize) / 1048576.0//String(format: "%.2f", self.bytesTØoMegabytes(videoSize))
                   
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
                    self.selectedVideosArray.append(videoAsset)
                        self.importedFile = true
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                            self.goToCompressorScreen()
                        }
                }
            }
        }
        //print("File URL: \(url)")
    }

}
