//
//  Extension.swift

import UIKit
import AVFoundation


//MARK: - CALayer extension
extension CALayer {
    
    func setUpBorder(borderColor : UIColor? = .clear, borderWidth : CGFloat? = 0.0, cornerRadius : CGFloat? = 0.0) {
        self.borderColor = borderColor?.cgColor
        self.borderWidth = borderWidth ?? 0.0
        self.cornerRadius = cornerRadius ?? 0.0
        self.masksToBounds = true
    }
}

//MARK: - UIView extension
extension UIView {
    
    func setOuterBorder(){
        self.layer.shadowColor = UIColor.lightGray.cgColor;
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 0.4;
        self.layer.shadowOffset = CGSize.zero;
        self.layer.masksToBounds = false;
    }
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    func roundCorners(cornerMasks : CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            layer.maskedCorners = cornerMasks
        } else {
            // Fallback on earlier versions
        }
    }
    
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[subview]-10-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-5-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["subview": self]))
    }
    
    
    func makeCircular(radius : CGFloat? , borderWidth : CGFloat? ,borderColor : UIColor?,needToApplyShadow : Bool? = false)  {
        self.clipsToBounds = true
        //        self.layer.masksToBounds = true
        self.borderWidth = borderWidth ?? 0.0
        self.borderColor = borderColor ?? UIColor.clear
        self.layer.cornerRadius = radius ?? self.frame.width/2
        if needToApplyShadow ?? false {
            self.shadowRadius = 5.0
            self.shadowOpacity = 1.0
            self.shadowOffset = CGSize(width: 1.0, height: 1.0)
            self.shadowColor = .white
        }
    }
    
    func setGradientBackground(arrayColor : [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = arrayColor
        gradientLayer.locations = [0.0,0.5,1.0]
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    //MARK: - Show/HideView
    func showView() {
        self.isHidden = false
        self.alpha = 1.0
    }
    
    func hideView(VC : UIViewController? = nil, isAnimated:Bool = false) {
        if isAnimated{
            self.alpha = 1.0
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
                self.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
                self.alpha = 0.0
                
            }, completion: { (finished: Bool) -> () in
                if VC != nil {
                    VC?.dismiss(animated: false, completion: nil)
                }
            })
        }else{
            self.alpha = 0.0
            if VC != nil {
                VC?.dismiss(animated: false, completion: nil)
            }
        }
    }
    

    
    func showShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.15, radius: CGFloat = 1.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    func dropShadow(scale: Bool = true, addShadow : Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = addShadow ? 1.0 : 0
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowRadius = addShadow ? 4 : 0
        self.layer.shouldRasterize = addShadow ? true : false
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    
    
    func addShadowForRoundedButton(view: UIView, button: UIButton, opacity: Float = 1) {
        let shadowView = UIView()
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.opacity = opacity
        shadowView.layer.shadowRadius = 5
        shadowView.layer.shadowOpacity = 0.35
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.cornerRadius = button.bounds.size.width / 2
        shadowView.frame = CGRect(origin: CGPoint(x: button.frame.origin.x, y: button.frame.origin.y), size: CGSize(width: button.bounds.width, height: button.bounds.height))
        self.addSubview(shadowView)
        view.bringSubviewToFront(button)
    }
    
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    
    func roundSpecificCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = false
        self.addSubview(blurEffectView)
    }
    
}


