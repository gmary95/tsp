//
//  ViewController.swift
//  tsp
//
//  Created by Mary Gerina on 2/25/19.
//  Copyright © 2019 Mary Gerina. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var inputTextView: NSTextView!
    @IBOutlet var outputTextView: NSTextView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var proccessedImageView: NSImageView!
    
    var map: [[Int]]!
    var mapWidht: Int!
    var mapHeight: Int!
    
    enum OverrideFlags: UInt8 {
        case OF_RIVER_MARSH = 0x10
        case OF_INLAND = 0x20
        case OF_WATER_BASIN = 0x40
    }
    
    // Some constants
    enum Constant: Int {
        case IMAGE_DIM = 2048 // Width and height of the elevation and overrides image
        
        case ROVER_X = 159
        case ROVER_Y = 1520
        case BACHELOR_X = 1303
        case BACHELOR_Y = 85
        case WEDDING_X = 1577
        case WEDDING_Y = 1294
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func loadFromFile(fileName: String) -> [UInt8]{
        var array = [UInt8]()
        if let path = Bundle.main.path(forResource: fileName, ofType: "data") {
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            array = [UInt8](data)
            return array
        }
        return array
    }
    
    func donut(x: Int, y: Int, x1: Int, y1: Int) -> Bool {
        let dx = x - x1
        let dy = y - y1
        let r2 = dx * dx + dy * dy
        return r2 >= 150 && r2 <= 400
    }
    
    func readFiles() {
        let elevation = loadFromFile(fileName: "elevation")
        let overrides = loadFromFile(fileName: "overrides")
        
        createMap(ovverides: overrides)
    }
    
    func createMap(ovverides: [UInt8]) {
        var map: [[Int]] = []
        for i in 0 ..< Constant.IMAGE_DIM.rawValue {
            var array: [Int] = []
            for j in 0 ..< Constant.IMAGE_DIM.rawValue {
                if ovverides[i * Constant.IMAGE_DIM.rawValue + j] == 0x00 {
                    array.append(0)
                } else {
                    array.append(1)
                }
            }
            map.append(array)
        }
        mapWidht = Constant.IMAGE_DIM.rawValue
        mapHeight = Constant.IMAGE_DIM.rawValue
        self.map = map
        drawMap()
    }
    public func readMap() {
        mapWidht = 10
        mapHeight = 10
        map = [
            [1,1,1,1,1,1,1,1,1,1],
            [1,0,0,0,0,0,0,0,0,1],
            [1,0,0,0,1,1,1,1,0,1],
            [1,1,1,0,1,0,1,1,0,1],
            [1,0,0,0,1,0,0,0,0,1],
            [1,0,1,1,1,0,1,1,1,1],           
            [1,0,0,0,0,0,0,0,0,1],
            [1,1,0,1,1,1,0,1,1,1],
            [1,0,0,0,0,1,0,0,0,1],
            [1,1,1,1,1,1,1,1,1,1],
        ]
    }
    
    public func drawMap() {
        let yourAttributes = [NSAttributedString.Key.foregroundColor: NSColor.red, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 1)]
        let yourOtherAttributes = [NSAttributedString.Key.foregroundColor: NSColor.green, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 1)]
        let pointsAttributes = [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 1)]
        
        let str = NSMutableAttributedString()
        for y in 0 ..< mapHeight {
            str.append(NSAttributedString(string: "\n"))
            for x in 0 ..< mapWidht {
                if map[y][x] == 1 {
                    str.append(NSMutableAttributedString(string: ".", attributes: yourAttributes))
                } else {
                    if (x == Constant.BACHELOR_X.rawValue && y == Constant.BACHELOR_Y.rawValue) || (x == Constant.ROVER_X.rawValue && y == Constant.ROVER_Y.rawValue) || (x == Constant.WEDDING_X.rawValue && y == Constant.WEDDING_Y.rawValue) {
                        str.append( NSMutableAttributedString(string: ".", attributes: pointsAttributes))
                    } else {
                        str.append( NSMutableAttributedString(string: ".", attributes: yourOtherAttributes))
                    }
                }
            }
        }
        
        inputTextView.textStorage?.append(str)
