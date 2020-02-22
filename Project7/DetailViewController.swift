//
//  DetailViewController.swift
//  Project7
//
//  Created by Nikola on 9/1/19.
//  Copyright © 2019 Nikola. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let detailItem = detailItem else { return }
        
        let html = """
                    <html>
                    <head>
                    <meta name ="viewport" content="width=device-width, initial-scale=1">
                    <style> body { font-size: 120% } </style>
                    </head>
                    <body>
                    \(detailItem.body)
                    </html>
                    """
        webView.loadHTMLString(html, baseURL: nil)
        
    }
    
    
    
}
