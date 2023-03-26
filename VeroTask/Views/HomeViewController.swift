
//
//  HomeViewController.swift
//  VeroTask
//
//  Created by Yigit Ozdamar on 24.03.2023.
//

import UIKit
import RealmSwift
import VisionKit

class HomeViewController: UIViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
   
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController()
    private let refreshControl = UIRefreshControl()
    let realm = try! Realm()
    var tasks: Results<PersonTaskRM>?
    var searchText = ""
    
    private let dataScannerViewController = DataScannerViewController(recognizedDataTypes: [.text()],
                                                                      qualityLevel: .fast,
                                                                      recognizesMultipleItems: false,
                                                                      isHighFrameRateTrackingEnabled: true,
                                                                      isPinchToZoomEnabled: true,
                                                                      isGuidanceEnabled: true,
                                                                      isHighlightingEnabled: true)
    
    private var isScannerAvailable: Bool { DataScannerViewController.isSupported && DataScannerViewController.isAvailable }

    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = realm.objects(PersonTaskRM.self)
        setupSearchBar()
        setupQRMenu()
        dataScannerViewController.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.reloadData()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        self.searchText = searchBar.text!
        
        if self.searchText.isEmpty {
            tasks = realm.objects(PersonTaskRM.self)
        }else {
            tasks = realm.objects(PersonTaskRM.self).where{$0.task.contains(searchText, options: .caseInsensitive) || $0.title.contains(searchText, options: .caseInsensitive) || $0.descriptions.contains(searchText, options: .caseInsensitive)}
        }
        tableView.reloadData()
    }
    
    
    func setupSearchBar(){
        searchController.loadViewIfNeeded()
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
    }
    
    func setupQRMenu(){
        
        let qrScanButton = UIBarButtonItem(title: "QR Scan", style: .plain, target: self, action: #selector(qrScanner))
        let quitButton = UIBarButtonItem(image: UIImage(systemName: "escape"), style: .plain, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItems = [quitButton,qrScanButton]

    }
    
    @objc func logout() {
        UserDefaults.standard.removeAccessToken()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navigationController?.popToRootViewController(animated: true)
    }


    @objc func refreshData(){
        APIManager.shared.requestUrl(accessToken: UserDefaults.standard.getAccessToken()!) { [weak self] personTaskRM in
            DispatchQueue.main.async {
                guard let self else { return }
                self.tasks = personTaskRM
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func qrScanner(){
        if isScannerAvailable {
            present(dataScannerViewController, animated: true)
            try? dataScannerViewController.startScanning() 
        }
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
        
        if let task = tasks?[indexPath.row] {
            cell.titleLabel.text = task.title
            cell.taskLabel.attributedText = attributedString(for: task.task, search: searchText)
            cell.descriptionsLabel.attributedText = attributedString(for: task.descriptions, search: searchText)
            cell.view.backgroundColor = UIColor.hexStringToUIColor(hex: task.color)
        }
        return cell
    }
    
    func attributedString(for text: String, search: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: search, options: .caseInsensitive)
        if range.location != NSNotFound {
            attributedString.addAttribute(.backgroundColor, value: UIColor.yellow, range: range)
        }
        return attributedString
    }

}

extension HomeViewController: DataScannerViewControllerDelegate {
    
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        switch item {
            case .text(let text):
                print("text: \(text.transcript)")
                searchText = text.transcript
                searchController.searchBar.text = searchText
                updateSearchResults(for: searchController)
                dismiss(animated: true)
            case .barcode:
                break
            default:
                print("unexpected item")
        }
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in addedItems {
            switch item {
                case .text(let text):
                    print("Text Observation - \(text.observation)")
                    print("Text transcript - \(text.transcript)")
                    
                case .barcode:
                    break
                @unknown default:
                    print("Should not happen")
            }
        }
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
        print("Scanner became unavailable")
    }
}

