//
//  WebView.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 08.02.2026.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {

    private let initialURL: String

    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = self
        wv.uiDelegate = self
        wv.allowsBackForwardNavigationGestures = true
        wv.translatesAutoresizingMaskIntoConstraints = false
        return wv
    }()

    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .bar)
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.isHidden = true
        return pv
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        return rc
    }()

    private var progressObservation: NSKeyValueObservation?

    private lazy var backButton = UIBarButtonItem(
        image: UIImage(systemName: "chevron.backward"),
        style: .plain,
        target: self,
        action: #selector(goBack)
    )

    private lazy var forwardButton = UIBarButtonItem(
        image: UIImage(systemName: "chevron.forward"),
        style: .plain,
        target: self,
        action: #selector(goForward)
    )

    private lazy var reloadButton = UIBarButtonItem(
        barButtonSystemItem: .refresh,
        target: self,
        action: #selector(reload)
    )

    init(url: String) {
        self.initialURL = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayout()
        setupToolbar()
        setupObservers()

        load(initialURL)
    }

    deinit {
        progressObservation?.invalidate()
    }

    private func setupLayout() {
        view.addSubview(progressView)
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        webView.scrollView.refreshControl = refreshControl
    }

    private func setupToolbar() {
        navigationItem.largeTitleDisplayMode = .never
        toolbarItems = [
            backButton,
            UIBarButtonItem.flexibleSpace(),
            forwardButton,
            UIBarButtonItem.flexibleSpace(),
            reloadButton
        ]
        navigationController?.isToolbarHidden = false
        updateNavButtons()
    }

    private func setupObservers() {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self else { return }
            let p = Float(webView.estimatedProgress)
            self.progressView.progress = p
            self.progressView.isHidden = (p >= 1.0)
        }
    }

    private func load(_ url: String) {
        guard let url = URL(string: url) else {
            showError("Некорректный URL")
            return
        }
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        webView.load(request)
    }

    private func updateNavButtons() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }

    @objc private func goBack() { webView.goBack() }
    @objc private func goForward() { webView.goForward() }
    @objc private func reload() { webView.reload() }

    @objc private func onPullToRefresh() {
        webView.reload()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка загрузки", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self else { return }
            self.webView.reload()
        })
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        present(alert, animated: true)
    }
}

extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        updateNavButtons()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
        refreshControl.endRefreshing()
        updateNavButtons()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        refreshControl.endRefreshing()
        updateNavButtons()
        showError(error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
        refreshControl.endRefreshing()
        updateNavButtons()
        showError(error.localizedDescription)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        let scheme = (url.scheme ?? "").lowercased()

        switch scheme {
        case "http", "https":
            decisionHandler(.allow)

        case "mailto", "tel", "itms-apps":
            UIApplication.shared.open(url)
            decisionHandler(.cancel)

        default:
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        }
    }
}

extension WebViewController: WKUIDelegate {

    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: webView.title ?? "Сообщение", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(alert, animated: true)
    }
}
