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
    
    /**显示在view？ view为nil的时候显示在keywindow 需要手动隐藏 hidden*/
    public func show(InView view:UIView?,withAnimated animated:Bool = true,backgroundColor:UIColor ,completion:(()->())?)
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
    public func show(InView view:UIView?,backgroundColor:UIColor = .clear)
    {
        show(InView: view, withAnimated: true,backgroundColor: backgroundColor,completion:nil)
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
    public func autoShow(InView view:UIView?,withAnimated animated:Bool = true,backgroundColor:UIColor = .clear,delayTime delay:Float = 1)
    {
        show(InView: view, withAnimated: animated,backgroundColor: backgroundColor,completion: {[weak self] in
            self?.hidden(delayTime: delay)
        })
        
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
    
    
    /**显示在view？ view为nil的时候显示在keywindow 不需要手动隐藏,默认是白色背景的菊花转*/
    public func autoShow(backgroundColor:UIColor = .white)
        {
           autoShow(InView: nil,backgroundColor: backgroundColor)
       }
    /**显示在keywindow 需要手动隐藏 hidden，默认是白色背景的菊花转*/
    public func show(backgroundColor:UIColor = .white){
           show(InView: nil,backgroundColor: backgroundColor)
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
