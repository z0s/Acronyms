//
//  AcronymTableViewController.swift
//  Acronyms
//
//  Created by Developer on 3/23/17.
//  Copyright © 2017 Zubair. All rights reserved.
//

import UIKit
import MBProgressHUD

class AcronymTableViewController: UIViewController {
    
    fileprivate static let cellReuseID = "TableViewCell"
    fileprivate static let cellHeight: CGFloat = 62.0
    
    override func loadView() {
        view = UIView()
        view.addSubview(tableView)
        view.addSubview(tableViewIsEmpty)
        view.addSubview(searchBar)
        
        tableViewIsEmpty.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableViewIsEmpty.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableViewIsEmpty.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        searchBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: AcronymTableViewController.cellReuseID)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchBarEditingEnded))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    fileprivate lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    fileprivate lazy var tableViewIsEmpty: UILabel = {
        let lbl = UILabel()
        lbl.adjustsFontSizeToFitWidth = true
        lbl.text = "Search your acronym!"
        lbl.sizeToFit()
        lbl.translatesAutoresizingMaskIntoConstraints  = false
        return lbl
    }()
    
    fileprivate lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.delegate = self
        sb.isTranslucent = false
        sb.placeholder = "Search"
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.sizeToFit()
        return sb
    }()
    
    fileprivate var dataTask: URLSessionDataTask?
    fileprivate var meanings = [Meaning]() {
        didSet {
            DispatchQueue.main.async {
                self.toggleEmptyState(show: self.meanings.isEmpty)
            }
        }
    }
    
    func searchBarEditingEnded() {
        view.endEditing(true)
    }
    
    private func toggleEmptyState(show: Bool) {
        if dataTask != nil {
            tableViewIsEmpty.text = "Nothing found for that search term!"
        } else {
            tableViewIsEmpty.text = "Search your acronym!"
        }
        tableViewIsEmpty.isHidden = !show
        tableView.isHidden = show
    }
}

extension AcronymTableViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let text = searchBar.text {
            if dataTask != nil {
                dataTask?.cancel()
            }
            let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
            loading.label.text = "Loading"
            dataTask = APIManager.requestMeanings(of: text, completion: { (meanings) in
                self.meanings = meanings
                DispatchQueue.main.async {
                    _ = MBProgressHUD.hide(for: self.view, animated: true)
                    self.tableView.reloadData()
                    self.tableView.setContentOffset(CGPoint.zero, animated: false)
                }
            })
            dataTask?.resume()
        }
    }
}

extension AcronymTableViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AcronymTableViewController.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AcronymTableViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AcronymTableViewController.cellReuseID, for: indexPath)
        cell.textLabel?.text = meanings[indexPath.row].longForm
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meanings.count
    }
}
