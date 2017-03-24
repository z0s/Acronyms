//
//  APIManager.swift
//  Acronyms
//
//  Created by Developer on 3/23/17.
//  Copyright © 2017 Zubair. All rights reserved.
//

import UIKit

// MARK: Handling Search Results
struct APIManager {
    
    private static var urlComponents = URLComponents(string: "http://www.nactem.ac.uk/software/acromine/dictionary.py")
    private static let session = URLSession.shared
    
    static func requestMeanings(of abbreviation: String, completion: (([Meaning]) -> ())? = nil) -> URLSessionDataTask? {
        let queryItem = URLQueryItem(name: "sf", value: abbreviation)
        var components = urlComponents
        components?.queryItems = [queryItem]
        var meanings = [Meaning]()
        guard let url = components?.url else {
            completion?(meanings)
            return nil
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                if let jsonDict = json?.first, let longFormDicts = jsonDict["lfs"] as? [[String: Any]] {
                    for longFormDict in longFormDicts {
                        let longForm = longFormDict["lf"] as! String
                        let meaning = Meaning(abbreviation: abbreviation, longForm: longForm)
                        meanings.append(meaning)
                    }
                }
            }
            
            completion?(meanings)
        }
        
        task.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return task
    }}



