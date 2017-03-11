//
//  MPC+CollectionProtocols.swift
//  Movies Pocket
//
//  Created by Diego Manuel Molina Canedo on 21/2/17.
//  Copyright © 2017 Universidad Pontificia de Salamanca. All rights reserved.
//

import Foundation
import UIKit

extension CollectionBaseViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return  appDelegate!.model.foundItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! MediaCell
        cell.image.image = UIImage() //nil
        
        let item = appDelegate!.model.foundItems[indexPath.row]
        
        
        let loadingView: UIView
        let activityIndicator: UIActivityIndicatorView
        
        (loadingView,activityIndicator) = InterfaceHelper.createImageLoadingView(image: cell.image)
        
        activityIndicator.startAnimating()
        cell.image.addSubview(loadingView)
        
        APIHelper.getImage(image: cell.image,
                           imageString: item.poster_path,
                           onCompletion:{
                            activityIndicator.stopAnimating()
                            loadingView.removeFromSuperview()
        },
                           onError:{
                            activityIndicator.stopAnimating()
                            loadingView.removeFromSuperview()
        
        })
        
        cell.title.text = item.title
        if item.overview == "" {
            cell.overview.text = "No hay sinopsis disponible"
        }
        else{
            cell.overview.text = item.overview
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //PORTRAIT
        let cv = collectionView
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        
        var size: CGSize
        if(collectionView.frame.height > collectionView.frame.width){
            
            //IPAD PORTRAIT CONF
            if(UIDevice.current.userInterfaceIdiom == .pad){
                size = CGSize(width: (cv.frame.width-(layout.minimumInteritemSpacing+layout.sectionInset.right+layout.sectionInset.left*2))/2,
                              height: cv.frame.height/4)
            }
            //IPHONE PORTRAIT CONF
            else{
                size = CGSize(width: cv.frame.width-(layout.minimumInteritemSpacing+layout.sectionInset.right+layout.sectionInset.left),
                              height: cv.frame.height/3)
            }
            
        }
            
        else{
            //IPAD LANDSCAPE CONF
            if(UIDevice.current.userInterfaceIdiom == .pad){
                size = CGSize(width:(cv.frame.width-(layout.minimumInteritemSpacing+layout.sectionInset.right+layout.sectionInset.left)*2)/3 ,
                          height: (cv.frame.height - (layout.sectionInset.top + layout.sectionInset.bottom)*4)/4)
            }
                //IPHONE LANDSCAPE CONF
            else{
                size = CGSize(width:cv.frame.width-(layout.minimumInteritemSpacing+layout.sectionInset.right+layout.sectionInset.left) ,
                              height: cv.frame.height - (layout.sectionInset.top + layout.sectionInset.bottom))
            }
        }
        
        return size
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "DetailSegue"){
            //print("Performing segue")
            segue.perform()
        }
    }
}

class MediaCell: UICollectionViewCell{
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var favoriteButton : UIButton!
    
    
    
    
    @IBAction func showDetails(_ sender: UIButton) {
        let cv = self.superview as! UICollectionView
        let indexPath = cv.indexPath(for: self)
        
        let collectionViewController = cv.delegate as! CollectionBaseViewController
        
        let media = collectionViewController.appDelegate!.model.foundItems[indexPath!.row]
        collectionViewController.appDelegate!.model.selectedMedia = media
        
        let loadingView: UIView
        let activityIndicator: UIActivityIndicatorView
        (loadingView,activityIndicator) = InterfaceHelper.createLoadingView()
        
        collectionViewController.view.addSubview(loadingView)
        activityIndicator.startAnimating()
        
        
        APIHelper.getDetails(media: media,
                             onCompletion: {
                                    activityIndicator.stopAnimating()
                                    loadingView.removeFromSuperview()
                                    let controller = UIApplication.shared.keyWindow?.rootViewController;
                                    controller?.performSegue(withIdentifier: "DetailSegue", sender: controller)
                            },
                             onError: {
                                    activityIndicator.stopAnimating()
                                    loadingView.removeFromSuperview()
                                    //Show error
                                    let alert = InterfaceHelper.createInfoAlert(title: "Error de conexión", text: "La conexión puede ser intermitente o el servidor no estar disponible.")
                                    collectionViewController.present(alert, animated: true, completion: nil)
                                
        })
        
    }
    
    @IBAction func favoriteButtonAction(_ sender: FavoriteButton) {

        if sender.favorite {
            sender.setFavorite(state: false)
        }
        else {
            sender.setFavorite(state: true)
        }
        
    }
    
}
