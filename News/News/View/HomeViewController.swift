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
        }.store(in: &cancellables)
        
        homeViewModel.errorSubject.sink {[weak self] (message) in
            guard let self = self else{return}
            self.showErrorMessage(errorMessage: message)
        }.store(in: &cancellables)
        homeViewModel.setupTopHeadlines()
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
    
    /// Method is used to display alert controller view when an error occurs
    /// - Parameter errorMessage: printed error message
    func showErrorMessage(errorMessage: String) {
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
        let view = UIView()
        view.backgroundColor = UIColor(named: "LightOily")
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 11, y: 12, width:170, height: 18)
        titleLabel.text = favoriteCategories[section]
        titleLabel.textColor = UIColor(named: "AccentColor")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "BaseColor")
        button.setTitle("Load more", for: .normal)
        button.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.frame = CGRect(x: 303, y: 14, width: 50, height: 25)
        button.addTarget(self, action: #selector(loadMore(sender:)), for: .touchUpInside)
        view.addSubview(titleLabel)
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonHorizontalConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 5)
        let buttonVerticalConstraint = NSLayoutConstraint(item:view, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: button, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let titleLabelVerticalConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let titleLabelBtnHorizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: titleLabel, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        
        view.addConstraints([buttonHorizontalConstraint, buttonVerticalConstraint, titleLabelVerticalConstraint, titleLabelBtnHorizontalConstraint])
        
        
        return view
    }

    @objc func loadMore(sender:UIButton){
        print("button tapped")
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
extension HomeViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
