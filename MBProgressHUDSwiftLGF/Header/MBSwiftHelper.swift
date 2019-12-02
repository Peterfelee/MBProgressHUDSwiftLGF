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
    public  static let share:MBSwiftHelper = MBSwiftHelper()
    private var action:(()->())?
    
    /**显示在view？ view为nil的时候显示在keywindow 需要手动隐藏 hidden*/
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if view == nil
            {
                UIApplication.shared.keyWindow?.addSubview(self.hud!)
            }
            else
            {
                view?.subviews.forEach({ (view) in
                    if view.isKind(of: MBProgressHudSwift.classForCoder())
                    {
                        view.removeFromSuperview()
                    }
                })
                view!.addSubview(self.hud!)
            }
            self.hud?.show(animated: animated)

        }
    }
    
    /**显示在view？ view为nil的时候显示在keywindow 需要手动隐藏 hidden*/
    public func show(InView view:UIView?)
    {
        show(InView: view, withAnimated: true)
    }
    /**显示在keywindow 需要手动隐藏 hidden*/
    public func show(){
        show(InView: nil)
    }
    
    /**显示在keywindow 单行的文字 需要手动隐藏 */
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
    
    /**显示在keywindow 多行的文字 需要手动隐藏 */
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
    
     
    
    
     /**显示在keywindow 按钮样式可增加点击事件 需要手动隐藏 */
    public func showActionButton(buttonTitle title:String?,buttonImage image:UIImage?,buttonAction action:(()->())?){
        show()
        hud?.mode = .Text
        hud?.button.setTitle(title, for: .normal)
        hud?.button.setImage(image, for: .normal)
        self.action = action
        hud?.button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    
    
///hidden
    
      /**手动隐藏*/
      public func hidden(withAnimated animated:Bool = true,delayTime delay:Float = 1)
      {
          if hud != nil {
              hud!.hide(animated: animated, afterDelay: TimeInterval(delay))
          }
      }
      
      /**手动隐藏*/
      public func hidden(){
          hidden(withAnimated: true, delayTime: 1)
      }
 
////autoshow
    /**显示在view？ view为nil的时候显示在keywindow 不需要手动隐藏*/
    public func autoShow(InView view:UIView?,withAnimated animated:Bool = true,delayTime delay:Float = 1)
    {
        show(InView: view, withAnimated: animated)
        hidden(delayTime: delay)
    }
    
    /**显示在view？ view为nil的时候显示在keywindow 不需要手动隐藏*/
    public func autoShow(){
        autoShow(InView: nil)
    }
    
    /**显示在keywindow 单行的文字 不需要手动隐藏 */
    public func autoShowTitle(titleString title:String?){
        if title == nil || title!.isEmpty{
            autoShow()
        }
        else
        {
            autoShow()
            hud?.mode = .Text
            hud?.label.text = title
        }
    }
    
    /**显示在keywindow 多行的文字 不需要手动隐藏 */
    public func autoShowMessage(Message msg:String?){
        if msg == nil || msg!.isEmpty{
            autoShow()
        }
        else
        {
            autoShow()
            hud?.mode = .Text
            hud?.detailLabel.text = msg
        }
    }
    
     /**显示在keywindow 按钮样式可增加点击事件 不需要手动隐藏 */
    public func autoShowActionButton(buttonTitle title:String?,buttonImage image:UIImage?,buttonAction action:(()->())?){
        autoShow()
        hud?.mode = .Text
        hud?.button.setTitle(title, for: .normal)
        hud?.button.setImage(image, for: .normal)
        self.action = action
        hud?.button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    
}

extension MBSwiftHelper{
    
    @objc private func buttonClick(){
        hud?.hide(animated: true, afterDelay: 0)
        if action != nil
        {
            action!()
        }
    }
}
