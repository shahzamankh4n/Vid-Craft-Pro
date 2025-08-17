//
//  PhotoAccessViewController.swift
//  VidCraft Pro
//
//  Created by Shahzaman Khan on 19/02/24.
//

import UIKit

class PhotoAccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func settingsBtnTapped(_ button: UIButton) {
        openAppSettings()
    }
    
    @IBAction func cancelBtnTapped(_ button: UIButton) {
        self.dismiss(animated: true)
    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}
