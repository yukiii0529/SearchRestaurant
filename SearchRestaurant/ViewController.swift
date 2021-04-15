//
//  ViewController.swift
//  SearchRestaurant
//
//  Created by 田中勇輝 on 2021/04/12.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager =  CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 現在地を取得します
       if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // Do any additional setup after loading the view.
    }

    /**
     現在位置取得
     */
    var count = 0 // 一度だけ取得
    var latitude: Double = 0.0 // 緯度
    var longitude: Double = 0.0 // 経度
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if count == 0 {
                locationManager.stopUpdatingLocation()
                // 緯度と経度取得
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                print("Location:\(location.coordinate.latitude), \(location.coordinate.longitude)")
                count += 1
            }
        }
        
        // レストラン検索
        getRApi()
    }

    /**
        レストラン検索機能
     */
    var resutaurantList :[(id:String , name:String , access:String , genre:[String: String] , photo:[String: String])] = [] // レストラン全体情報を入れる配列
    var photo: [String: String] = [:] // レストランの写真を入れる入れる
    private func getRApi(){
        // Keys.plistより個別api情報取得
        let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)
        let api = plist!["api"]!
        
        // JSON検索URL作成
        let url = NSURL(string: "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=\(api)&lat=\(latitude)&lng=\(longitude)&range=5&order=4&type=lite&format=json")

        let urlRequest = URLRequest(url: url! as URL)
        // JSONを取得
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration,delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: urlRequest,
        completionHandler: {
            (data, response, error) -> Void in //dataにJSONが入る
            //JSON解析の処理
            // 解析し配列に格納
            do{
                let json:Dictionary = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                // results情報取得
                if let items:Dictionary = json["results"] as? [String:Any] {
                    // レストラン情報取得
                    if let item = items["shop"] as? [[String:Any]]{
                        for shop in item {
                            guard let id = shop["id"] as? String else{ // ID取得
                                    continue
                            }
                            guard let name = shop["name"] as? String else{ // 店舗名取得
                                    continue
                            }
                            guard let access = shop["access"] as? String else{ // 交通アクセス取得
                                    continue
                            }
                            guard let genre = shop["genre"] as? [String: String] else{ // ジャンル取得
                                    continue
                            }
                           // print(shop["photo"])
                            guard let photos = shop["photo"] as? [String: Any] else{ // 店舗写真取得
                                    continue
                            }
                            self.photo = photos["pc"] as! [String : String]
                            let resutaurant = (id,name,access,genre,self.photo) // 店舗情報まとめる
                            self.resutaurantList.append(resutaurant) // 店舗情報を配列に入れる
                            print(resutaurant)
                        }
                    }
                }
            }catch{
                print("エラーが発生しました")
            }
        })
        task.resume() //実行
   }

}

