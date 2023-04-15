//
//  Camera View.swift
//  V2 JaJanken
//
//  Created by Carlos Mbendera on 2023-04-15.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable{
    
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cvc = CameraViewController()
        return cvc
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        //Not needed for this app
    }
}
