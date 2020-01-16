//
//  LGFCategory.swift
//  LGFHelper
//
//  Created by peterlee on 2019/12/16.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

extension UIImage{
    
    /**绘制纯色图片*/
    public class func drawImage(color:UIColor = .white,size:CGSize = CGSize(width: 1, height: 1)) -> UIImage
    {
        var newSize:CGSize = CGSize(width: 1, height: 1)
        if min(size.width, size.height) > 1
        {
            newSize = size
        }
        UIGraphicsBeginImageContext(newSize)
        color.set()
        UIRectFill(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    /**绘制渐变的image colors 渐变色数组 diection渐变色方向 true水平 false 垂直  size一定不能小5*/
   public class func drawGrandientImage(colors:[CGColor],direction:Bool = true ,size:CGSize = CGSize(width: 5, height: 5)) -> UIImage
    {
        var newSize:CGSize = CGSize(width: 5, height: 5)
        if min(size.width, size.height) > 5
        {
            newSize = size
        }
        UIGraphicsBeginImageContext(newSize)
        let context = UIGraphicsGetCurrentContext()
        let location:[CGFloat] = [0,1]
        let grandient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: location)
        let start = direction ? CGPoint(x: 0, y: newSize.height/2):CGPoint(x: newSize.width/2, y: 0)
        let end = direction ? CGPoint(x: newSize.width, y: newSize.height/2):CGPoint(x: newSize.width/2, y: newSize.height)
        context?.drawLinearGradient(grandient!, start: start, end: end, options: [CGGradientDrawingOptions.drawsBeforeStartLocation,CGGradientDrawingOptions.drawsAfterEndLocation])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    
   public func fixOriention() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        draw(at: .zero)
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return temp
    }
    
    
   public func cropImage(frame:CGRect,angle:NSInteger = 0) -> UIImage {
        var cropImage:UIImage? = nil
        let drawPoint:CGPoint = .zero
        UIGraphicsBeginImageContextWithOptions(frame.size, true, self.scale)
        let context = UIGraphicsGetCurrentContext()
        if angle != 0 {
            let imageView = UIImageView(image: self)
            imageView.layer.minificationFilter = CALayerContentsFilter(rawValue: "nearest")
            imageView.layer.magnificationFilter = CALayerContentsFilter(rawValue: "nearest")
            imageView.transform = CGAffineTransform.init(rotationAngle: CGFloat(angle) * CGFloat(Double.pi/180.0))
            let rotatedRect = imageView.bounds.applying(imageView.transform)
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: rotatedRect.size.width, height: rotatedRect.size.height))
            containerView.addSubview(imageView)
            imageView.center = containerView.center
            context?.translateBy(x: -frame.origin.x, y: -frame.origin.y)
            containerView.layer.render(in: context!)
        }else{
            context?.translateBy(x: -frame.origin.x, y: -frame.origin.y)
            self.draw(at:drawPoint)
        }
        
        cropImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cropImage ?? UIImage()
        
    }
    
    /**保存c图片 默认地址为documents下的images拼接图片名字 如果传path需要是完整的路径*/
    public func save(path:String?,imageName:String?) -> String?
    {
        if path != nil
        {
            do {
                try self.pngData()?.write(to: URL(string: path!)!)
                return path!
            }catch{
                return nil
            }
        }
        else if imageName != nil
        {
            //拼接路劲
            if let imagePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            {
                do{
                    var path = imagePath.appending("/images")
                    if FileManager.default.fileExists(atPath: path) == false
                    {
                       try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                    }
                    path = path.appending("/\(imageName!).png")
                    try self.pngData()?.write(to: URL(fileURLWithPath: path))
                    return "/images/\(imageName!).png"
                }
                catch{
                    return nil
                }
            }
            
            return nil
        }
        else
        {
            return nil
        }
    }
}



extension UIView{
    /**截取普通的view的页面为图片*/
    public func snapViewToImage(frame:CGRect) -> UIImage?
    {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


extension UIScrollView{
    
    /**截取UIscrollView以及其子类的页面为图片，一般为长图*/
    public func snapScrollViewToImage(rect:CGRect) -> UIImage?
    {
        
        let saveFrame = frame
        let saveContentOffset = contentOffset
        frame = CGRect(x: rect.origin.x - contentInset.top - contentInset.bottom, y: rect.origin.y, width: rect.width, height: rect.height)
        contentOffset = .zero
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        frame = saveFrame
        contentOffset = saveContentOffset
        return image
    }
}


extension UIColor{
    
    private class func colorComponentFrom(string:String,start:Int,length:Int) -> CGFloat
    {
        let substring = string.substring(with: Range(NSMakeRange(start, length), in: string)!)
        let fullhex = length == 2 ? substring : String(format: "%@%@", substring,substring)
        
        var result:UInt64 = 0
        Scanner(string: fullhex).scanHexInt64(&result)
        return CGFloat(result)/255.0
    }
    
    /**通过hexstring来创建uicolor alphaValue可选，设置的话就会生效  */
    public class func color(hexString:String,alphaValue:CGFloat?) -> UIColor
    {
        let colorString = hexString.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "0x", with: "").uppercased()
        var alpha:CGFloat = 1.0, red:CGFloat = 0 , blue:CGFloat = 0, green:CGFloat = 0
        switch colorString.count {
        case 3://RGB
            red = colorComponentFrom(string: colorString, start: 0, length: 1)
            green = colorComponentFrom(string: colorString, start: 1, length: 1)
            blue = colorComponentFrom(string: colorString, start: 2, length: 1)
        case 4://ARGB
            alpha = colorComponentFrom(string: colorString, start: 0, length: 1)
            red = colorComponentFrom(string: colorString, start: 1, length: 1)
            green = colorComponentFrom(string: colorString, start: 2, length: 1)
            blue = colorComponentFrom(string: colorString, start: 3, length: 1)
        case 6://RRGGBB
            red = colorComponentFrom(string: colorString, start: 0, length: 2)
            green = colorComponentFrom(string: colorString, start: 2, length: 2)
            blue = colorComponentFrom(string: colorString, start: 4, length: 2)
        case 8://AARRGGBB
            alpha = colorComponentFrom(string: colorString, start: 0, length: 2)
            red = colorComponentFrom(string: colorString, start: 2, length: 2)
            green = colorComponentFrom(string: colorString, start: 4, length: 2)
            blue = colorComponentFrom(string: colorString, start: 6, length: 2)
        default:
            assertionFailure(String(format: "Invalid color value Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", colorString))
        }
        if alphaValue != nil
        {
            alpha = alphaValue!
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**通过hexstring来创建uicolor  */
    public class func color(hexString:String) -> UIColor
    {
        return color(hexString: hexString,alphaValue: nil)
    }
    
    /**通过hexValue来创建uicolor alphaValue可选，设置的话就会生效  */
    public class func color(hexValue:NSInteger,alphaValue:CGFloat?) -> UIColor
    {
       return UIColor(red: CGFloat((hexValue & 0xFF0000) >> 16)/255.0,
                green: CGFloat((hexValue & 0xFF00) >> 8)/255.0,
                blue: CGFloat((hexValue & 0xFF))/255.0,
                alpha: alphaValue != nil ? alphaValue! : CGFloat((hexValue & 0xFF00) >> 24)/255.0)
    }
    
    /**通过hexValue来创建uicolor */
    public class func color(hexValue:NSInteger) -> UIColor
    {
       return color(hexValue: hexValue, alphaValue: nil)
    }
    
    
}

