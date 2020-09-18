//
//  ViewController.swift
//  SeeFood
//
//  Created by Yesbolat Syilybay on 17.09.2020.
//  Copyright © 2020 conizer. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

	@IBOutlet weak var mainImageView: UIImageView!
	let imagePicker = UIImagePickerController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imagePicker.delegate = self
		imagePicker.allowsEditing = true
		imagePicker.sourceType = .camera
	}

	@IBAction func cameraTapped(_ sender: UIBarButtonItem) {
		present(imagePicker, animated: true, completion: nil)
	}
	
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let userPickedImage = info[.editedImage] as? UIImage {
			mainImageView.image = userPickedImage
			
			guard let ciimage = CIImage(image: userPickedImage) else {
				fatalError("Cannot convert UIImage into CIImage.")
			}
			
			detect(image: ciimage)
		}
		
		imagePicker.dismiss(animated: true)
	}
	
	func detect(image: CIImage) {
		guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
			fatalError("Loading CoreML Model Failed.")
		}
		
		let request = VNCoreMLRequest(model: model) { (request, error) in
			guard let results = request.results as? [VNClassificationObservation] else {
				fatalError("Model failed to process image.")
			}
			
			self.navigationItem.title = results.first?.identifier
			
//			print(results)
		}
		
		let handler = VNImageRequestHandler(ciImage: image)
		
		do {
			try handler.perform([request])
		} catch {
			print(error)
		}
		
	}
}
