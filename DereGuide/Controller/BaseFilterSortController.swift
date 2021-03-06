//
//  BaseFilterSortController.swift
//  DereGuide
//
//  Created by zzk on 2017/1/12.
//  Copyright © 2017 zzk. All rights reserved.
//

import UIKit
import SnapKit

class BaseFilterSortController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    let toolbar = UIToolbar()
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.register(SortTableViewCell.self, forCellReuseIdentifier: "SortCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.estimatedRowHeight = 50
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topLayoutGuide.snp.bottom)
        }
        
        toolbar.tintColor = .parade
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.left.right.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.left.right.equalToSuperview()
            }
            make.height.equalTo(44)
        }

        let leftSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        leftSpaceItem.width = 0
        let doneItem = UIBarButtonItem(title: NSLocalizedString("完成", comment: "导航栏按钮"), style: .done, target: self, action: #selector(doneAction))
        let middleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let resetItem = UIBarButtonItem(title: NSLocalizedString("重置", comment: "导航栏按钮"), style: .plain, target: self, action: #selector(resetAction))
        
        let rightSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightSpaceItem.width = 0
        
        toolbar.setItems([leftSpaceItem, resetItem, middleSpaceItem, doneItem, rightSpaceItem], animated: false)
    }

    
    @objc func doneAction() {
        
    }
    
    @objc func resetAction() {
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            // since the size changes, update all table cells to fit the new size
            self?.tableView.beginUpdates()
            self?.tableView.endUpdates()
        }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("筛选", comment: "")
        } else {
            return NSLocalizedString("排序", comment: "")
        }
    }

}
