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
        let image: UIImage = UIImage(named: "logo-no-bg")!
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 20, y: 40, width: 40, height: 40)
        self.view.addSubview(imageView)
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
            let plane = SCNPlane(width: 0.45, height: 0.225)
            
            plane.cornerRadius = plane.width / 64
            
            let spriteKitScene = SKScene(fileNamed: "ProductInfo")
            
            plane.firstMaterial?.diffuse.contents = spriteKitScene
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi/2
            planeNode.position = SCNVector3(0, -0.6, 0)
            
            let shoeName = imageAnchor.referenceImage.name!

            let merchantNode1 = spriteKitScene?.childNode(withName: "Merchant1") as? SKLabelNode
            let merchantNode2 = spriteKitScene?.childNode(withName: "Merchant2") as? SKLabelNode
            let merchantNode3 = spriteKitScene?.childNode(withName: "Merchant3") as? SKLabelNode
            
            let priceNode1 = spriteKitScene?.childNode(withName: "Price1") as? SKLabelNode
            let priceNode2 = spriteKitScene?.childNode(withName: "Price2") as? SKLabelNode
            let priceNode3 = spriteKitScene?.childNode(withName: "Price3") as? SKLabelNode

            getShoeInfo (shoeName: shoeName, userCompletionHandler: { shoe, error in
                if let shoe = shoe {
                    merchantNode1?.text = shoe[0].seller
                    merchantNode2?.text = shoe[1].seller
                    merchantNode3?.text = shoe[2].seller
                    
                    priceNode1?.text = shoe[0].price
                    priceNode2?.text = shoe[1].price
                    priceNode3?.text = shoe[2].price
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
