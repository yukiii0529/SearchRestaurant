//
//  ViewController.swift
//  SearchRestaurant
//
//  Created by 田中勇輝 on 2021/04/12.
//

import UIKit

struct Results:Codable {
    let results: [Result]
    
    struct Result: Codable {
        let shop: [Shop]
        
        struct Shop: Codable {
            let access:String
        }
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getRApi()
    }

    private func getRApi(){
        let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist" )
        let plist = NSDictionary(contentsOfFile: filePath!)
        let api = plist!["api"]!
        
        let url = NSURL(string: "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=\(api)&lat=34.67&lng=135.52&range=5&order=4&type=lite&format=json")

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
                print("aaa")
                if let items:Dictionary = json["results"] as? [String:Any] {
                    print("bbb")
                    if let item = items["shop"] as? [[String:Any]]{
                        
                    }
                }
            }catch{
                print("エラーが発生しました")
            }
        })
        task.resume() //実行
   }

}

