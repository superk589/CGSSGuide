//
//  TeamTableViewCell.swift
//  CGSSGuide
//
//  Created by zzk on 16/7/28.
//  Copyright © 2016年 zzk. All rights reserved.
//

import UIKit
import SnapKit

class TeamTableViewCellCardView: UIView {
    var icon: CGSSCardIconView
    var label: UILabel

    override init(frame: CGRect) {
        icon = CGSSCardIconView()
        icon.isUserInteractionEnabled = false
        label = UILabel()
        label.adjustsFontSizeToFitWidth = true
//        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        
        super.init(frame: frame)
        addSubview(label)
        addSubview(icon)
        label.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        
        icon.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(snp.width)
            make.bottom.equalTo(label.snp.top)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TeamTableViewCell: UITableViewCell {
    
    var iconStackView: UIStackView!
    var cardIcons: [CGSSCardIconView] {
        return iconStackView.arrangedSubviews.flatMap{ ($0 as? TeamSimulationCardView)?.icon }
    }
    
//    var appealStackView: UIStackView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        prepareUI()
    }
    
    private func prepareUI() {
        var views = [UIView]()
        for _ in 0...5 {
            let view = TeamSimulationCardView()
            views.append(view)
        }
        iconStackView = UIStackView(arrangedSubviews: views)
        iconStackView.spacing = 5
        iconStackView.distribution = .fillEqually
        iconStackView.isUserInteractionEnabled = false
        contentView.addSubview(iconStackView)
        
//        var labels = [UILabel]()
//        let colors = [Color.life, Color.vocal, Color.dance, Color.visual, UIColor.darkGray]
//        for i in 0...4 {
//            let label = UILabel()
//            label.font = UIFont.init(name: "menlo", size: 12)
//            label.textColor = colors[i]
//            labels.append(label)
//        }
//        
//        appealStackView = UIStackView(arrangedSubviews: labels)
//        appealStackView.spacing = 5
//        appealStackView.distribution = .equalCentering
//        contentView.addSubview(appealStackView)
        
        iconStackView.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
        
//        appealStackView.snp.makeConstraints { (make) in
//            make.left.equalTo(10)
//            make.right.equalTo(-10)
//            make.top.equalTo(iconStackView.snp.bottom)
//            make.bottom.equalTo(-5)
//        }
        accessoryType = .disclosureIndicator
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareUI()
    }
    
    func setup(with team: CGSSTeam) {
        for i in 0...5 {
            if let teamMember = team[i], let card = teamMember.cardRef, let view = iconStackView.arrangedSubviews[i] as? TeamSimulationCardView {
                view.icon.cardId = card.id
                if i != 5 {
                    if card.skill != nil {
                        view.skillLabel.text = "SLv.\((teamMember.skillLevel)!)"
                    } else {
                        view.skillLabel.text = "n/a"
                    }
                } else {
                    view.skillLabel.text = "n/a"
                }
                view.potentialLabel.setup(with: teamMember.potential)
            }
        }
        
//        let values = [team.rawHP, team.rawVocal, team.rawDance, team.rawVisual, team.rawAppeal.total]
//        for i in 0...4 {
//            if let label = appealStackView.arrangedSubviews[i] as? UILabel {
//                label.text = String(values[i])
//            }
//        }
    }
    
}
