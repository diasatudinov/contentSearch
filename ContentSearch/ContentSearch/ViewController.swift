//
//  ViewController.swift
//  ContentSearch
//
//  Created by Dias Atudinov on 08.09.2024.
//

import UIKit

class ViewController: UIViewController {

    private let searchController = UISearchController(searchResultsController: nil)
    
    var networkDataFetcher = NetworkDataFetcher()
    private var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .yellow
        self.navigationItem.title = "FIRST View"
        let button = UIButton(type: .system)
        button.setTitle("Нажми меня", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false // Включаем Auto Layout
        
        // Добавляем кнопку на экран
        view.addSubview(button)
        
        // Устанавливаем ограничения для центрирования кнопки
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Центр по оси X
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor), // Центр по оси Y
            button.widthAnchor.constraint(equalToConstant: 150),          // Ширина кнопки
            button.heightAnchor.constraint(equalToConstant: 50)           // Высота кнопки
        ])
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        self.setupSearchController()
    }
    
    @objc func buttonTapped() {
        print(searchController.searchBar.text)
    }
    
    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.placeholder = "Search content"
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = false
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }

}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
       // print("", searchController.searchBar.text)
        
    }
    
    
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.networkDataFetcher.fetchImages(searchTearm: searchText) { searchResults in
                searchResults?.results.map { photo in
                    print("photo.urls[small]: ",photo.urls["small"], "DESCRIPTION: ", photo.description)
                    
                }
            }
        })
        
    }
}


class SearchViewController: UICollectionViewController {
    
    private let searchBar = UISearchBar()
    private var searchHistory: [String] = []
    private var filteredHistory: [String] = []
    private var searchResults: [SearchResult] = []
    private let maxHistoryCount = 5
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        
        
        
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        // Установка UI
        setupUI()
        
        // Загрузка истории поиска
        loadSearchHistory()
    }
    
    private func setupUI() {
        // Добавляем searchBar
        searchBar.placeholder = "Search..."
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
    // Загрузка истории поиска
    private func loadSearchHistory() {
        if let history = UserDefaults.standard.array(forKey: "searchHistory") as? [String] {
            searchHistory = history
        }
    }
    
    // Сохранение истории поиска
    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
    }
    
    // Фильтрация истории поиска по введенной строке
    private func filterSearchHistory(for query: String) {
        filteredHistory = searchHistory.filter { $0.lowercased().contains(query.lowercased()) }
    }
    
    // UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterSearchHistory(for: searchText)
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        
        // Выполняем поиск (эмуляция)
        performSearch(query: query)
        
        // Обновляем историю поиска
        updateSearchHistory(with: query)
    }
    
    // Обновление истории поиска
    private func updateSearchHistory(with query: String) {
        if let index = searchHistory.firstIndex(of: query) {
            searchHistory.remove(at: index)
        }
        searchHistory.insert(query, at: 0)
        
        if searchHistory.count > maxHistoryCount {
            searchHistory.removeLast()
        }
        
        saveSearchHistory()
    }
    
    // Эмуляция поиска
    private func performSearch(query: String) {
        // Эмулируем результаты поиска
        searchResults = (0..<30).map { SearchResult(image: UIImage(named: "placeholder"), description: "Result \($0) for \(query)") }
        collectionView.reloadData()
    }
    
    // UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SearchResultCell
        let result = searchResults[indexPath.item]
        cell.configure(with: result)
        return cell
    }
    
    // UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let result = searchResults[indexPath.item]
        // Переход на детальный экран
        let detailVC = DetailViewController(result: result)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

struct SearchResult {
    let image: UIImage?
    let description: String
}

class SearchResultCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(descriptionLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with result: SearchResult) {
        imageView.image = result.image
        descriptionLabel.text = result.description
    }
}

class DetailViewController: UIViewController {
    
    private let result: SearchResult
    
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    
    init(result: SearchResult) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        displayDetails()
    }
    
    private func setupUI() {
        // Настройка UI компонентов
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        view.addSubview(descriptionLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
    }
    
    private func displayDetails() {
        // Отображение данных
        imageView.image = result.image
        descriptionLabel.text = result.description
    }
}