extension UIColor{
    convenience init(hex: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        var hex:   String = hex

        if hex.hasPrefix("#") {
            let index   = hex.index(hex.startIndex, offsetBy: 1)
            hex         = hex.substring(from: index)
        }

        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hex.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
            }
        } else {
            print("Scan hex error")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

//MARK: - Collection view extension
extension UICollectionView {
    func registerCollectionViewCell(cellIdentifier : String)  {
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
}


extension UITableView {
        func registerTablViewCell(cellIdentifier : String)  {
            let nib = UINib(nibName: cellIdentifier, bundle: nil)
            self.register(nib, forCellReuseIdentifier: cellIdentifier)
            self.tableFooterView = UIView()
            self.setSepratoreToZero()
            self.showsVerticalScrollIndicator = false
        }
    
    func registerSectionView(cellIdentifier : String) {
        self.register(UINib(nibName:cellIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: cellIdentifier)
    }
    func setSepratoreToZero() {
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
    }

    func nextResponder(index: Int){
        var currIndex = -1
        for i in index+1..<index+100{
            if let view = self.superview?.superview?.viewWithTag(i){
                view.becomeFirstResponder()
                currIndex = i
                break
            }
        }

        let ind = IndexPath(row: currIndex - 100, section: 0)
        if let nextCell = self.cellForRow(at: ind){
            self.scrollRectToVisible(nextCell.frame, animated: true)
        }
    }
    
    func updateHeaderViewHeight() {
        if let header = self.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(CGSize(width: self.bounds.width, height: 0))
            header.frame.size.height = newSize.height
            self.tableHeaderView = header
        }
    }
    
    func updateFooterViewHeight() {
        if let footer = self.tableFooterView {
            let newSize = footer.systemLayoutSizeFitting(CGSize(width: self.bounds.width, height: 0))
            footer.frame.size.height = newSize.height
            self.tableFooterView = footer
        }
    }
}


extension UILabel {
    
    @IBInspectable
    var customFontName: String {
        get {
            return self.font.fontName
        }
        set {
            if !newValue.isEmpty {
                // Try loading the custom font
                if let customFont = UIFont(name: newValue, size: self.font.pointSize) {
                    self.font = customFont
                } else {
                    print("⚠️ Warning: Font '\(newValue)' not found. Check if it's added in Info.plist and project settings.")
                }
            }
        }
    }
    
    @IBInspectable
    var customSize: CGFloat {
        get {
            return self.font.pointSize
        }
        set {
            self.font = self.font.withSize(newValue)
        }
    }
}


enum SFProDisplayFontWeight: String {
    case regular = "SF-Pro-Display-Regular"
    case medium = "SF-Pro-Display-Medium"
    case semibold = "SF-Pro-Display-Semibold"
    case bold = "SF-Pro-Display-Bold"
    case light = "SF-Pro-Display-Light"
}

enum SFProRoundedFontWeight: String {
    case regular = "SF-Pro-Rounded-Regular"
    case medium = "SF-Pro-Rounded-Medium"
    case semibold = "SF-Pro-Rounded-Semibold"
    case bold = "SF-Pro-Rounded-Bold"
    case heavy = "SF-Pro-Rounded-Heavy"
    case light = "SF-Pro-Rounded-Light"
}

extension UIFont {
    static func sfProDisplay(_ weight: SFProDisplayFontWeight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func sfProRounded(_ weight: SFProRoundedFontWeight, size: CGFloat) -> UIFont {
        return UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }

}


extension UIApplication {
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
    
}


extension UIImage {
    /// Creates an animated UIImage object from a specified GIF resource name and playback speed.

    static func animatedGIF(named name: String, playbackSpeed: Double = 1.0) -> UIImage? {
        // Retrieve the URL for the GIF resource file
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
            return nil
        }

        // Load the GIF data from the URL
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            return nil
        }

        // Create a CGImageSource from the GIF data
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }

        // Determine the number of frames in the GIF
        let imageCount = CGImageSourceGetCount(source)

        // Initialize an empty array to store the individual UIImage frames
        var images = [UIImage]()

        // Calculate the total duration of the GIF animation
        var totalDuration: TimeInterval = 0.0

        // Iterate through each frame in the GIF
        for i in 0..<imageCount {
            // Retrieve the CGImage for the current frame
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }

            // Extract the delay time information for the current frame
            let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as NSDictionary?
            let gifInfo = frameProperties?[kCGImagePropertyGIFDictionary] as? NSDictionary
            let delayTimeUnclampedProp = gifInfo?[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber
            let delayTimeProp = gifInfo?[kCGImagePropertyGIFDelayTime] as? NSNumber

            // Calculate the unclamped and clamped delay times
            let delayTimeUnclamped = delayTimeUnclampedProp?.doubleValue ?? 0.1
            let delayTime = delayTimeProp?.doubleValue ?? 0.1

            // Apply the playback speed adjustment to the delay time
            let adjustedDelayTime = TimeInterval(min(delayTimeUnclamped, delayTime) / playbackSpeed)

            // Update the total duration of the animation
            totalDuration += adjustedDelayTime

            // Create a UIImage object from the CGImage and append it to the array
            images.append(UIImage(cgImage: cgImage))
        }

        // Create and return the animated UIImage object
        return UIImage.animatedImage(with: images, duration: totalDuration)
    }
    

    static func resizedAnimatedGIF(named name: String, playbackSpeed: Double = 1.0, targetSize: CGSize? = nil) -> UIImage? {
        // Retrieve the URL for the GIF resource file
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
            return nil
        }

        // Load the GIF data from the URL
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            return nil
        }

        // Create a CGImageSource from the GIF data
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }

        // Determine the number of frames in the GIF
        let imageCount = CGImageSourceGetCount(source)

        // Initialize an empty array to store the individual UIImage frames
        var images = [UIImage]()
        var totalDuration: TimeInterval = 0.0

        // Iterate through each frame in the GIF
        for i in 0..<imageCount {
            // Retrieve the CGImage for the current frame
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                continue
            }

            // Extract frame properties
            let frameProperties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as NSDictionary?
            let gifInfo = frameProperties?[kCGImagePropertyGIFDictionary] as? NSDictionary
            let delayTimeUnclampedProp = gifInfo?[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber
            let delayTimeProp = gifInfo?[kCGImagePropertyGIFDelayTime] as? NSNumber

            // Determine the frame delay time
            let delayTimeUnclamped = delayTimeUnclampedProp?.doubleValue ?? 0.1
            let delayTime = delayTimeProp?.doubleValue ?? 0.1
            let adjustedDelayTime = TimeInterval(min(delayTimeUnclamped, delayTime) / playbackSpeed)
            totalDuration += adjustedDelayTime

            // Scale frame to target size if provided
            let image = UIImage(cgImage: cgImage)
            if let targetSize = targetSize {
                let scaledImage = resizeImage(image, to: targetSize)
                images.append(scaledImage)
            } else {
                images.append(image)
            }
        }

        // Create and return the animated UIImage
        return UIImage.animatedImage(with: images, duration: totalDuration)
    }

    // Helper function to resize an image to a target size
    static func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleRatio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * scaleRatio, height: size.height * scaleRatio)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage!
    }

}



