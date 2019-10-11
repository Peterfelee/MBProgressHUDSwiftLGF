//
//  MBProgressHudSwift.swift
//  MoviePlayer
//
//  Created by peterlee on 2019/10/10.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit

public enum MBProgressHudSwiftMode:NSInteger {
    
    case Indeterminate ///UIActivityIndicatorView.
    case Determinate /// A round, pie-chart like, progress view.
    case DeterminateHorizontalBar /// Horizontal progress bar.
    case AnnularDeterminate /// Ring-shaped progress view.
    case CustomView /// Shows a custom view.
    case Text /// Shows only labels.
}

public enum MBProgressHudSwiftAnimation:NSInteger {
    case Fade /// Opacity animation
    case Zoom /// Opacity + scale animation (zoom in when appearing zoom out when disappearing)
    case ZoomOut /// Opacity + scale animation (zoom out style)
    case ZoomIn /// Opacity + scale animation (zoom in style)
}

public enum MBProgressHudSwiftBackgroundStyle {
    case SolidColor  /// Solid color background
    case Blur /// UIVisualEffectView or UIToolbar.layer background view
}

@objc protocol MBProgressHudSwiftDelegate:NSObjectProtocol{
    @objc optional func hudWasHidden(hud:MBProgressHudSwift)
}

typealias MBProgressHudSwiftCompletionBlock = ()->()

public func MBAssertForMainThread(){
    assert(Thread.current.isMainThread, "MB needs access in main thread")

}


//MARK:public Instance method

extension MBProgressHudSwift{
    
