//
//  ViewController.swift
//  PhotoRepository
//
//  Created by Egor Mesheryakov on 16.05.22.
//

import UIKit

final class ViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: Private
    var centerCell: CardCollectionViewCell?
    private let personPhotoCollectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let layout = UICollectionViewFlowLayout()

    private var persons: PersonInfo = .init() {
        didSet {
            personPhotoCollectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        addSetups()
        addContraints()
        fetchPersonInfo()
    }
    
    // MARK: - Networking
    
    // MARK: Private
    
    private func fetchPersonInfo() {
        NetworkingManager.shared.getPersonInfo { result in
            switch result {
            case .success(var response):
                DispatchQueue.main.async { [weak self] in
                    for person in response {
                        response[person.key]?.photoURL = person.value.photoURL + person.key + ImageFormat.jpg.rawValue
                    }
                    self?.persons = response
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - Constraints
    
    // MARK: Private
    
    private func addContraints() {
        personPhotoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        personPhotoCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        personPhotoCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        personPhotoCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        personPhotoCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    // MARK: - Setups
    
    // MARK: Private
    
    private func addSubviews() {
        view.addSubview(personPhotoCollectionView)
    }
    
    private func addSetups() {
        addPersonPhotoCollectionViewSetups()
        addPersonPhotoCollectionViewSetupsUI()
    }
    
    private func addPersonPhotoCollectionViewSetups() {
        personPhotoCollectionView.isPagingEnabled = true
        personPhotoCollectionView.delegate = self
        personPhotoCollectionView.dataSource = self
        personPhotoCollectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
    }
    
    private func addPersonPhotoCollectionViewSetupsUI() {
        personPhotoCollectionView.collectionViewLayout = layout
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    // MARK: - Helpers

    // MARK: Private

    private func getPhotoURL(_ id: Dictionary<String, Person>.Keys.Element) -> String {
        let photoURL = Constants.baseUrl.rawValue + Endpoint.task.rawValue + id + ImageFormat.jpg.rawValue
        return photoURL
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return persons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as? CardCollectionViewCell {
            let userName = Array(persons.values)[indexPath.row].userName
            let photoURL = Array(persons.keys)[indexPath.row]
            cell.set(userName, getPhotoURL(photoURL))
            return cell
        }
        return UICollectionViewCell()
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for view in personPhotoCollectionView.visibleCells {
            let view: CardCollectionViewCell = view as! CardCollectionViewCell
            let xOffset: CGFloat = ((personPhotoCollectionView.contentOffset.x - view.frame.origin.x) / 200) * 25
            view.personImageView.frame = CGRect(x: xOffset,
                                                y: view.personImageView.frame.origin.y,
                                                width: view.personImageView.frame.width,
                                                height: view.personImageView.frame.height)
        }
        zoomCell()
    }
    
    // MARK: - Helpers
    
    private func zoomCell() {
        let centerPoint = CGPoint(x: personPhotoCollectionView.frame.size.width / 2 + personPhotoCollectionView.contentOffset.x,
                                  y: personPhotoCollectionView.frame.size.height / 2 + personPhotoCollectionView.contentOffset.y)
        if let indexPath = personPhotoCollectionView.indexPathForItem(at: centerPoint), self.centerCell == nil {
            centerCell = (personPhotoCollectionView.cellForItem(at: indexPath) as! CardCollectionViewCell)
            self.centerCell?.transformToLarge()
        }
        
        if let cell = centerCell {
            let offsetX = centerPoint.x - cell.center.x
            if offsetX < -15 || offsetX > 15 {
                cell.transformStandart()
                self.centerCell = nil
            }
        }
    }
}