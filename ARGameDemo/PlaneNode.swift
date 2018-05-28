//
//  PlaneNode.swift
//  ARGameDemo
//
//  Created by Alexey Pak on 25/05/2018.
//  Copyright © 2018 Alexey Pak. All rights reserved.
//

import UIKit
import ARKit

class PlaneNode: SCNNode {

//	// Place content only for anchors found by plane detection.
//
//	// Create a SceneKit plane to visualize the plane anchor using its position and extent.
//	let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//	let planeNode = SCNNode(geometry: plane)
//	planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
//
//	// `SCNPlane` is vertically oriented in its local coordinate space, so
//	// rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
//	planeNode.eulerAngles.x = -.pi / 2
//
//	// Make the plane visualization semitransparent to clearly show real-world placement.
//	planeNode.opacity = 0.25
//
//	// Add the plane visualization to the ARKit-managed node so that it tracks
//	// changes in the plane anchor as plane estimation continues.
//	node.addChildNode(planeNode)

	let anchor: ARPlaneAnchor
	let planeGeometry: SCNPlane

	init(with anchor: ARPlaneAnchor) {
		self.anchor = anchor
		self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))

		super.init()

		let material: SCNMaterial = {
			let material = SCNMaterial()
			let image = UIImage(named: "tron_grid")
			material.diffuse.contents = image
			return material
		}()
		planeGeometry.materials = [material]
		self.geometry = planeGeometry

		simdPosition = float3(anchor.center.x, 0, anchor.center.z)
		eulerAngles.x = -.pi / 2

		opacity = 1.00

		let shape = SCNPhysicsShape(node: self, options: nil)
		physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
		physicsBody?.isAffectedByGravity = true

		setTextureScale()
	}

	func update(with anchor: ARPlaneAnchor) {
		planeGeometry.width = CGFloat(anchor.extent.x)
		planeGeometry.height = CGFloat(anchor.extent.z)

		simdPosition = float3(anchor.center.x, 0, anchor.center.z)

		let shape = SCNPhysicsShape(node: self, options: nil)
		physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
		physicsBody?.isAffectedByGravity = true
		
		setTextureScale()
	}

	func setTextureScale() {
		guard let material: SCNMaterial = planeGeometry.materials.first else { return }

		let width = Float(planeGeometry.width)
		let height = Float(planeGeometry.height)

		material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1)
		material.diffuse.wrapS = .repeat
		material.diffuse.wrapT = .repeat
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
