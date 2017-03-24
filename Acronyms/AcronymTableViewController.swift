//
//  AcronymTableViewController.swift
//  Acronyms
//
//  Created by Developer on 3/23/17.
//  Copyright © 2017 Zubair. All rights reserved.
//

import UIKit

class AcronymTableViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .blue
        return tv
    }()
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.delegate = self
        sb.isTranslucent = false
        sb.placeholder = "Search for Acronyms"
        sb.sizeToFit()
        return sb
    }()
    let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    var meaning = [Meaning]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.tableHeaderView = searchBar
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchBarEditingEnded))
        view.addGestureRecognizer(gestureRecognizer)
        
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func searchBarEditingEnded() {
        view.endEditing(true)
    }
    
}
extension AcronymTableViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if !searchBar.text!.isEmpty {
            // 1
            if dataTask != nil {
                dataTask?.cancel()
            }
            // 2
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            // 3
            let expectedCharSet = CharacterSet.urlQueryAllowed
            let searchTerm = searchBar.text!.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
            // 4
            let url = URL(string: "http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=\(searchTerm)")
            
            // 5
            dataTask = defaultSession.dataTask(with: url!, completionHandler: {
                data, response, error in
                // 6
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                // 7
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        APIManager.updateSearchResultsForSearchTerm(data, searchTerm: searchTerm, completion: {
                            self.meaning = APIManager.searchResults
                            for x in self.meaning {
                                print(x.abbreviation)
                                print(x.longForm)
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
            })
            // 8
            dataTask?.resume()
        }
    }
}
extension AcronymTableViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension AcronymTableViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        print(meaning[indexPath.row].abbreviation)
        cell.textLabel?.text = meaning[indexPath.row].longForm
        cell.backgroundColor = .green
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meaning.count
    }
}
