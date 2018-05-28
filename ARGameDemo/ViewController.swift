//
//  ViewController.swift
//  ARGameDemo
//
//  Created by Alexey Pak on 23/05/2018.
//  Copyright © 2018 Alexey Pak. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!

	var planes = [UUID: PlaneNode]()

    override func viewDidLoad() {
        super.viewDidLoad()

		sceneView.autoenablesDefaultLighting = true
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
		sceneView.session.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/

	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
		let plane = PlaneNode(with: planeAnchor)
		planes[planeAnchor.identifier] = plane

		node.addChildNode(plane)
	}

	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
		guard let plane = planes[anchor.identifier] else { return }

		plane.update(with: planeAnchor)
	}

	/**
	Set the object's position based on the provided position relative to the `cameraTransform`.
	If `smoothMovement` is true, the new position will be averaged with previous position to
	avoid large jumps.

	- Tag: VirtualObjectSetPosition
	*/
	func setTransform(_ newTransform: float4x4,  relativeTo cameraTransform: float4x4, to node: SCNNode) {
		let cameraWorldPosition = cameraTransform.translation
		var positionOffsetFromCamera = newTransform.translation - cameraWorldPosition

		// Limit the distance of the object from the camera to a maximum of 10 meters.
		if simd_length(positionOffsetFromCamera) > 10 {
			positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera)
			positionOffsetFromCamera *= 10
		}

		/*
		Compute the average distance of the object from the camera over the last ten
		updates. Notice that the distance is applied to the vector from
		the camera to the content, so it affects only the percieved distance to the
		object. Averaging does _not_ make the content "lag".
		*/

		node.simdPosition = cameraWorldPosition + positionOffsetFromCamera
	}

	@IBAction func didTouchAddButton(_ sender: Any) {
		let point = CGPoint(x: sceneView.bounds.width / 2, y: sceneView.bounds.height / 2)

		guard var transform = sceneView.hitTest(point, types: [.existingPlaneUsingGeometry]).first?.worldTransform else { return }
		guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else { return }

		let geometry = SCNSphere(radius: 0.05)
		transform.columns.3.y += Float(geometry.radius)

		let node = SCNNode(geometry: geometry)

		let shape = SCNPhysicsShape(geometry: geometry, options: nil)
		node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
		node.physicsBody?.isAffectedByGravity = true

		setTransform(transform, relativeTo: cameraTransform, to: node)

		sceneView.scene.rootNode.addChildNode(node)
	}

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}
