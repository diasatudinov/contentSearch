//
//  ContentCell.swift
//  ContentSearch
//
//  Created by Dias Atudinov on 10.09.2024.
//

import UIKit

class ContentCell: UICollectionViewCell {
    
    static let reuseId = "ContentCell"
    
    var dataProvider: DataProvider?
    
    private let contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.textColor = .black
        contentLabel.backgroundColor = .white
        contentLabel.font = .systemFont(ofSize: 11, weight: .bold)
        return contentLabel
    }()
    
    private let contentUserLabel: UILabel = {
        let contentUserLabel = UILabel()
        contentUserLabel.translatesAutoresizingMaskIntoConstraints = false
        contentUserLabel.textColor = .black
        contentUserLabel.backgroundColor = .white
        contentUserLabel.font = .systemFont(ofSize: 11, weight: .medium)
        return contentUserLabel
    }()
    
    var unsplashPhoto: UnsplashPhoto! {
        didSet {
            let photoURL = unsplashPhoto.urls["small"]
            
            guard let imageURL = photoURL, let url = URL(string: imageURL), let dataProvider = dataProvider else { return }
            dataProvider.downloadImage(url: url) { photo in
                
                self.contentImageView.image = photo
                self.contentLabel.text = self.unsplashPhoto.description
                if let name = self.unsplashPhoto.user.name {
                    self.contentUserLabel.text = "by \(name)"
                }
            }
            
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.contentImageView.image = nil
        self.contentLabel.text = nil
        self.contentUserLabel.text = nil
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContentImageView()
        setupContentLabel()
    }
    
    private func setupContentImageView() {
        addSubview(contentImageView)
        
        contentImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        contentImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

    }
    
    private func setupContentLabel() {
        addSubview(contentLabel)
        addSubview(contentUserLabel)
        
        contentLabel.leadingAnchor.constraint(equalTo: contentImageView.leadingAnchor, constant: 8).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: contentUserLabel.topAnchor, constant: -4).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: contentImageView.trailingAnchor, constant: -8).isActive = true
        
        
        
        contentUserLabel.leadingAnchor.constraint(equalTo: contentImageView.leadingAnchor, constant: 8).isActive = true
        contentUserLabel.bottomAnchor.constraint(equalTo: contentImageView.bottomAnchor, constant: 8).isActive = true
        contentUserLabel.trailingAnchor.constraint(equalTo: contentImageView.trailingAnchor, constant: -8).isActive = true
       // contentUserLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8).isActive = true
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension UIImageView {
    
   
}

class DataProvider {
    var imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(url: URL, complition: @escaping (UIImage?) -> Void) {
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            complition(cachedImage)
        } else {
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad)
            let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard error == nil, data != nil, let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      let `self` = self else {
                    return
                }
                
                guard let image = UIImage(data: data!) else { return }
                self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    complition(image)
                }
                
            }
            dataTask.resume()
        }
        
    }
    
}

