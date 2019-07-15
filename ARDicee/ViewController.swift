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

    // MARK: - Global Vars
    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    // MARK: - @IBActions
    @IBAction func rollAgainButtonPressed(_ sender: UIBarButtonItem) {
        rollAllDices()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.showsStatistics = true
        
        // Create a new scene
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.02)
        let ball = SCNSphere(radius: 0.25)
        let material = SCNMaterial()
        
        material.diffuse.contents = UIImage(named: "art.scnassets/8k_earth_daymap.jpg")
        
        cube.materials = [material]
        ball.materials = [material]
        
        let cude_node = SCNNode(geometry: cube)
        let ball_node = SCNNode(geometry: ball)
        
        cude_node.position = SCNVector3(0, 0.5, -0.5)  // -z is away from user
        ball_node.position = SCNVector3(0.2, 0.2, -1)  // -z is away from user
        
        sceneView.scene.rootNode.addChildNode(cude_node)
        sceneView.scene.rootNode.addChildNode(ball_node)
        

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

    // MARK: - Deletgate Methods
    // find a horizontal plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                 height: CGFloat(planeAnchor.extent.z))
            let plane_node = SCNNode(geometry: plane)
            plane_node.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
            
            // when plane node created, it is vertical, so rotate 90 degrees on X axis
            plane_node.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            node.addChildNode(plane_node)
        }
    }
    
    // detect where user touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        guard let hitResult = results.first else { return }
        print(hitResult)
        
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        let dice_node = diceScene.rootNode.childNode(withName: "Dice", recursively: true)!
        dice_node.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                        hitResult.worldTransform.columns.3.y + dice_node.boundingSphere.radius,
                                        hitResult.worldTransform.columns.3.z)

        diceArray.append(dice_node)
        sceneView.scene.rootNode.addChildNode(dice_node)
        rollDice(dice_node)
        
    }
    
    // when shake phone, roll all dices
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAllDices()
    }
    
    // MARK: - My Methods
    func rollAllDices() {
        for dice in diceArray {
            rollDice(dice)
        }
    }
    
    func rollDice(_ dice: SCNNode) {
        let randomX = CGFloat.random(in: 1...16).rounded() * CGFloat.pi / 2
        let randomZ = CGFloat.random(in: 1...16).rounded() * CGFloat.pi / 2
        let randomTime = Double.random(in: 0.4...2)
        
        dice.runAction(SCNAction.rotateBy(x: randomX, y: 0, z: randomZ, duration: randomTime))
    }
    

}
