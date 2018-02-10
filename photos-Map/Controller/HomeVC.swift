//
//  ViewController.swift
//  photos-Map
//
//  Created by Sakar Pokhrel on 2/4/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HomeVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    private let locationManager = CLLocationManager()
    private let regionRadius: Double = 1000
    
    private var imageCollectionView: UICollectionView!
    private let collectionViewLayout = UICollectionViewFlowLayout()
    
    lazy var screenSize = UIScreen.main.bounds
    private var downloadedImageArray = [UIImage]()
    
    var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForLocationAuthorization()
        mapView.delegate = self
        locationManager.delegate = self
        createCollectionView()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        registerForPreviewing(with: self, sourceView: imageCollectionView)
        
    }

    @IBAction func myLocationButtonTapped(_ sender: UIButton) {
        
        checkForLocationAuthorization()
        
    }
    
    
    //UPDATES MAP VIEW:
    func updateMapView() {
        
        if let mapLocation = locationManager.location?.coordinate {
            setUserRegion(withLocation: mapLocation)
            addDoubleTap()
            addDoubleTapOnBottomView()
        }
        
    }
    
    //CREATE COLLECTION VIEW:
    func createCollectionView() {
        
        //view.bounds
        imageCollectionView = UICollectionView(frame: view.frame , collectionViewLayout: collectionViewLayout)
        imageCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
        imageCollectionView.backgroundColor = .white
        
        bottomView.addSubview(imageCollectionView)
        
    }

    
    //ADDS DOUBLE TAP GESTURE ON MAP VIEW:
    private func addDoubleTap() {
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(withGesture:)))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    
    //WHEN USER DOUBLE TAPPED ON SCREEN:
    @objc private func handleDoubleTap(withGesture doubleTapGesture: UITapGestureRecognizer) {
        
        spinner?.removeFromSuperview()
        downloadedImageArray = []
        ImageDownloadService.instance.removeSession()
        
        addSpinner()
        
        imageCollectionView.reloadData()
        removePinAnnotation()
        
        
       let tappedLocationInScreen = doubleTapGesture.location(in: mapView)
       let mapCoordinate = mapView.convert(tappedLocationInScreen, toCoordinateFrom: mapView)
       let pin = PinAnnotation(coordinate: mapCoordinate, identifier: "mapPin")
        mapView.addAnnotation(pin)
        setUserRegion(withLocation: mapCoordinate)
        
        bottomViewHeightConstraint.constant = (screenSize.height / 2) - 85
        let flickrApi = ImageDownloadService.instance.flickrAPI(withAnnotation: pin)
        
        //image Downloaded:
        ImageDownloadService.instance.downloadImageURL(withflickrAPI: flickrApi) { (returnedUrlArray) in
            
            ImageDownloadService.instance.downloadImages(withURLArray: returnedUrlArray, completion: {[unowned self] (returnedImageArray) in
                self.downloadedImageArray = returnedImageArray
                print(returnedImageArray.count)
                self.imageCollectionView.reloadData()
                self.spinner?.removeFromSuperview()
            })
            
        }
        
        print("\((view.frame.width / 4) - 10)")
    }
    
    //ADD DOUBLE TAP GESTURE ON BOTTOM VIEW:
    private func addDoubleTapOnBottomView() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTappedOnBottomView))
        tap.numberOfTapsRequired = 2
        bottomView.addGestureRecognizer(tap)
    }
    
    //WHEN USER DOUBLE TAPPED ON BOTTOM VIEW:
    @objc private func doubleTappedOnBottomView() {
        
       bottomViewHeightConstraint.constant = 0.5
        ImageDownloadService.instance.removeSession()
        
    }
    
    //UIACTIVITY INDICATOR VIEW
    private func addSpinner() {
        
        spinner = UIActivityIndicatorView()
        spinner?.activityIndicatorViewStyle = .white
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: ((screenSize.height / 2 ) - 85) / 2)
        spinner?.color = #colorLiteral(red: 0.2001606524, green: 0.2001606524, blue: 0.2001606524, alpha: 1)
        spinner?.startAnimating()
        bottomView.addSubview(spinner!)
        
    }
    
    
    
}

//CLLOCATIONMANAGER DELEGATE
extension HomeVC: CLLocationManagerDelegate {
    
    //CHECKS IF USER HAS ENABLED LOCATION OR NOT:
    private func checkForLocationAuthorization() {
        
        if  CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            updateMapView()
            
        } else {
            
            locationManager.requestWhenInUseAuthorization()
            
        }
        
    }
    
    //WHEN USER CHANGE THE LOCATION AUTHORIZATION STATUS:
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            updateMapView()
            
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
}

//MK MAP VIEW DELEGATE
extension HomeVC: MKMapViewDelegate {
    
    //SETS USER REGION BASED ON USER LOCATION:
    private func setUserRegion(withLocation location: CLLocationCoordinate2D) {
        
        let region = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0 , regionRadius * 2.0)
        mapView.setRegion(region, animated: true)
        
    }
    
    //RETURNS CUSTOM PIN ANNOTATION VIEW:
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "mapPin")
        pin.pinTintColor = #colorLiteral(red: 0.4384006097, green: 0.8512130579, blue: 0.2838650313, alpha: 1)
        pin.animatesDrop = true
        return pin
        
    }
    
    //REMOVES ANNOTATIONS FROM MAP VIEW:
    private func removePinAnnotation() {
        
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    
}

//COLLECTION VIEW DELEGATE:
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloadedImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {return UICollectionViewCell()}
          cell.imageView.image = downloadedImageArray[indexPath.item]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width / 4) - 10 , height: 80)
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0)
    }
    
    
    
}

extension HomeVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = imageCollectionView.indexPathForItem(at: location), let cellInIndexPath = imageCollectionView.cellForItem(at: indexPath)  else {return nil}
        
        let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as! PopVC
        popVC.imageToPop = downloadedImageArray[indexPath.item]
        previewingContext.sourceRect = cellInIndexPath.contentView.frame
        return popVC
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}




















