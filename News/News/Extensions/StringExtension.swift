//
//  StringExtension.swift
//  News
//
//  Created by Radya Albasha on 11/12/2021.
//

import Foundation
extension String{
    func toDate() -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: self)
    }
}
