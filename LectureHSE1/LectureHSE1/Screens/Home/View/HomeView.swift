//
//  HomeView.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.11.2025.
//

import UIKit


final class HomeView: UIViewController {
    private let presenter: HomePresenting
    var news: [New] = []
    
    private var needsRetryWhenOnline = false
    private var isLoading = false
    
    init(presenter: HomePresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.hidesWhenStopped = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let searchField: UITextField = {
        let tf = UITextField()
        tf.text = "beer"
        tf.placeholder = "Введите текст…"
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let sendButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Send"
        config.cornerStyle = .medium
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private lazy var topBarStack: UIStackView = {
        let st = UIStackView(arrangedSubviews: [searchField, sendButton])
        st.axis = .horizontal
        st.spacing = 8
        st.alignment = .center
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        observeNetwork()
        presenter.viewDidLoad()
    }
    
    func setup() {
        view.backgroundColor = .systemBackground

        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none

        view.addSubview(topBarStack)
        view.addSubview(tableView)
        view.addSubview(spinner)

        tableView.dataSource = self
        tableView.delegate = self

        // !!! зарегистрируй свои ячейки тут
        tableView.register(NewCell.self, forCellReuseIdentifier: NewCell.reuseIdentifier)

        // чтобы текстовое поле расширялось, а кнопка держала размер
        sendButton.setContentHuggingPriority(.required, for: .horizontal)
        searchField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Actions
        sendButton.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)

        NSLayoutConstraint.activate([
            topBarStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBarStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBarStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topBarStack.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: topBarStack.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func sendRequest() {
        let text = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }

        presenter.search(query: text)

        searchField.resignFirstResponder()
    }
    
    private func observeNetwork() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkChanged(_:)),
            name: .networkStatusChanged,
            object: nil
        )
    }

    @objc private func networkChanged(_ note: Notification) {
        guard let isConnected = note.object as? Bool else { return }

        if isConnected, needsRetryWhenOnline, !isLoading {
            needsRetryWhenOnline = false
            sendRequest()
        }
    }
}

extension HomeView: HomeViewProtocol {
    func showLoading() {
        isLoading = true
        spinner.startAnimating()
        tableView.isHidden = true
    }

    func showNews(_ news: [New]) {
        isLoading = false
        spinner.stopAnimating()
        tableView.isHidden = false
        self.news = news
        tableView.reloadData()
    }

    func showError(_ message: String) {
        isLoading = false
        spinner.stopAnimating()
        tableView.isHidden = false

        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension HomeView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewCell.reuseIdentifier,
            for: indexPath
        ) as? NewCell else {
            return UITableViewCell()
        }

        let item = news[indexPath.row]
        cell.configure(with: item) { [presenter] urlString in
            await presenter.loadImage(urlString: urlString)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = news[indexPath.row]
        presenter.selectNews(item)
    }
}
