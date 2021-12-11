//
//  HeadlineTableViewCell.swift
//  News
//
//  Created by Radya Albasha on 11/12/2021.
//

import UIKit
import SDWebImage
/// custom TableViewCell confirm (ReusableView & NibLoadableView) protocols
class HeadlineTableViewCell: UITableViewCell,ReusableView,NibLoadableView{
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDate: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(item: HeadlineItem){
        newsTitle.text = item.headline
        if let date = item.date{
            newsDate.text = Utils.formatTheDate(theComingDate: date)
        }
        if let image = item.imageURL{
            newsImage.sd_setImage(with:URL(string : image) , placeholderImage: UIImage(named: "NewsPlaceholder"))
        }
    }
}
