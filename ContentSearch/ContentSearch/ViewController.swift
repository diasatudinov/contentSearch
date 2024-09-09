//
//  ViewController.swift
//  ContentSearch
//
//  Created by Dias Atudinov on 08.09.2024.
//

import UIKit

class ViewController: UIViewController {

    private let searchController = UISearchController(searchResultsController: nil)
    
    
    
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
        self.searchController.searchBar.placeholder = "Search content"
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = false
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }

}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("", searchController.searchBar.text)
    }
    
    
}

