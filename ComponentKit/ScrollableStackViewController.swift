//
//  ScrollableStackViewController.swift
//  ComponentKit
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit

open class ScrollableStackViewController: UIViewController {
    
    public let contentView: ScrollableStackView = {
        let view = ScrollableStackView()
        return view
    }()

    open override func loadView() {
        self.view = contentView
    }
}