//        findWave(startX: Constant.ROVER_X.rawValue, startY: Constant.ROVER_Y.rawValue, targetX: Constant.BACHELOR_X.rawValue, targetY: Constant.BACHELOR_Y.rawValue)
    }
    
    public func findWave(startX: Int, startY: Int, targetX: Int, targetY: Int) {
        var add = true
        var cMap = Array(repeating: Array(repeating: 0, count: mapWidht), count: mapHeight)
        var step = 0
        for y in 0 ..< mapHeight {
            for x in 0 ..< mapWidht {
                if map[y][x] == 1 {
                    cMap[y][x] = -2//this is wall
                } else {
                    cMap[y][x] = -1//empty cell
                }
            }
        }
        cMap[targetY][targetX] = 0
        while (add == true)
        {
            add = false
            for y in 0 ..< mapHeight {
                for x in 0 ..< mapWidht {
                    if cMap[x][y] == step {
                        if (y - 1 >= 0 && cMap[x][y - 1] != -2 && cMap[x][y - 1] == -1) {
                            cMap[x][y - 1] = step + 1
                        }
                        if (x - 1 >= 0 && cMap[x - 1][y] != -2 && cMap[x - 1][y] == -1) {
                            cMap[x - 1][y] = step + 1
                        }
                        
                        if (y + 1 < mapWidht && cMap[x][y + 1] != -2 && cMap[x][y + 1] == -1) {
                            cMap[x][y + 1] = step + 1
                        }
                        if (x + 1 < mapHeight && cMap[x + 1][y] != -2 && cMap[x + 1][y] == -1) {
                            cMap[x + 1][y] = step + 1
                        }
                    }
                }
            }
            step += 1
            
            add = true
            if cMap[startY][startX] == -1 {
                add = true
            }
            if step > mapWidht * mapHeight {
                add = false
            }
        }
        
        // create path
        var path: [Point] = []
        var x = startX
        var y = startY
        var stepForward = cMap[y][x]
        while stepForward != 0 {
            if (y - 1 >= 0 && cMap[y][x - 1] == stepForward - 1) {
                stepForward = cMap[y][x - 1]
                x = x - 1
                path.append(Point(x: x, y: y))
            }
            if (x - 1 >= 0 && cMap[y - 1][x] == stepForward - 1) {
                stepForward = cMap[y - 1][x]
                y = y - 1
                path.append(Point(x: x, y: y))
            }
            
            if (y + 1 < mapWidht && cMap[y][x + 1] == stepForward - 1) {
                stepForward = cMap[y][x + 1]
                x = x + 1
                path.append(Point(x: x, y: y))
            }
            if (x + 1 < mapHeight && cMap[y + 1][x] == stepForward - 1) {
                stepForward = cMap[y + 1][x]
                y = y + 1
                path.append(Point(x: x, y: y))
            }
        }
        
        
        let yourAttributes = [NSAttributedString.Key.foregroundColor: NSColor.red, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 25)]
        let yourOtherAttributes = [NSAttributedString.Key.foregroundColor: NSColor.green, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 25)]
        let startAttributes = [NSAttributedString.Key.foregroundColor: NSColor.blue, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 25)]
        let finishAttributes = [NSAttributedString.Key.foregroundColor: NSColor.yellow, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 25)]
        let regularAttributes = [NSAttributedString.Key.foregroundColor: NSColor.white, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 25)]
        
        let str = NSMutableAttributedString()
        for y in 0 ..< mapHeight {
            str.append(NSAttributedString(string: "\n"))
            for x in 0 ..< mapWidht {
                if (cMap[y][x] == -1) {
                    str.append(NSAttributedString(string: " \t"))
                } else if (cMap[y][x] == -2) {
                    str.append(NSMutableAttributedString(string: "-\t", attributes: yourAttributes))
                } else if (y == startY && x == startX) {
                    str.append(NSMutableAttributedString(string: "S\t", attributes: startAttributes))
                } else if (y == targetY && x == targetX) {
                    str.append(NSMutableAttributedString(string: "F\t", attributes: finishAttributes))
                } else if (cMap[y][x] > -1) {
                    if contains(a: path, v: (x, y)) {
                        str.append(NSMutableAttributedString(string: "\(cMap[y][x])\t", attributes: yourOtherAttributes))
                    } else {
                        str.append(NSMutableAttributedString(string: "\(cMap[y][x])\t", attributes: regularAttributes))
                    }
                }
            }
        }
        outputTextView.textStorage?.append(str)
    }
    
    func contains(a:[Point], v:(Int,Int)) -> Bool {
        let (x, y) = v
        for point in a {
            if point.x == x && point.y == y { return true }
        }
        return false
    }
    
    @IBAction func startProccess(_ sender: Any) {
        readFiles()
//        readMap()
//        drawMap()
    }
}

