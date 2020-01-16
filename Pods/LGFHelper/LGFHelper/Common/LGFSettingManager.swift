//
//  LGFSettingManager.swift
//  LGFHelper
//
//  Created by peterlee on 2019/12/16.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

/**保存数据和获取数据的一个管理类*/
public class LGFSettingManager: NSObject {
    
    private var sharedUserDefault:UserDefaults!
    
    private init(para:Int)
    {
        super.init()
        /**构建保存用的userDefault*/
        if let temp:UserDefaults = UserDefaults(suiteName: "group.\(Bundle.main.bundleIdentifier ?? "LGF")")
        {
            sharedUserDefault = temp
        }
        else
        {
            sharedUserDefault = UserDefaults.standard
        }
    }
    
    public static let share:LGFSettingManager = LGFSettingManager(para: 0)
    
    /**保存bool值*/
    public func setBool(value:Bool,key:String)
    {
        setObjectForKey(value, key)
    }
    
    /**获取bool值*/
    public func getBool(key:String,defaultValue:Bool = false) -> Bool
    {
        return objectForKey(key, defaultValue) as? Bool ?? defaultValue
    }
    
    
    /**保存String值*/
    public func setString(value:String,key:String)
    {
        setObjectForKey(value, key)
    }
    
    /**获取String值*/
    public func getString(key:String,defaultValue:String = "") -> String
    {
        return objectForKey(key, defaultValue) as? String ?? defaultValue
    }
    
    
    /**保存Integer值*/
    public func setInteger(value:NSInteger,key:String)
    {
        setObjectForKey(value, key)
    }
    
    /**获取Integer值*/
    public func getInteger(key:String,defaultValue:NSInteger = 0) -> NSInteger
    {
        return objectForKey(key, defaultValue) as? NSInteger ?? defaultValue
    }
    
    
    /**保存Double值*/
    public func setDouble(value:Double,key:String)
    {
        setObjectForKey(value, key)
    }
    
    /**获取Double值*/
    public func getDouble(key:String,defaultValue:Double = 0.0) -> Double
    {
        return objectForKey(key, defaultValue) as? Double ?? defaultValue
    }
    
    
    /**保存Float值*/
    public func setFloat(value:Float,key:String)
    {
        setObjectForKey(value, key)
    }
    
    /**获取Float值*/
    public func getFloat(key:String,defaultValue:Float = 0.0) -> Float
    {
        return objectForKey(key, defaultValue) as? Float ?? defaultValue
    }
}

extension LGFSettingManager{
    private func setObjectForKey(_ object:Any,_ key:String)
    {
        sharedUserDefault.setValue(object, forKey: key)
        sharedUserDefault.synchronize()
    }
    
    private func objectForKey(_ key:String,_ defaultValue:Any) -> Any
    {
        return sharedUserDefault.object(forKey: key) ?? defaultValue
    }
}
