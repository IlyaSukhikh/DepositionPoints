//
//  UIViewController.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showLocationDisabledAlert() {
        let cancel = UIAlertAction(title: .cancel, style: .cancel, handler: nil)
        let settings = UIAlertAction(title: .settings, style: .default) { _ in
            guard let url = URL(string: UIApplicationOpenSettingsURLString)
                else { return }
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        let alert = UIAlertController(title: nil, message: .geolocationDisabled, preferredStyle: .alert)
        alert.addAction(cancel)
        alert.addAction(settings)
        self.present(alert, animated: true, completion: nil)
    }
}
