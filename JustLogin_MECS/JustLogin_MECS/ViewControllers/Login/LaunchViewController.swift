//
//  ViewController.swift
//  JustLogin_MECS
//
//  Created by Samrat on 5/1/17.
//  Copyright © 2017 SMRT. All rights reserved.
//

import UIKit

class LaunchViewController: BaseViewController {

    /***********************************/
    // MARK: - Properties
    /***********************************/
    
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    struct LaunchContent {
        var imageName: String!
        var description: String!
    }
    
    /***********************************/
    // MARK: - View Lifecycle
    /***********************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Hide the navigation bar
        navigationController?.isNavigationBarHidden = true
        
        // Register to the login successful notification
        NotificationCenter.default.addObserver(self, selector: #selector(LaunchViewController.navigateToDashboard), name: Notification.Name(Constants.Notifications.LoginSuccessful), object: nil)
        
        automaticallyAdjustsScrollViewInsets = false;
        
        setCustomLayoutForCollectionView()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /***********************************/
    // MARK: - Actions
    /***********************************/
    
    @IBAction func signUpTapped(_ sender: Any) {
        
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
    }
    
    /***********************************/
    // MARK: - Helpers
    /***********************************/
    
    /**
     Method to set custom layout to the collection view. Removes the spaces between the cells, which was not possible to remove in the default flow layout.
     */
    func setCustomLayoutForCollectionView() {
        let customFlow = UICollectionViewFlowLayout()
        customFlow.itemSize = CGSize(width:collectionView.frame.width, height:collectionView.frame.height)
        customFlow.scrollDirection = UICollectionViewScrollDirection.horizontal
        customFlow.minimumInteritemSpacing = 0
        customFlow.minimumLineSpacing = 0
        collectionView.collectionViewLayout = customFlow
    }
    
    /**
     Method to set the content that will be displayed in the collection view.
     */
    func getLaunchContent() -> [LaunchContent] {
        // TODO: - Put these in the constants file.
        return [LaunchContent(imageName:"", description:"Effortlessly Expense Reporting."),
                LaunchContent(imageName:"", description:"Automatically extract data from receipts."),
                LaunchContent(imageName:"", description:"Know everything about your expense."),
                LaunchContent(imageName:"", description:"Track mileage with your phone.")]
    }
    
    /**
     Method to navigate to the dashboard after the user has logged in.
     */
    func navigateToDashboard(notification:Notification) {
        if let user = notification.object as? User {
            switch user.role {
            case .Submitter:
                // Navigate to submitter dashboard
                navigateToSubmitterDashboard()
            case .Admin, .Approver:
                // Navigate to admin/approver dashboard
                navigateToAdminAndApproverDashboard()
            }
        }
    }
    
    /**
     Method to navigate to the submitter's dashboard.
     */
    func navigateToSubmitterDashboard() {
        
        //let service = LoginService()
        //service.loginUser(withOrganizationName: "fargotest", userId: "admin", password: "admin", completionHandler: { _ in })
        
        //let service = OrganizationDetailsService()
        //service.getOrganizationDetail { _ in }
        
        //let submitterDashboard = UIStoryboard(name: Constants.StoryboardIds.DashboardStoryboard, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.SubmitterDashboard) as! UITabBarController
        
        //navigationController?.pushViewController(submitterDashboard, animated: true)
    }
    
    /**
     Method to navigate to the admin/approver's dashboard.
     */
    func navigateToAdminAndApproverDashboard() {
        let approverAndAdminDashboard = UIStoryboard(name: Constants.StoryboardIds.DashboardStoryboard, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIds.ApproverAndAdminDashboard) as! UITabBarController
        
        navigationController?.pushViewController(approverAndAdminDashboard, animated: true)
    }
}

extension LaunchViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getLaunchContent().count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifiers.LaunchCollectionViewCellIdentifier, for: indexPath) as! LaunchCollectionViewCell
        // TODO: - Uncomment once you have the images.
        //let imageName = getLaunchContent()[indexPath.row].imageName
        //cell.imgView.image = UIImage.init(named: imageName!)
        cell.lblDescription.text = getLaunchContent()[indexPath.row].description
        return cell
    }
}

extension LaunchViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageWidth = self.collectionView.frame.size.width
        pageControl.currentPage = Int(self.collectionView.contentOffset.x / pageWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
