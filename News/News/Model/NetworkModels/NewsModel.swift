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
    var category: String?//local
    var page: Int?//local
    
    init(status: String?, totalResults: Int?, articles: [ArticleModel]?, page: Int = 1) {
        self.status = status
        self.totalResults = totalResults
        self.articles = articles
        self.page = page
    }
}
