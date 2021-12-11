//
//  ArticleModel.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
class ArticleModel: Codable {
    let source: SourceModel?
    let author: String?
    let title, articleDescription: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case source, author, title
        case articleDescription = "description"
        case url, urlToImage, publishedAt, content
    }

    
    init(source: SourceModel?, author: String?, title: String?, articleDescription: String?, url: String?, urlToImage: String?, publishedAt: String?, content: String?) {
        self.source = source
        self.author = author
        self.title = title
        self.articleDescription = articleDescription
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.content = content
    }
}
