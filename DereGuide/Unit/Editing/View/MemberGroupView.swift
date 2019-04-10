//
//  MemberEditableItemView.swift
//  DereGuide
//
//  Created by zzk on 2017/6/16.
//  Copyright © 2017 zzk. All rights reserved.
//

import UIKit
import SnapKit

class MemberEditableItemView: UIView {
    
    let cardView = UnitSimulationCardView()
    let overlayView = UIView()
    let placeholderImageView = UIImageView(image: #imageLiteral(resourceName: "436-plus").withRenderingMode(.alwaysTemplate))
    let cardPlaceholder = UIView()
    
    private(set) var isSelected: Bool = false
    
    private var strokeColor: CGColor = UIColor.lightGray.cgColor {
        didSet {
            overlayView.layer.borderColor =  isSelected ? strokeColor : UIColor.lightGray.cgColor
            overlayView.layer.shadowColor = strokeColor
        }
    }
    
    private func setSelected(_ selected: Bool) {
        isSelected = selected
        if selected {
            overlayView.layer.shadowOpacity = 1
            overlayView.layer.borderColor = strokeColor
            overlayView.layer.shadowColor = strokeColor
            overlayView.layer.borderWidth = 2
        } else {
            overlayView.layer.shadowOpacity = 0
            overlayView.layer.borderColor = UIColor.lightGray.cgColor
            overlayView.layer.borderWidth = 0
        }
    }
    
    func setSelected(selected: Bool, animated: Bool) {
        
        if animated {
            overlayView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.overlayView.transform = .identity
                self.setSelected(selected)
            }, completion: nil)
        } else {
            setSelected(selected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(overlayView)
        overlayView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        overlayView.layer.shadowOffset = .zero
        setSelected(false)
        
        cardView.icon.isUserInteractionEnabled = false
        addSubview(cardView)
        cardView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4))
            make.height.greaterThanOrEqualTo(cardView.snp.width).offset(29)
        }
        
        addSubview(placeholderImageView)
        placeholderImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(self.snp.width).dividedBy(3)
        }
        placeholderImageView.tintColor = .lightGray
        
        addSubview(cardPlaceholder)
        cardPlaceholder.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-8)
            make.height.equalTo(cardPlaceholder.snp.width)
            make.center.equalToSuperview()
        }
        cardPlaceholder.layer.masksToBounds = true
        cardPlaceholder.layer.cornerRadius = 4
        cardPlaceholder.layer.borderWidth = 1 / Screen.scale
        cardPlaceholder.layer.borderColor = UIColor.border.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with member: Member) {
        placeholderImageView.isHidden = true
        cardPlaceholder.isHidden = true
        if let color = member.card?.attColor.cgColor {
            strokeColor = color
        }
        cardView.setup(with: member)
        bringSubviewToFront(cardView)
    }
}

protocol MemberGroupViewDelegate: class {
    func memberGroupView(_ memberGroupView: MemberGroupView, didLongPressAt item: MemberEditableItemView)
    func memberEditableView(_ memberGroupView: MemberGroupView, didDoubleTap item: MemberEditableItemView)
}

class MemberGroupView: UIView {
    
    weak var delegate: MemberGroupViewDelegate?
    
    let descLabel = UILabel()
    
    var stackView: UIStackView!
    
    var editableItemViews = [MemberEditableItemView]()
    
    let centerLabel = UILabel()
    
    let guestLabel = UILabel()
    
    var currentIndex: Int = 0 {
        didSet {
            if oldValue != currentIndex {
                editableItemViews[oldValue].setSelected(selected: false, animated: false)
                editableItemViews[currentIndex].setSelected(selected: true, animated: true)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for _ in 0..<6 {
            let view = MemberEditableItemView()
            editableItemViews.append(view)
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(_:)))
            doubleTap.numberOfTapsRequired = 2
            
            view.addGestureRecognizer(doubleTap)
            view.addGestureRecognizer(tap)
            view.addGestureRecognizer(longPress)
        }
        editableItemViews[0].setSelected(selected: true, animated: false)

        stackView = UIStackView(arrangedSubviews: editableItemViews)
        stackView.spacing = 6
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        addSubview(stackView)
        
        stackView.snp.remakeConstraints { (make) in
            make.left.greaterThanOrEqualTo(10)
            make.right.lessThanOrEqualTo(-10)
            // make the view as wide as possible
            make.right.equalTo(-10).priority(900)
            make.left.equalTo(10).priority(900)
            //
            make.bottom.equalTo(-10)
            make.width.lessThanOrEqualTo(104 * 6 + 30)
            make.centerX.equalToSuperview()
        }
        
        centerLabel.text = NSLocalizedString("队长", comment: "")
        centerLabel.font = .systemFont(ofSize: 12)
        centerLabel.adjustsFontSizeToFitWidth = true
        addSubview(centerLabel)
        centerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.centerX.equalTo(editableItemViews[0])
            make.bottom.equalTo(stackView.snp.top).offset(-5)
            make.width.lessThanOrEqualTo(editableItemViews[0].snp.width).offset(-4)
        }
        
        guestLabel.text = NSLocalizedString("好友", comment: "")
        guestLabel.font = .systemFont(ofSize: 12)
        guestLabel.adjustsFontSizeToFitWidth = true
        addSubview(guestLabel)
        guestLabel.snp.makeConstraints { (make) in
            make.top.equalTo(centerLabel)
            make.width.lessThanOrEqualTo(editableItemViews[5].snp.width).offset(-4)
            make.centerX.equalTo(editableItemViews[5])
        }
    }
    
    @objc func handleTapGesture(_ tap: UITapGestureRecognizer) {
        if let view = tap.view as? MemberEditableItemView {
            if let index = stackView.arrangedSubviews.firstIndex(of: view) {
                currentIndex = index
            }
        }
    }
    
    @objc func handleLongPressGesture(_ longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            guard let view = longPress.view as? MemberEditableItemView else { return }
            if let index = stackView.arrangedSubviews.firstIndex(of: view) {
                currentIndex = index
            }
            delegate?.memberGroupView(self, didLongPressAt: view)
        }
    }
    
    @objc func handleDoubleTapGesture(_ doubleTap: UITapGestureRecognizer) {
        guard let view = doubleTap.view as? MemberEditableItemView else { return }
        delegate?.memberEditableView(self, didDoubleTap: view)
    }
    
    func setup(with unit: Unit) {
        for i in 0..<6 {
            let member = unit[i]
            setup(with: member, at: i)
        }
    }
    
    func moveIndexToNext() {
        var nextIndex = currentIndex + 1
        if nextIndex == 6 {
            nextIndex = 0
        }
        currentIndex = nextIndex
    }
    
    func setup(with member: Member, at index: Int) {
        editableItemViews[index].setup(with: member)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
