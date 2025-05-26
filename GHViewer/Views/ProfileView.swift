//
//  ProfileView.swift
//  GHViewer
//
//  Created by Admin on 26/05/25.
//


import UIKit

class ProfileView: UIView {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.systemGray5
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private let joinedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.systemGray
        label.textAlignment = .center
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.systemGray2
        label.textAlignment = .center
        return label
    }()
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.systemGray2
        label.textAlignment = .center
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private let repositoriesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    private var skeletonViews: [SkeletonView] = []
    var onRepositoriesButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemBackground
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(joinedLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(companyLabel)
        contentView.addSubview(statsStackView)
        contentView.addSubview(repositoriesButton)
        
        setupConstraints()
        setupStatsStackView()
        setupActions()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            joinedLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            joinedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            joinedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            bioLabel.topAnchor.constraint(equalTo: joinedLabel.bottomAnchor, constant: 20),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            locationLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 12),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            companyLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            companyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            companyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statsStackView.topAnchor.constraint(equalTo: companyLabel.bottomAnchor, constant: 30),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            repositoriesButton.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 30),
            repositoriesButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            repositoriesButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            repositoriesButton.heightAnchor.constraint(equalToConstant: 50),
            repositoriesButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupStatsStackView() {
        let followersLabel = createStatLabel()
        let followingLabel = createStatLabel()
        let reposLabel = createStatLabel()
        
        statsStackView.addArrangedSubview(followersLabel)
        statsStackView.addArrangedSubview(followingLabel)
        statsStackView.addArrangedSubview(reposLabel)
    }
    
    private func createStatLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }
    
    private func setupActions() {
        repositoriesButton.addTarget(self, action: #selector(repositoriesButtonTapped), for: .touchUpInside)
    }
    
    @objc private func repositoriesButtonTapped() {
        HapticService.shared.impact()
        onRepositoriesButtonTapped?()
    }
    
    func showSkeletonLoading() {
        hideSkeletonLoading()
        
        let positions = [
            CGRect(x: bounds.width/2 - 60, y: 50, width: 120, height: 120), // Avatar
            CGRect(x: 20, y: 190, width: bounds.width - 40, height: 30), // Name
            CGRect(x: 20, y: 230, width: bounds.width - 40, height: 20), // Username
            CGRect(x: 20, y: 270, width: bounds.width - 40, height: 60), // Bio
            CGRect(x: 20, y: 350, width: bounds.width - 40, height: 80), // Stats
        ]
        
        for position in positions {
            let skeleton = SkeletonView(frame: position)
            addSubview(skeleton)
            skeletonViews.append(skeleton)
        }
    }
    
    func hideSkeletonLoading() {
        skeletonViews.forEach { $0.stopAnimating() }
        skeletonViews.removeAll()
    }
    
    func configure(with user: GitHubUser) {
        hideSkeletonLoading()
        
        nameLabel.text = user.name ?? "No name provided"
        usernameLabel.text = "@\(user.login)"
        joinedLabel.text = user.joinedDate
        bioLabel.text = user.bio ?? ""
        locationLabel.text = user.location != nil ? "📍 \(user.location!)" : ""
        companyLabel.text = user.company != nil ? "🏢 \(user.company!)" : ""
        
        repositoriesButton.setTitle("View \(user.publicRepos) Repositories", for: .normal)
        
        // Configure stats
        let labels = statsStackView.arrangedSubviews.compactMap { $0 as? UILabel }
        if labels.count >= 3 {
            labels[0].text = "\(user.followers)\nFollowers"
            labels[1].text = "\(user.following)\nFollowing"
            labels[2].text = "\(user.publicRepos)\nRepositories"
        }
        
        loadAvatar(from: user.avatarUrl)
    }
    
    private func loadAvatar(from urlString: String) {
        // Check cache first
        if let cachedImage = CacheService.shared.getCachedImage(forKey: urlString) {
            avatarImageView.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run {
                    if let image = UIImage(data: data) {
                        self.avatarImageView.image = image
                        CacheService.shared.cacheImage(image, forKey: urlString)
                    } else {
                        self.avatarImageView.image = UIImage(systemName: "person.circle.fill")
                    }
                }
            } catch {
                await MainActor.run {
                    self.avatarImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
    }
}