   public func show(animated:Bool){
        MBAssertForMainThread()
        minShowTimer?.invalidate()
        useAnimation = animated
        hasFinished = false
        if graceTime > 0.0{
            let timer = Timer.init(timeInterval: graceTime, target: self, selector: #selector(handleGraceTimer(timer:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
            graceTimer = timer
        }
        else
        {
            showUsingAnimation(animated: useAnimation)
        }
        
    }
    
   public func hide(animated:Bool){
        MBAssertForMainThread()
        graceTimer?.invalidate()
        useAnimation = animated
        hasFinished = true
        if minShowTime > 0 && showStarted != nil{
            let interval = Date().timeIntervalSince(showStarted!)
            if interval < minShowTime{
                let timer = Timer.init(timeInterval: minShowTime - interval, target: self, selector: #selector(handleMinShowTimer(timer:)), userInfo: nil, repeats: false)
                RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
                minShowTimer = timer
            }
        }
        else
        {
            hideUsingAnimation(animated: useAnimation)
        }
        
        
    }
    
   public func hide(animated:Bool,afterDelay:TimeInterval){
        hideDelayTimer?.invalidate()
        let timer = Timer.init(timeInterval: afterDelay, target: self, selector: #selector(handleHideTimer(timer:)), userInfo: nil, repeats: false)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        hideDelayTimer = timer
    }
}



//MARK:public class method
extension MBProgressHudSwift{
    
    class  public func showHud(addedToView view:UIView,withAnimated animated:Bool) -> MBProgressHudSwift{
        let hud = MBProgressHudSwift(view: view)
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.show(animated: animated)
        return hud
    }
    
    
    class public func hideHud(forView view:UIView,withAnimated animated:Bool) -> Bool{
        if let hud = Hud(forView: view){
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated: animated)
            return true
        }
        return false
    }
    
    class public func Hud(forView view:UIView) -> MBProgressHudSwift?{
        for subview:UIView in view.subviews
        {
            if subview.isKind(of: self)
            {
                let hud:MBProgressHudSwift = subview as! MBProgressHudSwift
                if hud.hasFinished == false {
                    return hud
                }
            }
        }
        return nil
    }
}


public class MBProgressHudSwift: UIView {
    
    static let MBDefaultPadding:CGFloat = 4
    static let MBDefaultLabelFontSize:CGFloat = 16
    static let MBDefaultDetailsLabelFontSize:CGFloat = 12
    
   public var contentColor:UIColor = .white{
        didSet{
            if oldValue != self.contentColor {
                updateViewsForColor(color: self.contentColor)
            }
        }
    }
   public var removeFromSuperViewOnHide:Bool = false
    weak var delegate:MBProgressHudSwiftDelegate?
    var completionBlock:MBProgressHudSwiftCompletionBlock?
    
   public var graceTime:TimeInterval = 0.0
   public var minShowTime:TimeInterval = 0.0
   public var mode:MBProgressHudSwiftMode = .Indeterminate{
        didSet{
            if oldValue != self.mode {
                updateIndicators()
            }
        }
    }
   public var animationType:MBProgressHudSwiftAnimation = .Fade
   public var offset:CGPoint = .zero{
        didSet{
            if oldValue != self.offset
            {
                setNeedsUpdateConstraints()
            }
        }
    }
   public var margin:CGFloat = 20.0{
        didSet{
            if oldValue != self.margin {
                setNeedsUpdateConstraints()
            }
        }
    }
   public var minSize:CGSize = .zero{
        didSet{
            if oldValue != self.minSize {
                setNeedsUpdateConstraints()
            }
        }
    }
   public var squre:Bool = false{
        didSet{
            if oldValue != self.squre {
                setNeedsUpdateConstraints()
            }
        }
    }
   public var defaultMotionEffectsEnabled = true{
        didSet{
            if oldValue != self.defaultMotionEffectsEnabled
            {
                updateBezelMotionEffects()
            }
        }
    }
    @objc var progress:Float = 0.0//0-1
    {
        didSet{
            if oldValue != self.progress {
                let indicator = self.indicator
                if (indicator?.responds(to: #selector(setter:MBProgressHudSwift.progress)))!{
                    indicator?.setValue(self.progress, forKey: "progress")
                }
            }
        }
    }
   public var progressObject:Progress?{
        didSet{
            if oldValue != self.progressObject
            {
                setProgressDisplayLinkEnabled(enabled: true)
            }
        }
    }
   public var customView:UIView!{
        didSet{
            if oldValue != self.customView && self.mode == .CustomView
            {
                updateIndicators()
            }
        }
    }
    
   lazy private(set) var bezelView:MBBackgroundView = {
    let temp = MBBackgroundView(frame:.zero)
    temp.translatesAutoresizingMaskIntoConstraints = false
    temp.layer.cornerRadius = 5.0
    temp.alpha = 0
    
    return temp
    }()
    
    lazy private(set) var backgroundView:MBBackgroundView = {
        let temp = MBBackgroundView(frame: .zero)
        temp.style = .SolidColor
        temp.backgroundColor = .clear
        temp.autoresizingMask = [.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        temp.alpha = 0.0
        return temp
    }()
    
    lazy private(set) var label:UILabel = {
        let temp = UILabel()
        temp.adjustsFontSizeToFitWidth = false
        temp.textAlignment = .center
        temp.font = UIFont.boldSystemFont(ofSize:MBProgressHudSwift.MBDefaultLabelFontSize)
        temp.isOpaque = false
        temp.backgroundColor = .clear
        return temp
    }()
    
    lazy private(set) var detailLabel:UILabel = {
        let temp = UILabel()
        temp.adjustsFontSizeToFitWidth = false
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.font = UIFont.boldSystemFont(ofSize:MBProgressHudSwift.MBDefaultLabelFontSize)
        temp.isOpaque = false
        temp.backgroundColor = .clear
        return temp
    }()
    
    lazy private(set) var button:UIButton = {
        let temp = UIButton(type: .custom)
        temp.titleLabel?.textAlignment = .center
        temp.titleLabel?.font = UIFont.boldSystemFont(ofSize:MBProgressHudSwift.MBDefaultLabelFontSize)
        return temp
    }()

   public convenience init(view:UIView)
    {
        self.init(frame: view.bounds)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
   
     
     deinit {
         unregisterFromNotification()
     }
    
    private var opacity = 1.0
    private var hasFinished = false
    weak private var graceTimer:Timer?
    weak private var minShowTimer:Timer?
    weak private var hideDelayTimer:Timer?
    private var progressObjectDisplayLink:CADisplayLink?{
        willSet{
            if newValue != self.progressObjectDisplayLink
            {
                self.progressObjectDisplayLink?.invalidate()
                self.progressObjectDisplayLink = newValue
                self.progressObjectDisplayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            }
        }
    }
    private var useAnimation:Bool = false
    private var showStarted:Date?
    private var indicator:UIView?
    private var paddingConstraints:[NSLayoutConstraint]?
    private var bezelConstraints:[NSLayoutConstraint]?

    lazy private var topSpacer:UIView = {
        let temp = UIView()
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.isHidden = true
        return temp
    }()
    
    lazy private var bottomSpacer:UIView = {
        let temp = UIView()
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.isHidden = true
        return temp
    }()
    
    
    private func commonInit(){
        let  isLegacy = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0
        contentColor = isLegacy ? UIColor.white:UIColor(white: 0, alpha: 0.7)
        
        isOpaque = false
        backgroundColor = UIColor.clear
        alpha = 0
        autoresizingMask = [.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        layer.allowsGroupOpacity = false
        
        setupViews()
        updateIndicators()
        registerForNotification()
    }
    
    private func setupViews(){
        
        backgroundView.frame = self.bounds
        bezelView.frame = self.bounds
        addSubview(backgroundView)
        addSubview(bezelView)
        updateBezelMotionEffects()
        label.textColor = contentColor
        detailLabel.textColor = contentColor
        button.setTitleColor(contentColor, for: .normal)
        [label,detailLabel,button].forEach { (view) in
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998), for: .horizontal)
            view.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998), for: .vertical)
            bezelView.addSubview(view)
        }
        bezelView.addSubview(topSpacer)
        bezelView.addSubview(bottomSpacer)
    }
    
    private func updateIndicators(){
        let isActivityIndicator = indicator?.isKind(of: UIActivityIndicatorView.classForCoder())
        let isRoundIndicator = indicator?.isKind(of: MBRoundProgressView.classForCoder())
        
        switch mode {
        case .Indeterminate:
            if isActivityIndicator == false || isActivityIndicator == nil {
                indicator?.removeFromSuperview()
                if #available(iOS 13.0, *) {
                    indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorView.Style.medium)
                } else {
                    // Fallback on earlier versions
                    indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorView.Style.whiteLarge)
                }
                (indicator as! UIActivityIndicatorView).startAnimating()
                bezelView.addSubview(indicator!)
            }
        case .DeterminateHorizontalBar:
            indicator?.removeFromSuperview()
            indicator = MBBarProgressView()
            (indicator as! MBBarProgressView).progress = progress
            bezelView.addSubview(indicator!)
        case .Determinate,.AnnularDeterminate:
            if isRoundIndicator == false || isRoundIndicator == nil {
                indicator?.removeFromSuperview()
                indicator = MBRoundProgressView()
                (indicator as! MBRoundProgressView).progress = progress
                bezelView.addSubview(indicator!)
            }
            if mode == .AnnularDeterminate
            {
                (indicator as! MBRoundProgressView).isAnnular = true
            }
        case .CustomView:
            if customView != indicator
            {
                indicator?.removeFromSuperview()
                indicator = customView
                bezelView.addSubview(indicator!)
            }
        case .Text:
            indicator?.removeFromSuperview()
            indicator = nil
        }
        
