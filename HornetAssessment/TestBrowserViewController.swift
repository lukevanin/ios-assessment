//
//  TestPageViewController.swift
//  HornetAssessment
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit

import ComponentKit

public final class TestBrowserViewController: BrowserViewController {

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource = self
        reloadData()
    }
}

extension TestBrowserViewController: BrowserControllerDataSource {

    public func numberOfPages(in controller: BrowserViewController) -> Int {
        return 10
    }
    
    public func browser(_ controller: BrowserViewController, configureView view: PageCollectionViewCell, forPageAtIndex index: Int) {
        // Add test content
        let views = view.itemsView.stackView.subviews
        views.forEach { $0.removeFromSuperview() }
        for i in 0 ..< 50 {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Label #\(index).\(i)"
            label.backgroundColor = .cyan
            view.itemsView.stackView.addArrangedSubview(label)
        }
        view.itemsView.layoutIfNeeded()
    }
}
