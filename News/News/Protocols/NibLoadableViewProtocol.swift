//
//  NibLoadableViewProtocol.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
import UIKit
/// the NibLoadableView protocol defines static property that allow you to get nib file name for the class that confirm this protocol.
protocol NibLoadableView: AnyObject {
    static var nibName: String { get }
}
/// the impelementation of NibLoadableView protocol return nib file name for the class that confirm this protocol when protocol did confirmd.
extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}
