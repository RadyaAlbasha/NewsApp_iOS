//
//  SourceModel.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
class SourceModel: Codable {
    let id: String?
    let name: String
    
    init(id: String?, name: String) {
        self.id = id
        self.name = name
    }
}
