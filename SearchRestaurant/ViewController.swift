//
//  ViewController.swift
//  SearchRestaurant
//  レストラン検索画面
//
//  Created by 田中勇輝 on 2021/04/12.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    var locationManager =  CLLocationManager()
    
    // 検索するのがレストランかジャンルか把握するための変数(0:ジャンル検索、1:レストラン検索)
     var searchDetailFlg = 0
    
    // 選択した距離を表示する変数
    @IBOutlet weak var selectDistance: UITextField!
    
    /**
     半径指定
     */
    // ドロップダウンリスト作成
    var pickerView: UIPickerView = UIPickerView()
    // ドロップダウンリストに表示する内容を格納した配列
    let chooseDistance = ["現在地より300m以内" , "現在地より500m以内" , "現在地より1km以内" , "現在地より2km以内" , "現在地より3km以内"]
    // 指定した半径をURLに反映させるための情報を格納している配列（レストラン検索時に利用）
    let distance = [
        "現在地より300m以内": "1",
        "現在地より500m以内": "2",
        "現在地より1km以内": "3",
        "現在地より2km以内": "4",
        "現在地より3km以内": "5",
    ]
    
    /**
     ジャンル指定
     */
    var genre: [String: String] = [:] //  ジャンルリスト（レストラン検索時に利用）
    var genreTableList: Array<String> =  [] // ジャンル選択画面に渡すジャンル名を入れた配列
    var selectGenre: Array<String> = [] // 選択したジャンルを格納する配列
    @IBOutlet weak var displayGenre: UILabel! // ジャンル表示
    var genreList = "" // ジャンルに関するクエリ作成用変数
    
    /**
     レストラン検索（キーワード検索）
     */
    @IBOutlet weak var restaurantNameField: UITextField! // レストラン名検索フィールド
    
    /**
     検索ボタン
     */
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // ジャンル情報取得
        getGenreContents()
        
        // 初めに検索ボタンを押せなくする
        searchButton.isEnabled = false
        // 検索ボタンデザイン変更（押せないのをわかりやすくする為）
        searchButton.setTitleColor(UIColor.white, for: .normal)
        searchButton.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1.0)
        
        // 現在地を取得
       if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        /**
         ドロップダウンリスト関連
         */
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
    var count = 0 // 一度だけ取得するためのカウント変数(0:初めに取得,2:再取得)
    var latitude: Double = 0.0 // 緯度
    var longitude: Double = 0.0 // 経度
    // 位置取得ボタンがタップされた時
    @IBAction func getNowLocationButtonTapped(_ sender: Any) {
        count = 2 //
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    // 位置取得
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if count == 0 || count == 2{
                locationManager.stopUpdatingLocation()
                // 緯度と経度取得
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                print("Location:\(location.coordinate.latitude), \(location.coordinate.longitude)")
                
                // 取得完了ダイアログ表示
                if count == 2 {
                    // 内容作成
                    let alert: UIAlertController = UIAlertController(title: "現在地取得完了", message: "現在地の取得が完了しました。", preferredStyle:  UIAlertController.Style.alert)
                    // OKボタン作成
                    let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                        (action: UIAlertAction!) -> Void in
                        print("OK")
                    })
                    alert.addAction(defaultAction)
                    // アラートを表示
                    present(alert, animated: true, completion: nil)
                }
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
    
    // MARK: - ジャンル選択関連
    // ジャンル情報取得
    func getGenreContents() {
        searchDetailFlg = 0
        // ジャンル取得
        getRApi()
    }

    // 選択画面に遷移
    @IBAction func chooseGenreButtonTapped(_ sender: Any) {
        // 戻るボタンのタイトルを"戻る"に変更します。
        let backButton = UIBarButtonItem()
        backButton.title = "戻る"
        navigationItem.backBarButtonItem = backButton
        
        let chooseGenreViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChooseGenreViewController") as! ChooseGenreViewController
        chooseGenreViewController.selectGenre = self.selectGenre // ジャンル情報を遷移画面へ渡す
        chooseGenreViewController.genre = self.genreTableList
        // ジャンル選択画面に遷移
        self.navigationController?.pushViewController(chooseGenreViewController, animated: true)
    }
    // MARK: - レストラン検索
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
    // 検索ボタンがタップされた時
    @IBAction func searchRestaurantButtonTapped(_ sender: Any) {
        searchDetailFlg = 1
        // JSON取得
        getRApi()
    }
    
    // MARK: - レストラン一覧画面遷移
    func listScreenTransition(){
        // 戻るボタンのタイトルを"戻る"に変更します。
        let backButton = UIBarButtonItem()
        backButton.title = "戻る"
        navigationItem.backBarButtonItem = backButton
        
        let restaurantListViewController = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantListViewController") as! RestaurantListViewController
        // 検索結果情報を遷移画面へ渡す
        restaurantListViewController.resutaurantList = self.resutaurantList
        // 検索した事柄を遷移画面へ渡す
        restaurantListViewController.searchList = self.searchList
        // レストラン一覧画面へ遷移
        self.navigationController?.pushViewController(restaurantListViewController, animated: true)
    }
    
    // MARK: - 検索機能（ジャンル・レストラン両方）
    func getRApi() {
        // Keys.plistより個別api情報取得
        let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)
        let api = plist!["api"]!
        
        var url = NSURL(string: "")
        
        /**
         URL作成
         */
        if searchDetailFlg == 0 { // ジャンル検索の場合のURL
            url = NSURL(string: "https://webservice.recruit.co.jp/hotpepper/genre/v1/?key=\(api)&format=json")
        } else { // レストラン検索の場合のURL
            // 再度検索した時の対処として検索結果を入れる配列を空にする
            self.resutaurantList = []
            // JSON検索URL作成
            let radius = distance[selectDistance.text!] // 半径距離
            searchList["distance"] = selectDistance.text!
            
            url = NSURL(string: "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=\(api)&lat=\(latitude)&lng=\(longitude)&range=\(radius ?? "5")&format=json")
            
            // 緯度と経度が取得できていない場合、検索できない旨を伝えて設定から変更してもらえるようにする
            if latitude == 0.0 || longitude == 0.0 {
                // 内容作成
                let alert: UIAlertController = UIAlertController(title: "現在地取得失敗", message: "現在地の取得ができない為検索できません。設定→プライバシーをご確認ください。", preferredStyle:  UIAlertController.Style.alert)
                // OKボタン作成
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("OK")
                })
                alert.addAction(defaultAction)
                // アラートを表示
                present(alert, animated: true, completion: nil)
                
            }
            
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
        }
        let urlRequest = URLRequest(url: url! as URL)
        
        /**
         JSON取得
         */
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
                    /**
                     ジャンル検索の場合
                     */
                    if self.searchDetailFlg == 0 {
                        // ジャンル情報取得
                        if let item = items["genre"] as? [[String:Any]]{
                            // ジャンルの配列に格納
                            for genre in item {
                                guard let name = genre["name"] as? String else{ // ジャンル名
                                        continue
                                }
                                guard let code = genre["code"] as? String else{ // ジャンルコード
                                        continue
                                }
                                self.genre.updateValue(code, forKey: name) // レストラン検索時に利用する配列へ格納
                                self.genreTableList.append(name) // ジャンル選択画面に持っていく用の配列に格納
                            }
                        }
                        /**
                         レストラン検索の場合
                         */
                    } else {
                        // レストラン情報取得
                        if let item = items["shop"] as? [[String:Any]]{
                            // レストラン一覧配列に格納
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
                        self.listScreenTransition() // レストラン一覧画面に遷移
                    }
                }
            } catch {
                print("エラーが発生しました")
            }
        })
        task.resume() //実行
    }

}

