//
//  NetworkConstants.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
public struct NetworkConstants
{
    
    static let baseNewsUrl = "https://newsapi.org/v2"
    public  struct Routes {
        static let topHeadLines = "/top-headlines?"
        static let country = "country="
        static let category = "&category="
        static let page = "&page="
    }
    static let apiKey = "&apiKey=86ea9268b1ce46bebe3795c240991d96"
}
