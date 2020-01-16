//
//  MainViewController.swift
//  MBProgressHUDSwiftLGF
//
//  Created by peterlee on 2020/1/15.
//  Copyright © 2020 Personal. All rights reserved.
//

import UIKit


let headerViewTop:CGFloat = 300

protocol SheetScrollDelegate:AnyObject {
    func sheetDidScroll(viewController:UIViewController,didScrollTo contentOffset: CGPoint)
}

class MainView:UIView
{
    var topDistance:CGFloat = headerViewTop
    {
        didSet{
            topView.snp.updateConstraints { (make) in
                make.top.equalTo(topDistance)
                make.left.right.bottom.equalTo(0)
            }
        }
    }
    
    private var topView:UIView!
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

class MainViewController: UIViewController {
    
    private var bottomVC:UIViewController!
    private var topVC:UIViewController!
    
    init(bottomVC:UIViewController,topVC:UIViewController)
    {
        super.init(nibName: nil, bundle: nil)
        self.bottomVC = bottomVC
        self.topVC = topVC
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


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
    
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee.y
        print("targetOffset = \(targetOffset)")
        let pulledUpOffset: CGFloat = 0
        let pulledDownOffset: CGFloat = -maxVisibleContentHeight
        
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
                scrollView.contentInset = UIEdgeInsets(top: UIScreen.main.bounds.height-20, left: 0, bottom: 0, right: 0)
                targetContentOffset.pointee.y =  -UIScreen.main.bounds.height + 20
            }
        }
    }
    
}
