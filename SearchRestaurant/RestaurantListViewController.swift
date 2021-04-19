//
//  RestaurantListViewController.swift
//  SearchRestaurant
//
//  Created by 田中勇輝 on 2021/04/19.
//

import UIKit

class RestaurantListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! // レストラン一覧を表示するテーブル
    var resutaurantList :[(id:String , name:String , access:String , genre:[String: String] , photo:[String: String])] = [] // レストラン全体情報を入れる配列
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    // 配列数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resutaurantList.count
    }

    // セル作成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : RestaurantListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantListTableViewCell
        cell.GenreField?.text = resutaurantList[indexPath.row].genre["name"]
        let url = URL(string: resutaurantList[indexPath.row].photo["l"]!)
        if let image_data = try? Data(contentsOf: url!){
            cell.ImageView?.image = UIImage(data: image_data)
        }
        cell.RestaurantNameField?.text = resutaurantList[indexPath.row].name
        cell.AccessField?.text = resutaurantList[indexPath.row].access
        cell.AccessField?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 200
    }
}
