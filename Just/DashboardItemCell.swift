//
//  DashboardItemCell.swift
//  Just
//
//  Created by Krzysztof Kapitan on 08.04.2017.
//  Copyright © 2017 CappSoft. All rights reserved.
//

import UIKit

final class DashboardItemCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureAction))
        rightSwipeGesture.direction = .right
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureAction))
        leftSwipeGesture.direction = .left;
        
        addGestureRecognizer(rightSwipeGesture)
        addGestureRecognizer(leftSwipeGesture)
        
        applyState(.normal, animated: false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        applyState(.normal, animated: false)
    }
    
    func swipeGestureAction(recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case [.right]:
            applyState(.normal, animated: true)
            break
        case [.left]:
            applyState(.expanded, animated: true)
            break
        default:
            break
        }
    }
    
    func applyState(_ state: DashboardItemCell.State, animated: Bool) {
    
        trailingConstraint.constant = -state.offset
        leadingConstraint.constant = state.offset
        
        guard animated else { return }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    var accessoryImage: UIImage? {
        didSet {
            accessoryImageView.image = accessoryImage
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var status: Priority? {
        didSet {
            statusLabel.text = status?.description
        }
    }
    
    var taskDescription: String? {
        didSet {
            descriptionLabel.text = taskDescription
        }
    }
}

extension DashboardItemCell {
    struct State {
        let offset: CGFloat
        
        init(offset: CGFloat = 0.0) {
            self.offset = offset
        }
    }
}

extension DashboardItemCell.State {
    static let normal: DashboardItemCell.State = {
        return .init()
    }()
    
    static let expanded: DashboardItemCell.State = {
        return .init(offset: 180)
    }()
}
