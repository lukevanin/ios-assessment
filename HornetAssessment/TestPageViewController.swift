//
//  TestPageViewController.swift
//  HornetAssessment
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit

import ComponentKit

public final class TestPageViewController: PageViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        reloadData()
    }
}

extension TestPageViewController: PageControllerDataSource {

    public func pageControllerNumberOfPages(controller: PageViewController) -> Int {
        return 10
    }
    
    public func pageController(controller: PageViewController, configureView view: PageCollectionViewCell, forPageAtIndex index: Int) {
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
    }
}
