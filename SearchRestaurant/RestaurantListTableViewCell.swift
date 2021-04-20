//
//  RestaurantListTableViewCell.swift
//  SearchRestaurant
//
//  Created by 田中勇輝 on 2021/04/19.
//

import UIKit

class RestaurantListTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ImageView: UIImageView! // レストラン画像
    @IBOutlet weak var GenreField: UILabel! // ジャンル
    @IBOutlet weak var RestaurantNameField: UILabel! // レストラン名
    @IBOutlet weak var AddressField: UILabel! // 住所
    @IBOutlet weak var AccessField: UILabel! // 交通アクセス
    @IBOutlet weak var openField: UILabel! // 営業時間
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
