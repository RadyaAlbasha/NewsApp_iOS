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
    
    /// passthrough subject to emit if headlines header
    var loadMoreSubject = PassthroughSubject<HeadlineTableViewHeaderModel,Never>()

    var topHeadlines: [String:[ArticleModel]] = [:]{
        didSet{
            self.dataSubject.send(topHeadlines)
        }
    }
    //[category:pageNumber]
    var page: [String:Int] = [:]{
        didSet{
            savePage(page: page)
        }
    }
    var loadMore : [String: HeadlineTableViewHeaderModel] = [:]{
        didSet{
            saveLoadMore(loadMore: loadMore)
        }
    }
    
    /// initializer for viewModel
    /// - Parameter networkManager: Network Manager object to be able to make API call
    init(networkManager:NetworkManagerContract = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func setup(){
        if let page = getSavedPage(){
            self.page = page
        }
        if let loadMore = getSavedLoadMore(){
            self.loadMore = loadMore
        }
        if let topHeadlines = getSavedArticles(){
            self.topHeadlines = topHeadlines
        }
    }
    func resetPage(favoriteCategories: [String]){
        favoriteCategories.forEach { category in
            page[category] = 1
        }
    }
    func increaseCategoryPage(category: String){
        if page[category] != nil{//keyExists
            page[category]! += 1
        }else{
            page[category] = 1
        }
    }
    func fetchTopHeadlines(countryName:String,category:String, page:Int){
        loadingSubject.send(true)
        networkManager.getTopHeadlines(countryName: countryName, category: category, page: page) {[weak self] (result) in
            switch result{
            case .success(let news):
                self?.loadingSubject.send(false)
                guard let news = news else{return}
                if let category = news.category{
                    if let newsPage = news.page, newsPage > 1,  self?.topHeadlines[category] != nil{
                        self?.topHeadlines[category]?.append(contentsOf: news.articles ?? [])
                    }else{
                        self?.topHeadlines[category] = news.articles ?? []
                    }
                    self?.handleLoadMore(news:news)
                }
                self?.cacheData()
            case .failure(let error):
                self?.loadingSubject.send(false)
                self?.errorSubject.send(error.rawValue)
            }
        }
        increaseCategoryPage(category: category)
    }
    func handleLoadMore(news: NewsModel){
        if let category = news.category{
            if (news.totalResults ?? 0) > (self.topHeadlines[category]?.count ?? 0){
                //show load more btn
                self.loadMoreSubject.send(HeadlineTableViewHeaderModel(category: category, loadMore: true))
            }else{
                //hide load more btn
                self.loadMoreSubject.send(HeadlineTableViewHeaderModel(category: category, loadMore: false))
            }
        }
    }
    func getArticles(countryName: String, favoriteCategories: [String],refresh:Bool = false){
        if refresh{
            fetchTopHeadlinesForAllCatigories(countryName: countryName, favoriteCategories: favoriteCategories)
        }else{
            var hours = 1 // lastCallNumberOfHours
            if let date = UserDefaults.standard.object(forKey:CachingConstants.lastLoadDate.rawValue) as? Date, let totalHours = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour{
                hours = totalHours //the number of hours that have passed since the last call
            }
            
            let articles = getSavedArticles() ?? [:]
            
            if hours >= 1 || articles.isEmpty{
                fetchTopHeadlinesForAllCatigories(countryName: countryName, favoriteCategories: favoriteCategories)
            }else{
                topHeadlines = articles
                // page = saved page
                page = getSavedPage() ?? [:]
            }
        }
    }
    private func fetchTopHeadlinesForAllCatigories(countryName: String, favoriteCategories: [String]){
        //reset page
        resetPage(favoriteCategories: favoriteCategories)
        favoriteCategories.forEach { category in
            fetchTopHeadlines(countryName: countryName , category: category, page: 1)
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
    func savePage(page:[String:Int]){
        UserDefaults.standard.set(object: page, forKey:CachingConstants.page.rawValue)
    }
    func getSavedPage()-> [String:Int]?{
        return UserDefaults.standard.object([String:Int].self, with: CachingConstants.page.rawValue)
    }
    func saveLoadMore(loadMore:[String: HeadlineTableViewHeaderModel]){
        UserDefaults.standard.set(object: loadMore, forKey:CachingConstants.loadMore.rawValue)
    }
    func getSavedLoadMore()-> [String: HeadlineTableViewHeaderModel]?{
        return UserDefaults.standard.object([String: HeadlineTableViewHeaderModel].self, with: CachingConstants.loadMore.rawValue)
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
