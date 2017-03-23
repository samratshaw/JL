//
//  AddExpenseManager.swift
//  JustLogin_MECS
//
//  Created by Samrat on 24/2/17.
//  Copyright © 2017 SMRT. All rights reserved.
//

import Foundation
import UIKit

class AddExpenseManager {
    
    var fields: [[ExpenseAndReportField]] = []
    
    var expenseService: IExpenseService = ExpenseService()
    
    var lastSelectedNavigationIndex: IndexPath?
    
    var dictCells: [IndexPath:AddExpenseBaseTableViewCell] = [:]
    
    init() {
        updateFields()
    }
}
/***********************************/
// MARK: - Data tracking methods
/***********************************/
extension AddExpenseManager {
    /**
     * Populate the cells from the table view.
     */
    func populateCells(fromController controller: AddExpenseViewController) {
        for section in 0..<fields.count {
            for row in 0..<fields[section].count {
                let indexPath = IndexPath(row: row, section: section)
                let cell = controller.tableView(controller.tableView, cellForRowAt: indexPath) as! AddExpenseBaseTableViewCell
                dictCells[indexPath] = cell
            }
        }
    }
    
    /**
     * Get the existing cells that have already been populated before.
     */
    func getExistingCells() -> [IndexPath:AddExpenseBaseTableViewCell] {
        return dictCells
    }
    
    /**
     * Method to get all the expenses that need to be displayed.
     */
    func getExpenseFields() -> [[ExpenseAndReportField]] {
        return fields
    }
    
    /**
     * Get the cell identifier for the indexPath.
     * This works based on the expense field type & accordingly the cell is displayed.
     */
    func getTableViewCellIdentifier(forIndexPath indexPath: IndexPath) -> String {
        let expenseField = (fields[indexPath.section])[indexPath.row]
        switch expenseField.fieldType {
        case ExpenseAndReportFieldType.category.rawValue:
            return Constants.CellIdentifiers.addExpenseTableViewCellCategory
        case ExpenseAndReportFieldType.date.rawValue:
            return Constants.CellIdentifiers.addExpenseTableViewCellDate
        case ExpenseAndReportFieldType.currencyAndAmount.rawValue:
            return Constants.CellIdentifiers.addExpenseTableViewCellCurrencyAndAmount
        case ExpenseAndReportFieldType.text.rawValue:
            return Constants.CellIdentifiers.addExpenseTableViewCellWithTextField
        case ExpenseAndReportFieldType.textView.rawValue:
            return Constants.CellIdentifiers.addExpenseTableViewCellWithTextView
        case ExpenseAndReportFieldType.imageSelection.rawValue:
            return Constants.CellIdentifiers.addExpenseTableViewCellWithImageSelection
        case ExpenseAndReportFieldType.dropdown.rawValue:
            return Constants.CellIdentifiers.addExpenseTableViewCellWithMultipleSelection
        default:
            return Constants.CellIdentifiers.addExpenseTableViewCellWithTextField
        }
    }
}
/***********************************/
// MARK: - UI updating
/***********************************/
extension AddExpenseManager {
    
    func formatCell(_ cell: AddExpenseBaseTableViewCell, forIndexPath indexPath: IndexPath) {
        let expenseField = (fields[indexPath.section])[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.updateView(withField: expenseField)
    }
}
/***********************************/
// MARK: - Services
/***********************************/
extension AddExpenseManager {
    /**
     * Method to get all the expenses that need to be displayed.
     */
    func addExpenseWithInput(completionHandler: (@escaping (ManagerResponseToController<Void>) -> Void)) {
        let payload = getPayload()
        
        expenseService.create(payload: payload) { (result) in
            switch(result) {
            case .success(_):
                completionHandler(ManagerResponseToController.success())
            case .error(let serviceError):
                completionHandler(ManagerResponseToController.failure(code: serviceError.code, message: serviceError.message))
            case .failure(let message):
                completionHandler(ManagerResponseToController.failure(code: "", message: message))
            }
        }
    }
}
/***********************************/
// MARK: - Actions
/***********************************/
extension AddExpenseManager {
    /**
     * This will return true if we have to navigate to details screen for choosing a particular value.
     * Else return false.
     */
    func checkIfNavigationIsRequired(forIndexPath indexPath: IndexPath) -> Bool {
        let expenseField = getExpenseFields()[indexPath.section][indexPath.row]
        
        // The below checks are done on the field TYPE.
        if expenseField.fieldType == ExpenseAndReportFieldType.category.rawValue ||
            expenseField.fieldType == ExpenseAndReportFieldType.currencyAndAmount.rawValue ||
            expenseField.fieldType == ExpenseAndReportFieldType.dropdown.rawValue {
            return true
        }
        
        // The below checks are done on the JSON PARAMETER of the field.
        if expenseField.jsonParameter == Constants.RequestParameters.Expense.reportId {
            return true
        }
        
        return false
    }
    
