//
//  HomeViewModel.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
import Combine

/// Home ViewModel is responsible for holding business logic for Home screen
class HomeViewModel{
    
    /// Network Manager object to be able to make API call
    private var networkManager:NetworkManagerContract
    
    /// passthrough subject to emit errors
    var errorSubject = PassthroughSubject<String,Never>()
    
    /// passthrough subject to emit results
    var dataSubject = PassthroughSubject<[String:[ArticleModel]],Never>()

    /// passthrough subject to emit loading state
    var loadingSubject = PassthroughSubject<Bool,Never>()

    var topHeadlines: [String:[ArticleModel]] = [:]{
        didSet{
            self.dataSubject.send(topHeadlines)
        }
    }
    
    /// initializer for viewModel
    /// - Parameter networkManager: Network Manager object to be able to make API call
    init(networkManager:NetworkManagerContract = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func setupTopHeadlines(){
        topHeadlines = getSavedArticles() ?? [:]
    }
    func fetchTopHeadlines(countryName:String,category:String){
        loadingSubject.send(true)
        networkManager.getTopHeadlines(countryName: countryName, category: category) {[weak self] (result) in
            switch result{
            case .success(let news):
                self?.loadingSubject.send(false)
                if let category = news?.category{
                    self?.topHeadlines[category] = news?.articles ?? []
                }
                self?.cacheData()
            case .failure(let error):
                self?.loadingSubject.send(false)
                self?.errorSubject.send(error.rawValue)
            }
        }
    }
    func getArticles(countryName: String, favoriteCategories: [String],refresh:Bool = false){
        var hours = 1 // lastCallNumberOfHours
        if let date = UserDefaults.standard.object(forKey:CachingConstants.lastLoadDate.rawValue) as? Date, let totalHours = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour{
            hours = totalHours //the number of hours that have passed since the last call
        }
        
        let articles = getSavedArticles() ?? [:]
        
        if hours >= 1 || articles.isEmpty || refresh{
            favoriteCategories.forEach { category in
                fetchTopHeadlines(countryName: countryName , category: category)
            }
        }else{
            topHeadlines = articles
        }
    }
    func filterHeadlines(searchText: String) -> [String:[ArticleModel]]{
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        var filteredHeadlines : [String:[ArticleModel]] = [:]
        if searchText.isEmpty{
            filteredHeadlines = topHeadlines
        }else{
            topHeadlines.forEach { (key, value) in
                var filteredArticles = value.filter({
                    // If dataItem matches the searchText, return true to include it
                    return $0.title?.range(of: searchText, options: .caseInsensitive) != nil
                })
                filteredArticles = sortArticles(articles: filteredArticles)
                filteredHeadlines[key] = filteredArticles
            }
        }
        return filteredHeadlines
    }
    func sortArticles(articles: [ArticleModel])-> [ArticleModel]{
        return articles.sorted{(article1, article2) in
            if let date1 = article1.publishedAt?.toDate(), let date2 = article2.publishedAt?.toDate(){
                return date1.compare(date2) == .orderedDescending
            }
            return false
        }
    }
    func saveArticles(articles:[String:[ArticleModel]]){
        UserDefaults.standard.set(object: articles, forKey:CachingConstants.savedArticles.rawValue)
    }
    func getSavedArticles()-> [String:[ArticleModel]]?{
        return UserDefaults.standard.object([String:[ArticleModel]].self, with: CachingConstants.savedArticles.rawValue)
    }
    func getSavedSelectedCountry()->String?{
        return UserDefaults.standard.string(forKey: CachingConstants.selectedCountry.rawValue)
    }
    func getSavedFavoriteCategories()->[String]?{
        return UserDefaults.standard.array(forKey: CachingConstants.favoriteCategories.rawValue) as? [String]
    }
    func cacheData(){
        UserDefaults.standard.set(Date(), forKey: CachingConstants.lastLoadDate.rawValue)
        if !self.topHeadlines.isEmpty{
            self.saveArticles(articles: self.topHeadlines)
        }
    }
}
