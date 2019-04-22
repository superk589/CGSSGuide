//
//  EventDetailView.swift
//  DereGuide
//
//  Created by zzk on 2017/1/16.
//  Copyright © 2017 zzk. All rights reserved.
//

import UIKit
import SnapKit
import ZKCornerRadiusView

protocol EventDetailViewDelegate: class {
    func eventDetailView(_ view: EventDetailView, didClick icon: CGSSCardIconView)
    func gotoPtChartView(eventDetailView: EventDetailView)
    func gotoScoreChartView(eventDetailView: EventDetailView)
    func gotoLiveTrendView(eventDetailView: EventDetailView)
    func refreshPtView(eventDetailView: EventDetailView)
    func refreshScoreView(eventDetailView: EventDetailView)
}

class EventDetailView: UIView, CGSSIconViewDelegate {

    let startToEndLabel = UILabel()
    
    let timeIndicator = TimeStatusIndicator()
    
    let line1 = LineView()
    
    let line2 = LineView()
    
    let line3 = LineView()
    
    let card1View = EventCardView()
    
    let card2View = EventCardView()
    
    let songDescLabel = UILabel()
    
    let liveTrendLabel = UILabel()
    
    let liveView = LiveTableViewCell()
    
    let eventPtContentView = UIView()
    let line4 = LineView()
    let eventPtDescLabel = UILabel()
    let gotoPtChartLabel = UILabel()
    let eventPtView = EventPtView()
    
    let eventScoreContentView = UIView()
    let line5 = LineView()
    let eventScoreDescLabel = UILabel()
    let gotoScoreChartLabel = UILabel()
    let eventScoreView = EventScoreView()
    
    private struct Height {
        static let ptContentView: CGFloat = 192
        static let scoreContentView: CGFloat = 156
    }
    
    weak var delegate: (EventDetailViewDelegate & LiveTableViewCellDelegate)? {
        didSet {
            liveView.delegate = self.delegate
        }
    }
   
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(startToEndLabel)
        startToEndLabel.snp.makeConstraints { (make) in
            make.right.lessThanOrEqualTo(-10)
            make.left.equalTo(32)
            make.top.equalTo(8)
        }
        startToEndLabel.font = .systemFont(ofSize: 12)
        startToEndLabel.textColor = .darkGray
        startToEndLabel.textAlignment = .left
        startToEndLabel.adjustsFontSizeToFitWidth = true
        startToEndLabel.baselineAdjustment = .alignCenters
        
        addSubview(timeIndicator)
        timeIndicator.snp.makeConstraints { (make) in
            make.height.width.equalTo(12)
            make.left.equalTo(10)
            make.centerY.equalTo(startToEndLabel)
        }
        
