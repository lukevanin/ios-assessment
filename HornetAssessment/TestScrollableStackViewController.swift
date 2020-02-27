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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add test content
        for i in 0 ..< 10 {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.text = "Label #\(i)"
            view.backgroundColor = .cyan
            contentView.stackView.addArrangedSubview(view)
        }
        
        #warning("TODO: Fix incorrect scroll position on load")
    }

}
