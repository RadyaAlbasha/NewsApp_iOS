//
//  HomeViewController.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    @IBOutlet weak var searchBar : UISearchBar!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var headlinesTV: UITableView!
    let refreshControl = UIRefreshControl()
    var favoriteCategories : [String] = []
    var selectedCountry: String = ""
    var refresh = false

    private var filteredHeadlines: [String:[ArticleModel]] = [:]
    /// Home viewModel object
    private var homeViewModel:HomeViewModel!
    /// set of cancellables to cancel all subjects at end of controller life cycle
    private var cancellables: Set<AnyCancellable> = []
    /// activity indicator view object
    private var activityView:UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        homeViewModel.getArticles(countryName: selectedCountry, favoriteCategories: favoriteCategories)
    }
    
    func setup(){
        navigationItem.hidesBackButton = true
        configureTableViewNib()
        titleLabel.text = "Top headlines from \(selectedCountry.uppercased())"
        setupLoader()
        setupViewModel()
        if selectedCountry.isEmpty{
            selectedCountry = homeViewModel.getSavedSelectedCountry() ?? ""
        }
        if favoriteCategories.isEmpty{
            favoriteCategories = homeViewModel.getSavedFavoriteCategories() ?? []
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    func setupViewModel(){
        homeViewModel = HomeViewModel()
        homeViewModel.dataSubject.sink {[weak self] (topHeadlines) in
            guard let self = self else{return}
            self.filteredHeadlines = topHeadlines
            DispatchQueue.main.async {[weak self] in
                self?.headlinesTV.reloadData()
            }
        }.store(in: &cancellables)
        
        homeViewModel.loadingSubject.sink {[weak self] (value) in
            guard let self = self else{return}
            switch value{
            case true:
                if !self.refresh{
                    self.showLoading()
                }
            case false:
                self.hideLoading()
                self.refreshControl.endRefreshing()
                self.refresh = false
            }
            DispatchQueue.main.async {[weak self] in
                self?.headlinesTV.reloadData()
            }
        }.store(in: &cancellables)
        
        homeViewModel.errorSubject.sink {[weak self] (message) in
            guard let self = self else{return}
            self.showErrorMessage(errorMessage: message)
        }.store(in: &cancellables)
        
        homeViewModel.loadMoreSubject.sink {[weak self] (headerModel) in
            guard let self = self else{return}
           //show or hide load more btn
            headerModel.isEnabled = true
            self.homeViewModel.loadMore[headerModel.category] = headerModel
            DispatchQueue.main.async {[weak self] in
                self?.headlinesTV.reloadData()
            }
            
        }.store(in: &cancellables)
        homeViewModel.setup()
        setupRefreshController()
    }
    func setupLoader(){
        activityView = UIActivityIndicatorView(style: .large)
        activityView.center = self.view.center
        activityView.color = UIColor(named: "BaseColor") ?? .black
        self.view.addSubview(activityView)
    }
    func setupRefreshController(){
        refreshControl.tintColor = UIColor(named: "BaseColor") ?? .black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "BaseColor") ?? .black])
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        headlinesTV.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        refresh = true
        homeViewModel.getArticles(countryName: selectedCountry, favoriteCategories: favoriteCategories,refresh: true)
    }
    /**
    Register a nib object containing a cell with the table view.
    */
    func configureTableViewNib() {
        headlinesTV.register(HeadlineTableViewCell.self)
        let headerNib = UINib(nibName: "HeadlineTableHeaderView", bundle: Bundle(for: HomeViewController.self))
        headlinesTV.register(headerNib, forHeaderFooterViewReuseIdentifier: "HeadlineTableHeaderView")
    }
    /// Show activity indicator view
    func showLoading() {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else{return}
            self.activityView.startAnimating()
        }
    }
    
    /// Hide activity indicator view
    func hideLoading() {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else{return}
            self.activityView?.stopAnimating()
        }
    }
    
    /// method is called before controller object deleted from memory to cancel all subscribtions
    deinit {
        for cancelable in cancellables{
            cancelable.cancel()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension HomeViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return favoriteCategories.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHeadlines[favoriteCategories[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : HeadlineTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let article = filteredHeadlines[favoriteCategories[indexPath.section]]?[indexPath.row]
        let item =  HeadlineItem(headline: article?.title, date: article?.publishedAt, imageURL: article?.urlToImage)
        cell.configureCell(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsViewController = storyBoard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        detailsViewController.articleModel = filteredHeadlines[favoriteCategories[indexPath.section]]?[indexPath.row]
        self.navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeadlineTableHeaderView") as! HeadlineTableHeaderView
        headerView.titleLabel.text = favoriteCategories[section]
        if self.homeViewModel.loadMore[favoriteCategories[section]]?.loadMore == true{
            headerView.loadMoreButton.isHidden = false
            headerView.loadMoreLabel.isHidden = false
        }else{
            headerView.loadMoreButton.isHidden = true
            headerView.loadMoreLabel.isHidden = true
        }
        if self.homeViewModel.loadMore[favoriteCategories[section]]?.isEnabled == true{
            headerView.loadMoreButton.isEnabled = true
        }
       
        headerView.loadMoreButton.tag = section
        headerView.loadMoreButton.addTarget(self, action: #selector(loadMore(sender:)), for: .touchUpInside)
        return headerView
    }

    @objc func loadMore(sender:UIButton){
        print("loadMore button tapped \(sender.tag)")
        sender.isEnabled = false
        let category = favoriteCategories[sender.tag]
        homeViewModel.loadMore[category]?.isEnabled = false
        let page = homeViewModel.page[category] ?? 1
        homeViewModel.fetchTopHeadlines(countryName: selectedCountry, category: category, page:page)
    }
}

extension HomeViewController : UISearchBarDelegate{
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredHeadlines = homeViewModel.filterHeadlines(searchText: searchText)
        DispatchQueue.main.async {[weak self] in
            self?.headlinesTV.reloadData()
        }
    }
}
