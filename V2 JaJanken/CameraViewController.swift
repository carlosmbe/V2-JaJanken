//
//  CameraViewController.swift
//  V2 JaJanken
//
//  Created by Carlos Mbendera on 2023-04-15.
//

import AVFoundation
import UIKit
import Vision

enum errors: Error{
    //TODO: Write actual error cases
    case TooLazyToWrite
}

final class CameraViewController : UIViewController{
    
    private var cameraFeedSession: AVCaptureSession?
    
    override func loadView() {
        view = CameraPreview()
    }
    
    private var cameraView: CameraPreview{ view as! CameraPreview}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do{
            
            if cameraFeedSession == nil{
                try setupAVSession()
                
                cameraView.previewLayer.session = cameraFeedSession
                //MARK: Commented out cause it cropped
             //   cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            
            //MARK: Surronded the code into a DispatchQueue Cause we were having crashes
            DispatchQueue.global(qos: .userInteractive).async {
                self.cameraFeedSession?.startRunning()
               }
            
        }catch{
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
        //Start of setup
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw errors.TooLazyToWrite
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else{
            throw errors.TooLazyToWrite
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard session.canAddInput(deviceInput) else{
            throw errors.TooLazyToWrite
        }
        
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput){
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        }else{
            throw errors.TooLazyToWrite
        }
        
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    

        
    }


    extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
        //Handler and Observation
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
           
            
        }
        
    }
