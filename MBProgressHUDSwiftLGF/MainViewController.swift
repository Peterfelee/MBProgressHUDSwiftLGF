//
//  MainViewController.swift
//  MBProgressHUDSwiftLGF
//
//  Created by peterlee on 2020/1/15.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit



/**中间停留时顶部距离*/
let headerViewTop:CGFloat = 300

/**底部停留时底部距离*/
let headerViewBottom:CGFloat = 80

/**顶部的view滑动时传递的代理*/
protocol SheetScrollDelegate:AnyObject {
    func sheetDidScroll(viewController:UIViewController,didScrollTo contentOffset: CGPoint)
}

//MARK:主要承载页面
class MainView:UIView
{
    /**顶部滑动的view*/
    private var topView:UIView!
    /**底部滑动的view*/
    private var bottomView:UIView!
    
    init(bottomView:UIView,topView:UIView)
    {
        super.init(frame: .zero)
        self.bottomView = bottomView
        self.topView = topView
            
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100*50), byRoundingCorners: [UIRectCorner.topLeft,UIRectCorner.topRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        topView.layer.mask = shape
        addSubview(bottomView)
        addSubview(topView)
        
        bottomView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.right.bottom.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let temp:UIScrollView = topView as? UIScrollView , point.y + temp.contentOffset.y > 0
        {
            return topView
        }
        return bottomView.hitTest(bottomView.convert(point, from: self), with: event)
    }
}


//MARK:主要的承载控制器
class MainViewController: UIViewController {
    
    private var bottomVC:UIViewController!
    private var topVC:UIViewController!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.bottomVC = BottomViewController()
        self.topVC = TopViewController()
        addChild(self.bottomVC)
        addChild(self.topVC)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        let mainView = MainView(bottomView: self.bottomVC.view, topView: self.topVC.view)
        view = mainView
    }
    
    override func viewDidLoad() {
        bottomVC.didMove(toParent: self)
        topVC.didMove(toParent: self)
    }
}

//MARK:底部的控制器 填充自己想要数据主要在这里
class BottomViewController:UIViewController{
    
    override func viewDidLoad() {
        view.backgroundColor = .red
        let btn = UIButton(type: .contactAdd)
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(buttonclick(btn:)), for: .touchUpInside)
        btn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(150)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
    }
    
    @objc func buttonclick(btn:UIButton){
        print("btn ---- clicked")
    }
}


//MARK:顶部的控制器 填充自己想要数据主要在这里
class TopViewController:UITableViewController{
    
    let maxVisibleContentHeight = headerViewTop
    
    var sheetDelegate:SheetScrollDelegate?
    
    override func viewDidLoad() {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.classForCoder()))
        tableView.contentInset.top = maxVisibleContentHeight
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sheetDelegate?.sheetDidScroll(viewController: self, didScrollTo: tableView.contentOffset)
        
        if tableView.contentSize.height < tableView.bounds.height {
            tableView.contentSize.height = tableView.bounds.height
        }
    }
    
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee.y
        let contentoffsetY:CGFloat = scrollView.contentOffset.y

        print("targetOffset = \(targetOffset)")
        print("contentoffsetY = \(contentoffsetY)")
        let pulledUpOffset: CGFloat = 0
        let pulledDownOffset: CGFloat = -maxVisibleContentHeight
        
        if contentoffsetY > 0
        {
            return
        }
        if (pulledDownOffset...pulledUpOffset).contains(targetOffset) {
            if velocity.y < 0 {
                targetContentOffset.pointee.y = pulledDownOffset
            } else {
                targetContentOffset.pointee.y = pulledUpOffset
            }
        }
        else{
            if velocity.y > 0 {
                scrollView.contentInset = UIEdgeInsets(top: maxVisibleContentHeight, left: 0, bottom: 0, right: 0)
                targetContentOffset.pointee.y =  pulledDownOffset

            }
            else
            {
                scrollView.contentInset = UIEdgeInsets(top: UIScreen.main.bounds.height-headerViewBottom, left: 0, bottom: 0, right: 0)
                targetContentOffset.pointee.y =  -UIScreen.main.bounds.height + headerViewBottom
            }
        }
    }
}



extension TopViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.classForCoder()))
        if cell == nil
        {
            cell = UITableViewCell()
        }
        cell?.textLabel?.text = "text"
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    
    
}
