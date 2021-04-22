//
//  DetailResuaurantViewController.swift
//  SearchRestaurant
//  レストラン詳細画面
//
//  Created by 田中勇輝 on 2021/04/19.
//

import UIKit

class DetailRestaurantViewController: UIViewController {
    
    // レストラン名デザイン
    @IBOutlet weak var titleView: UIView!
    
    // レストラン一覧表示関連
    var resutaurantList : (
        id:String , // レストランID
        name:String , // レストラン名
        address:String , // 住所
        access:String , // 交通アクセス
        genre:[String: String] , // ジャンル
        middle_area:[String: String] , // 中エリアコード
        photo:[String: String] , // レストランの写真
        open:String , // 営業時間
        close:String , // 定休日
        catchs:String , // お店キャッチ
        budget:[String: String] , // 平均予算
        capacity:Int , // 総席数
        lat:Double , // 緯度
        lng:Double // 経度
    )! // レストラン情報が入った配列
    
    @IBOutlet weak var genreField: UILabel! // ジャンル＋中エリアコード
    @IBOutlet weak var restaurantNameField: UILabel! // レストラン名
    @IBOutlet weak var imageView: UIImageView! // レストラン画像
    @IBOutlet weak var catchField: UILabel! // お店キャッチ
    @IBOutlet weak var addressField: UILabel!// 住所
    @IBOutlet weak var accessField: UILabel! // 交通アクセス
    @IBOutlet weak var openField: UILabel! // 営業日
    @IBOutlet weak var closeField: UILabel! // 定休日
    @IBOutlet weak var averageField: UILabel! // 平均予算
    @IBOutlet weak var capacityField: UILabel! // 総席数
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - レストラン詳細項目表示
        /**
         詳細画面に値を入れる
         */
        genreField.text = resutaurantList.genre["name"]! + " | " + resutaurantList.middle_area["name"]! // ジャンル・中エリアコード
        genreField.adjustsFontSizeToFitWidth = true // 枠内に文字を収める
        restaurantNameField.text = resutaurantList.name // レストラン名
        restaurantNameField.adjustsFontSizeToFitWidth = true // 枠内に文字を収める
        let url = URL(string: resutaurantList.photo["l"]!)
        if let image_data = try? Data(contentsOf: url!){
            imageView.image = UIImage(data: image_data) // レストラン画像
        }
        catchField.text = resutaurantList.catchs // お店キャッチ
        addressField.text = resutaurantList.address // 住所
        accessField.text = resutaurantList.access // 交通アクセス
        openField.text = resutaurantList.open // 営業日
        closeField.text = "定休日：" + resutaurantList.close // 定休日
        averageField.text = "平均予算：" + resutaurantList.budget["average"]! // 平均予算
        capacityField.text = "総席数：" + String(resutaurantList.capacity) + "名" // 総席数
        
        let bottomBorder1 = CALayer()
        bottomBorder1.frame = CGRect(x: 0, y: titleView.frame.height, width: titleView.frame.width - 40, height:1.0)
        bottomBorder1.backgroundColor = UIColor(red: 255/255, green: 190/255, blue: 61/255, alpha: 0.66).cgColor
        titleView.layer.addSublayer(bottomBorder1)
    }
    
    // MARK: - Appleのマップを開く
    // マップで開くボタンをタップした時
    @IBAction func openMapButtonTapped(_ sender: Any) {
        let daddr = NSString(format: "%f,%f", resutaurantList.lat, resutaurantList.lng)
        let urlString = "http://maps.apple.com/?daddr=\(daddr)&dirflg=w"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
