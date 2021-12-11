//
//  ChecklistTableViewCell.swift
//  News
//
//  Created by Radya Albasha on 10/12/2021.
//

import UIKit
/// custom TableViewCell confirm (ReusableView & NibLoadableView) protocols
class ChecklistTableViewCell: UITableViewCell,ReusableView,NibLoadableView{

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(item: ChecklistItem){
        title.text = item.name.capitalized
        checkImage.isHighlighted = item.isChecked
    }
}
