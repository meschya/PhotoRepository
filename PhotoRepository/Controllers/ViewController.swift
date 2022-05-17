import UIKit
import SafariServices

final class ViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: Private

    private var activityIndicator = UIActivityIndicatorView(style: .large)
    private var centerCell: CardCollectionViewCell?
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
        showActivityIndicator()
        NetworkingManager.shared.getPersonInfo { result in
            switch result {
            case .success(var response):
                DispatchQueue.main.async { [weak self] in
                    for person in response {
                        response[person.key]?.photoURL = person.value.photoURL + person.key + ImageFormat.jpg.rawValue
                    }
                    self?.persons = response
                    self?.hideActivityIndicator()
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
    
    private func showActivityIndicator() {
        view.isUserInteractionEnabled = false
        let viewController = tabBarController ?? navigationController ?? self
        activityIndicator.frame = CGRect(
            x: 0,
            y: 0,
            width: viewController.view.frame.width,
            height: viewController.view.frame.width
        )
        viewController.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }

    private func getPhotoURL(_ id: Dictionary<String, Person>.Keys.Element) -> String {
        let photoURL = Constants.baseUrl.rawValue + Endpoint.task.rawValue + id + ImageFormat.jpg.rawValue
        return photoURL
    }
    
    private func presentFailedOpenAlert() {
        let alert = UIAlertController(
            title: "Unable to Open",
            message: "We were unable to open the article",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    private func open(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return persons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let person = Array(self.persons.values)[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as? CardCollectionViewCell {
            let photoURL = Array(persons.keys)[indexPath.row]
            DispatchQueue.main.async { [weak self] in
                cell.set(person.userName, self?.getPhotoURL(photoURL) ?? "05")
            }
            // Delete cell
            cell.deleteHandler = {
                self.persons.removeValue(forKey: Array(self.persons.keys)[indexPath.row])
                self.personPhotoCollectionView.reloadData()
            }
            // Open user_url
            cell.userURLHandler = {
                guard let url = URL(string: person.userURL) else {
                    self.presentFailedOpenAlert()
                    return
                }
                self.open(url: url)
            }
            // Open photo_url
            cell.photoURLHandler = {
                guard let url = URL(string: person.photoURL) else {
                    self.presentFailedOpenAlert()
                    return
                }
                self.open(url: url)
            }
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
            DispatchQueue.main.async {
                self.centerCell?.transformToLarge()
            }
        }
        
        if let cell = centerCell {
            let offsetX = centerPoint.x - cell.center.x
            if offsetX < -15 || offsetX > 15 {
                DispatchQueue.main.async {
                    cell.transformStandart()
                    self.centerCell = nil
                }
            }
        }
    }
}
