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
        contentView.contentInsetAdjustmentBehavior = .always
        contentView.alwaysBounceVertical = true
        dataSource = self
        reloadData()
    }
}

extension TestScrollableStackViewController: ListControllerDataSource {
    
    func numberOfItems(in list: UIViewController) -> Int {
        return 10
    }
    
    func list(_ controller: UIViewController, viewForItemAtIndex index: Int) -> UIView {
        let spam = (0 ..< index).map { i in
            return String(i)
        }
        let view = ImageLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel.text = "Label #\(index)\n" + spam.joined(separator: "\n")
        view.backgroundColor = .yellow
        return view
    }
}
