//
//  ViewController.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet var zoomInButton: UIButton! {
        didSet { zoomInButton.applyMapStyle() }
    }
    
    @IBOutlet var zoomOutButton: UIButton! {
        didSet { zoomOutButton.applyMapStyle() }
    }
    
    @IBOutlet var currentLocationButton: UIButton! {
        didSet { currentLocationButton.applyMapStyle() }
    }
    
    @IBOutlet var mapView: MKMapView!

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = .title
        mapView.register(AnnotationView.self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        map.checkUserLocation()
    }
    
    var map: Map!
    
    private var annotaionsHidden = false
}

// MARK: Actions

extension ViewController {
    
    @IBAction func zoomInButtonTouch() {
        let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta / 2,
                                    longitudeDelta: mapView.region.span.longitudeDelta / 2)
        updateMapView(with: span)
    }
    
    @IBAction func zoomOutButtonTouch() {
        let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta * 2,
                                    longitudeDelta: mapView.region.span.longitudeDelta * 2)
        updateMapView(with: span)
    }
    
    private func updateMapView(with span: MKCoordinateSpan, animated: Bool = true) {
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(region, animated: animated)
    }
    
    @IBAction func findCurrentLocation() {
        map.moveToUserLocation()
    }
}

// MARK: MapOutput

extension ViewController: MapOutput {

    func navigateTo(region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
    
    func showUserLocation() {
        mapView.showsUserLocation = true
    }
    
    func showLocatioUnavaliableAlert() {
        showLocationDisabledAlert()
    }
    
    func show(annotations: [MKAnnotation]) {
        mapView.addAnnotations(annotations)
    }
    
    func remove(annotations: [MKAnnotation]) {
        mapView.removeAnnotations(annotations)
    }
}

// MARK: MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let visibleArea = mapView.visibleMapRect.toCircle()
        guard visibleArea.radius <= 7_000 else {
            mapView.removeAnnotations(mapView.annotations)
            annotaionsHidden = true
            return
        }
        
        if annotaionsHidden {
            mapView.addAnnotations(map.annotations)
            annotaionsHidden = false
        }
        map.fetchPoints(in: visibleArea, region: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? DepositionPointAnnotation
            else { return nil }
        guard let view = mapView.dequeueReusableAnnotationView(AnnotationView.self, for: annotation) as? AnnotationView
            else { return nil }
        view.configure(annotation)
        return view
    }
}

// MARK: Help

private extension UIButton {
    
    func applyMapStyle() {
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 1.0
        backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }
}
