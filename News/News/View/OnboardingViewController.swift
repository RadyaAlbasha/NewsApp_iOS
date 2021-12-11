//
//  OnboardingViewController.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var categoriesTV: UITableView!
    var categories : [ChecklistItem] = []
    var favoriteCategories : [String] = []
    var selectedCountry: String = ""
    var onboardingViewModel:OnboardingViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    func setup(){
        navigationItem.hidesBackButton = true
        configureTableViewNib()
        setupViewModel()
        setDefaulteSellection()
    }
    func setDefaulteSellection(){
        categories = onboardingViewModel.getCatigories()
        selectedCountry = onboardingViewModel.getDefaulteCountry()
        categories.forEach { item in
            if item.isChecked{
                favoriteCategories.append(item.name)
            }
        }
    }
    func setupViewModel(){
        onboardingViewModel = OnboardingViewModel()
    }
    /**
    Register a nib object containing a cell with the table view.
    */
    func configureTableViewNib() {
        categoriesTV.register(ChecklistTableViewCell.self)
    }

    @IBAction func didPressContinue(_ sender: UIButton) {
        saveData()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeViewController.favoriteCategories = favoriteCategories
        homeViewController.selectedCountry = selectedCountry
        self.navigationController?.pushViewController(homeViewController, animated: false)
    }
    func saveData(){
        onboardingViewModel.setupCompleted()
        onboardingViewModel.saveFavoriteCategories(favoriteCategories: favoriteCategories)
        onboardingViewModel.saveSelectedCountry(country: selectedCountry)
    }

}
extension OnboardingViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ChecklistTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: #selector(toggleSelcted(button:)), for: UIControl.Event.touchUpInside)
        cell.configureCell(item: categories[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    @objc func toggleSelcted(button: UIButton) {
        let category = categories[button.tag]
        category.isChecked = !category.isChecked
        if category.isChecked{
            favoriteCategories.append(category.name)
        }else{
            favoriteCategories.removeAll {$0 == category.name}
        }
            categoriesTV.reloadData()
    }
}

extension OnboardingViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return HelpersData.countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: HelpersData.countries[row].uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountry = HelpersData.countries[row]
    }

}


