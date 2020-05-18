//
//  NetworkManager.swift
//  Challenge
//
//  Created by Suraj Kodre on 15/05/20.
//  Copyright © 2020 Suraj Kodre. All rights reserved.
//

import Foundation

class NetWorkManager {
    public static let sharedInstance = NetWorkManager()
    
    func fetchDataFromURL(url: URL?, closure: @escaping ([GitRepoBO]?,Double?,Bool)->()) {
        guard let url = url else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                guard let data = data else { throw JSONError.NoData }
                guard let repoArray = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] else { throw JSONError.ConversionFailed }
                var totalUserCount = 0.0
                if let totalCount = repoArray["total_count"] as? Double {
                    totalUserCount = totalCount
                    let totalPages = Int(ceil(totalCount / 30.0))
                    UserDefaults.standard.set(totalPages, forKey: "totalPageCountOfSearchResult")
                }
                var gitRepoArray = [GitRepoBO]()
                if let items = repoArray["items"] as? [[String:Any]] {
                    for item in items {
                        let repoName = item["login"] as! String
                        let repoImage = item["avatar_url"] as? String
                        let repoScore = item["score"] as? Double
                        let gitRepo = GitRepoBO(userName: repoName, repoScore: repoScore, repoImage: repoImage)
                        gitRepoArray.append(gitRepo)
                    }
                }
                closure(gitRepoArray,totalUserCount,true)
            } catch let error as JSONError {
                print(error.rawValue)
                closure(nil,nil, false)
            } catch let error as NSError {
                print("Error: \(error)")
                closure(nil,nil,false)
            }
            }.resume()
    }
}
