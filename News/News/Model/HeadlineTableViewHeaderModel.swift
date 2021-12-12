//
//  HeadlineTableViewHeaderModel.swift
//  News
//
//  Created by Radya Albasha on 12/12/2021.
//

import Foundation
class HeadlineTableViewHeaderModel:Codable {
    var category: String
    var loadMore: Bool
    var isEnabled: Bool = true
    
    init(category: String, loadMore: Bool = false) {
        self.category = category
        self.loadMore = loadMore
    }
}
