//
//  ViewController.swift
//  SystemDetectFaceDemo
//
//  Created by zhangxin on 2022/2/14.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let originImage = UIImage.init(named: "image1")
        let imageV1 = UIImageView.init(image: originImage)
        imageV1.frame = CGRect(x: 100, y: 200, width: 150, height: 150)
        self.view.addSubview(imageV1)
        
        let imageV2 = UIImageView()
        imageV2.frame = CGRect(x: 100, y: 400, width: 150, height: 150)
        self.view.addSubview(imageV2)
        
        let faceList = FaceDetectorManager.getFaceFrame(image: originImage!)
        if let t_frame = faceList.first {
            let result_image = FaceDetectorManager.croppingFaceImage(originImage: originImage!, faceFrame: t_frame, scale: 1)
            imageV2.image = result_image
        }
        
        
    }


}

class FaceDetectorManager: NSObject {
    /// 人脸检测。 返回的是人脸在图像中的坐标， 若数组元素个数为检测到的人脸个数。 .count = 0 则表示检测失败 或者未检测到人脸
    /// - Parameter image: 要检测的图片
    class func getFaceFrame(image:UIImage) -> [CGRect] {
        let ciImage = CIImage.init(image: image)
        let faceDetector:CIDetector = CIDetector.init(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow,CIDetectorTracking:true])!
        let featureArray:[CIFeature] = faceDetector.features(in: ciImage!)
        
        let ciImageSize = ciImage?.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        
        transform = transform.translatedBy(x: 0, y: -CGFloat((ciImageSize?.height)!))
        
        var faceFrameList:[CGRect] = []
        
        for index in 0..<featureArray.count {
            let face:CIFaceFeature = featureArray[index] as! CIFaceFeature
            // 应用变换转换坐标
            var faceViewBounds = face.bounds.applying(transform)
            
            // 在图像视图中计算矩形的实际位置和大小
            let viewSize = image.size
            //计算宽高比例
            let scale = min(viewSize.width / (ciImageSize?.width)!, viewSize.height / (ciImageSize?.height)!)
            
            //放在imageview 之后 图片相对于背景 的 x y 坐标
            let offsetX = (viewSize.width - (ciImageSize?.width)! * scale) / 2
            let offsetY = (viewSize.height - (ciImageSize?.height)! * scale) / 2
            
            //获取缩放后的 脸部位置坐标
            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            faceFrameList.append(faceViewBounds)
        }
        
        return faceFrameList
    }
    
    /// 从图片中截取人脸图像
    /// - Parameter originImage: 原图
    /// - Parameter faceFrame: 人脸坐标
    /// - Parameter scale: 截取的范围 放大的倍数
    class func croppingFaceImage(originImage:UIImage,faceFrame:CGRect,scale:CGFloat,aspectRatio:CGFloat = 1, centerOffset: CGSize = .zero) -> UIImage {
        let center = CGPoint.init(x: faceFrame.midX + (faceFrame.width * centerOffset.width), y: faceFrame.midY + (faceFrame.height * centerOffset.height))
        var frame:CGRect = faceFrame

        //放大截取区域
        frame.size.width = frame.width * scale
        frame.size.height = frame.height * scale
        
        //对比原图大小
        frame.size.width = min(frame.size.width, originImage.size.width)
        frame.size.height = min(frame.size.height, originImage.size.height)
        
        //使得图片的宽高相等
        frame.size.width = max(frame.width,frame.height)
        frame.size.height = frame.width / aspectRatio

        //设置中点
        frame.origin.x = center.x - frame.size.width / 2
        frame.origin.y = center.y - frame.size.height / 2
        
        //判断左上角是否越界
        frame.origin.x = max(0, frame.origin.x)
        frame.origin.y =  max(0, frame.origin.y)

        //判断右下角是否越界
        if frame.maxX > originImage.size.width {
            frame.origin.x =  originImage.size.width - frame.width
        }
        
        if frame.maxY > originImage.size.height {
            frame.origin.y =  originImage.size.height - frame.height
        }
        
        //let croImage = originImage.cropping(cropFrame: frame)
        let croImage = originImage.imageWithClipRect(frame)
     
        return croImage
    }
}


extension UIImage {
    func imageWithClipRect(_ imageRect: CGRect) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(imageRect.size, true, 0.0)
        
        self.draw(in:CGRect(origin: CGPoint(x: -imageRect.x, y: -imageRect.y), size: size))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        //结束上下文
        UIGraphicsEndImageContext()
        return image
    }
}
public extension CGRect {
    
    var x: CGFloat {
        get {
            return origin.x
        }
        
        set {
            origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return origin.y
        }
        
        set {
            origin.y = newValue
        }
    }
    
    
    var width: CGFloat {
        get {
            return size.width
        }
        
        set {
            size.width = newValue
        }
    }
    
    
    var height: CGFloat {
        get {
            return size.height
        }
        
        set {
            size.height = newValue
        }
    }
    
    
    var center: CGPoint {
        get {
            return  CGPoint(x: x + width/2, y: y + height/2)
        }
        
        set {
            origin.x = newValue.x - width/2
            origin.y = newValue.y - height/2
        }
    }

    
    var centerX: CGFloat {
        get {
            return  center.x
        }
        
        set {
            origin.x = newValue - width/2
        }
    }
    
    var centerY: CGFloat {
        get {
            return  center.y
        }
        
        set {
            origin.y = newValue - height/2
        }
    }

}
