import Kingfisher
import UIKit

final class CardCollectionViewCell: UICollectionViewCell {
    // MARK: - Identifier
    
    static let identifier = "CardCollectionViewCell"
    
    // MARK: - Properties
    
    // MARK: Private
    
    private let mainView: UIView = .init()
    private let trashImageView: UIImageView = .init()
    
    // MARK: Public
    
    var deleteHandler: (() -> ())?
    var personImageView: UIImageView = .init()
    let personNameLabel: UILabel = .init()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        addSetups()
        addConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    func set(_ name: String, _ image: String) {
        personNameLabel.text = name
        personImageView.kf.setImage(with: URL(string: image))
    }
    
    // MARK: - Commands
    
    func transformToLarge() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.10, y: 1.10)
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func transformStandart() {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderWidth = 0
            self.transform = CGAffineTransform.identity
        }
    }
    
    // MARK: - Constraints
    
    // MARK: Private
    
    private func addConstraints() {
        addMainViewConstraints()
        addPersonImageViewConstraints()
        addPersonNameLabelConstraints()
        addTrashImageViewConstraints()
    }
    
    private func addMainViewConstraints() {
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100).isActive = true
        mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30).isActive = true
        mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
        mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100).isActive = true
    }
    
    private func addPersonImageViewConstraints() {
        personImageView.translatesAutoresizingMaskIntoConstraints = false
        personImageView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        personImageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        personImageView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        personImageView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
    }
    
    private func addPersonNameLabelConstraints() {
        personNameLabel.translatesAutoresizingMaskIntoConstraints = false
        personNameLabel.bottomAnchor.constraint(equalTo: personImageView.bottomAnchor, constant: -50).isActive = true
        personNameLabel.leadingAnchor.constraint(equalTo: personImageView.leadingAnchor, constant: 20).isActive = true
        personNameLabel.trailingAnchor.constraint(equalTo: personImageView.trailingAnchor, constant: -20).isActive = true
    }
    
    private func addTrashImageViewConstraints() {
        trashImageView.translatesAutoresizingMaskIntoConstraints = false
        trashImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20).isActive = true
        trashImageView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20).isActive = true
        trashImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        trashImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    // MARK: - Setups
    
    // MARK: Private
    
    private func addSubviews() {
        contentView.addSubview(mainView)
        mainView.addSubview(personImageView)
        personImageView.addSubview(personNameLabel)
        mainView.addSubview(trashImageView)
    }
    
    private func addSetups() {
        addMainViewSetups()
        addPersonImageViewSetups()
        addPersonNameLabelSetups()
        addTrashImageViewSetups()
    }
    
    private func addMainViewSetups() {
        mainView.backgroundColor = .white
        mainView.layer.cornerRadius = 20
        mainView.clipsToBounds = true
    }
    
    private func addPersonImageViewSetups() {
        personImageView.contentMode = .scaleAspectFill
        personImageView.layer.masksToBounds = true
        personImageView.layer.cornerRadius = 20
    }
    
    private func addPersonNameLabelSetups() {
        personNameLabel.textColor = .white
        personNameLabel.font = .bruta(50, .thin)
        personNameLabel.textAlignment = .center
        personNameLabel.adjustsFontSizeToFitWidth = true
        personNameLabel.minimumScaleFactor = 0.5
    }
    
    private func addTrashImageViewSetups() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteButtonClick))
        trashImageView.isUserInteractionEnabled = true
        trashImageView.addGestureRecognizer(tap)
        trashImageView.image = UIImage(systemName: "trash")
        trashImageView.tintColor = .systemRed
        trashImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - Actions
    
    // MARK: Private
    
    @objc private func deleteButtonClick() {
        deleteHandler?()
    }
}
