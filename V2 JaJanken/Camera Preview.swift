//
//  Camera Preview.swift
//  V2 JaJanken
//
//  Created by Carlos Mbendera on 2023-04-15.
//

import UIKit
import AVFoundation

final class CameraPreview: UIView{
    
    var previewLayer : AVCaptureVideoPreviewLayer{
        layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass{
        AVCaptureVideoPreviewLayer.self
    }
}
