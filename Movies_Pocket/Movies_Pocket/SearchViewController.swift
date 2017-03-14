//
//  SearchViewController.swift
//  Movies Pocket
//
//  Created by Diego Manuel Molina Canedo on 28/2/17.
//  Copyright © 2017 Universidad Pontificia de Salamanca. All rights reserved.
//

import UIKit
import FTPopOverMenu_Swift

class SearchViewController: CollectionBaseViewController, UISearchBarDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    
    let gradient = CAGradientLayer()
    
    var showingNowPlaying = true
    var menuOptionNameArray : [String] = ["Favoritos","Novedades","About"]
    var menuOptionImageNameArray : [String] = ["favorite-menu-icon","news","about-us"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        APIHelper.getNowPlaying(page: 1, updatingCollectionView: collectionView)
        gradient.colors = [UIColor.init(red: 0.5, green: 0, blue: 0.1, alpha: 0.2).cgColor, UIColor.init(red: 0.53, green: 0.06, blue: 0.27, alpha: 1.0).cgColor]
        backgroundView.layer.insertSublayer(gradient, at: 0)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            let menuConfiguration = FTConfiguration.shared
            menuConfiguration.menuWidth = self.view.frame.width/3
            menuConfiguration.textAlignment = .natural
            menuConfiguration.textFont = UIFont(name: "HelveticaNeue-Light", size: 30.0)!
        }
        else{
            let menuConfiguration = FTConfiguration.shared
            menuConfiguration.menuWidth = self.view.frame.width*2/3
            menuConfiguration.textAlignment = .natural
            menuConfiguration.textFont = UIFont(name: "HelveticaNeue-Light", size: 20.0)!
        }
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeynoard))
        self.view.addGestureRecognizer(tapGR)
    
    }

    @objc func dismissKeynoard(){
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard var searchString = searchBar.text else{
            showingNowPlaying = true
            return
        }
        showingNowPlaying = false
        appDelegate?.model.foundItems = []
        collectionView.reloadData()
        
        searchString = searchString.replacingOccurrences(of: " ", with: "+")
        APIHelper.getSearch(page: 1, searchString: searchString, collectionView: collectionView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Get more pages if showing news
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) / scrollView.contentSize.height > 0.95) && showingNowPlaying){
            APIHelper.getNowPlaying(page: appDelegate!.model.foundItems.count/20 + 1, updatingCollectionView: collectionView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradient.frame = view.bounds
        
        backgroundView.layoutIfNeeded()
        collectionView.collectionViewLayout.invalidateLayout()
     }
    
    @IBAction func menuButtonAction(_ sender: UIButton) {
        FTPopOverMenu.showForSender(sender: sender, with: menuOptionNameArray, menuImageArray: menuOptionImageNameArray, done: { (selectedIndex) -> () in
            sender.setBackgroundImage(UIImage.init(named: "menu-image-empty"), for: .normal)
            
            switch (selectedIndex){
            case 0:
                self.showingNowPlaying = false
                let mediaArray = Media.createMediaArrayFrom(mediaEntityArray: self.appDelegate?.storedFavoriteMedia ?? [])
                self.appDelegate?.model.foundItems = mediaArray
                self.collectionView.reloadData()
                break;
            case 1:
                self.showingNowPlaying = true
                self.appDelegate?.model.foundItems = []
                self.collectionView.reloadData()
                APIHelper.getNowPlaying(page: 1, updatingCollectionView: self.collectionView)
                break;
            case 2:
                self.performSegue(withIdentifier: "AboutSegue", sender: self)
                break;
            default:break;
            }
            print(selectedIndex)
        }) {
           sender.setBackgroundImage(UIImage.init(named: "menu-image-empty"), for: .normal)
        }
        
        sender.setBackgroundImage(UIImage.init(named: "menu-image-full"), for: .normal)    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
