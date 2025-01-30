import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var progressView: UIProgressView!

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Настройка на прогресивния индикатор
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 2)
        view.addSubview(progressView)

        // Наблюдаване на прогрес на зареждане
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

        // Добавяне на бутон "Назад"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(goBack))

        // Зареждане на уебсайта
        if let url = URL(string: "https://bgkontrola.bg/") {
            let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
            webView.load(urlRequest)
        }

        // Разрешаване на жестове за назад/напред
        webView.allowsBackForwardNavigationGestures = true
    }

    // Обработка на промени в прогрес на зареждане
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            if webView.estimatedProgress >= 1.0 {
                progressView.isHidden = true
            } else {
                progressView.isHidden = false
            }
        }
    }

    // Бутон "Назад"
    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    // Обработка на грешки при зареждане
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Failed to load website: \(error.localizedDescription)")
        // Покажи съобщение за грешка на потребителя
        let alert = UIAlertController(title: "Грешка", message: "Неуспешно зареждане на сайта.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Почистване на наблюдателя
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}
