//
//  Utilities.swift
//  JustLogin_MECS
//
//  Created by Samrat on 20/2/17.
//  Copyright © 2017 SMRT. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Utilities {
    
    /**
     * Method to convert server string to date.
     */
    static func convertServerStringToDate(_ string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.General.ServerDateFormat
        return dateFormatter.date(from: string)
    }
    
    /**
     * Method to convert date to string.
     */
    static func convertDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.General.LocalDisplayDateFormat
        return dateFormatter.string(from: date)
    }
    
    /**
     * Method to show an error alert.
     */
    static func showErrorAlert(withMessage message: String, onController controller: UIViewController) {
        // TODO: - Add to the text file.
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        })
        controller.present(alert, animated: true)
    }
    
    /**
     * Check if connection is available.
     */
    static func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    /**
     * Method to adjust the inset of a scroll view when the keyboard is displayed or hidden.
     */
    static func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification, scrollView: UIScrollView) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : -1)
        
        
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
}
    
