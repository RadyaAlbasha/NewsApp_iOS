//
//  OnboardingViewModel.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import Foundation
/// Home ViewModel is responsible for holding business logic for Onboarding screen
class OnboardingViewModel{
    func getCatigories()->[ChecklistItem]{
        var categories : [ChecklistItem] = []
        getAllCatigories().forEach { categoryName in
            categories.append(ChecklistItem(name: categoryName, isChecked: false))
        }
        categories.first?.isChecked = true//defaulte
        return categories
    }
    func getDefaulteCountry()->String{
        return HelpersData.countries.first ?? ""
    }
    func getDefaulteCatigory()->String{
        return HelpersData.countries.first ?? ""
    }
    func getAllCatigories()-> [String]{
        return HelpersData.categories
    }
    func saveSelectedCountry(country: String){
        UserDefaults.standard.set(country, forKey: CachingConstants.selectedCountry.rawValue)
    }
    func saveFavoriteCategories(favoriteCategories: [String]){
        UserDefaults.standard.set(favoriteCategories, forKey: CachingConstants.favoriteCategories.rawValue)
    }
    func setupCompleted(){
        UserDefaults.standard.set(true, forKey: CachingConstants.SetupCompleted.rawValue)
    }
}
