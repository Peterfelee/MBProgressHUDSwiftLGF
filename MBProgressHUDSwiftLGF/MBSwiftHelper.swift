//
//  MBSwiftHelper.swift
//  MBProgressHUDSwiftLGF
//
//  Created by peterlee on 2019/10/18.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

public class MBSwiftHelper: NSObject {
    
    private var hud:MBProgressHudSwift?
    
    static let share:MBSwiftHelper = MBSwiftHelper()
    
    private var action:(()->())?
    
    public func show(InView view:UIView?,withAnimated animated:Bool = true)
    {
        hud?.removeFromSuperview()
        hud = nil
        if hud == nil
        {
            if view == nil
            {
                hud = MBProgressHudSwift()
            }
            else
            {
                hud = MBProgressHudSwift(view: view!)
            }
        }
        hud?.mode = .Indeterminate
        if view == nil
        {
            UIApplication.shared.keyWindow?.addSubview(hud!)
        }
        else
        {
            view?.subviews.forEach({ (view) in
                if view.isKind(of: MBProgressHudSwift.classForCoder())
                {
                    view.removeFromSuperview()
                }
            })
            view!.addSubview(hud!)
        }
        hud?.show(animated: animated)
    }
    public func show(InView view:UIView?)
    {
        show(InView: view, withAnimated: true)
    }
    
    public func show(){
        show(InView: nil)
    }
    
    public func autoShow(InView view:UIView?,withAnimated animated:Bool = true,delayTime delay:Float = 1)
    {
        show(InView: view, withAnimated: animated)
        hidden(delayTime: delay)
    }
    
    public func autoShow(){
        autoShow(InView: nil)
    }
    
    public func hidden(withAnimated animated:Bool = true,delayTime delay:Float = 1)
    {
        if hud != nil {
            hud!.hide(animated: animated, afterDelay: TimeInterval(delay))
        }
    }
    
    public func hidden(){
        hidden(withAnimated: true, delayTime: 1)
    }
    
    
    //其他样式
    public func showTitle(titleString title:String?){
        if title == nil || title!.isEmpty{
            show()
        }
        else
        {
            show()
            hud?.mode = .Text
            hud?.label.text = title
        }
    }
    
    public func showMessage(Message msg:String?){
        if msg == nil || msg!.isEmpty{
            show()
        }
        else
        {
            show()
            hud?.mode = .Text
            hud?.detailLabel.text = msg
        }
    }
    
    ///必须含有按钮事件
    public func showActionButton(buttonTitle title:String?,buttonImage image:UIImage?,buttonAction action:(()->())?){
        show()
        hud?.mode = .Text
        hud?.button.setTitle(title, for: .normal)
        hud?.button.setImage(image, for: .normal)
        self.action = action
        hud?.button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    
    
}

extension MBSwiftHelper{
    
    @objc private func buttonClick(){
        if action != nil
        {
            action!()
        }
    }
}
