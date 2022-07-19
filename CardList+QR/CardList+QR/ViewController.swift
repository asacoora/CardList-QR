//
//  ViewController.swift
//  LINE Fintech
//

import UIKit

class ViewController: UIViewController {
    var timer : Timer?
    var timerNum = 30
    let CELL_ID = "CARD_CELL"
    var CARD_IMG_WEIDTH = 300.0
    let CARD_IMG_HEIGHT = 200.0
    
    var cardImgStr :[String] = [String]()
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var qrStr: UILabel!
    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnRefresh: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //CARD_IMG_WEIDTH = self.collectionView.frame.size.width - 10.0
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = CardsCollectionFlowLayout()
        
        
        self.callQrString {
            //self.setQrStr(str: <#T##String#>)
        }
        
        self.callCardList()
        // API 호출 예시입니다. (확인 후 제거)
        
        
        // ImageLoader 사용 예시입니다. (확인 후 제거)
        //        ImageLoader(url: "이미지 URL").load { result in
        //            switch result {
        //            case .success(let image):
        //                print(image)
        //            case .failure(let error):
        //                print(error)
        //            }
        //        }
    }
    
    @IBAction func refreshQr(_ sender: Any) {
        btnRefresh.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            self.btnRefresh.isEnabled = true
        }
        self.clearQr()
        self.progress.progress = 0
        self.lblTime.text = ""
        
        self.callQrString{}
        
    }
    func callQrString(complete : @escaping ()->Void){
        
        self.progress.progress = 0.0
        API.qrString.send { result in
            switch result {
            case .success(let data):
                print(data)
                
                self.setQrStr(str: data.qrString)
                let size : CGSize = CGSize(width: 100, height: 100)
                let img = Utils.generateQRCode(from: data.qrString , size: size)
                if let i = img{
                    self.setQrImg(img: i)
                }
                self.beginProgress()
                
            case .failure(let error):
                print(error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                    
                    self.callQrString {}
                }
                
                
                
            }
        }
    }
    func beginProgress(){
        
        if timer != nil && timer!.isValid {
            timer!.invalidate()
        }
        
        
        timerNum = 30
        
    
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setProgress), userInfo: nil, repeats: true)
    }
    
    @objc func setProgress( ){
        
        let v = Float(self.timerNum) / Float(30)
        self.progress.progress = v
        self.lblTime.text = " \(self.timerNum) "
        
        if(timerNum == 0) {
                timer?.invalidate()
                timer = nil
                
            self.clearQr()
            }
        self.timerNum -= 1
        
    }
    
    func callCardList(){
        
        API.cardList.send{ result in
            switch result {
            case .success(let data):
                //print(data)
                self.cardImgStr.removeAll()
                for  card in data.cardList{
                    print ()
                    self.cardImgStr.append(card.imgPath)
                    self.collectionView.reloadData()
                }
                
                
                
            case .failure(let error):
                print(error)
            }
        }
    }
    func setQrStr(str : String){
        self.qrStr.text = str
    }
    func setQrImg(img : UIImage){
        self.qrImg.image = img
    }
    func clearQr(){
        self.qrStr.text = ""
        self.qrImg.image = nil
    }
    
}
extension ViewController : UICollectionViewDelegate{
    
}
extension ViewController : UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let s = CGSize(width: self.CARD_IMG_WEIDTH, height: self.CARD_IMG_HEIGHT)
        return s
    }
    
}
extension ViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cardImgStr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for: indexPath) as! CardCell
        print ("cell")
        
        let loader = ImageLoader(url: self.cardImgStr[indexPath.row])
        
        loader.load{ result in
            switch result{
            case .success(let data):
                print (data)
                cell.cardImg.image = data
                let imgNmae = "card\(indexPath.row + 1)"
                cell.cardImg.image = UIImage(named: imgNmae)
            case .failure(let error):
                print (error)
                
            }
        }
        
        
        return cell
    }
    
    
}

class CardCell : UICollectionViewCell{
    @IBOutlet weak var cardImg: UIImageView!
    
}

class CardsCollectionFlowLayout: UICollectionViewFlowLayout {
    private let itemWidth = 300
    private let itemHeight = 200
    
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        scrollDirection = .horizontal
        itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        let peekingItemWidth = itemSize.width / 10
        let horizontalInsets = (collectionView.frame.size.width - itemSize.width) / 2
        
        print ("inset:\(horizontalInsets)")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: horizontalInsets, bottom: 0, right: horizontalInsets)
        //minimumLineSpacing = horizontalInsets - peekingItemWidth
        minimumLineSpacing = peekingItemWidth
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        var a = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left
        print ("proposedContentOffset.x : \(proposedContentOffset.x)")
        print ("horizontalOffset : \(horizontalOffset)")
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        
        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
        
        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            print ("itemoffset\(itemOffset):// \(itemOffset - horizontalOffset)")
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
                a = itemOffset
            }
        })
        //print ("offset:\(offsetAdjustment)")
        print ("offset:\(proposedContentOffset.x + offsetAdjustment)")
        
        print ("a:\(a)")
        //return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
        return CGPoint(x: a - collectionView.contentInset.left, y: 0)
    }
    
}