        addSubview(line1)
        line1.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1 / Screen.scale)
            make.top.equalTo(startToEndLabel.snp.bottom).offset(8)
        }
        
        addSubview(card1View)
        card1View.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(line1.snp.bottom)
            make.height.equalTo(91)
        }
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        card1View.addGestureRecognizer(tap1)
    
        addSubview(line3)
        line3.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1 / Screen.scale)
            make.top.equalTo(card1View.snp.bottom)
        }
        
        addSubview(card2View)
        card2View.snp.makeConstraints { (make) in
            make.right.left.equalToSuperview()
            make.top.equalTo(line3.snp.bottom)
            make.height.equalTo(91)
        }
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        card2View.addGestureRecognizer(tap2)
        
        addSubview(line2)
        line2.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1 / Screen.scale)
            make.top.equalTo(card2View.snp.bottom)
        }
        
        addSubview(songDescLabel)
        songDescLabel.textColor = .black
        songDescLabel.text = NSLocalizedString("活动曲", comment: "")
        songDescLabel.font = .systemFont(ofSize: 16)
        songDescLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(line2.snp.bottom).offset(8)
        }
        
        addSubview(liveTrendLabel)
        liveTrendLabel.textColor = .lightGray
        liveTrendLabel.text = NSLocalizedString("流行曲", comment: "") + " >"
        liveTrendLabel.font = .systemFont(ofSize: 16)
        liveTrendLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line2.snp.bottom).offset(8)
            make.right.equalTo(-10)
        }
        liveTrendLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoLiveTrendViewAction(gesture:)))
        liveTrendLabel.addGestureRecognizer(tap)
        
        addSubview(liveView.readableContentView)
        liveView.readableContentView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(songDescLabel.snp.bottom)
        }
        
        addSubview(eventPtContentView)
        eventPtContentView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(liveView.readableContentView.snp.bottom)
            make.height.equalTo(192)
        }
        eventPtContentView.layer.masksToBounds = true
        
        eventPtContentView.addSubview(line4)
        line4.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1 / Screen.scale)
            make.top.equalToSuperview()
        }

        eventPtContentView.addSubview(eventPtDescLabel)
        eventPtDescLabel.textColor = .black
        eventPtDescLabel.text = NSLocalizedString("活动pt档位", comment: "")
        eventPtDescLabel.font = .systemFont(ofSize: 16)
        eventPtDescLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(line4.snp.bottom).offset(8)
        }
        
        eventPtContentView.addSubview(gotoPtChartLabel)
        gotoPtChartLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(eventPtDescLabel)
        }
        gotoPtChartLabel.font = .systemFont(ofSize: 16)
        gotoPtChartLabel.textColor = .lightGray
        gotoPtChartLabel.text = NSLocalizedString("查看完整图表", comment: "") + " >"
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(gotoPtChartAction))
        gotoPtChartLabel.addGestureRecognizer(tap3)
        gotoPtChartLabel.isUserInteractionEnabled = true
        gotoPtChartLabel.isHidden = true
        
        eventPtContentView.addSubview(eventPtView)
        eventPtView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(158.5)
            make.top.equalTo(eventPtDescLabel.snp.bottom).offset(-2)
        }
        
        eventPtView.delegate = self
        
        addSubview(eventScoreContentView)
        eventScoreContentView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(eventPtContentView.snp.bottom)
            make.height.equalTo(156)
            make.bottom.equalToSuperview().offset(-30)
        }
        eventScoreContentView.layer.masksToBounds = true
        
        eventScoreContentView.addSubview(line5)
        line5.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1 / Screen.scale)
            make.top.equalToSuperview()
        }
        
        eventScoreContentView.addSubview(eventScoreDescLabel)
        eventScoreDescLabel.textColor = .black
        eventScoreDescLabel.text = NSLocalizedString("歌曲分数档位", comment: "")
        eventScoreDescLabel.font = .systemFont(ofSize: 16)
        eventScoreDescLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(line5.snp.bottom).offset(8)
        }
        
        eventScoreContentView.addSubview(gotoScoreChartLabel)
        gotoScoreChartLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(eventScoreDescLabel)
        }
        gotoScoreChartLabel.font = .systemFont(ofSize: 16)
        gotoScoreChartLabel.textColor = .lightGray
        gotoScoreChartLabel.text = NSLocalizedString("查看完整图表", comment: "") + " >"
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(gotoScoreChartAction))
        gotoScoreChartLabel.isUserInteractionEnabled = true
        gotoScoreChartLabel.addGestureRecognizer(tap4)
        gotoScoreChartLabel.isHidden = true
        
        eventScoreContentView.addSubview(eventScoreView)
        eventScoreView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(122.5)
            make.top.equalTo(eventScoreDescLabel.snp.bottom).offset(-2)
        }
        
        eventScoreView.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapAction(tap: UITapGestureRecognizer) {
        if let view = tap.view as? EventCardView {
            delegate?.eventDetailView(self, didClick: view.cardView.cardIconView)
        }
    }
    
    @objc func gotoScoreChartAction() {
        delegate?.gotoScoreChartView(eventDetailView: self)
    }
    
    @objc func gotoPtChartAction() {
        delegate?.gotoPtChartView(eventDetailView: self)
    }
    
    @objc func gotoLiveTrendViewAction(gesture: UITapGestureRecognizer) {
        delegate?.gotoLiveTrendView(eventDetailView: self)
    }
    
    func setup(event: CGSSEvent, bannerId: Int) {
        if event.startDate.toDate() > Date() {
            timeIndicator.style = .future
        } else if event.endDate.toDate() < Date() {
            timeIndicator.style = .past
        } else {
            timeIndicator.style = .now
        }
        
        if event.startDate.toDate() > Date() {
            startToEndLabel.text = NSLocalizedString("待定", comment: "")
            card1View.isHidden = true
            card2View.isHidden = true
            liveView.isHidden = true
            songDescLabel.isHidden = true
            liveTrendLabel.isHidden = true
            
            line1.isHidden = true
            line2.isHidden = true
            line3.isHidden = true
            
            eventPtContentView.isHidden = true
            eventScoreContentView.isHidden = true
            
        } else {
            startToEndLabel.text = "\(event.startDate.toDate().toString(format: "(zzz)yyyy-MM-dd HH:mm:ss", timeZone: TimeZone.current)) ~ \(event.endDate.toDate().toString(timeZone: TimeZone.current))"
            if event.reward.count >= 2 {
                var rewards = event.reward.sorted(by: { (r1, r2) -> Bool in
                    return r1.recommandOrder < r2.recommandOrder
                })
                if let card1 = CGSSDAO.shared.findCardById(rewards[0].cardId) {
                    card1View.setup(card: card1, desc: NSLocalizedString("上位", comment: ""))
                }
                if let card2 = CGSSDAO.shared.findCardById(rewards[1].cardId) {
                    card2View.setup(card: card2, desc: NSLocalizedString("下位", comment: ""))
                }
            }
            
            if let live = event.live {
                liveView.setup(live: live, sorter: nil)
                liveView.snp.updateConstraints { (update) in
                    update.height.equalTo(88)
                }
                songDescLabel.isHidden = false
            } else {
                liveView.snp.updateConstraints { (update) in
                    update.height.equalTo(0)
                }
                songDescLabel.isHidden = true
            }
        
            if CGSSEventTypes.ptRankingExists.contains(event.eventType) {
                eventPtContentView.snp.updateConstraints { (update) in
                    update.height.equalTo(Height.ptContentView)
                }
            } else {
                eventPtContentView.snp.updateConstraints { (update) in
                    update.height.equalTo(0)
                }
            }
            
            if CGSSEventTypes.scoreRankingExists.contains(event.eventType) {
                eventScoreContentView.snp.updateConstraints { (update) in
                    update.height.equalTo(Height.scoreContentView)
                }
            } else {
                eventScoreContentView.snp.updateConstraints { (update) in
                    update.height.equalTo(0)
                }
            }
            
            liveTrendLabel.isHidden = !event.hasTrendLives
        }
    }
    
    func setup(ptItems: [RankingItem], onGoing: Bool) {
        eventPtView.setup(items: ptItems, onGoing: onGoing)
    }
    
    func setup(scoreItems: [RankingItem], onGoing: Bool) {
        eventScoreView.setup(items: scoreItems, onGoing: onGoing)
    }
    
    func iconClick(_ iv: CGSSIconView) {
        delegate?.eventDetailView(self, didClick: iv as! CGSSCardIconView)
    }
}

extension EventDetailView: EventPtViewDelegate {
    
    func refresh(eventPtView: EventPtView) {
        delegate?.refreshPtView(eventDetailView: self)
    }
    
}

extension EventDetailView: EventScoreViewDelegate {
    
    func refresh(eventScoreView: EventScoreView) {
        delegate?.refreshScoreView(eventDetailView: self)
    }
    
}
