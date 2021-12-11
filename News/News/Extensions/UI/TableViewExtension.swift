//
//  TableViewExtension.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
import UIKit
/// register a nib file and get reusable table-view cell in an easier way.
extension UITableView {
    /**
    register a nib file for use in creating new table view cells.

    - Parameters:
       - _: **Cell Class** Generic type where confirm ReusableView protocol.
     # Notes: #
     1. this method use register(_:forCellReuseIdentifier:).
     2. forCellReuseIdentifier is the nib file name by default.
     # Example #
     ```
     tableViewObject.register(tableViewCell.self)
     ```
    */
    func register<T: UITableViewCell>(_: T.Type) where T: ReusableView {
        
        register(T.self, forCellReuseIdentifier:   T.defaultReuseIdentifier)
    }

    /**
    register a nib file for use in creating new collection view cells.

    - Parameters:
       - _: **Cell Class** Generic type where confirm ReusableView, NibLoadableView protocols.
     # Notes: #
     1. this method use register(_:forCellReuseIdentifier:).
     2. forCellReuseIdentifier is the nib file name by default.
     # Example #
     ```
     tableViewObject.register(tableViewCell.self)
     ```
    */
    func register<T: UITableViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }

    /**
    Returns a reusable table-view cell object for the default reuse identifier and adds it to the table.

    - Parameters:
       - for: indexPath for the cell

    - Returns: reusable table-view cell object (type of ReusableView).
    */
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }

        return cell
    }
}
