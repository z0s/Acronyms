//
//  APIManager.swift
//  Acronyms
//
//  Created by Developer on 3/23/17.
//  Copyright © 2017 Zubair. All rights reserved.
//

import Foundation

// MARK: Handling Search Results
struct APIManager {
    static var searchResults = [Meaning]()
    // This helper method helps parse response JSON NSData into an array of Track objects.
    static func updateSearchResultsForSearchTerm(_ data: Data?, searchTerm: String, completion: () -> Void) {
        searchResults.removeAll()
        do {
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                
                if let jsonDict = json?.first, let longFormDicts = jsonDict["lfs"] as? [[String: Any]] {
                    for longFormDict in longFormDicts {
                        
                        let longForm = longFormDict["lf"] as! String
                        let meaning = Meaning(abbreviation: searchTerm, longForm: longForm)
                        searchResults.append(meaning)
                        completion()
                        
                    }
                }
            }
            
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        
    }
}



