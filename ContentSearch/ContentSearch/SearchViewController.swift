//
//  SearchViewController.swift
//  ContentSearch
//
//  Created by Dias Atudinov on 10.09.2024.
//

import UIKit

class SearchViewController: UICollectionViewController {
    
    var dataProvider = DataProvider()
    var networkDataFetcher = NetworkDataFetcher()
    private var timer: Timer?
    private var contents = [UnsplashPhoto]()
    
    private let itemPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .mainBg
        
        setupCollectionView()
        setupNavigationBar()
        setupSearchBar()
    }
    
    private func setupCollectionView() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.register(ContentCell.self, forCellWithReuseIdentifier: ContentCell.reuseId)
        
        collectionView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.contentInsetAdjustmentBehavior = .automatic
    }
    
    private func setupNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Content"
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .red
        }
    }
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCell.reuseId, for: indexPath) as! ContentCell
        let unsplashContent = contents[indexPath.item]
        cell.unsplashPhoto = unsplashContent
        cell.dataProvider = dataProvider
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.networkDataFetcher.fetchImages(searchTearm: searchText) { [weak self] searchResults in
                guard let fetchedContent = searchResults else { return }
                self?.contents = fetchedContent.results
                self?.collectionView.reloadData()
            }
        })
        
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let content = contents[indexPath.item]
        let paddingSpace = sectionInsets.left * (itemPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemPerRow
        let height = CGFloat(content.height) * widthPerItem / CGFloat(content.width)
        return CGSize(width: widthPerItem, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}
