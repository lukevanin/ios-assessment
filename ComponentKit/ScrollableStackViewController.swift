//
//  ScrollableStackViewController.swift
//  ComponentKit
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit

open class ScrollableStackViewController: UIViewController {
    
    public let contentView = ScrollableStackView()

    open override func loadView() {
        super.loadView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
}
