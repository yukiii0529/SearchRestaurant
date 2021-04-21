//
//  ViewController.swift
//  SearchRestaurant
//
//  Created by 田中勇輝 on 2021/04/12.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
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
    var genre: [String: String] = [:] //  ジャンルリスト
    var genreTableList: Array<String> =  [] // ジャンル選択画面に渡すジャンル名を入れた配列
    var selectGenre: Array<String> = [] // 選択したジャンルを格納する配列
    @IBOutlet weak var displayGenre: UILabel! // ジャンル表示
    var genreList = "" // ジャンルに関するクエリ作成用変数
    
    @IBOutlet weak var restaurantNameField: UITextField! // レストラン名検索フィールド
    
    /**
     検索ボタン
     */
    @IBOutlet weak var searchButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ジャンル情報取得
        getGenreContents()
        
        // 初めに検索ボタンを押せなくする
        searchButton.isEnabled = false
        // 検索ボタンデザイン変更（押せないのをわかりやすくする為）
        searchButton.setTitleColor(UIColor.white, for: .normal)
        searchButton.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
        
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
        
        // ジャンル選択から戻ってきた際に戻るボタンを隠す
        self.navigationItem.hidesBackButton = true
    }
    
    // MARK: - ジャンル関連（選択したジャンルを画面に表示）
    // 選択したジャンルを画面に表示、クエリ作成変数に格納
    override func viewDidAppear(_ animated: Bool) {
        displayGenre.text = "指定なし"
        // ジャンル関連
        if selectGenre.count != 0 {
            if selectGenre.count == 1 { // ジャンル選択が１つだけ
                displayGenre.text! = selectGenre[0] // // 選択したジャンル名を画面表示する為の変数に入れる（displayGenre）
                genreList = genre[selectGenre[0]]! // クエリ作成変数に入れる（genreList）
            } else {
                for i in 0..<selectGenre.count {
                    if i == 0 {
                        displayGenre.text! = selectGenre[i] // // 選択したジャンル名を画面表示する為の変数に入れる（displayGenre）
                        genreList += genre[selectGenre[i]]! // クエリ作成変数に入れる（genreList）
                    } else {
                        displayGenre.text! += " , " + selectGenre[i] // 選択したジャンル名を画面表示する為の変数に入れ、","で区切る（displayGenre）
                        genreList += "," + genre[selectGenre[i]]! // クエリ作成変数に入れ、ジャンル間を","で区切る
                    }
                }
            }
        }
    }

    // MARK: - 現在位置取得
    var count = 0 // 一度だけ取得するためのカウント変数
    var latitude: Double = 0.0 // 緯度
    var longitude: Double = 0.0 // 経度
    // 位置取得ボタンがタップされた時
    @IBAction func getNowLocationButtonTapped(_ sender: Any) {
        count = 0
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    // 位置取得
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
                count += 1 // カウント＋１して次に取得しないようにする
            }
        }
    }
    
    // MARK: - 検索距離指定
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
        selectDistance.text = "\(chooseDistance[pickerView.selectedRow(inComponent: 0)])" // 選択した距離を画面に表示
        searchButton.isEnabled = true // 検索ボタンを有効にする
        // ボタンデザイン変更
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.backgroundColor = UIColor(red: 255/255, green: 190/255, blue: 61/255, alpha: 0.66)
    }
    
    // MARK: - ジャンル選択
    // ジャンル情報取得
    func getGenreContents() {
        // Keys.plistより個別api情報取得
        let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)
        let api = plist!["api"]!
        
        let url = NSURL(string: "https://webservice.recruit.co.jp/hotpepper/genre/v1/?key=\(api)&format=json")
        
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
                    // ジャンル情報取得
                    if let item = items["genre"] as? [[String:Any]]{
                        for genre in item {
                            guard let name = genre["name"] as? String else{ // ジャンル名
                                    continue
                            }
                            guard let code = genre["code"] as? String else{ // ジャンルコード
                                    continue
                            }
                            self.genre.updateValue(code, forKey: name)
                            self.genreTableList.append(name)
                        }
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        })
        task.resume() //実行
    }

    // 選択画面に遷移
    @IBAction func chooseGenreButtonTapped(_ sender: Any) {
        let chooseGenreViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChooseGenreViewController") as! ChooseGenreViewController
        chooseGenreViewController.selectGenre = self.selectGenre // ジャンル情報を遷移画面へ渡す
        chooseGenreViewController.genre = self.genreTableList
        self.navigationController?.pushViewController(chooseGenreViewController, animated: true)
    }
    // MARK: - レストラン検索
    // 検索ボタンがタップされた時
    @IBAction func searchRestaurantButtonTapped(_ sender: Any) {
        // JSON取得
        getRApi()
    }
    // レストラン全体情報を入れる配列
    var resutaurantList :[(
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
    )] = []
    // 検索した情報を格納する配列
    var searchList = [
        "distance": "",
        "genre": "",
        "keyword": ""
    ]
    var photo: [String: String] = [:] // レストランの写真を入れる配列
    private func getRApi(){
        // 再度検索した時の対処として検索結果を入れる配列を空にする
        resutaurantList = []
        // Keys.plistより個別api情報取得
        let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)
        let api = plist!["api"]!
        
        // JSON検索URL作成
        let radius = distance[selectDistance.text!] // 半径距離
        searchList["distance"] = selectDistance.text!
        
        var url = NSURL(string: "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=\(api)&lat=\(latitude)&lng=\(longitude)&range=\(radius ?? "5")&format=json")
        
        // ジャンル関連
        if selectGenre.count != 0 {
            // URLにジャンルクエリ追加
            var components = URLComponents(url: url! as URL, resolvingAgainstBaseURL: true)
            components?.queryItems! += [URLQueryItem(name: "genre", value: genreList)]
            url = components?.url as NSURL?
            searchList["genre"] = displayGenre.text
        }
        
        // レストラン名関連
        if restaurantNameField.text != "" { // 検索キーワードが入力されている場合
            // URLにジャンルクエリ追加
            var components = URLComponents(url: url! as URL, resolvingAgainstBaseURL: true)
            components?.queryItems! += [URLQueryItem(name: "keyword", value: restaurantNameField.text)]
            url = components?.url as NSURL?
            searchList["keyword"] = restaurantNameField.text
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
                            guard let address = shop["address"] as? String else{ // 住所
                                    continue
                            }
                            guard let access = shop["access"] as? String else{ // 交通アクセス取得
                                    continue
                            }
                            guard let genre = shop["genre"] as? [String: String] else{ // ジャンル取得
                                    continue
                            }
                            guard let middle_area = shop["middle_area"] as? [String: String] else{ // 中エリアコード
                                    continue
                            }
                            guard let photos = shop["photo"] as? [String: Any] else{ // 店舗写真取得
                                    continue
                            }
                            self.photo = photos["pc"] as! [String : String]
                            guard let open = shop["open"] as? String else{ // 営業時間
                                    continue
                            }
                            guard let close = shop["close"] as? String else{ // 定休日
                                    continue
                            }
                            guard let catchs = shop["catch"] as? String else{ // お店キャッチ
                                    continue
                            }
                            guard let budget = shop["budget"] as? [String: String] else{ // 平均予算
                                    continue
                            }
                            guard let capacity = shop["capacity"] as? Int else{ // 総席数
                                    continue
                            }
                            guard let lat = shop["lat"] as? Double else{ // 緯度
                                    continue
                            }
                            guard let lng = shop["lng"] as? Double else{ // 経度
                                    continue
                            }
                            let resutaurant = (id,name,address,access,genre,middle_area,self.photo,open,close,catchs,budget,capacity,lat,lng) // 店舗情報まとめる
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
    
    // MARK: - レストラン一覧画面遷移
    func listScreenTransition(){
        let restaurantListViewController = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantListViewController") as! RestaurantListViewController
        // 検索結果情報を遷移画面へ渡す
        restaurantListViewController.resutaurantList = self.resutaurantList
        // 検索した事柄を遷移画面へ渡す
        restaurantListViewController.searchList = self.searchList
        self.navigationController?.pushViewController(restaurantListViewController, animated: true)
    }

}

