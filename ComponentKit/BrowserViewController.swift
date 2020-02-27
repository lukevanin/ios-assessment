//
//  PageViewController.swift
//  ComponentKit
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit


public class ContainerCollectionViewCell: UICollectionViewCell {
    
    typealias OnPrepareForReuse = (ContainerCollectionViewCell) -> Void
    
    var onPrepareForReuse: OnPrepareForReuse?
    
    var containedView: UIView? {
        didSet {
            if let view = oldValue {
                view.removeFromSuperview()
            }
            if let view = containedView {
                view.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(view)
                NSLayoutConstraint.activate([
                    view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                    view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                    view.topAnchor.constraint(equalTo: contentView.topAnchor),
                    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    ])
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        clipsToBounds = false
        contentView.clipsToBounds = false
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        onPrepareForReuse?(self)
    }
}


public protocol BrowserControllerDataSource: class {
    func numberOfPages(in controller: BrowserViewController) -> Int
    func browser(_ controller: BrowserViewController, viewControllerForPageAtIndex index: Int) -> UIViewController
}


open class BrowserViewController: UIViewController {
    
    private let containerCellIdentifier = "container-cell"
    
    public weak var dataSource: BrowserControllerDataSource?
    
    public let collectionView: UICollectionView = {
        let screenSize = UIScreen.main.bounds.size
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(
            width: 100,
            height: 100
        )
        let view = UICollectionView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 100,
                height: 100
            ),
            collectionViewLayout: layout
        )
        view.isPagingEnabled = true
        return view
    }()
    
    open override func loadView() {
        super.loadView()
        
        #warning("TODO: Remove background colour")
        collectionView.backgroundColor = .red
        collectionView.alwaysBounceHorizontal = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            ContainerCollectionViewCell.self,
            forCellWithReuseIdentifier: containerCellIdentifier
        )
        
        self.view = collectionView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.flashScrollIndicators()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
}

extension BrowserViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: containerCellIdentifier,
            for: indexPath
        )
        if let cell = cell as? ContainerCollectionViewCell {
            if let viewController = dataSource?.browser(self, viewControllerForPageAtIndex: indexPath.item) {
                viewController.willMove(toParent: self)
                addChild(viewController)
                cell.containedView = viewController.view
                viewController.didMove(toParent: self)
                cell.onPrepareForReuse = { [weak viewController] cell in
                    viewController?.willMove(toParent: nil)
                    cell.containedView = nil
                    viewController?.removeFromParent()
                    viewController?.didMove(toParent: nil)
                }
            }
        }
        return cell
    }
}

extension BrowserViewController: UICollectionViewDelegate {
    
}

extension BrowserViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.size
        let contentInset = collectionView.adjustedContentInset
        return CGSize(
            width: size.width - (contentInset.left + contentInset.right),
            height: size.height - (contentInset.top + contentInset.bottom)
        )
    }
}
