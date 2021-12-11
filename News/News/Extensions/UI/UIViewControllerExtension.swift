//
//  UIViewControllerExtension.swift
//  News
//
//  Created by Radya Albasha on 12/12/2021.
//

import Foundation
import UIKit
extension UIViewController{
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// Method is used to display alert controller view when an error occurs
    /// - Parameter errorMessage: printed error message
    func showErrorMessage(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
