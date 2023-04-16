//
//  CameraViewController.swift
//  V2 JaJanken
//
//  Created by Carlos Mbendera on 2023-04-15.
//

import AVFoundation
import UIKit
import Vision

enum errors: Error {
    case cameraError
}

final class CameraViewController: UIViewController {
    
    private var lastBeepTime: Date?

    private var cameraFeedSession: AVCaptureSession?
    
    private var coreMLRequest: VNCoreMLRequest!
    
    override func loadView() {
        view = CameraPreview()
    }
    
    private var cameraView: CameraPreview { view as! CameraPreview }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let coreMLModel = try? VNCoreMLModel(for: WalletObject().model) else {
            fatalError("Failed to load the Core ML model")
        }
        
        coreMLRequest = VNCoreMLRequest(model: coreMLModel) { [weak self] request, error in
            self?.handleDetectionResults(request: request, error: error)
        }
        coreMLRequest.imageCropAndScaleOption = .scaleFill
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
            }
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.cameraFeedSession?.startRunning()
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewDidDisappear(animated)
    }
    
    private let videoDataOutputQueue =
        DispatchQueue(label: "CameraFeedOutput", qos: .userInteractive)
    
    func setupAVSession() throws {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw errors.cameraError
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw errors.cameraError
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard session.canAddInput(deviceInput) else {
            throw errors.cameraError
        }
        
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw errors.cameraError
        }
        
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    private func handleDetectionResults(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                return
            }
            
            let currentTime = Date()
             let minimumTimeBetweenBeeps: TimeInterval = 2
             
             
            if !results.isEmpty{
              //   AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                AudioServicesPlaySystemSound(1103)
                print(results)
                 self.lastBeepTime = currentTime
             }
            // Process the results (e.g., filter objects by class and confidence, and notify the SwiftUI view)
        }
    }

}



extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([coreMLRequest])
        } catch {
            print("Failed to perform the object detection request: \(error)")
        }
    }
}
