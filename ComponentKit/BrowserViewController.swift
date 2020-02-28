//
//  PageViewController.swift
//  ComponentKit
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit


///
/// General purpose CollectionViewCell used to host a view. Used to contain the child scrollable stack view
/// controller.
///
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
        // Disable bounds clipping to allow a child scroll view to scroll
        // outside the bounds of the cell (ie behind the top and bottom bars).
        clipsToBounds = false
        contentView.clipsToBounds = false
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        onPrepareForReuse?(self)
    }
}


///
/// Data source for the browser view controller. The data source should provide:
///     1. The count of the number of individual view controllers to display.
///     2. View controller instance for the given page.
///
public protocol BrowserControllerDataSource: class {
    
    ///
    /// Number of view controllers to display.
    ///
    func numberOfPages(in controller: BrowserViewController) -> Int
    
    ///
    /// View controller for a page at a specific index. The browser view controller does not provide any
    /// reusability assistance for view controllers. The data source should cache view controllers (e.g using
    /// an LRU cache) to reduce the overhead of instantiating a view controller.
    ///
    func browser(_ controller: BrowserViewController, viewControllerForPageAtIndex index: Int) -> UIViewController
}


///
/// Displays a full screen horizontally scrolling list of view controllers. The implementation of the child view
/// controllers is dependant on the data source (ie independent of the browser view controller).
///
/// Notes: Only portrait mode is currently supported. Pagination does not work correctly in landscape mode.
///
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
        collectionView.backgroundColor = .white
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
        // Adjust the size of the collection view cells when transitioning
        // portrait and landscape modes.
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
                // Instantiate the view controller for the cell, and attach the
                // view controller as a child of the current view controller.
                // Calling willMove() and didMove() is not strictly required
                // per the documentation, however it is necessary on some
                // earlier to correctly propogate
                // view(will/did)(Appear/Disappear) calls.
                viewController.willMove(toParent: self)
                addChild(viewController)
                cell.containedView = viewController.view
                viewController.didMove(toParent: self)
                cell.onPrepareForReuse = { [weak viewController] cell in
                    // Remove the view controller from the parent view
                    // controller when the cell is recycled.
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
        /// Size the collection view cell to the full extent size of the adjusted safe content insets.
        let size = collectionView.bounds.size
        let contentInset = collectionView.adjustedContentInset
        return CGSize(
            width: size.width - (contentInset.left + contentInset.right),
            height: size.height - (contentInset.top + contentInset.bottom)
        )
    }
}
