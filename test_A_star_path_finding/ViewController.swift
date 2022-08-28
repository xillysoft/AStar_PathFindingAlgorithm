//
//  ViewController.swift
//  test_A_star_path_finding
//
//  Created by zhao on 2022/8/21.
//

import UIKit
import CoreFoundation
import CoreGraphics

class ViewController: UIViewController {
    @IBOutlet weak var gridsView: UIView!
    @IBOutlet weak var switchHeuristic: UISwitch!
    @IBOutlet weak var swithIterativeDeepening: UISwitch!
    @IBOutlet weak var switch8Directional: UISwitch!
    
    var startPoint: CGPoint! = nil
    var endPoint: CGPoint! = nil
    var _circle1: CAShapeLayer! = nil
    var _circle2: CAShapeLayer! = nil
    var _pathShape: CAShapeLayer!
    
    let nWidthi: Int = 20
    var nHeighti: Int! //update after .view did layout
    var graph: MyGraph! = nil
    
    var gridsLayer: CALayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let image0  = UIImage(named: "path_finding_sample.png")  else { fatalError() }
        let size1 = self.gridsView.bounds.size
        
        self.nHeighti = Int(CGFloat(nWidthi) * size1.height / size1.width)
        gridsLayer = CALayer()
        gridsLayer.frame = gridsView.bounds
        self.gridsView.layer.addSublayer(gridsLayer)
        
        self.graph = MyGraph(image: image0.cgImage!, nWidthi: nWidthi, nHeighti: nHeighti, gridsLayer: gridsLayer)
    }
    
    func _convertPointf(point: CGPoint) -> Pointi {
        let size0 = gridsLayer.bounds.size
        let ix = Int( point.x / size0.width * CGFloat(nWidthi) )
        let iy = Int( point.y / size0.height * CGFloat(nHeighti) )
        return Pointi(x: ix, y: iy)
    }
    
    func _convertPointi(pointi: Pointi) -> CGPoint {
        let size0 = gridsLayer.bounds.size
        let fx = CGFloat(pointi.x) * size0.width / CGFloat(nWidthi)
        let fy = CGFloat(pointi.y) * size0.height / CGFloat(nHeighti)
        return CGPoint(x: fx, y: fy)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location_pointf0 = touch.location(in: self.gridsView)
        if startPoint == nil {
            startPoint = _roundPointToGridCenter(point0: location_pointf0)
            _circle1 = _makeCircleLayer(point: startPoint, color: UIColor.green)
            gridsLayer.addSublayer(_circle1)
            
        } else if endPoint == nil {
            endPoint = _roundPointToGridCenter(point0: location_pointf0)
            _circle2 = _makeCircleLayer(point: endPoint, color: UIColor.yellow)
            gridsLayer.addSublayer(_circle2)
            
            
            let startPointi = _convertPointf(point: self.startPoint)
            let endPointi = _convertPointf(point: self.endPoint)
            
            if let pathPointsi = _findPath(startPointi: startPointi,
                                                endPointi: endPointi) {
                print("pathPoints.count=\(pathPointsi.count)")
                
                let pathPointsf = pathPointsi.map { (pi: Pointi) -> CGPoint in
                    let size0 = gridsLayer.bounds.size
                    let x0 = size0.width / CGFloat(nWidthi) / 2.0
                    let y0 = size0.height / CGFloat(nHeighti) / 2.0
                    let xf = CGFloat(pi.x) * size0.width / CGFloat(nWidthi) + x0
                    let yf = CGFloat(pi.y) * size0.height / CGFloat(nHeighti) + y0
                    return CGPoint(x: xf, y: yf)
                }
                
                let path = UIBezierPath()
                for i in 0..<pathPointsf.count {
                    let pt1 = pathPointsf[i]
                    if i == 0 {
                        path.move(to: pt1)
                    } else {
                        path.addLine(to: pt1)
                    }
                }
                _pathShape = CAShapeLayer()
                _pathShape.path = path.cgPath
                _pathShape.strokeColor = UIColor.red.cgColor
                _pathShape.lineWidth = 2.0
                _pathShape.fillColor = UIColor.clear.cgColor
                gridsLayer.addSublayer(self._pathShape)

            } else {
                _circle1.fillColor = UIColor.red.cgColor
                _circle2.fillColor = UIColor.red.cgColor
            }
            
            
        } else { //both point not nil, clear up and ready to start again
            startPoint = nil
            endPoint = nil
            _circle1?.removeFromSuperlayer()
            _circle2?.removeFromSuperlayer()
            _pathShape?.removeFromSuperlayer()

            startPoint = _roundPointToGridCenter(point0: location_pointf0)
            _circle1 = _makeCircleLayer(point: startPoint, color: UIColor.green)
            gridsLayer.addSublayer(_circle1)
        }
    }

    func _roundPointToGridCenter(point0: CGPoint) -> CGPoint {
        let size0 = gridsLayer.bounds.size
        let pointi = _convertPointf(point: point0)
        let pointf = _convertPointi(pointi: pointi)
        
        let fgridx = size0.width / CGFloat(nWidthi)
        let fgridy = size0.height / CGFloat(nHeighti)
        
        let point = CGPoint(x: pointf.x + fgridx/2, y: pointf.y + fgridy/2)
        return point
    }
    
    func _makeCircleLayer(point: CGPoint, color: UIColor) -> CAShapeLayer {
        let circleLayer = CAShapeLayer()
        let radius = 5.0
        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: point.x-radius, y: point.y-radius, width: radius*2, height: radius*2)).cgPath
        circleLayer.fillColor = color.cgColor
        circleLayer.strokeColor = UIColor.blue.cgColor
        return circleLayer
    }
    
    @IBAction func switch8DirectionalValue_didChange(_ sender: UISwitch) {
        self.graph.dir8 = sender.isOn
    }
    
    func _findPath(startPointi: Pointi, endPointi: Pointi) -> [Pointi]? {
        print("_findPath(\n\tstartPointi=\(startPointi), endPointi=\(endPointi)")

        let pathPointsi: [Pointi]?
        let t0 = CFAbsoluteTimeGetCurrent()
        graph.dir8 = switch8Directional.isOn
        
        if self.switchHeuristic.isOn {
            if self.swithIterativeDeepening.isOn {
                //IDA* algorithm
                let ida_star_finder = IDAStarPathFinding<MyGraph>(node0: startPointi,
                                                                  target: endPointi,
                                                                  graph: graph)
                pathPointsi = ida_star_finder.findPath_ID_AStar()
            } else {
                //A* algorithm
                pathPointsi = findPathAStar(from: startPointi, to: endPointi, with: graph)
            }
        } else {
            //Dijkstra algorithm
            pathPointsi = findPathDijkstra(from: startPointi, to: endPointi, with: graph)
        }
        print("time used=\(CFAbsoluteTimeGetCurrent() - t0)s")
        return pathPointsi
    }

}

