//
//  DetailViewController.swift
//  ContentSearch
//
//  Created by Dias Atudinov on 12.09.2024.
//

import UIKit

class DetailViewController: UIViewController {
    
    private let result: UnsplashPhoto
    var dataProvider: DataProvider?
    
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let userLabel: UILabel = {
        let userLabel = UILabel()
        userLabel.textAlignment = .left
        userLabel.textColor = .white
        return userLabel
    }()
    
    init(result: UnsplashPhoto) {
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

        view.backgroundColor = .mainBg
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        view.addSubview(userLabel)
        view.addSubview(descriptionLabel)
        
        
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        userLabel.translatesAutoresizingMaskIntoConstraints = false
       

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: view.bounds.width - 32),
            imageView.heightAnchor.constraint(equalToConstant: 400),
            
            userLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            userLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        self.descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
    }
    
    private func displayDetails() {

        let photoURL = result.urls["small"]
        
        guard let imageURL = photoURL, let url = URL(string: imageURL), let dataProvider = dataProvider else { return }
        dataProvider.downloadImage(url: url) { photo in
            
            self.imageView.image = photo
            self.descriptionLabel.text = self.result.description
            self.userLabel.text = self.result.user.name
        }
        
    }
}

