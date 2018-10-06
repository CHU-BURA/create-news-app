//
//  News2ViewController.swift
//  NewsApp
//
//  Created by Sho Nozaki on 2018/09/30.
//  Copyright © 2018年 sho.nozaki. All rights reserved.
//

import UIKit

class News2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, XMLParserDelegate {
    
    // TableViewの定義・初期化 【TODO: StoryBoard上から適応したい】
    var tableView: UITableView = UITableView()
    
    // 下スクロールによる更新 【TODO: StoryBoard上から適応したい】
    var refreshControl: UIRefreshControl!
    
    // 取得するRSS(xml)表示用 【TODO: StoryBoard上から適応したい】
    var webView: UIWebView = UIWebView()
    
    // 進むボタン【TODO: StoryBoard上から適応したい】
    var goButton: UIButton!
    // 戻るボタン【TODO: StoryBoard上から適応したい】
    var backButton: UIButton!
    // キャンセルボタン【TODO: StoryBoard上から適応したい】
    var cancelButton: UIButton!
    
    // 読み込み 【TODO: ライブラリとして導入するよう変更したい】
    var dotsView: DotsLoader! = DotsLoader()
    
    // ニュースXML
    var parser = XMLParser()
    // ニュース情報
    var totalBox = NSMutableArray()
    // タグ解析群
    var elements = NSMutableDictionary()
    // タグ
    var element = String()
    // タイトル
    var titleString = NSMutableString()
    // リンク
    var linkString = NSMutableString()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景の生成
        let imageView = UIImageView()
        imageView.frame = self.view.bounds // 画面表示を全体に適用
        imageView.image = UIImage(named: "2.jpg") // 背景画像の設定 【TODO: 独自の画像に変更する】
        self.view.addSubview(imageView)
        
