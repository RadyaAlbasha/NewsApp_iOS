//
//  DetailsViewController.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var headlineLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var sourceLabel: UILabel!
    
    @IBOutlet weak var articleURLLabel: UILabel!
    
    @IBOutlet weak var articleImage: UIImageView!
    
    @IBOutlet weak var descriptionTextV: UITextView!
    
    var articleModel : ArticleModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup(){
        guard let articleModel = articleModel else {
            return
        }

        if let image = articleModel.urlToImage{
            articleImage.sd_setImage(with:URL(string : image) , placeholderImage: UIImage(named: "NewsPlaceholder"))
        }
        headlineLabel.text = articleModel.title
        authorLabel.text = articleModel.author
        sourceLabel.text = articleModel.source?.name
        articleURLLabel.text = articleModel.url
        descriptionTextV.text = articleModel.articleDescription
    }
    
    @IBAction func didPressArticleURL(_ sender: UIButton) {
        DispatchQueue.main.async {[weak self] in
            if let artcileURL = self?.articleModel?.url{
                if let url = URL(string: artcileURL) {// open safari with article URL.
                    UIApplication.shared.open(url)
                }else{
                    //invalid url
                    self?.showErrorMessage(errorMessage: "Invalid URL")
                }
            }
        }
    }
}