    func getDetailsNavigationController(forIndexPath indexPath: IndexPath, withDelegate delegate: AddExpenseViewController) -> UIViewController {
        let expenseField = getExpenseFields()[indexPath.section][indexPath.row]
        
        // This will be used when setting the selected value.
        lastSelectedNavigationIndex = indexPath
        
        if expenseField.fieldType == ExpenseAndReportFieldType.category.rawValue {
            return getReviewSelectCategoryController(forIndexPath: indexPath, withDelegate: delegate)
        }
        
        if expenseField.fieldType == ExpenseAndReportFieldType.currencyAndAmount.rawValue {
            return getReviewSelectCurrencyController(forIndexPath: indexPath, withDelegate: delegate)
        }
        
        if expenseField.jsonParameter == Constants.RequestParameters.Expense.reportId {
            return getReviewSelectReportController(forIndexPath: indexPath, withDelegate: delegate)
        }
        
        // TODO - Need to handle multiple choice for dropdown report fields
        return UIViewController()
    }
    /**
     * Sing the other cells are already being checked at the controller,
     */
    func performActionForSelectedCell(_ cell: AddExpenseBaseTableViewCell, forIndexPath indexPath: IndexPath) {
        cell.makeFirstResponder()
    }
    
    func validateInputs() -> (success: Bool, errorMessage: String) {
        for (indexPath, cell) in dictCells {
            let validation = cell.validateInput(withField: fields[indexPath.section][indexPath.row])
            if !validation.success {
                return validation
            }
        }
        return (true, Constants.General.emptyString)
    }
    
    func updateCellBasedAtLastSelectedIndex(withId id: String, value: String) {
        if lastSelectedNavigationIndex != nil {
            let cell = dictCells[lastSelectedNavigationIndex!]
            cell?.updateView(withId: id, value: value)
        }
    }
    
    /* This will be enabled in Phase 2
    
    // TODO - This method needs to check if the exchange rate is already present, then dont add it.
    func addExchangeRateField() {
        var exchangeRate = ExpenseAndReportField()
        exchangeRate.name = "Exchange Rate"
        exchangeRate.fieldType = ExpenseAndReportFieldType.text.rawValue
        exchangeRate.jsonParameter = Constants.RequestParameters.Expense.exchange
        exchangeRate.isMandatory = true
        exchangeRate.isEnabled = true
        
        fields[0].append(exchangeRate)
    }
    
    // TODO - The same needs to be removed from the dictCells.
    func removeExchangeRateField() {
        if fields[0].last?.jsonParameter == Constants.RequestParameters.Expense.exchange {
            fields[0].removeLast()
        }
    }
     
     */
}
/***********************************/
// MARK: - Data manipulation
/***********************************/
extension AddExpenseManager {
    