        // 下スクロール更新
        refreshControl = UIRefreshControl() // 初期化
        refreshControl.tintColor = UIColor.white // ローディングの色
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged) // リフレッシュ時のアクション追加
        
        // TableViewの生成
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 54.0) // TableViewのサイズ・位置設定
        tableView.backgroundColor = UIColor.clear
        tableView.addSubview(refreshControl) // UIRefreshControlの適応
        self.view.addSubview(tableView)
        
        // WebViewの生成
        webView.frame = tableView.frame // WebViewサイズをTableViewに合わせる
        webView.delegate = self
        webView.scalesPageToFit = true // コンテンツサイズを調節する
        webView.contentMode = .scaleAspectFill //　画面サイズへの表示を調節
        self.view.addSubview(webView)
        webView.isHidden = true // 初期は非表示
        
        // 進むボタン
        goButton = UIButton()
        goButton.frame = CGRect(x: self.view.frame.size.width - 50, y: self.view.frame.size.height - 128, width: 50, height: 50) // 表示位置・サイズの設定
        goButton.setImage(UIImage(named: "go.png"), for: .normal) // 画像の設定
        goButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        self.view.addSubview(goButton)
        
        // 戻るボタン
        backButton = UIButton()
        backButton.frame = CGRect(x: 10, y: self.view.frame.size.height - 128, width: 50, height: 50)
        backButton.setImage(UIImage(named: "back.png"), for: .normal) // 画像の設定
        backButton.addTarget(self, action: #selector(backPage), for: .touchUpInside)
        self.view.addSubview(backButton)
        
        // キャンセルボタン
        cancelButton = UIButton()
        cancelButton.frame = CGRect(x: 10, y: 80, width: 50, height: 50)
        cancelButton.setImage(UIImage(named: "cancel.png"), for: .normal) // 画像の設定
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(cancelButton)
        
        // 各ボタン非表示
        goButton.isHidden = true
        backButton.isHidden = true
        cancelButton.isHidden = true
        
        // 読み込み
        dotsView.frame = CGRect(x: 0, y: self.view.frame.height/3, width: self.view.frame.width, height: 100)
        dotsView.dotsCount = 5 //　点の数を設定
        dotsView.dotsRadius = 10 // 大きさ
        self.view.addSubview(dotsView)
        dotsView.isHidden = true
        
        // ニュースXMLの解析(パース処理)
        let url: String = "https://news.yahoo.co.jp/pickup/computer/rss.xml" // 対象ニュースのRSS(URL)
        let urlToSend: URL = URL(string: url)! // URL型へ変換
        parser = XMLParser(contentsOf: urlToSend)! // パース型へ変換
        totalBox = [] // 初期化
        parser.delegate = self
        parser.parse() // XMLのパース処理を開始する
        tableView.reloadData() // TableViewの更新
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     セル高さの設定
     - return: セルの高さ
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    /*
     セクション数の設定
     - return: セクション数
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     セクション内のセル数の設定
     - return: 取得したRSS数
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalBox.count
    }
    
    /*
     セルの表示内容の設定
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        cell.selectionStyle = .none // セル選択時のハイライトを消す
        
        cell.backgroundColor = UIColor.clear // 背景色の設定
        // titleの設定
        cell.textLabel?.text = (totalBox[indexPath.row] as AnyObject).value(forKey: "title") as? String // 取得したタイトルの設定
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0) // フォントサイズ
        cell.textLabel?.textColor = UIColor.white // 文字色
        // linkの設定
        cell.detailTextLabel?.text = (totalBox[indexPath.row] as AnyObject).value(forKey: "link") as? String // 取得したlinkの設定
        cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 9.0)
        cell.detailTextLabel?.textColor = UIColor.white
        return cell
    }
    
    /*
     セル押下時の処理
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // WebViewの表示
        print(totalBox[indexPath.row])
        let linkURL = (totalBox[indexPath.row] as AnyObject).value(forKey: "link") as? String
        let urlStr = linkURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url: URL = URL(string: urlStr!)! // URL型へ変換
        let urlRequest = URLRequest(url: url) // リクエスト
        self.webView.loadRequest(urlRequest) // URLの読み込み
    }
    
    /*
     WebView読み込み時の処理
     */
    func webViewDidStartLoad(_ webView: UIWebView) {
        // 読み込みのアニメーションを開始する
        dotsView.isHidden = false
        dotsView.startAnimating()
    }
    
    /*
     WebView読み込み後の処理
     */
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // 読み込みのアニメーションを終了する
        dotsView.isHidden = true
        dotsView.stopAnimating()
        // WebView、各種ボタンの非表示を解除する
        webView.isHidden = false
        goButton.isHidden = false
        backButton.isHidden = false
        cancelButton.isHidden = false
    }
    
    /*
     [XML]開始タグの解析
     - 開始タグを見つけたときの処理
     */
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        element = elementName // 解析したタグを一時格納
        if element == "item" {
            // 初期化
            elements = NSMutableDictionary()
            elements = [:]
            titleString = NSMutableString()
            titleString = ""
            linkString = NSMutableString()
            linkString = ""
        }
    }
    
    /*
     [XML]開始タグ・終了タグ間の解析
     */
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if element == "title" {
            titleString.append(string) // titleタグの値設定
        } else if element == "link" {
            linkString.append(string) // linkタグの値設定
        }
    }
    
    /*
     [XML]終了タグの解析
     - 終了タグを見つけたときの処理
     */
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // 取得するXMLのタグを保存する
        if elementName == "item" {
            if titleString != "" {
                // タイトルの取得
                elements.setObject(titleString, forKey: "title" as NSCopying)
            }
            if linkString != "" {
                // リンクの取得
                elements.setObject(linkString, forKey: "link" as NSCopying)
            }
            // 保存する
            totalBox.add(elements)
        }
    }
    
    
    /*
     リフレッシュ(下スクロール更新)
     */
    @objc func refresh() {
        // リフレッシュ動作による遅延処理
        perform(#selector(delay), with: nil, afterDelay: 2.0) // 2秒後にdelay()を呼ぶ
    }
    
    /*
     XML解析(パース処理)
     */
    @objc func delay() {
        // ニュースXMLの解析(パース処理)
        let url: String = "https://news.yahoo.co.jp/pickup/computer/rss.xml" // 対象ニュースのRSS(URL)
        let urlToSend: URL = URL(string: url)! // URL型へ変換
        parser = XMLParser(contentsOf: urlToSend)! // パース型へ変換
        totalBox = [] // 初期化
        parser.delegate = self
        parser.parse() // XMLのパース処理を開始する
        tableView.reloadData() // TableViewの更新
        
        // リフレッシュ処理を終了させる
        refreshControl.endRefreshing()
    }
    
    /*
     進む
     - WebViewを1ページ進める
     */
    @objc func nextPage() {
        webView.goForward()
    }
    
    /*
     戻る
     - WebViewを1ページ戻す
     */
    @objc func backPage() {
        webView.goBack()
    }
    
    /*
     キャンセル
     - WebViewを閉じる(隠す)
     */
    @objc func cancel() {
        webView.isHidden = true
        goButton.isHidden = true
        backButton.isHidden = true
        cancelButton.isHidden = true
    }
}