        indicator?.translatesAutoresizingMaskIntoConstraints = false
        
        indicator?.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998), for: .horizontal)
        indicator?.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998), for: .vertical)
        updateViewsForColor(color: contentColor)
        setNeedsUpdateConstraints()
        
    }
    
    private func updateViewsForColor(color:UIColor){
        label.textColor = color
        detailLabel.textColor = color
        button.setTitleColor(color, for: .normal)
        
        if let temp:UIActivityIndicatorView = indicator as? UIActivityIndicatorView{
            let appearance : UIActivityIndicatorView = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHudSwift.classForCoder() as! UIAppearanceContainer.Type])
            if appearance.color == nil
            {
                temp.color = color
            }
        }
        else if let temp:MBRoundProgressView = indicator as? MBRoundProgressView{
            let appearance : MBRoundProgressView = MBRoundProgressView.appearance(whenContainedInInstancesOf: [MBProgressHudSwift.classForCoder() as! UIAppearanceContainer.Type])
            if appearance.progressTintColor == nil{
                temp.progressTintColor = color
            }
            if appearance.backgroundTintColor == nil
            {
                temp.backgroundTintColor = color.withAlphaComponent(0.1)
            }
        }
        else if let temp:MBBarProgressView = indicator as? MBBarProgressView{
            let appearance : MBBarProgressView = MBBarProgressView.appearance(whenContainedInInstancesOf: [MBProgressHudSwift.classForCoder() as! UIAppearanceContainer.Type])
            if appearance.progressColor == nil{
                temp.progressColor = color
            }
            if appearance.lineColor == nil {
                temp.lineColor = color
            }
        }else{
                indicator?.tintColor = color
        }
        
    }
    
    
    private func registerForNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChange(notify:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation , object: nil)
    }
    
    private func unregisterFromNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
  
    
    @objc private func handleGraceTimer(timer:Timer){
        if hasFinished == false
        {
            showUsingAnimation(animated: useAnimation)
        }
    }
    
    @objc private func handleMinShowTimer(timer:Timer){
        hideUsingAnimation(animated: useAnimation)
    }
    
    @objc private func handleHideTimer(timer:Timer){
        hide(animated: (timer.userInfo != nil))
    }
    
    private func showUsingAnimation(animated:Bool){
        bezelView.layer.removeAllAnimations()
        backgroundView.layer.removeAllAnimations()
        hideDelayTimer?.invalidate()
        showStarted = Date()
        alpha = 1.0
        
        setProgressDisplayLinkEnabled(enabled: true)
        if animated{
            animateIn(animatingIn: animated, withType: animationType, completion: nil)
        }
        else{
            bezelView.alpha = CGFloat(opacity)
            backgroundView.alpha = 1.0
        }
    }
    
    
    private func hideUsingAnimation(animated:Bool){
        if animated && showStarted != nil
        {
            showStarted = nil
            animateIn(animatingIn: false, withType: animationType) { (finish) in
                self.done()
            }
        }
        else
        {
           showStarted = nil
            bezelView.alpha = 0
            backgroundView.alpha = 1
            done()
        }
    }
    
    private func animateIn(animatingIn:Bool,withType type:MBProgressHudSwiftAnimation,completion:((Bool)->())?){
        
        var tempType = type
        if tempType == .Zoom
        {
            tempType = animatingIn ? MBProgressHudSwiftAnimation.ZoomIn : MBProgressHudSwiftAnimation.ZoomOut
        }
        
        let small:CGAffineTransform = .init(scaleX: 0.5, y: 0.5)
        let large:CGAffineTransform = .init(scaleX: 1.5, y: 1.5)
        
        let temp = bezelView
        if animatingIn && temp.alpha == 0 && type == .ZoomIn{
            temp.transform = small
        }
        else if animatingIn && temp.alpha == 0 && type == .ZoomOut{
            temp.transform = large
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
            if animatingIn{
                temp.transform = .identity
            }
            else if animatingIn && type == .ZoomIn{
                temp.transform = large
            }
            else if animatingIn && type == .ZoomOut{
                temp.transform = small
            }
            
            temp.alpha = CGFloat(animatingIn ? self.opacity:0)
            self.backgroundView.alpha = animatingIn ? 1.0 : 0
        }, completion: completion)
    }
    
    private func done(){
        hideDelayTimer?.invalidate()
        setProgressDisplayLinkEnabled(enabled: false)
        
        if hasFinished {
            alpha = 0
            if removeFromSuperViewOnHide{
                removeFromSuperview()
            }
        }
        if let tempCompletionBlock = completionBlock{
            tempCompletionBlock()
        }
        
        if let tempDelegate = delegate{
            if tempDelegate.responds(to: #selector(MBProgressHudSwiftDelegate.hudWasHidden(hud:)))
            {
                tempDelegate.perform(#selector(MBProgressHudSwiftDelegate.hudWasHidden(hud:)))
            }
        }
    }
    
    
    private func setProgressDisplayLinkEnabled(enabled:Bool){
        if enabled && progressObject != nil{
            if progressObjectDisplayLink == nil
            {
                progressObjectDisplayLink = CADisplayLink(target: self, selector: #selector(updateProgressFromProgressObject))
            }
        }
        else
        {
            progressObjectDisplayLink = nil
        }
    }
    
    @objc private func updateProgressFromProgressObject(){
        progress = Float(progressObject!.fractionCompleted)
    }
    
    
    @objc private func statusBarOrientationDidChange(notify:NSNotification){
        if superview == nil
        {
            return
        }
        frame = superview!.bounds
    }
 
}


//MARK: constraints
extension MBProgressHudSwift{
    
    override public func didMoveToSuperview() {
        if superview != nil
        {
            frame = superview!.bounds
        }
    }
    
    override public func updateConstraints() {
        var bezelConstraints:[NSLayoutConstraint] = [NSLayoutConstraint]()
        let metrics = ["margin":margin]
        var subviews = [topSpacer,label,detailLabel,button,bottomSpacer]
        if indicator != nil {
            subviews.insert(indicator!, at: 1)
        }
        
        
        removeConstraints(self.constraints)
        topSpacer.removeConstraints(topSpacer.constraints)
        bottomSpacer.removeConstraints(bottomSpacer.constraints)
        if self.bezelConstraints != nil {
            bezelView.removeConstraints(self.bezelConstraints!)
            self.bezelConstraints = nil
        }
        
        var centeringConstraints:[NSLayoutConstraint] = [NSLayoutConstraint]()
        centeringConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: offset.x))
        centeringConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: offset.y))
        applyPriority(priority: UILayoutPriority(rawValue: 998), toConstraints: centeringConstraints)
        addConstraints(centeringConstraints)
        
        
        var sideConstraints:[NSLayoutConstraint] = [NSLayoutConstraint]()
        sideConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[bezelView]-(>=margin)-|", options: .init(rawValue: 0), metrics: metrics, views: ["bezelView":bezelView]))
        
        sideConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=margin)-[bezelView]-(>=margin)-|", options: .init(rawValue: 0), metrics: metrics, views: ["bezelView":bezelView]))
        
        applyPriority(priority: UILayoutPriority(rawValue: 999), toConstraints: sideConstraints)
        addConstraints(sideConstraints)
        
        if minSize != .zero
        {
            var minSizeConstraints:[NSLayoutConstraint] = [NSLayoutConstraint]()
            minSizeConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: minSize.width))
            minSizeConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: minSize.height))
            applyPriority(priority: UILayoutPriority(rawValue: 997), toConstraints: minSizeConstraints)
            addConstraints(minSizeConstraints)
        }
        
        if squre{
            let square = NSLayoutConstraint(item: bezelView, attribute: .height, relatedBy: .equal, toItem: bezelView, attribute: .width, multiplier: 1.0, constant: 0)
            square.priority = UILayoutPriority(rawValue: 997)
            bezelConstraints.append(square)
        }
        
        topSpacer.addConstraint(NSLayoutConstraint(item: topSpacer, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: margin))
        bottomSpacer.addConstraint(NSLayoutConstraint(item: bottomSpacer, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: margin))
        
        bezelConstraints.append(NSLayoutConstraint(item: topSpacer, attribute: .height, relatedBy: .equal, toItem: bottomSpacer, attribute: .height, multiplier: 1.0, constant: 0))
        
        subviews.enumerated().forEach { (offset, element) in
            bezelConstraints.append(NSLayoutConstraint(item: element, attribute: .centerX, relatedBy: .equal, toItem: bezelView, attribute: .centerX, multiplier: 1.0, constant: 0))
            
            bezelConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[element]-(>=margin)-|", options: .init(rawValue: 0), metrics: metrics, views: ["element":element]))
            
            if offset == 0{
                bezelConstraints.append(NSLayoutConstraint(item: element, attribute: .top, relatedBy: .equal, toItem: bezelView, attribute: .top, multiplier: 1.0, constant: 0.0))
            }
            else if offset == subviews.count - 1{
                bezelConstraints.append(NSLayoutConstraint(item: element, attribute: .bottom, relatedBy: .equal, toItem: bezelView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
            }
            
            if offset > 0 {
                let padding = NSLayoutConstraint(item: element, attribute: .top, relatedBy: .equal, toItem: subviews[offset - 1], attribute: .bottom, multiplier: 1.0, constant: 0)
                bezelConstraints.append(padding)
                paddingConstraints?.append(padding)
            }
        }
        
        bezelView.addConstraints(bezelConstraints)
        self.bezelConstraints = bezelConstraints
        
        updatePaddingConstraints()
        super.updateConstraints()
        
    }
    
    override public func layoutSubviews() {
        if needsUpdateConstraints() == false
        {
            updatePaddingConstraints()
        }
        super.layoutSubviews()
    }
    
    private func updatePaddingConstraints(){
        var hasVisibleAncestors = false
        paddingConstraints?.forEach({ (constraint) in
            if let firstView:UIView = constraint.firstItem as? UIView,let secondView:UIView = constraint.secondItem as? UIView{
                let firstVisible = (firstView.isHidden == false)&&(firstView.intrinsicContentSize != CGSize.zero)
                let secondVisible = (secondView.isHidden == false)&&(secondView.intrinsicContentSize != CGSize.zero)
                constraint.constant = firstVisible && (secondVisible || hasVisibleAncestors) ? MBProgressHudSwift.MBDefaultPadding:0.0
                hasVisibleAncestors = hasVisibleAncestors||secondVisible
            }
        })
    }
    
    private func applyPriority(priority:UILayoutPriority,toConstraints:[NSLayoutConstraint]){
        toConstraints.forEach { (constraint) in
            constraint.priority = priority
        }
    }

    
    
    private func updateBezelMotionEffects(){
        if bezelView.responds(to: #selector(UIView.addMotionEffect(_:))) == false
        {
            return
        }
        if defaultMotionEffectsEnabled{
            let effectOffset = 10.0
            let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
            effectX.maximumRelativeValue = effectOffset
            effectX.minimumRelativeValue = -effectOffset
            
            let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
            effectY.maximumRelativeValue = effectOffset
            effectY.minimumRelativeValue = -effectOffset
            
            let group = UIMotionEffectGroup()
            group.motionEffects = [effectX,effectY]
            bezelView.addMotionEffect(group)
        }
        else{
            bezelView.motionEffects.forEach { (effect) in
                bezelView.removeMotionEffect(effect)
            }
        }
    }
    
}



/**
* A progress view for showing definite progress by filling up a circle (pie chart).
*/
class MBRoundProgressView:UIView{
    var progress:Float = 0 ///0-1
    {
        didSet{
            if oldValue != self.progress
            {
                setNeedsDisplay()
            }
        }
    }
    var progressTintColor:UIColor?
    {
        didSet{
            if oldValue != self.progressTintColor {
                setNeedsDisplay()
            }
        }
    }
    var backgroundTintColor:UIColor? //= UIColor(white: 1, alpha: 0.1)
    {
        didSet
        {
            if oldValue != self.backgroundTintColor {
                setNeedsDisplay()
            }
        }
    }
    var isAnnular:Bool = false ///Display mode - NO = round or YES = annular. Defaults to round.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        progress = 0
        isAnnular = false
        progressTintColor = UIColor(white: 1, alpha: 1)
        backgroundTintColor = UIColor(white: 1, alpha: 1)
    }
    
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 37, height: 37))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        get{
            return CGSize(width: 37, height: 37)
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        if isAnnular
        {
            let lineWidth:CGFloat = 2.0
            let processBackgroundPath:UIBezierPath = UIBezierPath()
            processBackgroundPath.lineCapStyle = .butt
            processBackgroundPath.lineWidth = lineWidth
            let center:CGPoint = CGPoint(x: bounds.midX, y: bounds.midY)
            let radius:CGFloat = (bounds.width - lineWidth)/2
            let startAngle:CGFloat = -CGFloat(Double.pi/2)
            var endAngle:CGFloat = CGFloat(2*Double.pi) + startAngle
            processBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            backgroundTintColor?.set()
            processBackgroundPath.stroke()
            
            let processPath:UIBezierPath = UIBezierPath()
            processPath.lineCapStyle = .square
            processPath.lineWidth = lineWidth
            endAngle = CGFloat(progress * 2 * Float(Double.pi)) + startAngle
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            processPath.stroke()
        }
        else
        {
            let lineWidth:CGFloat = 2
            let allRect:CGRect = self.bounds
            let circleRect:CGRect = allRect.insetBy(dx: lineWidth/2, dy: lineWidth/2)
            let center = CGPoint(x: allRect.midX, y: allRect.midY)
            progressTintColor?.setStroke()
            backgroundTintColor?.setFill()
            context?.setLineWidth(lineWidth)
            context?.strokeEllipse(in: circleRect)
            let startAngle:CGFloat = -CGFloat(Double.pi/2)
            let processPath:UIBezierPath = UIBezierPath()
            processPath.lineCapStyle = .butt
            processPath.lineWidth = lineWidth*2.0
            let radius:CGFloat = allRect.width/2.0 - processPath.lineWidth/2.0
            let endAngle:CGFloat = CGFloat(progress) * 2.0 * CGFloat(Double.pi) + startAngle
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            context?.setBlendMode(.copy)
            progressTintColor?.set()
            processPath.stroke()
        }
    }
    
}

