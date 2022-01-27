//
//  ViewController.swift
//  PairsAR
//
//  Created by Tulum1 on 1/21/22.
//

import UIKit
import RealityKit
import Combine
import AR


class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //scene
        
        
        
        let anchor  = AnchorEntity(plane:.horizontal, minimumBounds: [0.2,0.2])
        arView.scene.addAnchor(anchor)
                     
        //represent a physical object in scene
        
        //define array of entities
        
        var cards: [Entity] = []
        for _ in 1...4 {
            let box = MeshResource.generateBox(width: 0.088, height: 0.08, depth: 0.088)
            let metalMaterial = SimpleMaterial(color: .green, isMetallic: true)
            //model
            let model = ModelEntity(mesh:box, materials:[metalMaterial])
            
            //ability to press on boxes
            
            //use model to create collision shapes
            model.generateCollisionShapes(recursive: true)
            
            cards.append(model)
            
            for (index, card)in cards.enumerated(){
                let x = Float(index % 2)
                let z = Float(index/2)
                
                card.position = [x*0.2, 0, z*0.2]
                
                //now that card is positioned, we can anchor the child we add (our card) on real device
                
                //we must use real device now for target simulation
                 
                anchor.addChild(card)
                
                
                // Now to have interaction via "touch" to entity
                //tap and rotate
                //command shift L to story board and drag tap gesture recognizer ,
                
            }
            
            var cancellable: AnyCancellable? = nil
            
            
            cancellable = ModelEntity.loadModelAsync(named: "finalacemetallicdiamond")
                .append(ModelEntity.loadModelAsync(named: "finalacemetallicdiamond" ))
            .collect()
            .sink(receiveCompletion: {error in
                print("Error: \(error)")
                cancellable?.cancel()
            }, receiveValue: { entities in
                var objects: [ModelEntity] = []
                for entity in entities {
                    entity.setScale(SIMD3<Float>(0.9, 0.9, 0.9),
                        relativeTo: anchor)
                    entity.generateCollisionShapes(recursive: true)
                    //clone
                    
                    for _ in 1...2 {
                        objects.append(entity.clone(recursive: true))
                    }
                }
                objects.shuffle()
                
                for (index, object) in objects.enumerated() {
                    cards[index].addChild(object)
                }
                                    
            })
            
            
            // var objects: [ModelEntity] = [] // this intializes an array
            
            //for entity in entities{ entity.setScale(scale: }
            // ____________    ________________
        }
        
    }
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        
        // this is where you can pin tap to location of gesture interaction
        
        let tapLocation = sender.location(in: arView)
        if let card = arView.entity(at:tapLocation){
            
            //if card is already turned around.. we want to flip it back down
        if card.transform.rotation.angle == .pi {
           
            var flipDownTransform = card.transform
            
            // to make rotation possible
            flipDownTransform.rotation = simd_quatf(angle: 0, axis: [1,0,0])
            
            //the axis there rotates it
            card.move(to: flipDownTransform, relativeTo: card.parent, duration:0.25, timingFunction: .easeInOut)
            
        }
            else {
                var flipUpTranform = card.transform
                flipUpTranform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
                card.move(to: flipUpTranform, relativeTo: card.parent, duration:0.25, timingFunction: .easeInOut)
                
                
            }
        }
    }
}
