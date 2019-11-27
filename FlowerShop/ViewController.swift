//
//  ViewController.swift
//  FlowerShop
//
//  Created by Brian Advent on 14.06.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

     @IBOutlet var sceneView: ARSCNView!

    struct Shoe {
        var id: Int
        var title: String
        var seller: String
        var price: String
      
        init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? Int ?? 0
        self.title = dictionary["title"] as? String ?? ""
        self.seller = dictionary["seller"] as? String ?? ""
        self.price = dictionary["price"] as? String ?? ""
        }
    }

    func makeGetCall(shoeName: String){
    guard let url = URL(string: "https://my-json-server.typicode.com/pranav94/Savary/posts?title_like=" + shoeName) else {return}
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
    guard let dataResponse = data,
          error == nil else {
          print(error?.localizedDescription ?? "Response Error")
          return }  
    do{ 
            let jsonResponse = try JSONSerialization.jsonObject(with:
                                dataResponse, options: []) 
            //print(jsonResponse) 
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
            return 
            }
            //print(jsonArray)
            var model = [Shoe]()
            model = jsonArray.flatMap{ (dictionary) in
                return Shoe(dictionary)
            }
            print(model[0].seller)
            print(model[0].price)
            print(model[1].seller)
            print(model[1].price)
            print(model[2].seller)
            print(model[2].price)
            return model
        } 
            catch let parsingError {
                print("Error", parsingError) 
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        makeGetCall(shoeName: "Nike Court Boro Mid")
        makeGetCall(shoeName: "Levi")
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Image Detection
        configuration.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "ShoeObjects", bundle: Bundle.main)!

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
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
//            planeNode.position = SCNVector3Make(imageAnchor.referenceImage.center.x, imageAnchor.referenceImage.center.y + 0.35, imageAnchor.referenceImage.center.z)
            
            planeNode.eulerAngles.x = -.pi/2
            
            let shoeName = imageAnchor.referenceImage.name!
            
            //Get Shoe Details
            var modeldetails = makeGetCall(shoeName: shoeName)
            
            let seller1 = modeldetails[0].seller
            let price1 = modeldetails[0].price

            let seller2 = modeldetails[1].seller
            let price2 = modeldetails[1].price

            let seller3 = modeldetails[2].seller
            let price3 = modeldetails[2].price
            
            let labelNode = spriteKitScene?.childNode(withName: "label") as? SKLabelNode
            labelNode?.text = shoeName

            let imageNode = spriteKitScene?.childNode(withName: "image") as? SKSpriteNode
            imageNode?.texture = SKTexture(imageNamed: shoeName+"-image.jpeg")
            
            node.addChildNode(planeNode)
            
        }
        
        return node
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
