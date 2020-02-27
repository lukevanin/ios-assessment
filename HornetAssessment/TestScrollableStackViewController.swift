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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.contentInsetAdjustmentBehavior = .automatic
        contentView.alwaysBounceVertical = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add test content
        for i in 0 ..< 10 {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.text = "Label #\(i)"
            view.backgroundColor = .yellow
            contentView.stackView.addArrangedSubview(view)
        }
    }

}
