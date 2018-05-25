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

		let planeNode = SCNNode(geometry: geometry)
		planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
  		planeNode.transform = SCNMatrix4MakeRotation(-.pi / 2.0, 1.0, 0.0, 0.0);

		setTextureScale()
		addChildNode(planeNode)
	}

	func update(with anchor: ARPlaneAnchor) {
		planeGeometry.width = CGFloat(anchor.extent.x)
		planeGeometry.height = CGFloat(anchor.extent.z)

		position = SCNVector3(anchor.center.x, 0, anchor.center.z)
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
