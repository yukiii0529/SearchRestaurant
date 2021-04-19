//
//  RestaurantListTableViewCell.swift
//  SearchRestaurant
//
//  Created by 田中勇輝 on 2021/04/19.
//

import UIKit

class RestaurantListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var GenreField: UILabel!
    @IBOutlet weak var RestaurantNameField: UILabel!
    @IBOutlet weak var AddressField: UILabel!
    @IBOutlet weak var AccessField: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
