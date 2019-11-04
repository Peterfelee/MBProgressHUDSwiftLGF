//
//  ViewController.swift
//  MBProgressHUDSwiftLGF
//
//  Created by peterlee on 2019/10/11.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit
import SnapKit


class ViewController: UIViewController {
    let buttonTitles = ["重力","视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频视频","网页","弹窗"]
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        buttonTitles.enumerated().forEach { (offset: Int, element: String) in
            let temp = createButton(title: element)
            temp.tag = offset + 1
            view.addSubview(temp)

            temp.snp.makeConstraints { (make) in
                make.centerX.equalTo(view)
                make.size.equalTo(CGSize(width: 80, height: 50))
                make.top.equalTo((50 + 20) * offset + 50)
            }
        }
    }
    
}

extension ViewController{
    
    @objc private func testClick(btn:UIButton){
        switch btn.tag {
        case 1://展示一个单行的文字，过长的话自动省略显示
            MBSwiftHelper.share.showTitle(titleString: btn.currentTitle)
        case 2://展示一个多行的文字，过长的话自动换行
            MBSwiftHelper.share.showMessage(Message: btn.currentTitle)
        case 3://展示白底的菊花转 可以自动移除
            MBSwiftHelper.share.autoShow()
        default://展示带有title的按钮，事件即为点击的按钮事件
            MBSwiftHelper.share.showActionButton(buttonTitle: btn.currentTitle, buttonImage: nil, buttonAction: {
                
            })
        }
        
        MBSwiftHelper.share.hidden()

    }

    private func createButton(title:String) -> UIButton {
        let temp = UIButton(type: .custom)
        temp.setTitle(title, for: .normal)
        temp.setTitleColor(UIColor.blue.withAlphaComponent(0.4), for: .normal)
        temp.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
        temp.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        temp.layer.cornerRadius = 10
        temp.layer.masksToBounds = true
        temp.addTarget(self, action: #selector(testClick(btn:)), for: .touchUpInside)
        return temp
    }
}


extension UIButton{
    
    open override var isHighlighted: Bool
        {
        didSet{
            if isHighlighted {
                UIView.animate(withDuration: 0.2) {
                    self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                }
            }
            else
            {
                UIView.animate(withDuration: 0.2) {
                    self.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
}
