//
//  TestScrollableStackView.swift
//  HornetAssessment
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit

import ComponentKit

final class TestScrollableStackViewController: ScrollableStackViewController {
    
    var name: String? {
        didSet {
            reload()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.contentInsetAdjustmentBehavior = .always
        contentView.alwaysBounceVertical = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }
    
    private func reload() {
        let views = contentView.stackView.arrangedSubviews
        views.forEach { view in
            view.removeFromSuperview()
        }
        
        for i in 0 ..< 100 {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.text = "Label \(name) #\(i)"
            view.backgroundColor = .yellow
            contentView.stackView.addArrangedSubview(view)
        }
    }

}
