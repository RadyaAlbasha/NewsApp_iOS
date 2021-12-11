//
//  ChecklistItem.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
class ChecklistItem {
    var name: String
    var isChecked: Bool
    
    init(name: String, isChecked: Bool = false) {
        self.name = name
        self.isChecked = isChecked
    }
}
