//
//  ReportDetailsViewController.swift
//  JustLogin_MECS
//
//  Created by Samrat on 27/2/17.
//  Copyright © 2017 SMRT. All rights reserved.
//

import Foundation
import UIKit

class ReportDetailsViewController: BaseViewControllerWithTableView {
    
    /***********************************/
    // MARK: - Properties
    /***********************************/
    let manager = ReportDetailsManager()
    
    var report: Report?
    
    @IBOutlet weak var headerView: ReportDetailsHeaderView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var btnSubmit: UIBarButtonItem!
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    @IBOutlet weak var btnMoreOptions: UIBarButtonItem!
    
    var footerView: ReportDetailsFooterView = ReportDetailsFooterView.instanceFromNib()
    
    let segmentedControl = UISegmentedControl(items: ["Expenses", "More Details", "History"]) // TODO - Move to constants
    
    /***********************************/
    // MARK: - View Lifecycle
    /***********************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This will help the header update faster
        manager.report = report!
        
        tableView.tableFooterView = footerView
        
        updateTableHeaderAndFooter()
        fetchReportDetails()
    }
}
/***********************************/
// MARK: - Helpers
/***********************************/
extension ReportDetailsViewController {
    func updateUIAfterSuccessfulResponse() {
        updateTableHeaderAndFooter()
        updateToolbarItems()
        tableView.reloadData()
    }
    
    func updateToolbarItems() {
        if !manager.isReportEditable() {
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
            
            let btnArchive = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: nil)
            btnArchive.title = "Archive"
            
            let btnViewAsPDF = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: nil)
            btnViewAsPDF.title = "View As PDF"
            
            toolbar.items = [flexibleSpace, btnArchive, flexibleSpace, btnViewAsPDF, flexibleSpace]
        }
    }
    
    func getHeaderViewWithSegmentedControl() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 48)) // TODO - Move to constants
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        segmentedControl.frame = CGRect(x: 20, y: 10, width: view.frame.width - 40, height: 28)
        segmentedControl.selectedSegmentIndex = manager.getSelectedSegmentedControlIndex()
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChange(_:)), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        return view
    }
    
    func updateTableHeaderAndFooter() {
        headerView.updateView(withManager: manager)
        footerView.updateView(withManager: manager)
    }
    
    func navigateToApproversList() {
        if report != nil {
            let approversListViewController = UIStoryboard(name: Constants.StoryboardIds.reportStoryboard, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.approversListViewController) as! ApproversListViewController
            approversListViewController.report = report!
            approversListViewController.delegate = self
            // TODO - Create a utility function for this
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(approversListViewController, animated: true)
        } else {
            log.error("Report found nil while unwrapping in report details")
        }
    }
}
/***********************************/
// MARK: - Actions
/***********************************/
extension ReportDetailsViewController {
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func submitButtonTapped(_ sender: UIBarButtonItem) {
        navigateToApproversList()
    }
    
    @IBAction func moreOptionsButtonTapped(_ sender: UIBarButtonItem) {
        // TODO: - Display the action sheet here
    }
    
    func segmentedControlValueChange(_ sender: UISegmentedControl) {
        manager.setSelectedSegmentedControlIndex(sender.selectedSegmentIndex)
        
        if manager.shouldDisplayFooter() {
            tableView.tableFooterView = footerView
        } else {
            tableView.tableFooterView = nil
        }
        
        tableView.reloadData()
    }
}
/***********************************/
// MARK: - UITableViewDataSource
/***********************************/
extension ReportDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return manager.getCell(withTableView: tableView, atIndexPath: indexPath)
    }
}
/***********************************/
// MARK: - UITableViewDelegate
/***********************************/
extension ReportDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return getHeaderViewWithSegmentedControl()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return getHeaderViewWithSegmentedControl().frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return manager.getHeightForRowAt(withTableView: tableView, atIndexPath: indexPath)
    }
}
/***********************************/
// MARK: - UITableViewDelegate
/***********************************/
extension ReportDetailsViewController:ApproversListDelegate {
    func reportSubmitted() {
        fetchReportDetails()
    }
}
/***********************************/
// MARK: - Service Call
/***********************************/
extension ReportDetailsViewController {
    /**
     * Method to fetch expenses that will be displayed in the tableview.
     */
    func fetchReportDetails() {
        showLoadingIndicator(disableUserInteraction: false)
        manager.fetchReportDetails(withReportId: report!.id) { [weak self] (response) in
            guard let `self` = self else {
                log.error("Self reference missing in closure.")
                return
            }
            switch(response) {
            case .success(let report):
                self.report = report
                self.updateUIAfterSuccessfulResponse()
                self.hideLoadingIndicator(enableUserInteraction: true)
            case .failure(_, _):
                self.hideLoadingIndicator(enableUserInteraction: true)
                // TODO: - Need to kick the user out of this screen & send to the expense list.
                Utilities.showErrorAlert(withMessage: "Something went wrong. Please try again.", onController: self)// TODO: - Hard coded message. Move to constants or use the server error.
            }
        }
    }
}
