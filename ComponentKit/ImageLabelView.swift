//
//  ImageLabelView.swift
//  ComponentKit
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

public final class ImageLabelView: UIView {
    
    public let imageView = UIImageView()
    public let titleLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .green
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .magenta
        titleLabel.numberOfLines = 0
        addSubview(imageView)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            imageView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            imageView.widthAnchor.constraint(equalToConstant: 64),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1) ,

            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 1),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1) ,
            ])
    }
}
