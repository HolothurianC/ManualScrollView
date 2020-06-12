//
//  ViewController.swift
//  ScrollViewAlbum
//
//  Created by  on 2020/6/10.
//  Copyright © 2020 Holo. All rights reserved.
//

import UIKit
let ScreenWidth = UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height

class ViewController: UIViewController,ManualScrollViewDelegate{
    lazy var imageNameArr: [String] = {
        var imageNames = [String]()
        for i in 1...7 {
            imageNames.append(String(format: "Image%d.jpg", i))
        }
        return imageNames
    }()

    var netNameArr:[String] = ["https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2239849064,780768630&fm=26&gp=0.jpg",
                               "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1183907347,3925693872&fm=26&gp=0.jpg",
                               "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1484979443,3511461428&fm=26&gp=0.jpg",
                               "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2403573783,98733114&fm=26&gp=0.jpg",
                               "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3907114015,1675853880&fm=26&gp=0.jpg"]

//MARK：封装View
    var manualScrollView = ManualScrollView(frame: CGRect(x: 0, y: 100, width:ScreenWidth, height: ScreenHeight - 100))
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.createMainView()

        manualScrollView.delegate = self
        manualScrollView.isTestHidden = false
#if  true
        //本地图片
        manualScrollView.imageType = .Local
        manualScrollView.imageNameArr = self.imageNameArr
#else
        //网络图片
        manualScrollView.imageType = .Network
        manualScrollView.imageNameArr = self.netNameArr
#endif

        view.addSubview(manualScrollView)

    }

//MARK : ManualScrollViewDelegate
    func didSelectImageAction(index: Int) {
        print("currentIndex:\(index)")
    }

}

