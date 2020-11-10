//
//  ViewController.swift
//  CairoTiles
//
//  Created by n/a on 10/17/20.
//  Copyright © 2020 Werner Lonsing. All rights reserved.
//

// search for cairo on instructables
// https://en.wikipedia.org/wiki/Pentagonal_tiling


import Cocoa    // general OS and UI framework, former AppKit and FoundationKit
import SceneKit // framework for rendring 3D-shapes

class ViewController: NSViewController, NSTextFieldDelegate {
    // a bunch of global varibles
    // since this is a small prgramm, we don't cara about local vs. global, or namespaces
    
    var sceneView: SCNView?
    let cairoName = "CairoTiles"    // name for the rootNode to find it in the node tree
    
    var tileDegree:CGFloat = 60// from 45 to 90 convex, to 135 concave
    
    var sinVal:CGFloat? // for overall calcualtions
    var cosVal:CGFloat?
    var dihedralAngle:Double?
    
    var eventMonitor:Any?   // hookup for the very basic  UI, once e key is pressed, an alert pops up for the angle
    
    
    override func viewDidAppear() {
        
        self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)  // add the monitor for key events
            return $0
        }
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        sceneView = SCNView(frame: view.frame)
        sceneView?.autoresizingMask = view.autoresizingMask
        
        let scene = SCNScene()//named: "CairoTiles")
        sceneView?.scene = scene
        
        sceneView?.scene?.rootNode.addChildNode(createCairoMap())
        
        sceneView?.backgroundColor = NSColor.systemBlue
        sceneView?.allowsCameraControl = true
        
        self.view = sceneView!
        
    }
    
    func createCairoMap() -> SCNNode
    {
        let template = self.cairoShape()
        var node = template
        let rootNode = SCNNode()
        rootNode.name = cairoName
        
        for vert:CGFloat in stride(from: -8.0, through: 8.0, by: 4.0) {// create a map by 5 tiles per row (-8.0,-4.0,0.0,4.0,8.0; nice loopings)
            let vertOffset = vert * sinVal!
            let vertOffsetb = (vert - 2) * sinVal!
            for horz:CGFloat in stride(from: -8.0, through: 8.0, by: 4.0) {
                node = template.clone()
                
                node.position = SCNVector3Make(-horz * sinVal!, vertOffset, 0);
                rootNode.addChildNode(node)
                
                node = template.clone()
                node.position = SCNVector3Make(-(horz + 2) * sinVal!, vertOffsetb, 0);
                rootNode.addChildNode(node)
            }
        }
        // calculate and add the surrounding box for a group of four tiles
        let box = SCNBox.init(width: 4 * (sinVal)!, height: 2 * (sinVal! + cosVal!), length: 0.4, chamferRadius: 0.02)
        
        // print the values to the concole, the referring 1.0 is the size of the four other sides of the tiles
        let s = String(format: " box: %3.6f height: %3.6f angle: %3.2f; tile: small side: %1.6f height: %1.6f width: %1.6f", 4 * (sinVal)!, 2 * (sinVal! + cosVal!), self.tileDegree, 2 * (sinVal! - cosVal!),cosVal! + sinVal!, 2 * sinVal!)
        print(s)
        
        node = SCNNode(geometry: box)
        let aMaterial = SCNMaterial()
        
        aMaterial.diffuse.contents = NSColor.init(white: 0.9, alpha: 0.4)
        box.materials = [aMaterial]
        
        let scale = 1.0
        node.scale = SCNVector3(scale, scale, scale)
        node.position = SCNVector3Make(0, 0, 0.1);
        
        // comment only this line out, if you don't want to see the box
        rootNode.addChildNode(node)
        
        return rootNode
    }
    
    
    
    func cairoTile(materials:[SCNMaterial]) -> SCNNode
    {
        let shape =  SCNShape.init(path: self.cairoPath(), extrusionDepth: 0.2)
        
        shape.materials = materials
        
        let node = SCNNode(geometry: shape)
        let scale = 0.98
        node.scale = SCNVector3(scale, scale, scale)
        
        
        return node
    }
    
    func cairoShape() -> SCNNode
    {
        
        let aWhiteMaterial = SCNMaterial()
        aWhiteMaterial.diffuse.contents = NSColor.white
        
        let aBlackMaterial = SCNMaterial()
        aBlackMaterial.diffuse.contents = NSColor.black
        
        let aGrayMaterial = SCNMaterial()
        aGrayMaterial.diffuse.contents = NSColor.gray
        let aLightGrayMaterial = SCNMaterial()
        aLightGrayMaterial.diffuse.contents = NSColor.lightGray
        let aDarkGrayMaterial = SCNMaterial()
        aDarkGrayMaterial.diffuse.contents = NSColor.darkGray
        
        var materials = [aWhiteMaterial, aGrayMaterial, aGrayMaterial]
        
        
        let node = SCNNode()
        var tile = self.cairoTile(materials: materials)
        tile.position = SCNVector3Make(0, -sinVal!, 0);
        
        node.addChildNode(tile)
        materials.reverse()
        
        tile = self.cairoTile(materials: materials)
        tile.rotation = SCNVector4Make(0, 0, 1, (.pi/2));
        tile.rotation = SCNVector4Make(1, 0, 0, (.pi));
        tile.position = SCNVector3Make(0, sinVal!, 0);
        
        node.addChildNode(tile)
        materials = [aBlackMaterial, aGrayMaterial, aDarkGrayMaterial]
        
        tile = self.cairoTile(materials: materials)
        tile.rotation = SCNVector4Make(0, 0, 1, (.pi/2 * 3));
        tile.position = SCNVector3Make(sinVal!, 0, 0);
        node.addChildNode(tile)
        materials.reverse()
        
        tile = self.cairoTile(materials: materials)
        tile.rotation = SCNVector4Make(0, 0, 1, (.pi/2));
        tile.position = SCNVector3Make(-sinVal!, 0, 0);
        node.addChildNode(tile)
        
        return node
        
    }
    
    
    func cairoPath() -> NSBezierPath
    {
        let bPath = NSBezierPath()
        sinVal = CGFloat(sin(tileDegree * .pi / 180.0))
        cosVal = CGFloat(cos(tileDegree * .pi / 180.0))
        
        bPath.move(to: NSPoint(x: -sinVal!, y: 0.0))
        bPath.line(to: NSPoint(x: 0.0, y: -cosVal!))
        bPath.line(to: NSPoint(x: sinVal!, y: 0.0))
        
        bPath.line(to: NSPoint(x: sinVal! - cosVal!, y: sinVal!))
        bPath.line(to: NSPoint(x: -(sinVal! - cosVal!), y: sinVal!))
        bPath.close()
        return bPath
    }
    
    
    
    override func keyDown(with event: NSEvent) {
        
        if(nil != self.eventMonitor)
        {
            NSEvent.removeMonitor(eventMonitor!)
            eventMonitor = nil
        }
        
        let alert = NSAlert()
        alert.messageText = "Angle"
        alert.informativeText = "The key-angle of the Cairo-tile"
        alert.alertStyle = .warning
        
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        
        let unameField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        let fm = NumberFormatter()
        fm.minimum = 45.0
        fm.maximum = 180.0
        fm.numberStyle = .decimal
        alert.accessoryView = unameField
        alert.window.initialFirstResponder = unameField
        unameField.delegate = self
        unameField.formatter = fm
        
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) in
            if modalResponse == .alertFirstButtonReturn {
                let angle = unameField.floatValue
                if(45.0 <= angle && 135.0 >= angle)
                {
                    let oldNode = self.sceneView?.scene?.rootNode.childNode(withName: self.cairoName, recursively: true)
                    if(nil != oldNode)
                    {
                        oldNode?.removeFromParentNode()
                        self.tileDegree = CGFloat(angle)
                    }
                    self.sceneView?.scene?.rootNode.addChildNode(self.createCairoMap())
                }
                self.nextResponder!.flushBufferedKeyEvents()
                self.flushBufferedKeyEvents()
                
                
            }
        })
    }
    
}

