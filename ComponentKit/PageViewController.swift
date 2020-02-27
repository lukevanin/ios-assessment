//
//  PageViewController.swift
//  ComponentKit
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import UIKit


public class PageCollectionViewCell: UICollectionViewCell {
    
    public let itemsView = ScrollableStackView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        #warning("TODO: Remove background colour")
        contentView.backgroundColor = .brown
        itemsView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(itemsView)
        NSLayoutConstraint.activate([
            itemsView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            itemsView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            itemsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            itemsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
    }
}


public protocol PageControllerDataSource: class {
    func pageControllerNumberOfPages(controller: PageViewController) -> Int
    func pageController(controller: PageViewController, configureView view: PageCollectionViewCell, forPageAtIndex index: Int)
}


open class PageViewController: UIViewController {
    
    private let pageCellIdentifier = "page-cell"
    
    public weak var dataSource: PageControllerDataSource?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = UIScreen.main.bounds.size
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
            PageCollectionViewCell.self,
            forCellWithReuseIdentifier: pageCellIdentifier
        )

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        
//        self.view = collectionView
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
    
    public func reloadData() {
        collectionView.reloadData()
    }
}

extension PageViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.pageControllerNumberOfPages(controller: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: pageCellIdentifier,
            for: indexPath
        )
        if let cell = cell as? PageCollectionViewCell {
            dataSource?.pageController(
                controller: self,
                configureView: cell,
                forPageAtIndex: indexPath.item
            )
        }
        return cell
    }
}

extension PageViewController: UICollectionViewDelegate {
    
}
