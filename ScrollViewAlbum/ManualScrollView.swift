//
//  ManualScrollView.swift
//  ScrollViewAlbum
//
//  Created by  on 2020/6/11.
//  Copyright © 2020 Holo. All rights reserved.
//

import UIKit

/// 图片来源
enum SourceType {
    case Local
    case Network
}

protocol ManualScrollViewDelegate  : NSObjectProtocol {
    func didSelectImageAction(index:Int) -> Void
}

/// 手动滚动视图、无定时器
class ManualScrollView: UIView,UIScrollViewDelegate {
    var imageType:SourceType = .Local
    var currentIndex:Int = 0
    var scrollView = UIScrollView(frame: .zero)
    public var pageControl = UIPageControl(frame: .zero)
    weak var delegate:ManualScrollViewDelegate?
    private var imageCount = 0
    private var imageViewList = [UIImageView]()
    /*
     1、获取图片资源的时候、创建三张复用的UIImageView,不够三张、通过逻辑补齐
     2、imageView.tag 作为每张图片的索引、
     3、未滑动时、imageViewList[0]记录的是0
     4、滑动后修改复用的三张imageView的tag和图片、
     5、每次滚动后、scrollView.contentOffset设置为偏移一个视图宽度、所以currentIndex的取值为imageViewList[1]
     6、因为属性isPagingEnabled = true、按页翻动、所以offset.x是视图的整数倍，0 或者 2 * width
     */
    var imageNameArr:[String] = [String](){
        didSet{
            imageCount = imageNameArr.count
            let s_width = frame.size.width
            let s_height = frame.size.height
            //不够三张、补齐三张
            if imageCount < 3 {
                while imageNameArr.count < 3 {
                    imageNameArr.append(imageNameArr.first ?? "")
                }
            }
            for i in 0..<3 {
                let imageView = UIImageView()
                let imageName:String = imageNameArr[i]
                imageView.frame = CGRect(x: CGFloat(i) * self.frame.size.width, y: 0, width: s_width, height: s_height)
                scrollView.addSubview(imageView)
                //tag作为当前图片索引、随时可变
                imageView.tag  =  i % imageCount
                // count==2 时特殊处理、使其变为第一张的标记
                if imageCount == 2 && i == 2 {imageView.tag = 0}
                self.setImageToView(imageView: imageView, imageName: imageName)
                imageViewList.append(imageView)
            }
            pageControl.numberOfPages = imageCount
            //初始化tag值、默认使其右滑了一次、便于理解了
            self.reuseImages()
        }
    }

//MARK: private test button
    var leftBtn = UIButton(type: .custom)
    var rightBtn = UIButton(type: .custom)
    var isTestHidden:Bool = true{
        didSet{
            leftBtn.isHidden = isTestHidden
            rightBtn.isHidden = isTestHidden
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(scrollView)
        self.addSubview(pageControl)
        let s_width = frame.size.width
        let s_height = frame.size.height

        scrollView.frame = CGRect(x: 0, y: 0, width: s_width, height: s_height)
        scrollView.isPagingEnabled = true
        scrollView.delegate  = self
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: 3 * s_width, height: s_height)


        pageControl.frame = CGRect(x: 50, y: s_height - 50, width: s_width - 100, height: 30)
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .red
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)

        self.addSubview(leftBtn)
        self.addSubview(rightBtn)
        leftBtn.frame = CGRect(x: 0, y: self.frame.size.height/2.0-30, width: 60, height: 60)
        leftBtn.setTitle("Left", for: .normal)
        leftBtn.setTitleColor(.cyan, for: .normal)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        leftBtn.tag = 100000
        leftBtn.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)

        rightBtn.frame = CGRect(x: self.frame.size.width-60, y: self.frame.size.height/2.0-30, width: 60, height: 60)
        rightBtn.setTitle("Right", for: .normal)
        rightBtn.setTitleColor(.cyan, for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        rightBtn.tag = 100001
        rightBtn.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)

    }

    @objc func buttonAction(sender:UIButton){
        let index = sender.tag
        if index == 100000 {
            scrollView.setContentOffset(.zero, animated: true)
        }else{
            scrollView.setContentOffset(CGPoint(x: 2 * self.frame.size.width, y: 0), animated: true)
        }
    }

    @objc func pageControlChanged(){
        var offset = scrollView.contentOffset
        //左
        if (pageControl.currentPage == imageViewList[2].tag ){
            offset.x = 2 * self.frame.size.width
        }//右
        else if (pageControl.currentPage == imageViewList[0].tag){
            offset.x = 0
        }else{

        }
        scrollView.setContentOffset(offset, animated: true)
        if self.delegate != nil {
            self.delegate?.didSelectImageAction(index: pageControl.currentPage)
        }

    }


    func reuseImages(){
        var flag = 0
        let offset:CGPoint = scrollView.contentOffset
        //往左滑动、
        if (offset.x == 2 * self.frame.size.width)  {flag = 1}
        //往右滑动
        else if (offset.x == 0)                     {flag = -1 }
        //滑动失败
        else                                        {return }
        //修改三张 imageView的tag、1位置的currentIndex表示当前index
        imageViewList.forEach { (tempImgView:UIImageView) in
            //计算每个ImagView的轮询索引
            let index = tempImgView.tag+flag+imageCount
            tempImgView.tag = index%imageCount
            let imageName:String = imageNameArr[tempImgView.tag]
            self.setImageToView(imageView: tempImgView, imageName: imageName)
        }
        scrollView.contentOffset = CGPoint(x: self.frame.size.width, y: 0)
        pageControl.currentPage = imageViewList[1].tag
        print("currentIndex = %d",imageViewList[1].tag)
    }

    private func setImageToView(imageView:UIImageView,imageName:String){
        switch imageType {
        case .Network:
            let imgUrl = URL(string: imageName)
            imageView.kf.setImage(with:imgUrl)
            break
        default:
            imageView.image = UIImage(named: imageName)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.reuseImages()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.reuseImages()
    }



    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
