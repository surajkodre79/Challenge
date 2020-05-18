//
//  ViewController.swift
//  Challenge
//
//  Created by Suraj Kodre on 15/05/20.
//  Copyright © 2020 Suraj Kodre. All rights reserved.
//

import UIKit

class GitRepoViewController: UIViewController {

    @IBOutlet weak var showingResultForLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortByView: UIView!
    @IBOutlet weak var totalRepoCountLabel: UILabel!
    @IBOutlet weak var showInfoLabel: UILabel!
    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var dataLoadingLabel: UILabel!
    
    var gitRepoList = [GitRepoBO]()
    var totalPages = 1
    var parPageCount = 30
    var pageCounterUpadater = 1
    var searchedText = ""
    let sortByArray = ["Name (A-Z)", "Name (Z-A)", "Rank Assending", "Rank Decending"]

    override func viewDidLoad() {
        super.viewDidLoad()
        sortByView.isHidden = true
        showingResultForLabel.text = "Showing result for -"
        loadingIndicatorView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpView(isHidden: true)
    }
    
    func setUpView(isHidden: Bool) {
        totalRepoCountLabel.text = "Showing 0 result"
        showInfoLabel.isHidden = !isHidden
        showInfoLabel.text = "Please use search bar to fetch user data..."
        tableView.isHidden = isHidden
    }
    
    func showNoDataToSortAlertView() {
        let alert = UIAlertController(title: "Alert", message: "There is no data for sorting", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchDataFromNetworkManager(name: String, pageNo: Int, perPageCount: Int) {
        showInfoLabel.isHidden = true
        let gitFilterURL = creteURL(nameToSearch: name, pageNo: pageNo, perPageItem: perPageCount)
        NetWorkManager.sharedInstance.fetchDataFromURL(url: gitFilterURL) { (repoData, totalRepoCount ,sucess)  in
            guard let repoInfo = repoData else { return }
            guard let totalRepoCount = totalRepoCount else { return }
            for repo in repoInfo {
                self.gitRepoList.append(repo)
            }
            DispatchQueue.main.async {
                self.setUpView(isHidden: false)
                self.stopActivityIndicator()
                self.totalRepoCountLabel.text = "Showing \(Int(totalRepoCount)) results"
                self.tableView.reloadData()
            }
        }
    }
    
    func startActivityIndicator(withMessage: String) {
        dataLoadingLabel.text = withMessage
        loadingIndicatorView.isHidden = false
        indicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        tableView.isHidden = false
        self.loadingIndicatorView.isHidden = true
        self.indicator.stopAnimating()
    }
    
    func creteURL(nameToSearch: String, pageNo: Int, perPageItem: Int) -> URL {
        let baseUrl = Constants.URLs.baseURL+nameToSearch
        let pageNo = Constants.URLs.pageNo+"\(pageNo)"
        let perPageCount = Constants.URLs.perPage+"\(perPageItem)"
        let gitFilterStringURL = baseUrl + pageNo + perPageCount
        let gitFilterURL = URL(string: gitFilterStringURL)!
        return gitFilterURL
    }
    
    @IBAction func addSortByView(_ sender: Any) {
        if gitRepoList.count > 0 {
            sortByView.isHidden = false
        } else {
            showNoDataToSortAlertView()
        }
    }
    
    @IBAction func removeSortByView(_ sender: Any) {
        sortByView.isHidden = true
    }
    
    func sortRepoNameByAssending() {
        gitRepoList.sort {
            $0.userName < $1.userName
        }
        reloadTableData()
    }
    
    func sortRepoNameByDecending() {
        gitRepoList.sort {
            $0.userName > $1.userName
        }
        reloadTableData()
    }
    
    func sortRepoByRankAssending() {
        gitRepoList.sort {
            $0.repoScore ?? 0 < $1.repoScore ?? 0
        }
        reloadTableData()
    }
    
    func sortRepoByRankDecending() {
        gitRepoList.sort {
            $0.repoScore ?? 0 > $1.repoScore ?? 0
        }
        reloadTableData()
    }
    
    func reloadTableData() {
        self.tableView.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

extension GitRepoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return gitRepoList.count
        }
        return sortByArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GitRepoTableViewCell.self), for: indexPath) as? GitRepoTableViewCell else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: String(describing:UITableViewCell.self))
                 return cell
            }
            cell.repoTitleLabel.text = gitRepoList[indexPath.row].userName
            if let score = gitRepoList[indexPath.row].repoScore {
                cell.repoScoreLabel.text = "Score: \(score)"
            } else {
                cell.repoScoreLabel.text = "Score: \(0)"
            }
            DispatchQueue.global(qos: .background).async {
                    if let urlString = self.gitRepoList[indexPath.row].repoImage {
                        let url = URL(string: urlString)
                        let data = try? Data(contentsOf: url!)
                        DispatchQueue.main.async {
                            cell.repoImageView.image = UIImage(data: data!)
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.repoImageView.image = nil
                        }
                    }
                }
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: String(describing:UITableViewCell.self))
        cell.selectionStyle = .none
        cell.textLabel?.text = sortByArray[indexPath.row]
        return cell
    }
}

extension GitRepoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            if indexPath.row == gitRepoList.count - 1 {
                if let pageCountFromServer = UserDefaults.standard.value(forKey: "totalPageCountOfSearchResult") as? Int {
                    if pageCountFromServer >= pageCounterUpadater {
                        pageCounterUpadater += 1
                        startActivityIndicator(withMessage: "Data is loading for page \(pageCounterUpadater) please wait...")
                        fetchDataFromNetworkManager(name: searchedText, pageNo: pageCounterUpadater, perPageCount: 30)
                    } else {
                        pageCounterUpadater = 1
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            return 85
        } else {
            return 35
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView != self.tableView {
            sortByView.isHidden = true
            switch indexPath.row {
            case 0: sortRepoNameByAssending()
            case 1: sortRepoNameByDecending()
            case 2: sortRepoByRankAssending()
            case 3: sortRepoByRankDecending()
            default:
                print("Dafault")
            }
        }
    }
}

extension GitRepoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        gitRepoList.removeAll()
        let searchText = searchBar.text ?? ""
        if searchText.count > 0 {
            self.showingResultForLabel.text = "Search result for \"\(searchText)\""
            startActivityIndicator(withMessage: "Data is loading please wait...")
            searchedText = searchText
            fetchDataFromNetworkManager(name: searchText, pageNo: 1, perPageCount: 30)
        } else {
            searchedText = ""
            showingResultForLabel.text = "Showing result for -"
            setUpView(isHidden: true)
        }
    }
}
