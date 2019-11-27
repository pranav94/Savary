//
//  ViewController.swift
//  Savary
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

     @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "ShoeObjects", bundle: Bundle.main)!
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: 0.6, height: 0.3)
            
            plane.cornerRadius = plane.width / 32
            
            let spriteKitScene = SKScene(fileNamed: "ProductInfo")
            
            plane.firstMaterial?.diffuse.contents = spriteKitScene
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi/2
            
            let shoeName = imageAnchor.referenceImage.name!

            let priceNode1 = spriteKitScene?.childNode(withName: "Price1") as? SKLabelNode
            let priceNode2 = spriteKitScene?.childNode(withName: "Price2") as? SKLabelNode
            let priceNode3 = spriteKitScene?.childNode(withName: "Price3") as? SKLabelNode

            getShoeInfo (shoeName: shoeName, userCompletionHandler: { shoe, error in
                if let shoe = shoe {
                    priceNode1?.text = shoe[0].seller + ": " + shoe[0].price
                    priceNode2?.text = shoe[1].seller + ": " + shoe[1].price
                    priceNode3?.text = shoe[2].seller + ": " + shoe[2].price
                }
            })
          
            let labelNode = spriteKitScene?.childNode(withName: "label") as? SKLabelNode
            labelNode?.text = shoeName

            let imageNode = spriteKitScene?.childNode(withName: "image") as? SKSpriteNode
            imageNode?.texture = SKTexture(imageNamed: shoeName+"-image.jpeg")
            
            node.addChildNode(planeNode)
            
        }
        
        return node
    }
}
