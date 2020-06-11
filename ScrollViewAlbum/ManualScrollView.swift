//
//  ManualScrollView.swift
//  ScrollViewAlbum
//
//  Created by Monph on 2020/6/11.
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
    var pageControl = UIPageControl(frame: .zero)
    weak var delegate:ManualScrollViewDelegate?
    private var imageCount = 0
    private var imageViewList = [UIImageView]()
    /*
     1、获取图片资源的时候、创建每个UIImageView,不够三张、通过逻辑补齐、实现三张复用的现象
     2、imageView.tag 作为每张图片的索引、
     3、未滑动时、第一张记录的是最后一张图片的index
     4、滑动后修改所有imageView的tag和图片、currentIndex的取值根据第一个元素
     5、每次滚动后、contentOffset偏移量为 一个视图宽度、所以当前显示的currentIndex取数组中的第一个元素值。
     */
    var imageNameArr:[String] = [String](){
        didSet{
            imageCount = imageNameArr.count
            let s_width = frame.size.width
            let s_height = frame.size.height
            if imageCount < 3 {
                while imageNameArr.count<3 {
                    imageNameArr.append(imageNameArr.first ?? "")
                }
            }
            for i in 0..<imageNameArr.count {
                let imageView = UIImageView()
                let imageName:String = imageNameArr[i]
                imageView.frame = CGRect(x: CGFloat(i) * self.frame.size.width, y: 0, width: s_width, height: s_height)
                scrollView.addSubview(imageView)
                //tag作为当前图片索引、随时可变
                imageView.tag  =  (i - 1 + imageCount)%imageNameArr.count
                // count==2 时特殊处理
                if imageCount == 2 && i == 2 {
                    imageView.tag = -1
                }
                self.setImageToView(imageView: imageView, imageName: imageName)
                imageViewList.append(imageView)
            }
            pageControl.numberOfPages = imageCount
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
//        pageControl.backgroundColor = .white
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
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
        if (offset.x == 2 * self.frame.size.width)  {flag = 1}
        else if (offset.x == 0)                     {flag = -1 }
        else                                        {return }
        //修改所有imageView的tag、1位置的currentIndex随着改变
        imageViewList.forEach { (tempImgView:UIImageView) in
            //计算每个ImagView的轮询索引
            let index = tempImgView.tag+flag+imageCount
            tempImgView.tag = index%imageCount
            let imageName:String = imageNameArr[tempImgView.tag]
            self.setImageToView(imageView: tempImgView, imageName: imageName)
            print("imageView.tag = %d",tempImgView.tag)
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
