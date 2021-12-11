//
//  ResusableViewProtocol.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
import UIKit
/// the ReusableView protocol defines static property that allow you to get default ReuseIdentifier for the class that confirm this protocol.
protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

/**
 the impelementation of ReusableView protocol return default ReuseIdentifier for the class that confirm this protocol when protocol did confirmd.
 # Notes: #
   1. defaultReuseIdentifier equal class name
*/
extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
