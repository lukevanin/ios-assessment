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
    public let separatorView = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = .white
        isOpaque = true
        // Image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .white
        titleLabel.isOpaque = true
        titleLabel.numberOfLines = 0
        // Separator
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .lightGray
        separatorView.isOpaque = true
        // Layout
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(separatorView)
        let m = CGFloat(2)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: m),
            imageView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: m),
            imageView.widthAnchor.constraint(equalToConstant: 64),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: imageView.bottomAnchor, multiplier: m) ,

            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: m),
            trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: m),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: m),
            bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: m) ,
            
            separatorView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: m),
            trailingAnchor.constraint(equalToSystemSpacingAfter: separatorView.trailingAnchor, multiplier: m),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
}
