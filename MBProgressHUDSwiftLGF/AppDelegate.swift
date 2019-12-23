//
//  AppDelegate.swift
//  MBProgressHUDSwiftLGF
//
//  Created by peterlee on 2019/10/11.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit
import LGFHelper


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window:UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.color(hexValue: 0xffffff)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }


}