    func updateFields() {
        // Mandatory fields
        var category = ExpenseAndReportField()
        category.name = "Category"
        category.fieldType = ExpenseAndReportFieldType.category.rawValue
        category.isMandatory = true
        category.isEnabled = true
        
        var date = ExpenseAndReportField()
        date.name = "Date"
        date.jsonParameter = Constants.RequestParameters.Expense.date
        date.fieldType = ExpenseAndReportFieldType.date.rawValue
        date.isMandatory = true
        date.isEnabled = true
        
        // By default choose the base currency id
        var currencyAndAmount = ExpenseAndReportField()
        currencyAndAmount.fieldType = ExpenseAndReportFieldType.currencyAndAmount.rawValue
        currencyAndAmount.isMandatory = true
        currencyAndAmount.isEnabled = true
        
        fields.append([category, date, currencyAndAmount])
        
        // Custom fields
        if let paymentModeField = Singleton.sharedInstance.organization?.expenseFields["paymentMode"], paymentModeField.isEnabled {
            fields.append([paymentModeField])
        }
        
        var sectionThree: [ExpenseAndReportField] = []
        if let merchantNameField = Singleton.sharedInstance.organization?.expenseFields["merchant"], merchantNameField.isEnabled {
            sectionThree.append(merchantNameField)
        }
        
        if let referenceNumberField = Singleton.sharedInstance.organization?.expenseFields["reference"], referenceNumberField.isEnabled {
            sectionThree.append(referenceNumberField)
        }
        
        if let locationField = Singleton.sharedInstance.organization?.expenseFields["location"], locationField.isEnabled {
            sectionThree.append(locationField)
        }
        
        if let descriptionField = Singleton.sharedInstance.organization?.expenseFields["description"], descriptionField.isEnabled {
            sectionThree.append(descriptionField)
        }
        
        fields.append(sectionThree)
        
        // Section 4
        var sectionFour: [ExpenseAndReportField] = []
        if let isBillableField = Singleton.sharedInstance.organization?.expenseFields["isBillable"], isBillableField.isEnabled {
            sectionFour.append(isBillableField)
        }
        
        if let customerField = Singleton.sharedInstance.organization?.expenseFields["customer"], customerField.isEnabled {
            sectionFour.append(customerField)
        }
        
        if let projectField = Singleton.sharedInstance.organization?.expenseFields["project"], projectField.isEnabled {
            sectionFour.append(projectField)
        }
        
        var addToReport = ExpenseAndReportField()
        addToReport.name = "Add to Report"
        addToReport.jsonParameter = Constants.RequestParameters.Expense.reportId
        addToReport.fieldType = ExpenseAndReportFieldType.dropdown.rawValue
        addToReport.isMandatory = false
        addToReport.isEnabled = true
        
        sectionFour.append(addToReport)
        
        // Add the section 4 elements to the complete fields
        fields.append(sectionFour)
        
        // TODO - Add the custom fields
        
        // Finally add the image block
        var attachImage = ExpenseAndReportField()
        attachImage.fieldType = ExpenseAndReportFieldType.imageSelection.rawValue
        attachImage.isMandatory = true
        attachImage.isEnabled = true
        
        fields.append([attachImage])
    }
}
/***********************************/
// MARK: - Helpers
/***********************************/
extension AddExpenseManager {
    
    func getReviewSelectCategoryController(forIndexPath indexPath: IndexPath, withDelegate delegate: AddExpenseViewController) -> ReviewSelectCategoryViewController {
        let controller = UIStoryboard(name: Constants.StoryboardIds.categoryStoryboard, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.reviewSelectCategoryViewController) as! ReviewSelectCategoryViewController
        controller.delegate = delegate
        
        // Now check if it already has a preSelected value
        let cell = dictCells[indexPath]!
        
        let expenseField = getExpenseFields()[indexPath.section][indexPath.row]
        if cell.validateInput(withField: expenseField).success {
            let payload = cell.getPayload(withField: expenseField)
            if !payload.isEmpty {
                let preSelectedCategoryId = payload[Constants.RequestParameters.Expense.categoryId] as! String
                controller.preSelectedCategory = Singleton.sharedInstance.organization?.categories[preSelectedCategoryId]
            }
        }
        return controller
    }
    
    func getReviewSelectCurrencyController(forIndexPath indexPath: IndexPath, withDelegate delegate: AddExpenseViewController) -> ReviewSelectCurrencyViewController {
        let controller = UIStoryboard(name: Constants.StoryboardIds.currencyStoryboard, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.reviewSelectCurrencyViewController) as! ReviewSelectCurrencyViewController
        controller.delegate = delegate
        
        // Now check if it already has a preSelected value
        let cell = dictCells[indexPath]!
        
        let expenseField = getExpenseFields()[indexPath.section][indexPath.row]
        let payload = cell.getPayload(withField: expenseField)
        
        if !payload.isEmpty {
            let preSelectedCurrencyId = payload[Constants.RequestParameters.Expense.currencyId] as! String
            controller.preSelectedCurrency = Singleton.sharedInstance.organization?.currencies[preSelectedCurrencyId]
        }
        return controller
    }
    
    func getReviewSelectReportController(forIndexPath indexPath: IndexPath, withDelegate delegate: AddExpenseViewController) -> ReviewSelectReportViewController {
        let controller = UIStoryboard(name: Constants.StoryboardIds.reportStoryboard, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.reviewSelectReportViewController) as! ReviewSelectReportViewController
        controller.delegate = delegate
        
        // Now check if it already has a preSelected value
        let cell = dictCells[indexPath]!
        
        let expenseField = getExpenseFields()[indexPath.section][indexPath.row]
        
        if cell.validateInput(withField: expenseField).success {
            let payload = cell.getPayload(withField: expenseField)
            if !payload.isEmpty {
                controller.preSelectedReportId = payload[Constants.RequestParameters.Expense.reportId] as? String
            }
        }
        return controller
    }
    
    /**
     * Get payload from all the cells of the table.
     */
    func getPayload() -> [String: Any] {
        var payload = [String:Any]()
        for (indexPath, cell) in dictCells {
            payload = payload.merged(with: cell.getPayload(withField: fields[indexPath.section][indexPath.row]))
        }
        return payload
    }
}
