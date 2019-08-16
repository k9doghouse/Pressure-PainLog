//
//  TableViewController.swift
//  PressureTracker2
//
//  thanks to: Reinder, https://learnappmaking.com/pass-data-view-controllers-swift-how-to/
//
//  Created by murph on 7/10/19.
//  Copyright © 2019 k9doghouse. All rights absurd.
//

import UIKit

class TableViewController: UITableViewController {

    var passedData:[PointEntry] = []
    var passedData01:[DataCenter] = []

    fileprivate let CELL_ID = "CELL_ID"

    override func viewDidLoad() {

        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_ID)
    }
        /// TODO: Filter into time segments


    override func numberOfSections(in tableView: UITableView) -> Int
        { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        { return passedData.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath)
        cell.textLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        cell.backgroundColor      = #colorLiteral(red: 0.1184270903, green: 0.1533128619, blue: 0.128531754, alpha: 1)
        cell.textLabel?.text      = passedData[indexPath.row].bigTitle
        return cell
    }



}
