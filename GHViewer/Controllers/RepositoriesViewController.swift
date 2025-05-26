//
//  RepositoriesViewController.swift
//  GHViewer
//
//  Created by Admin on 26/05/25.
//

import Foundation
import UIKit
import SafariServices

class RepositoriesViewController: UIViewController {
    private let user: GitHubUser
    private var repositories: [GitHubRepository] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let refreshControl = UIRefreshControl()
    
    init(user: GitHubUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRepositories()
    }
    
    private func setupUI() {
        title = "\(user.login)'s Repositories"
        view.backgroundColor = UIColor.systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissTapped)
        )
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshRepositories), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func dismissTapped() {
        dismiss(animated: true)
    }
    
    @objc private func refreshRepositories() {
        loadRepositories()
    }
    
    private func loadRepositories() {
        if !refreshControl.isRefreshing {
            loadingIndicator.startAnimating()
        }
        
        Task {
            do {
                let repos = try await GitHubService.shared.fetchRepositories(username: user.login, perPage: 20)
                await MainActor.run {
                    self.repositories = repos
                    self.tableView.reloadData()
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    HapticService.shared.success()
                }
            } catch {
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.showAlert(title: "Error", message: "Failed to load repositories")
                    HapticService.shared.error()
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension RepositoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: indexPath) as! RepositoryCell
        cell.configure(with: repositories[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let repository = repositories[indexPath.row]
        if let url = URL(string: repository.htmlUrl) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
            HapticService.shared.selection()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
