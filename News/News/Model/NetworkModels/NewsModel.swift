//
//  NewsModel.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
class NewsModel: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [ArticleModel]?
    var category: String?
    
    init(status: String?, totalResults: Int?, articles: [ArticleModel]?) {
        self.status = status
        self.totalResults = totalResults
        self.articles = articles
    }
}