/*
 Font: SFProDisplay-Regular
 Font: SFProDisplay-Ultralight
 Font: SFProDisplay-Thin
 Font: SFProDisplay-Light
 Font: SFProDisplay-Medium
 Font: SFProDisplay-Semibold
 Font: SFProDisplay-Bold
 Font: SFProDisplay-Heavy
 Font: SFProDisplay-Black
 Family: SF Pro Text
 Font: SFProText-Regular
 Font: SFProText-Light
 Font: SFProText-Medium
 Font: SFProText-Semibold
 Font: SFProText-Bold
 Font: SFProText-Heavy
 */





extension FileManager {
    func getDocumentDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    
    func getFullPathWithFileName(fileName: String) -> URL? {
        guard let documentDirectory = getDocumentDirectory() else { return nil }
        return documentDirectory.appendingPathComponent(fileName)
    }
    
    func convertFileNameToDate(fileName: String) -> Date? {
        // Extract timestamp from file name
        let components = fileName.split(separator: "_") // ["file", "timestamp.ext"]
        guard components.count > 1, let timestampPart = components.last?.split(separator: ".").first,
              let timestamp = TimeInterval(timestampPart) else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
}


/*   - SFProDisplay-Regular
 - SFProDisplay-Ultralight
 - SFProDisplay-Thin
 - SFProDisplay-Light
 - SFProDisplay-Medium
 - SFProDisplay-Semibold
 - SFProDisplay-Bold
 - SFProDisplay-Heavy
 - SFProDisplay-Black
*/
