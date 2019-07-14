//
//  ViewController.swift
//  ARDicee
//
//  Created by 胡洞明 on 2019-07-07.
//  Copyright © 2019 Dongming Hu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.02)
        let ball = SCNSphere(radius: 0.25)
        let material = SCNMaterial()
        
        material.diffuse.contents = UIImage(named: "art.scnassets/8k_earth_daymap.jpg")
        
        cube.materials = [material]
        ball.materials = [material]
        
        let cude_node = SCNNode(geometry: cube)
        let ball_node = SCNNode(geometry: ball)
        let dice_node = diceScene.rootNode.childNode(withName: "Dice", recursively: true)!
        
        cude_node.position = SCNVector3(0, 0.5, -0.5)  // -z is away from user
        ball_node.position = SCNVector3(0.2, 0.2, -1)  // -z is away from user
        dice_node.position = SCNVector3(0, 0, -0.1)
        
        sceneView.scene.rootNode.addChildNode(cude_node)
        sceneView.scene.rootNode.addChildNode(ball_node)
        sceneView.scene.rootNode.addChildNode(dice_node)

        sceneView.autoenablesDefaultLighting = true
        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported {
            // Create a session configuration (A9 chip requried for performance)
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            
            // Run the view's session
            sceneView.session.run(configuration)
        } else {
            let configuration = AROrientationTrackingConfiguration()
            
            sceneView.session.run(configuration)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}
