//
//  TestViewController.swift
//  HornetAssessment
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit

import ComponentKit

final class ScrollableStackViewTestViewController: UIViewController {
    
    private let layout = ScrollableStackView()
    
    override func loadView() {
        super.loadView()

        // Set up scroll view.
        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(layout)
        NSLayoutConstraint.activate([
            layout.leftAnchor.constraint(equalTo: view.leftAnchor),
            layout.rightAnchor.constraint(equalTo: view.rightAnchor),
            layout.topAnchor.constraint(equalTo: view.topAnchor),
            layout.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Add test content
        for i in 0 ..< 100 {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.text = "Label #\(i)"
            view.backgroundColor = .orange
            layout.stackView.addArrangedSubview(view)
        }
    }
}
