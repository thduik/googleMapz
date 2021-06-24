//
//  CompletionTableViewController.swift
//  googleMapz
//
//  Created by Macbook on 6/21/21.
//

import UIKit
import MapKit

class CompletionTableViewController: UITableViewController {
    var completionArray = [MKLocalSearchCompletion]() {
        didSet {
            self.tableView.reloadData()
            self.tableView.contentOffset = .zero
        }
    }
    
    var selectionHandler: (MKLocalSearchCompletion) -> Void = {_ in}
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.completionArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = self.completionArray[indexPath.row].title + ". " + self.completionArray[indexPath.row].title
        // Configure the cell...
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectionHandler(completionArray[indexPath.row])
    }

   

}
