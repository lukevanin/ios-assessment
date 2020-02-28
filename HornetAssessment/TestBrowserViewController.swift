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
    
    private let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue]
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInsetAdjustmentBehavior = .always
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource = self
        reloadData()
    }
}

extension TestBrowserViewController: BrowserControllerDataSource {

    public func numberOfPages(in controller: BrowserViewController) -> Int {
        return 100
    }
    
    public func browser(_ controller: BrowserViewController, viewControllerForPageAtIndex index: Int) -> UIViewController {
        let viewController = TestScrollableStackViewController()
        viewController.view.backgroundColor = .white // colors[index % colors.count]
        viewController.contentView.clipsToBounds = false
        return viewController
    }
}
