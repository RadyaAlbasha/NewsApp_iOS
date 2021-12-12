//
//  NetworkManager.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation

/// Network manager class that uses URLSession to make API Call
class NetworkManager: NetworkManagerContract{
    
    /// method is used to hit api call and returns result whether with failure or sucess
    /// - Parameters:
    ///   - completion: completion handler thet returns result whether with failure or sucess
    func getTopHeadlines(countryName:String,category:String,page:Int = 1,completion: @escaping (Result<NewsModel?,ErrorMessage>) -> Void){
        let pageStr = String(page)
        let routes = NetworkConstants.Routes.topHeadLines+NetworkConstants.Routes.country+countryName + NetworkConstants.Routes.category+category + NetworkConstants.Routes.page+pageStr
        let requestUrl = NetworkConstants.baseNewsUrl+routes+NetworkConstants.apiKey
        
        let url = URL(string: requestUrl)
        guard let newURL = url else {
            completion(.failure(.SERVER_MESSAGE))
            return
        }
            
        let request = URLRequest(url: newURL)
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if(error != nil){
                    completion(.failure(.NO_CONNECTION))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                        completion(.failure(.INVALID_CONFIGRATION))
                    return
                }
                guard let data = data else {
                    completion(.failure(.NO_DATA))
                    return
                }
                guard let responseObject = try? JSONDecoder().decode(NewsModel.self, from: data) else {
                    completion(.failure(.INVALID_CONFIGRATION))
                    return
                }
                responseObject.category = category
                responseObject.page = page
                completion(.success(responseObject))
            }
        }.resume()
    }
}
