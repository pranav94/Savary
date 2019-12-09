//
//  ViewController.swift
//  Savary
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!;
    
    private var worldConfiguration: ARWorldTrackingConfiguration?
    var isCameraLightOn = false;
    
    let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSceneKitQueue")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
//        sceneView.showsStatistics = true
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        sceneView.scene = scene
        
        
        
        let imageView = UIImageView(image: UIImage(named: "logo-no-bg")!)
        imageView.frame = CGRect(x: 20, y: 20, width: 40, height: 40)
        
        let buttonView = UIButton()
        
        let iconImage:UIImage? = UIImage(named: "flash.png")
        buttonView.contentVerticalAlignment = .fill
        buttonView.contentHorizontalAlignment = .fill
        buttonView.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right:10)
        buttonView.setImage(iconImage, for: UIControl.State.normal)
        buttonView.setTitleColor(UIColor.black, for: [])
        buttonView.frame = CGRect(
            x: self.view.bounds.size.width - 60,
            y: 20,
            width: 40, height: 40
        )
        buttonView.addTarget(self, action: #selector(self.buttonPressed), for: .touchUpInside)
        
        self.view.addSubview(imageView)
        self.view.addSubview(buttonView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            toggleTorch(on: false)
            self!.isCameraLightOn = true
        }
        setupObjectDetection()
    }
    
    private func setupObjectDetection() {
      worldConfiguration = ARWorldTrackingConfiguration()

      guard let referenceObjects = ARReferenceObject.referenceObjects(
        inGroupNamed: "AR Objects", bundle: nil) else {
          fatalError("Missing expected resources.")
      }

      worldConfiguration?.detectionObjects = referenceObjects

      guard let referenceImages = ARReferenceImage.referenceImages(
        inGroupNamed: "ShoeObjects", bundle: Bundle.main) else {
          fatalError("Missing expected resources.")
      }
      worldConfiguration?.detectionImages = referenceImages
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let configuration = worldConfiguration{
            sceneView.debugOptions = .showFeaturePoints
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            handleFoundImage(imageAnchor, node)
        } else if let objectAnchor = anchor as? ARObjectAnchor {
            handleFoundObject(objectAnchor, node)
        }
        
        return node
    }
    
    private func handleFoundImage(_ imageAnchor: ARImageAnchor, _ node: SCNNode){
        let shoeName = imageAnchor.referenceImage.name!
        handleFoundReferences(imageAnchor, node, shoeName)
    }
    
    private func handleFoundObject(_ objectAnchor: ARObjectAnchor, _ node: SCNNode){
        let shoeName = objectAnchor.referenceObject.name!
        handleFoundReferences(objectAnchor, node, shoeName)
    }
    
    private func handleFoundReferences(_ imageAnchor: ARAnchor, _ node: SCNNode, _ shoeName: String) {
          let plane = SCNPlane(width: 0.45, height: 0.225)
          
          plane.cornerRadius = plane.width / 64
          
          let spriteKitScene = SKScene(fileNamed: "ProductInfo")
          
          plane.firstMaterial?.diffuse.contents = spriteKitScene
          plane.firstMaterial?.isDoubleSided = true
          plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
          
          let planeNode = SCNNode(geometry: plane)
          planeNode.eulerAngles.x = -.pi / 2
          planeNode.eulerAngles.y = 0
          planeNode.eulerAngles.z = 0
          planeNode.position = SCNVector3(
              0,
              -0.5,
              0
          )
          
          //let shoeName = imageAnchor.referenceImage.name!
          let merchantNode1 = spriteKitScene?.childNode(withName: "Merchant1") as? SKLabelNode
          let merchantNode2 = spriteKitScene?.childNode(withName: "Merchant2") as? SKLabelNode
          let merchantNode3 = spriteKitScene?.childNode(withName: "Merchant3") as? SKLabelNode
          
          let priceNode1 = spriteKitScene?.childNode(withName: "Price1") as? SKLabelNode
          let priceNode2 = spriteKitScene?.childNode(withName: "Price2") as? SKLabelNode
          let priceNode3 = spriteKitScene?.childNode(withName: "Price3") as? SKLabelNode

          getShoeInfo (shoeName: shoeName, userCompletionHandler: { shoe, error in
              if let shoe = shoe {
                  if (shoe.count != 0) {
                      merchantNode1?.text = shoe[0].seller
                      merchantNode2?.text = shoe[1].seller
                      merchantNode3?.text = shoe[2].seller
                      
                      priceNode1?.text = shoe[0].price + "$"
                      priceNode2?.text = shoe[1].price + "$"
                      priceNode3?.text = shoe[2].price + "$"
                  }
              }
          })
        
          let labelNode = spriteKitScene?.childNode(withName: "label") as? SKLabelNode
          labelNode?.text = shoeName

          let imageNode = spriteKitScene?.childNode(withName: "image") as? SKSpriteNode
          imageNode?.texture = SKTexture(imageNamed: shoeName+"-image.jpeg")
          
          node.addChildNode(planeNode)

    }
    
        
    @objc func buttonPressed(sender: UIButton){
        self.isCameraLightOn = !self.isCameraLightOn
        toggleTorch(on: self.isCameraLightOn)
    }
}
