//
//  CustomBotCell.swift
//  ChatBot
//
//  Created by Riddhi Makwana on 08/09/21.
//

import UIKit

class CustomBotCell: UITableViewCell , UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
   
    @IBOutlet weak var imgBackground : UIImageView!

    @IBOutlet weak var lblFeatureTitle : UILabel!
    @IBOutlet weak var collectionView : UICollectionView!
    var arrFeature : [ResponseButton] = []
    var btnFeaturePressed :  (String,String) -> Void = {_,_  in }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
    func loadCompanyCollectionView(arrFeature:[ResponseButton]){
        self.arrFeature = arrFeature
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.collectionView.frame.size.width , height: 50)

    }
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return  0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFeature.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featureDetailCollectionCell", for: indexPath as IndexPath) as! featureDetailCollectionCell
        let obj = arrFeature[indexPath.row]
        cell.lblFeature.setTitle(" \(obj.title ?? "")", for: .normal)
        cell.lblFeature.tag = indexPath.row
        cell.lblFeature.layer.cornerRadius = 8.0
        cell.lblFeature.layer.masksToBounds = true
        
        return cell
    }
    
    @IBAction func btnFeatureClick(_ sender : UIButton){
        let obj = arrFeature[sender.tag]

        btnFeaturePressed(obj.payload ?? "",obj.title ?? "")
    }
}
class featureDetailCollectionCell: UICollectionViewCell{
    @IBOutlet weak var lblFeature : UIButton!
}
