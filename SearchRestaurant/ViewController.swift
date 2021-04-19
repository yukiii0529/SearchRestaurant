//
//  ViewController.swift
//  SearchRestaurant
//
//  Created by 田中勇輝 on 2021/04/12.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var locationManager =  CLLocationManager()
    
    @IBOutlet weak var selectDistance: UITextField!
    // 半径距離指定用配列
    var pickerView: UIPickerView = UIPickerView()
    let chooseDistance = ["現在地より300m以内" , "現在地より500m以内" , "現在地より1km以内" , "現在地より2km以内" , "現在地より3km以内"]
    let distance = [
        "現在地より300m以内": "1",
        "現在地より500m以内": "2",
        "現在地より1km以内": "3",
        "現在地より2km以内": "4",
        "現在地より3km以内": "5",
    ]
    
    // ジャンル指定用配列
    let genre = [
        "居酒屋": "G001",
        "ダイニングバー・バル": "G002",
        "創作料理": "G003",
        "和食": "G004",
        "洋食": "G005",
        "イタリアン・フレンチ": "G006",
        "中華": "G007",
        "焼肉・ホルモン": "G008",
        "韓国料理": "G017",
        "アジア・エスニック料理": "G009",
        "各国料理": "G010",
        "カラオケ・パーティ": "G011",
        "バー・カクテル": "G012",
        "ラーメン": "G013",
        "お好み焼き・もんじゃ": "G016",
        "カフェ・スイーツ": "G014",
        "その他グルメ": "G015"
    ]
    var selectGenre: Array<String> = [] // 選択したジャンルを格納する配列
    @IBOutlet weak var displayGenre: UILabel! // ジャンル表示
    var genreList = "" // ジャンルに関するクエリ作成用変数
    
    @IBOutlet weak var restaurantNameField: UITextField! // レストラン名検索フィールド
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 現在地を取得します
       if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // ピッカー設定
        pickerView.delegate = self
        pickerView.dataSource = self
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        // インプットビュー設定
        selectDistance.inputView = pickerView
        selectDistance.inputAccessoryView = toolbar
        
        // ジャンル関連
        if selectGenre.count != 0 {
            if selectGenre.count == 1 { // ジャンル選択が１つだけ
                genreList = genre[selectGenre[0]]! // クエリ作成変数に入れる（genreList）
            } else {
                for i in 0..<selectGenre.count {
                    if i == 0 {
                        displayGenre.text! += selectGenre[i] // // 選択したジャンル名を画面表示する為の変数に入れる（displayGenre）
                        genreList += genre[selectGenre[i]]! // クエリ作成変数に入れる（genreList）
                    } else {
                        displayGenre.text! += "," + selectGenre[i] // 選択したジャンル名を画面表示する為の変数に入れ、","で区切る（displayGenre）
                        genreList += "," + genre[selectGenre[i]]! // クエリ作成変数に入れ、ジャンル間を","で区切る
                    }
                }
            }
        }
        
        self.navigationItem.hidesBackButton = true
    }

    /**
     現在位置取得
     */
    var count = 0 // 一度だけ取得
    var latitude: Double = 0.0 // 緯度
    var longitude: Double = 0.0 // 経度
    // 位置取得ボタンがタップされた時
    @IBAction func getNowLocationButtonTapped(_ sender: Any) {
        count = 0
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if count == 0 {
                locationManager.stopUpdatingLocation()
                // 緯度と経度取得
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                print("Location:\(location.coordinate.latitude), \(location.coordinate.longitude)")
                count += 1
            }
        }
    }
    
    /**
     半径距離選択
     */
    // ドラムロールの行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return chooseDistance.count
    }
    // ドラムロールの各タイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return chooseDistance[row]
    }
    // ドラムロールの列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // 決定ボタン押下
    @objc func done() {
        selectDistance.endEditing(true)
        selectDistance.text = "\(chooseDistance[pickerView.selectedRow(inComponent: 0)])"
    }
    
    /**
     ジャンル指定
     */
    @IBAction func chooseGenreButtonTapped(_ sender: Any) {
        let chooseGenreViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChooseGenreViewController") as! ChooseGenreViewController
        chooseGenreViewController.selectGenre = self.selectGenre
        self.navigationController?.pushViewController(chooseGenreViewController, animated: true)
    }
    
    /**
        レストラン検索機能
     */
    // 検索ボタンがタップされた時
    @IBAction func searchRestaurantButtonTapped(_ sender: Any) {
        getRApi()
    }
    var resutaurantList :[(id:String , name:String , access:String , genre:[String: String] , photo:[String: String])] = [] // レストラン全体情報を入れる配列
    var photo: [String: String] = [:] // レストランの写真を入れる配列
    private func getRApi(){
        // Keys.plistより個別api情報取得
        let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)
        let api = plist!["api"]!
        
        // JSON検索URL作成
        let radius = distance[selectDistance.text!] // 半径距離
        
        var url = URL(string: "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=\(api)&lat=\(latitude)&lng=\(longitude)&range=\(radius ?? "5")&type=lite&format=json")
        
        // ジャンル関連
        if selectGenre.count != 0 {
            // URLにジャンルクエリ追加
            var components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            components?.queryItems! += [URLQueryItem(name: "genre", value: genreList)]
            url = components?.url
        }
        
        // レストラン名関連
        if restaurantNameField.text != "" { // 検索キーワードが入力されている場合
            // URLにジャンルクエリ追加
            var components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            components?.queryItems! += [URLQueryItem(name: "keyword", value: restaurantNameField.text)]
            url = components?.url
        }

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
                        }
                    }
                    
                    self.listScreenTransition()
                }
            }catch{
                print("エラーが発生しました")
            }
        })
        task.resume() //実行
   }
    

    // レストラン一覧画面遷移
    func listScreenTransition(){
        let restaurantListViewController = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantListViewController") as! RestaurantListViewController
        restaurantListViewController.resutaurantList = self.resutaurantList
        self.navigationController?.pushViewController(restaurantListViewController, animated: true)
    }

}

