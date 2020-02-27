//
//  TestViewController.swift
//  HornetAssessment
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit

import ComponentKit

final class TestViewController: UIViewController {
    
    override func loadView() {
        super.loadView()
        
        // Add scrolling layout to view.
        let layout = ScrollableStackView()
        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.alwaysBounceVertical = true
        layout.insetsLayoutMarginsFromSafeArea = true
        view.addSubview(layout)
        NSLayoutConstraint.activate([
            layout.leftAnchor.constraint(equalTo: view.leftAnchor),
            layout.rightAnchor.constraint(equalTo: view.rightAnchor),
            layout.topAnchor.constraint(equalTo: view.topAnchor),
            layout.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        
        // Add test content
        for i in 0 ..< 10 {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.text = "Label #\(i)"
            view.backgroundColor = .orange
            layout.stackView.addArrangedSubview(view)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
