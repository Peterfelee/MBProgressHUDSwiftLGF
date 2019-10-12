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
        
        let hud = MBProgressHudSwift.showHud(addedToView: view, withAnimated: true)
//        let hud = MBProgressHUD.showAdded(to: view, animated: true)
//        hud.mode = .text
//        hud.label.text = "test modeel"
//        hud.hide(animated: true, afterDelay: 5)
        switch btn.tag {
        case 1:
            hud.mode = .Text
            hud.label.text = btn.currentTitle
        case 2:
            hud.mode = .Text
            hud.detailLabel.text = btn.currentTitle
        case 3:
            hud.mode = .Indeterminate
        default:
           hud.mode = .Text
           hud.button.setTitle(btn.currentTitle, for: .normal)
        }
        
        hud.hide(animated: true, afterDelay: 14)
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
