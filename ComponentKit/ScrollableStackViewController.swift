//
//  ScrollableStackViewController.swift
//  ComponentKit
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit

public protocol ListControllerDataSource: class {
    func numberOfItems(in list: UIViewController) -> Int
    func list(_ controller: UIViewController, viewForItemAtIndex index: Int) -> UIView
}

open class ScrollableStackViewController: UIViewController {
    
    public weak var dataSource: ListControllerDataSource?
    
    public let contentView = ScrollableStackView()

    open override func loadView() {
        self.view = contentView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }
    
    public func reloadData() {
        removeSubviews()
        createSubviews()
    }
    
    private func removeSubviews() {
        let views = contentView.stackView.arrangedSubviews
        views.forEach { view in
            view.removeFromSuperview()
        }
    }
    
    private func createSubviews() {
        guard let dataSource = dataSource else {
            return
        }
        let count = dataSource.numberOfItems(in: self)
        let views = (0 ..< count).map { index in
            return dataSource.list(self, viewForItemAtIndex: index)
        }
        views.forEach(contentView.stackView.addArrangedSubview)
    }
}