/**
 * A flat bar progress view.
 */
class MBBarProgressView: UIView {
    var progress:Float = 0 ///0-1
    {
        didSet{
            if oldValue != self.progress{
                setNeedsDisplay()
            }
        }
    }
    var lineColor:UIColor?// = .white
    
    var progressRemainingColor:UIColor = .clear
    {
        didSet{
                   if oldValue != self.progressRemainingColor{
                       setNeedsDisplay()
                   }
               }
    }
    var progressColor:UIColor?// = .white
    {
        didSet{
                   if oldValue != self.progressColor{
                       setNeedsDisplay()
                   }
               }
    }
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        progress = 0
        lineColor = .white
        progressColor = .white
        progressRemainingColor = .clear
        backgroundColor = .clear
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize
        {
        get{
            return CGSize(width: 120, height: 10)
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2)
        context?.setStrokeColor(lineColor!.cgColor)
        context?.setFillColor(progressRemainingColor.cgColor)
        
        var radius:CGFloat = rect.height/2 - 2
        context?.move(to: CGPoint(x: 2, y: rect.height/2))
        context?.addArc(tangent1End: CGPoint(x: 2, y: 2), tangent2End: CGPoint(x: radius+2, y: 2), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: rect.width - 2, y: 2), tangent2End: CGPoint(x: rect.width - 2, y: rect.height/2), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: rect.width - 2, y: rect.height - 2), tangent2End: CGPoint(x: rect.width - radius - 2, y: rect.height - 2), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: 2, y: rect.height - 2), tangent2End: CGPoint(x: 2, y: rect.height/2), radius: radius)
        context?.drawPath(using: .fillStroke)
        context?.setFillColor(progressColor!.cgColor)
        radius = radius - 2
        let amout:CGFloat = CGFloat(progress)*rect.width
        if amout >= radius + 4 && amout <= rect.width - radius - 4{
            context?.move(to: CGPoint(x: 4, y: rect.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius + 4, y: 4), radius: radius)
            context?.addLine(to: CGPoint(x: amout, y: 4))
            context?.addLine(to: CGPoint(x: amout, y: radius + 4))
            context?.move(to: CGPoint(x: 4, y: rect.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: rect.height - 4), tangent2End: CGPoint(x: radius + 4, y: rect.height - 4), radius: radius)
            context?.addLine(to: CGPoint(x: amout, y: rect.height - 4))
            context?.addLine(to: CGPoint(x: amout, y: radius + 4))
            context?.fillPath()
        }
        else if amout > radius + 4{
            let x:CGFloat = amout - (rect.width - radius - 4)
            
            context?.move(to: CGPoint(x: 4, y: rect.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius + 4, y: 4), radius: radius)
            context?.addLine(to: CGPoint(x: rect.width - radius - 4, y: 4))
            var angle:CGFloat = CGFloat(-acos(x/radius))
            if angle.isNaN {
                angle = 0
            }
            context?.addArc(tangent1End: CGPoint(x: rect.width - radius - 4, y: rect.height/2), tangent2End: CGPoint(x: radius, y: CGFloat(Double.pi)), radius: 0)
            context?.addLine(to: CGPoint(x: amout, y: rect.height/2))
            context?.move(to: CGPoint(x: 4, y: rect.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: rect.height - 4), tangent2End: CGPoint(x: radius + 4, y: rect.height - 4), radius: radius)
            context?.addLine(to: CGPoint(x: rect.width - radius - 4, y: rect.height - 4))
            angle = acos(x/radius)
            if angle.isNaN
            {
                angle = 0
            }
            context?.addArc(center: CGPoint(x: rect.width - radius - 4, y: rect.height/2), radius: radius, startAngle: CGFloat(-Double.pi), endAngle: angle, clockwise: true)
            context?.addLine(to: CGPoint(x: amout, y: rect.height/2))
            context?.fillPath()
        }
        else if amout > 0 && amout < radius + 4{
            context?.move(to: CGPoint(x: 4, y: rect.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius + 4, y: 4), radius: radius)
            context?.move(to: CGPoint(x: 4, y: rect.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: rect.height - 4), tangent2End: CGPoint(x: radius + 4, y: rect.height - 4), radius: radius)
            context?.addLine(to: CGPoint(x: radius + 4, y: rect.height/2))
            context?.fillPath()
        }
    }
    
}

