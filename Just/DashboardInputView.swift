//
//  DashboardInputView.swift
//  Just
//
//  Created by Krzysztof Kapitan on 09.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class DashboardInputView: UIView, Reusable, NibLoadable {
   
    @IBOutlet weak var clockButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyState(.inactive, animated: false)
    }
    
    func activate() {
        applyState(.active, animated: true)
    }
    
    func deactivate() {
        applyState(.inactive, animated: true)
    }
    
    var date: Date? {
        didSet {
            if let date = date {
                let formatter: DateFormatter = .short
                dateLabel.text = formatter.string(from: date)
            } else {
                dateLabel.text = ""
            }
        }
    }
    
    var list: List? {
        didSet {
            listLabel.text = list?.name ?? ""
        }
    }
}

extension DashboardInputView {
    struct State {
        let text: String
        let offset: CGFloat
        let clearsInput: Bool
    }
    
    func applyState(_ state: State, animated: Bool) {
        leadingConstraint.constant = state.offset
        inputTextView.text = state.text
        
        if state.clearsInput {
            date = nil
            list = nil
        }
        
        guard animated else { return }
        
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
}

extension DashboardInputView.State {
    static let active: DashboardInputView.State = {
        return .init(text: "", offset: 10, clearsInput: false)
    }()
    
    static let inactive: DashboardInputView.State = {
        return .init(text: "Type things to be done...", offset: -100, clearsInput: true)
    }()
}