struct Pointi: Hashable, Equatable, CustomStringConvertible {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    var magnitude: Int {
        return Int( Float((self.x * self.x + self.y * self.y)).squareRoot() )
    }
    
    var manhattan: Int {
        return abs(self.x) + abs(self.y)
    }
    
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    static func -(lhs: Pointi, rhs: Pointi) -> Pointi {
        return Pointi(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    var description: String {
        return "[\(x), \(y)]"
    }
}

struct MyGraph: IGraph {
    
    typealias NodePointi = Pointi
    typealias WeightType = Int
    
    var dir8: Bool = true  //determines which nodes returned from adjacentNodes()
    
    private var dxdy: [(Int, Int)] {
        if dir8 {
            var dxdy_8: [(Int, Int)] = []
            for dx in -1...1 {
                for dy in -1...1 {
                    if dx == 0 && dy == 0 { continue }
                    dxdy_8.append((dx, dy))
                }
            }
            return dxdy_8
        } else {
            return [(-1, 0), (1, 0), (0, -1), (0, 1)]
        }
    }
    
    let nWidthi: Int
    let nHeighti: Int
    
    let imagePixelsi: [[Bool]]
    
    init(image: CGImage, nWidthi: Int, nHeighti: Int, gridsLayer: CALayer) {
        print("image.size=\((image.width, image.height)), gridsLayer.size=\(gridsLayer.bounds)")
        self.nWidthi = nWidthi
        self.nHeighti = nHeighti
        let imageWidth = CGFloat(image.width)
        let imageHeight = CGFloat(image.height)
                
        var imagePixelsi: [[Bool]] = []
        let imageGridSizeX = imageWidth / CGFloat(nWidthi)
        let imageGridSizeY = imageHeight / CGFloat(nHeighti)
        let x0 = imageGridSizeX / 2.0
        let y0 = imageGridSizeY / 2.0
        let fdx = CGFloat(imageGridSizeX * 0.25)
        let fdy = CGFloat(imageGridSizeY * 0.25)

        print("image.size=\((imageWidth, imageHeight)), iwidth=\(nWidthi), iheight=\(nHeighti) gridSize=\((imageGridSizeX, imageGridSizeY)) gridsLayer.size=\(gridsLayer.bounds.size)")

        
        for iy0 in 0..<nHeighti {
            var rowPixels: [Bool] = []
            for ix0 in 0..<nWidthi {
                let fcx0 = CGFloat(ix0) * imageWidth / CGFloat(nWidthi) + x0
                let fcy0 = CGFloat(iy0) * imageHeight / CGFloat(nHeighti) + y0
                //pick 5 pixels and average them into `pixel`
                let pixel0 = image.getPixelValue(CGPoint(x: fcx0, y: fcy0))
                let pixel1 = image.getPixelValue(CGPoint(x: fcx0 - fdx, y: fcy0 - fdy))
                let pixel2 = image.getPixelValue(CGPoint(x: fcx0 - fdx, y: fcy0 + fdy))
                let pixel3 = image.getPixelValue(CGPoint(x: fcx0 + fdx, y: fcy0 - fdy))
                let pixel4 = image.getPixelValue(CGPoint(x: fcx0 + fdx, y: fcy0 + fdy))
                let pixel = (pixel0 + pixel1 + pixel2 + pixel3 + pixel4) / 5
                rowPixels.append(pixel >= 128) //binarize the pixel into white/black
            }
            imagePixelsi.append(rowPixels)
        }
        self.imagePixelsi = imagePixelsi
        
        let layerGridSizeX = gridsLayer.frame.size.width / CGFloat(nWidthi)
        let layerGridSizeY = gridsLayer.frame.size.height / CGFloat(nHeighti)
        for iy in 0..<nHeighti {
            for ix in 0..<nWidthi {
                let fx0 = CGFloat(ix) * gridsLayer.bounds.size.width / CGFloat(nWidthi)
                let fy0 = CGFloat(iy) * gridsLayer.bounds.self.height / CGFloat(nHeighti)
                let pixel0 = imagePixelsi[iy][ix]
                                
                let gridShapeLayer1 = CAShapeLayer()
                let gridPath = UIBezierPath.init(rect: CGRect(x: fx0, y: fy0,
                                                                     width: layerGridSizeX, height: layerGridSizeY))
                gridShapeLayer1.path = gridPath.cgPath
                gridShapeLayer1.strokeColor = UIColor.darkGray.cgColor
                gridShapeLayer1.fillColor = pixel0 ? UIColor.cyan.cgColor : UIColor.blue.cgColor
                gridsLayer.addSublayer(gridShapeLayer1)
            }
        }
        
    }
    
    //<a, b> is adjacent if they are neighbor and they have same color
    func adjacentNodes(with a: NodePointi) -> Set<NodePointi> {
        let ix0 = a.x, iy0 = a.y
        guard ix0 < nWidthi && iy0 < nHeighti else { fatalError() }
        let pixel0 = imagePixelsi[iy0][ix0]
        var adj: Set<NodePointi> = []
        for (dx, dy) in self.dxdy {
            let ix1 = ix0 + dx, iy1 = iy0 + dy
            if ix1 < 0 || iy1 < 0 || ix1 >= nWidthi || iy1 >= nHeighti { continue }
            
            let pixel1 = imagePixelsi[iy1][ix1]
            if pixel1 == pixel0 {
                adj.insert(Pointi(x: ix1, y: iy1))
            }
        }
        return adj
    }
    
    func W(_ a: NodePointi, _ b: NodePointi) -> WeightType? {
        return (a - b).manhattan
    }
    
    func H(_ a: Pointi, _ b: Pointi) -> WeightType {
        return (a - b).manhattan
    }

}

extension CGImage {
    
    func getPixelValue(_ point: CGPoint) -> Int {
        let pix = getPixelRGBA(point)
        let rw = Int(0.3 * 255), gw = Int(0.6 * 255), bw = Int(0.1 * 255)
        let grayscale = (Int(pix.0) * rw + Int(pix.1) * gw + Int(pix.2) * bw) / 255
        return grayscale
    }
    
    func getPixelRGBA(_ point: CGPoint) -> (CUnsignedChar, CUnsignedChar, CUnsignedChar, CUnsignedChar) {
        
        var pixel: [CUnsignedChar] = [0, 0, 0, 0] //RGBA pixel

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                                space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        context!.translateBy(x: -point.x, y: -point.y)

        context!.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        let (red, green, blue, alpha) = (pixel[0], pixel[1], pixel[2], pixel[3])
        return (red, green, blue, alpha)
        
    }

}

extension CGSize {
    static func /(size1: CGSize, size2: CGSize) -> (CGFloat, CGFloat) {
        return (size1.width/size2.width, size1.height/size2.height)
    }
}
extension CGPoint {
    static func *(pt: CGPoint, a: CGFloat) -> CGPoint {
        return CGPoint(x: pt.x * a, y: pt.y * a)
    }
    
    var magnitude: CGFloat {
        return (self.x * self.x + self.y * self.y).squareRoot()
    }
    
    var manhattan: CGFloat {
        return abs(self.x) + abs(self.y)
    }
    
    var rounded: CGPoint {
        return CGPoint(x: Int(self.x), y: Int(self.y))
    }
    
    var pointi: Pointi{
        return Pointi(x: Int(self.x), y: Int(self.y))
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}

extension UIImage {
    func scaledSizeTo(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { fatalError() }
        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { fatalError() }
        UIGraphicsEndImageContext()
        return newImage
    }
}
