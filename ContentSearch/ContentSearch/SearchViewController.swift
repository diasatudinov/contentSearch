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
    private var searchHistory = [String]() // Массив для хранения истории запросов
    private var filteredHistory = [String]() // Отфильтрованная история для подсказок
    private var suggestionsTableView = UITableView()
    private var searchController = UISearchController(searchResultsController: nil)
    
    private let itemPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .mainBg
        
        setupCollectionView()
        setupNavigationBar()
        setupSearchBar()
        setupSuggestionsTableView()
    }
    
    private func setupSuggestionsTableView() {
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        suggestionsTableView.isHidden = true // Изначально скрываем таблицу
        suggestionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
        
        collectionView.addSubview(suggestionsTableView)
        
        // Настройка Auto Layout
        suggestionsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            suggestionsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            suggestionsTableView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            suggestionsTableView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            suggestionsTableView.heightAnchor.constraint(equalToConstant: 200)// Ограничиваем высоту таблицы
        ])
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
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
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
    
    // MARK: - История поиска

    private func addSearchQueryToHistory(_ query: String) {
        if !searchHistory.contains(query) {
            if searchHistory.count >= 5 {
                searchHistory.removeFirst()
            }
            searchHistory.append(query)
        }
    }

    private func filterHistory(for query: String) {
        filteredHistory = searchHistory.filter { $0.lowercased().contains(query.lowercased()) }
    }

    private func displaySearchSuggestions() {
        print("Подсказки: \(filteredHistory)")
        if filteredHistory.isEmpty {
            suggestionsTableView.isHidden = true
            
        } else {
            suggestionsTableView.isHidden = false
            suggestionsTableView.reloadData()
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        filterHistory(for: searchText)
        displaySearchSuggestions() // Отображаем подсказки по мере ввода
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.networkDataFetcher.fetchImages(searchTearm: searchText) { [weak self] searchResults in
                guard let fetchedContent = searchResults else { return }
                self?.contents = fetchedContent.results
                self?.collectionView.reloadData()
            }
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        addSearchQueryToHistory(searchText) // Сохраняем запрос в историю
        searchBar.resignFirstResponder() // Закрываем клавиатуру
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        cell.textLabel?.text = filteredHistory[indexPath.row]
        cell.backgroundColor = .blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSuggestion = filteredHistory[indexPath.row]
        searchController.searchBar.text = selectedSuggestion
        searchBarSearchButtonClicked(searchController.searchBar)
        suggestionsTableView.isHidden = true
    }
}