class MBBackgroundView:UIView{
    var style:MBProgressHudSwiftBackgroundStyle = .Blur
    {
        didSet{
            if oldValue != self.style
            {
                updateForBackgroundStyle()
            }
            
        }
    }
    var blurEffectStyle:UIBlurEffect.Style = .light
    {
           didSet{
               if oldValue != self.blurEffectStyle
               {
                   updateForBackgroundStyle()
               }
           }
       }
    var color:UIColor!
    {
           didSet{
            if oldValue != self.color
            {
                updateViewsForColor(color: self.color)
            }
               
           }
       }
    
    private var effectView:UIVisualEffectView?
    private var toolbar:UIToolbar?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style = .Blur
        blurEffectStyle = .light
        color = UIColor(white: 0.8, alpha: 0.6)
        clipsToBounds = true
        updateForBackgroundStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize{
        get{
            return .zero
        }
    }
    
    
    
    private func updateForBackgroundStyle(){
        if style == .Blur
        {
            let effect:UIBlurEffect = UIBlurEffect(style: blurEffectStyle)
            effectView = UIVisualEffectView(effect: effect)
            addSubview(effectView!)
            effectView?.frame = bounds
            effectView?.autoresizingMask = [.flexibleHeight,.flexibleHeight]
            backgroundColor = color
            layer.allowsGroupOpacity = false
        }
        else
        {
            effectView?.removeFromSuperview()
            effectView = nil
            backgroundColor = color
        }
    }
    
    
    private func updateViewsForColor(color:UIColor){
        if style == .Blur
        {
            backgroundColor = self.color
        }
        else
        {
            backgroundColor = self.color
        }
    }
}
