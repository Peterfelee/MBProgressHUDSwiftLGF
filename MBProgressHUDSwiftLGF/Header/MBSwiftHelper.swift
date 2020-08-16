//
//  MBSwiftHelper.swift
//  MBProgressHudSwiftLGFLGF
//
//  Created by peterlee on 2019/10/18.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

public class MBSwiftHelper: NSObject {
    
    private var hud:MBProgressHudSwiftLGF?
    public  static let share:MBSwiftHelper = MBSwiftHelper(para: 0)
    private var action:(()->())?
    
    private init(para:Int) {
        super.init()
    }
    
    /**显示在view？ view为nil的时候显示在keywindow 需要手动隐藏 hidden  ,backgroundColor  背景色 contentColor显示文字或按钮的背景色*/
    public func show(InView view:UIView?,withAnimated animated:Bool = true,backgroundColor:UIColor ,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6),completion:(()->())?)
    {
        hud?.removeFromSuperview()
        hud = nil
        if hud == nil
        {
            if view == nil
            {
                hud = MBProgressHudSwiftLGF()
            }
            else
            {
                hud = MBProgressHudSwiftLGF(view: view!)
            }
        }
        hud?.mode = .Indeterminate
        hud?.backgroundColor = backgroundColor
        hud?.bezelView.color = contentColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if view == nil
            {
                UIApplication.shared.keyWindow?.addSubview(self.hud!)
            }
            else
            {
                view?.subviews.forEach({ (view) in
                    if view.isKind(of: MBProgressHudSwiftLGF.classForCoder())
                    {
                        view.removeFromSuperview()
                    }
                })
                view!.addSubview(self.hud!)
            }
            self.hud?.show(animated: animated)
            if completion != nil {completion!()}
        }
    }
    
    /**显示在view？ view为nil的时候显示在keywindow 需要手动隐藏 hidden*/
    public func show(InView view:UIView?,backgroundColor:UIColor = .clear,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6))
    {
        show(InView: view, withAnimated: true,backgroundColor: backgroundColor,contentColor: contentColor,completion:nil)
    }
    
    /**显示在keywindow 需要手动隐藏 hidden，默认是白色背景的菊花转*/
      public func show(backgroundColor:UIColor = .white,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6)){
             show(InView: nil,backgroundColor: backgroundColor,contentColor: contentColor)
         }
    /**显示在keywindow 单行的文字 需要手动隐藏 */
    public func showTitle(titleString title:String?,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6)){
        if title == nil || title!.isEmpty{
            show(contentColor: contentColor)
        }
        else
        {
            show(contentColor: contentColor)
            hud?.mode = .Text
            hud?.label.text = title
        }
    }
    
    /**显示在keywindow 多行的文字 需要手动隐藏 */
    public func showMessage(Message msg:String?,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6)){
        if msg == nil || msg!.isEmpty{
            show(contentColor: contentColor)
        }
        else
        {
            show(contentColor: contentColor)
            hud?.mode = .Text
            hud?.detailLabel.text = msg
        }
    }
    
     
    
    
     /**显示在keywindow 按钮样式可增加点击事件 需要手动隐藏 */
    public func showActionButton(buttonTitle title:String?,buttonImage image:UIImage?,buttonAction action:(()->())?,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6)){
        show(contentColor: contentColor)
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
        if let view:UIView = UIApplication.shared.keyWindow, let temp:MBProgressHudSwiftLGF = MBProgressHudSwiftLGF.Hud(forView: view)
        {
            temp.hide(animated: animated, afterDelay: TimeInterval(delay))
        }
    }
      
      /**手动隐藏*/
      public func hidden(){
          hidden(withAnimated: true, delayTime: 1)
      }
 
////autoshow
    /**显示在view？ view为nil的时候显示在keywindow 不需要手动隐藏*/
    public func autoShow(InView view:UIView?,withAnimated animated:Bool = true,backgroundColor:UIColor = .clear,delayTime delay:Float = 1,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6))
    {
        show(InView: view, withAnimated: animated,backgroundColor: backgroundColor,contentColor: contentColor,completion: {[weak self] in
            self?.hidden(delayTime: delay)
        })
        
    }
    
    /**显示在view？ view为nil的时候显示在keywindow 不需要手动隐藏*/
    public func autoShow(contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6)){
        autoShow(InView: nil,contentColor: contentColor)
    }
    
    /**显示在keywindow 单行的文字 不需要手动隐藏 */
    public func autoShowTitle(titleString title:String?,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6)){
        if title == nil || title!.isEmpty{
            autoShow(contentColor: contentColor)
        }
        else
        {
            autoShow(contentColor: contentColor)
            hud?.mode = .Text
            hud?.label.text = title
        }
    }
    
    /**显示在keywindow 多行的文字 不需要手动隐藏 */
    public func autoShowMessage(Message msg:String?,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6)){
        if msg == nil || msg!.isEmpty{
            autoShow(contentColor: contentColor)
        }
        else
        {
            autoShow(contentColor: contentColor)
            hud?.mode = .Text
            hud?.detailLabel.text = msg
        }
    }
    
     /**显示在keywindow 按钮样式可增加点击事件 不需要手动隐藏 */
    public func autoShowActionButton(buttonTitle title:String?,buttonImage image:UIImage?,buttonAction action:(()->())?,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6)){
        autoShow(contentColor: contentColor)
        hud?.mode = .Text
        hud?.button.setTitle(title, for: .normal)
        hud?.button.setImage(image, for: .normal)
        self.action = action
        hud?.button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    
    /**显示在view？ view为nil的时候显示在keywindow 不需要手动隐藏,默认是白色背景的菊花转*/
    public func autoShow(backgroundColor:UIColor = .white,contentColor:UIColor = UIColor(white: 0.8, alpha: 0.6))
        {
            autoShow(InView: nil,backgroundColor: backgroundColor,contentColor: contentColor)
       }
       
}

extension MBSwiftHelper{
    
    @objc private func buttonClick(){
        if action != nil
        {
            action!()
            hud?.hide(animated: true, afterDelay: 0)
        }
    }
}
