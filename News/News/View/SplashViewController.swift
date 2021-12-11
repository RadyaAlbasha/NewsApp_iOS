//
//  SplashViewController.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {[weak self] in
            self?.showNextView(setupCompleated: UserDefaults.standard.bool(forKey: CachingConstants.SetupCompleted.rawValue))
        })
    }

    func showNextView(setupCompleated: Bool){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if setupCompleated{
            //The user has chosen his country and his favorite categories, proceed as normal.
            let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(homeViewController, animated: false)
        }else{
            //The user did not choose his country and favorite categories, show onboarding view to complete the setup.
            let onboardingViewController = storyBoard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
            self.navigationController?.pushViewController(onboardingViewController, animated: false)
        }
    }

}

