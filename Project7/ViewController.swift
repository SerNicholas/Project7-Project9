//
//  ViewController.swift
//  Project7
//
//  Created by Nikola on 9/1/19.
//  Copyright © 2019 Nikola. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var creditsBarButton: UIBarButtonItem!
    var searchBarButton: UIBarButtonItem!
    var homeButton: UIBarButtonItem!
    var filtered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barButtons()
        fetchJSON()
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filtered {
            return filteredPetitions.count
        } else {
            return petitions.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var petition: Petition
        
        if filtered {
            petition = filteredPetitions[indexPath.row]
        } else {
            petition = petitions[indexPath.row]
        }
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}





extension ViewController {
    
    @objc func searchPetitions() {
        let ac = UIAlertController(title: "Search petitions...", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) {
            [weak self, weak ac ] _ in
            guard let title = ac?.textFields?[0].text else { return }
            self?.searchTitle(title)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    
    
    func searchTitle(_ item: String) {
        let itemLowercased = item.lowercased() // first part that makes search function case insensitive
        filtered = true
        filteredPetitions.removeAll()
        for i in petitions {
            // second  part that makes SEARCH function case insensitive
            if i.title.lowercased().contains(itemLowercased) || i.body.lowercased().contains(itemLowercased) {
                filteredPetitions.append(i)
            }
        }
        self.tableView.reloadData()
    }
    
    func barButtons() {
        // Adding Credits button
        creditsBarButton = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        // adding Search Bar Button
        searchBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchPetitions))
        //adding home button to return to home page after searching through petitions is done
        homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(returnHome))
        navigationItem.rightBarButtonItems = [creditsBarButton, searchBarButton]
        navigationItem.leftBarButtonItem = homeButton
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits To:", message: "We Are The People Of The Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    @objc func returnHome() {
        fetchJSON()
    }
    
    func parse(json: Data) {
        // 1. creating an instance of JSONDecoder which is dedicated to convert between JSON and Codable objects
        let decoder = JSONDecoder()
        //2. calling a decode() method on that decoder, asking it to convert our json data into Petiotion object
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            //3 if the json was converted succssfully asign the results array to our petitions property than reload table view
            petitions = jsonPetitions.results
            filtered = false
            //NEVER do UI work on the backround thread. Returning it to the main thread =>
            DispatchQueue.main.async { [ weak self ] in
                self?.tableView.reloadData()
            }
        } else {
            showError()
        }
    }
    
    func fetchJSON() {
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    return
                }
            }
            self?.showError()
        }
    }
    
    
    
    func showError() {
        DispatchQueue.main.async { [weak self ] in
            let ac = UIAlertController(title: "Loading Error", message: "There was the problem loading the feed. Check your connection or try again!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
}

