//
//  AnnotationView.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 18/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit
import MapKit

final class AnnotationView: MKAnnotationView {
    
    static let imageSize = CGSize(width: 25, height: 25)
    
    private var imageView = UIImageView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        addSubview(imageView)
        imageView.frame = CGRect(origin: .zero, size: AnnotationView.imageSize)
        imageView.contentMode = .center
    }
    
    override var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }

    private var token: Observable<UIImage?>.Token?
    
    func configure(_ model: DepositionPointAnnotation) {
        image = model.image.value
        token = model.image.observe { [weak self] _, newImage in
            self?.image = newImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        token?.dispose()
    }
}
