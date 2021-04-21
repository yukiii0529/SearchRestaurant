//
//  ChooseGenreViewController.swift
//  SearchRestaurant
//
//  Created by 田中勇輝 on 2021/04/17.
//

import UIKit

class ChooseGenreViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    // 一覧表示するジャンル
    var genre: Array<String> = []
    
    var selectGenre: Array<String> = [] // 選択したジャンルを格納する配列
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(selectGenre)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        
        // ２回目以降のジャンル再選択の際に既に選択済みのジャンルにチェックマークをつける
        for d in 0..<self.genre.count {
            for didGenre in self.selectGenre {
                if didGenre == genre[d] {
                    self.tableView.selectRow(at: IndexPath(row: d, section: 0), animated: false, scrollPosition: .none)
                    let cell = tableView.cellForRow(at: IndexPath(row: d, section: 0))
                    cell?.accessoryType = .checkmark // チェックマークを入れる
                }
            }
        }
    }
    
    // 表示するテーブルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genre.count
    }
    
    // ジャンルを選択した時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark // チェックマークを入れる
        self.selectGenre.append(genre[indexPath.row]) // 選択したジャンルを格納する配列（selectGrnre）に入れる
        print(selectGenre)
    }

    // ジャンルを選択解除した時
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        cell?.accessoryType = .none // チェックマークを外す
        for i in 0..<self.selectGenre.count { // 選択したジャンルを格納する配列（selectGrnre）から外す
            if self.selectGenre[i] == genre[indexPath.row] {
                self.selectGenre.remove(at: i)
                break
            }
        }
    }
    
    // ジャンルを一覧表示する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        // テーブルに値を入れる
        cell?.textLabel?.text = genre[indexPath.row]
        cell?.selectionStyle = .none
        return cell!
    }
    
    // ジャンル選択完了ボタンがタップされた時
    @IBAction func chooseButtonTapped(_ sender: Any) {
        let nav = self.navigationController
        // 一つ前のViewControllerを取得する
        let viewController = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! ViewController
        // 一つ前の画面に選択したジャンル情報を渡す
        viewController.selectGenre = self.selectGenre
        self.navigationController?.popViewController(animated: true)
    }
}
