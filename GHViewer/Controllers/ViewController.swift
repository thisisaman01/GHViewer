//
//  ViewController.swift
//  GHViewer
//
//  Created by Admin on 26/05/25.
//

import UIKit

class ViewController: UIViewController {
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter GitHub username"
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Search", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear", for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.isHidden = true
        return button
    }()
    
    private let historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("📝 History", for: .normal)
        button.backgroundColor = UIColor.systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        return refresh
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alpha = 0
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let historyTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.systemBackground
        tableView.layer.cornerRadius = 12
        tableView.isHidden = true
        return tableView
    }()
    
    private var profileView: ProfileView?
    private var currentUser: GitHubUser?
    private var searchHistory: [SearchHistory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadSearchHistory()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "GitHub Profile Lookup"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add clear history button to navigation bar
        let clearHistoryButton = UIBarButtonItem(
            title: "Clear History",
            style: .plain,
            target: self,
            action: #selector(clearHistoryTapped)
        )
        navigationItem.rightBarButtonItem = clearHistoryButton
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        view.addSubview(clearButton)
        view.addSubview(historyButton)
        view.addSubview(loadingIndicator)
        view.addSubview(scrollView)
        view.addSubview(historyTableView)
        
        scrollView.addSubview(contentView)
        scrollView.refreshControl = refreshControl
        
        setupConstraints()
        setupTableView()
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchTextField.heightAnchor.constraint(equalToConstant: 50),
            
            searchButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 12),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4, constant: -25),
            searchButton.heightAnchor.constraint(equalToConstant: 50),
            
            clearButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 12),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            clearButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4, constant: -25),
            clearButton.heightAnchor.constraint(equalToConstant: 50),
            
            historyButton.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 12),
            historyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            historyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            historyButton.heightAnchor.constraint(equalToConstant: 40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: historyButton.bottomAnchor, constant: 40),
            
            scrollView.topAnchor.constraint(equalTo: historyButton.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            historyTableView.topAnchor.constraint(equalTo: historyButton.bottomAnchor, constant: 12),
            historyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            historyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            historyTableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupTableView() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        historyTableView.separatorStyle = .singleLine
        historyTableView.layer.borderWidth = 1
        historyTableView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func setupActions() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        refreshControl.addTarget(self, action: #selector(refreshProfile), for: .valueChanged)
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        searchTextField.delegate = self
    }
    
    private func loadSearchHistory() {
        searchHistory = CacheService.shared.getSearchHistory()
        historyTableView.reloadData()
    }
    
    @objc private func searchButtonTapped() {
        performSearch()
    }
    
    @objc private func clearButtonTapped() {
        HapticService.shared.impact()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.alpha = 0
            self.profileView?.alpha = 0
        }) { _ in
            self.profileView?.removeFromSuperview()
            self.profileView = nil
            self.currentUser = nil
            self.clearButton.isHidden = true
            self.searchTextField.text = ""
            self.textFieldDidChange()
        }
    }
    
    @objc private func historyButtonTapped() {
        HapticService.shared.selection()
        historyTableView.isHidden.toggle()
        
        UIView.animate(withDuration: 0.3) {
            self.historyTableView.alpha = self.historyTableView.isHidden ? 0 : 1
        }
    }
    
    @objc private func clearHistoryTapped() {
        let alert = UIAlertController(
            title: "Clear Search History",
            message: "Are you sure you want to clear all search history?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            CacheService.shared.clearSearchHistory()
            self.loadSearchHistory()
            self.historyTableView.isHidden = true
            HapticService.shared.success()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func refreshProfile() {
        guard let currentUser = currentUser else {
            refreshControl.endRefreshing()
            return
        }
        
        Task {
            do {
                let user = try await GitHubService.shared.fetchUser(username: currentUser.login)
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                    self.displayProfile(user: user)
                    HapticService.shared.success()
                }
            } catch {
                await MainActor.run {
                    self.refreshControl.endRefreshing()
                    HapticService.shared.error()
                }
            }
        }
    }
    
    @objc private func textFieldDidChange() {
        let hasText = !(searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        searchButton.isEnabled = hasText
        searchButton.alpha = hasText ? 1.0 : 0.6
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        historyTableView.isHidden = true
    }
    
    private func performSearch() {
        guard let username = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !username.isEmpty else {
            showAlert(title: "Invalid Input", message: "Please enter a valid GitHub username.")
            return
        }
        
        view.endEditing(true)
        historyTableView.isHidden = true
        showLoading()
        
        // Save to search history
        CacheService.shared.saveSearchHistory(username)
        loadSearchHistory()
        
        Task {
            do {
                let user = try await GitHubService.shared.fetchUser(username: username)
                await MainActor.run {
                    self.hideLoading()
                    self.displayProfile(user: user)
                    HapticService.shared.success()
                }
            } catch let error as GitHubError {
                await MainActor.run {
                    self.hideLoading()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    HapticService.shared.error()
                }
            } catch {
                await MainActor.run {
                    self.hideLoading()
                    self.showAlert(title: "Error", message: "An unexpected error occurred.")
                    HapticService.shared.error()
                }
            }
        }
    }
    
    private func showLoading() {
        loadingIndicator.startAnimating()
        searchButton.isEnabled = false
        clearButton.isHidden = true
        
        // Show skeleton loading in profile view
        profileView?.showSkeletonLoading()
    }
    
    private func hideLoading() {
        loadingIndicator.stopAnimating()
        searchButton.isEnabled = true
    }
    
    private func displayProfile(user: GitHubUser) {
        currentUser = user
        profileView?.removeFromSuperview()
        
        let newProfileView = ProfileView()
        newProfileView.translatesAutoresizingMaskIntoConstraints = false
        newProfileView.alpha = 0
        contentView.addSubview(newProfileView)
        
        NSLayoutConstraint.activate([
            newProfileView.topAnchor.constraint(equalTo: contentView.topAnchor),
            newProfileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            newProfileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            newProfileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            newProfileView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        ])
        
        newProfileView.onRepositoriesButtonTapped = { [weak self] in
            self?.showRepositories(for: user)
        }
        
        newProfileView.configure(with: user)
        profileView = newProfileView
        clearButton.isHidden = false
        
        // Animate profile appearance
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut) {
            self.scrollView.alpha = 1
            newProfileView.alpha = 1
        }
    }
    
    private func showRepositories(for user: GitHubUser) {
        let reposVC = RepositoriesViewController(user: user)
        let navController = UINavigationController(rootViewController: reposVC)
        present(navController, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performSearch()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !searchHistory.isEmpty {
            historyTableView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.historyTableView.alpha = 1
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let history = searchHistory[indexPath.row]
        
        cell.textLabel?.text = "🔍 \(history.username)"
        cell.backgroundColor = UIColor.systemBackground
        cell.selectionStyle = .default
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        cell.detailTextLabel?.text = dateFormatter.string(from: history.searchDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let history = searchHistory[indexPath.row]
        searchTextField.text = history.username
        historyTableView.isHidden = true
        
        HapticService.shared.selection()
        performSearch()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            searchHistory.remove(at: indexPath.row)
            
            // Update UserDefaults
            if let data = try? JSONEncoder().encode(searchHistory) {
                UserDefaults.standard.set(data, forKey: "SearchHistory")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            HapticService.shared.impact()
        }
    }
}

