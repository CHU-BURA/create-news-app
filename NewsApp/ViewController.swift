//
//  ViewController.swift
//  NewsApp
//
//  Created by Sho Nozaki on 2018/09/29.
//  Copyright © 2018年 sho.nozaki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    /* 上部スクロールメニューバーの定義 */
    var pageMenu: CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 各メニュー画面の管理 TODO: もっとスマートなやり方がある[参考]https://qiita.com/fromage-blanc/items/4c358e1e57e298baad18
        var VCArray: [UIViewController] = [] // 各メニュー画面を格納する配列を作成
        let VC1: News1ViewController = News1ViewController() // 各メニュー画面とタイトルを設定し格納
        VC1.title = "TOP"
        VCArray.append(VC1)
        let VC2: News2ViewController = News2ViewController()
        VC2.title = "Yahoo!"
        VCArray.append(VC2)
        let VC3: News3ViewController = News3ViewController()
        VC3.title = "CNET"
        VCArray.append(VC3)
        let VC4: News4ViewController = News4ViewController()
        VC4.title = "グルメ"
        VCArray.append(VC4)
        let VC5: News5ViewController = News5ViewController()
        VC5.title = "コラム"
        VCArray.append(VC5)
        
        // ページメニューにオプションを追加する
        let params: [CAPSPageMenuOption] = [
            .menuItemWidth(4.3),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorPercentageHeight(0)
        ]
        
        // PageMenuの幅・高さを設定する
        pageMenu = CAPSPageMenu(viewControllers: VCArray, frame: CGRect(x: 0.0, y: 20.0, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: params)
        
        // PageMenuのViewを親のView(ViewController)に追加
        self.view.addSubview(pageMenu!.view)
        // PageMenuのViewをToolbarの後ろへ移動
        self.view.sendSubview(toBack: pageMenu!.view)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

