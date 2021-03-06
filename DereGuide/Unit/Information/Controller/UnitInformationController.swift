//
//  UnitInformationController.swift
//  DereGuide
//
//  Created by zzk on 2017/5/16.
//  Copyright © 2017 zzk. All rights reserved.
//

import UIKit

class UnitInformationController: BaseTableViewController, UnitDetailConfigurable {
        
    var unit: Unit {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    weak var parentTabController: UDTabViewController?
    
    init(unit: Unit) {
        self.unit = unit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        
        tableView.register(UnitInformationUnitCell.self, forCellReuseIdentifier: UnitInformationUnitCell.description())
        tableView.register(UnitInformationLeaderSkillCell.self, forCellReuseIdentifier: UnitInformationLeaderSkillCell.description())
        tableView.register(UnitInformationAppealCell.self, forCellReuseIdentifier: UnitInformationAppealCell.description())
        tableView.register(UnitInformationSkillListCell.self, forCellReuseIdentifier: UnitInformationSkillListCell.description())
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("load cell \(indexPath.row)")
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: UnitInformationUnitCell.description(), for: indexPath) as! UnitInformationUnitCell
            cell.setup(with: unit)
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: UnitInformationLeaderSkillCell.description(), for: indexPath) as! UnitInformationLeaderSkillCell
            cell.setup(with: unit)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: UnitInformationAppealCell.description(), for: indexPath) as! UnitInformationAppealCell
            cell.setup(with: unit)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: UnitInformationSkillListCell.description(), for: indexPath) as! UnitInformationSkillListCell
            cell.setup(with: unit)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
}


extension UnitInformationController: UnitInformationUnitCellDelegate {
    
    func unitInformationUnitCell(_ unitInformationUnitCell: UnitInformationUnitCell, didClick cardIcon: CGSSCardIconView) {
        if let id = cardIcon.cardID, let card = CGSSDAO.shared.findCardById(id) {
            let vc = CDTabViewController(card: card)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
