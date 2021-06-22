//
//  ImageMapRenderer.swift
//  googleMapz
//
//  Created by Macbook on 6/17/21.
//

import Foundation
import MapKit

class ImageMapRenderer: MKOverlayRenderer {
    var image:UIImage?
    
    init(imageOverlay:ImageMapOverlay) {
        image = imageOverlay.image
        super.init(overlay: imageOverlay)
        
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let cgImage = image?.cgImage else {return}
        let mapRect = overlay.boundingMapRect
        let cgRect = rect(for: mapRect)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0, y: -cgRect.size.height)
        context.draw(cgImage, in: cgRect)
    }
    
}
