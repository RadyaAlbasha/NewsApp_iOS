//
//  NetworkManagerContract.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
protocol NetworkManagerContract {
    func getTopHeadlines(countryName:String,category:String,completion: @escaping (Result<NewsModel?,ErrorMessage>) -> Void)
}
