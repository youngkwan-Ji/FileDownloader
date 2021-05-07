//
//  FileDownLoadPopup.swift
//  iOS_UTILL
//
//  Created by 영관 on 2018. 7. 24..
//  Copyright © 2018년 Ji Young-Kwan. All rights reserved.
//

import Foundation
import UIKit

class FileDownLoadPopup: UIView {
	var basePopupView = UIView.init()
	var cancelButton : UIButton?
	var lblFileName : UILabel?
	var lblFileSize : UILabel?
	var progressBar : UIProgressView?
	var naviVC : UINavigationController?
	
	var downloader : FileDownLoader?
	var url : String?
	var fileName : String?
	var location : String?
	
	/// 팝업뷰 초기화
	///
	/// - Parameters:
	///   - url: 파일 다운로드 URL
	///   - fileName: 다운받을 파일명
	@objc init(url : String, fileName : String) {
		super.init(frame: UIScreen.main.bounds)
		self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
		self.url = url
		self.fileName = fileName
		
		downloader = FileDownLoader.init(delegate: self)
		downloader?.fileName = fileName
		
		setBasePopupView()
		setMessageAndProgressView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// 팝업 표출과 동시에 다운로드 시작
	func show(){
		let app = UIApplication.shared.delegate as! AppDelegate
		guard self.url != nil && self.fileName != nil else {
			errorPopup(title: "잘못된 요청 인자입니다.")
			return
		}
		
		downloader?.requestFromFileURL(url: url!, fileName: fileName!)
		app.window?.rootViewController?.view.addSubview(self)
	}
	
	/// 팝업뷰 세팅
	private func setBasePopupView(){
		basePopupView.frame.size = CGSize.init(width: UIScreen.main.bounds.size.width / 1.5,
											   height: UIScreen.main.bounds.size.height / 4)
		self.addSubview(basePopupView)
		basePopupView.center = self.center
		basePopupView.backgroundColor = UIColor.white
		basePopupView.layer.cornerRadius = 7.0
	}
	
	/// 팝업뷰 안에 레이블, 버튼 세팅
	private func setMessageAndProgressView(){
		lblFileName = UILabel.init(frame: CGRect.init(x: basePopupView.frame.size.width / 14,
													  y: basePopupView.frame.size.height / 12,
													  width: basePopupView.frame.size.width - basePopupView.frame.size.width / 7,
													  height: basePopupView.frame.size.height / 6))
		lblFileSize = UILabel.init(frame: CGRect.init(x: basePopupView.frame.size.width / 14,
													  y: (basePopupView.frame.size.height / 6) + (basePopupView.frame.size.height / 6),
													  width: basePopupView.frame.size.width - basePopupView.frame.size.width / 7,
													  height: basePopupView.frame.size.height / 6))
		lblFileName?.adjustsFontSizeToFitWidth = true
		lblFileSize?.adjustsFontSizeToFitWidth = true
		lblFileName?.text = "파일이름 :"
		lblFileSize?.text = "파일크기 :"
		basePopupView.addSubview(lblFileName!)
		basePopupView.addSubview(lblFileSize!)
		progressBar = UIProgressView.init(frame: CGRect.init(x: basePopupView.frame.size.width / 14,
															 y: (basePopupView.frame.size.height / 3) + (basePopupView.frame.size.height / 4),
															 width: basePopupView.frame.size.width - (basePopupView.frame.size.width / 7),
															 height: 20))
		basePopupView.addSubview(progressBar!)
		
		cancelButton = UIButton.init(type: UIButtonType.custom)
		cancelButton!.frame.size = CGSize.init(width: basePopupView.frame.size.width / 2.5,
											   height: basePopupView.frame.size.height / 5)
		basePopupView.addSubview(cancelButton!)
		cancelButton!.addTarget(self, action: #selector(removePopupView), for: .touchUpInside)
		cancelButton!.setTitle("취소", for: .normal)
		cancelButton!.backgroundColor = UIColor.init(red: 146/255.0, green: 146/255.0, blue: 146/255.0, alpha: 1)
		cancelButton!.center = CGPoint.init(x: basePopupView.frame.size.width / 2 , y: basePopupView.frame.size.height - (cancelButton!.frame.size.height/1.3) )
	}
	
	/// 다운로드 된 파일 웹뷰로 미리보기
	/// *일부 확장자 형식만 볼 수 있음
	@objc private func showWebView(){
		guard location != nil && FileManager.default.fileExists(atPath: location!) else {
			errorPopup(title: "저장된 파일이 없습니다.")
			return
		}
		
		let webView = UIWebView.init(frame: UIScreen.main.bounds)
		let fileUrl = URL.init(fileURLWithPath: location!)
		let request = URLRequest.init(url: fileUrl)
		webView.loadRequest(request)
		
		let webVC = UIViewController.init()
		webVC.view = webView
		webVC.title = "미리보기"
		
		naviVC = UINavigationController.init(rootViewController: webVC)
		let lefttButton = UIBarButtonItem.init(title: "닫기", style: .done, target: self, action: #selector(removeNaviVC))
		let rightButton = UIBarButtonItem.init(title: "저장", style: .done, target: self, action: #selector(saveFile))
		webVC.navigationItem.leftBarButtonItem = lefttButton
		webVC.navigationItem.rightBarButtonItem = rightButton
		
		self.addSubview(naviVC!.view)
	}
	
	
	/// 임시 폴더에 저장된 파일 사용자 지정 저장
	@objc private func saveFile(){
		guard location != nil && FileManager.default.fileExists(atPath: location!) else {
			errorPopup(title: "파일을 찾을 수 없습니다.")
			return
		}
		
		let fileUrl = URL.init(fileURLWithPath: location!)
		let vc = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
		naviVC?.present(vc, animated: true, completion: nil)
	}
	
	/// 웹뷰 닫기
	@objc private func removeNaviVC(){
		naviVC?.view.removeFromSuperview()
	}
	
	/// 파일 다운로드 완료 시 파일보기 버튼 추가
	fileprivate func addFileShowButton(){
		DispatchQueue.main.async {
			let btnShow = UIButton.init(type: UIButtonType.custom)
			btnShow.frame = self.cancelButton!.frame
			self.basePopupView.addSubview(btnShow)
			btnShow.addTarget(self, action: #selector(self.showWebView), for: .touchUpInside)
			btnShow.setTitle("미리보기", for: .normal)
			btnShow.backgroundColor = UIColor.init(red: 21/255.0, green: 126/255.0, blue: 251/255.0, alpha: 1)
			btnShow.center = CGPoint.init(x: (self.basePopupView.frame.size.width / 4) * 3 , y: self.cancelButton!.center.y)
			self.cancelButton!.center = CGPoint.init(x: self.basePopupView.frame.size.width / 4 , y: self.cancelButton!.center.y )
		}
	}
	
	/// 팝업 닫기
	@objc private func removePopupView(){
		if location != nil{
			try? FileManager.default.removeItem(atPath: location!)
		}
		self.removeFromSuperview()
	}

	/// 에러메세지 팝업 및 다운로드팝업 제거
	///
	/// - Parameter title: 에러 설명
	@objc fileprivate func errorPopup(title : String){
		DispatchQueue.main.async {
			let app = UIApplication.shared.delegate as! AppDelegate
			
			let alert = UIAlertController.init(title: title, message: "다운로드에 실패하였습니다.", preferredStyle: .alert)
			let cancel = UIAlertAction.init(title: "확인", style: .cancel, handler: {(_) in
				self.removePopupView()
			})
			
			alert.addAction(cancel)
			app.window?.rootViewController?.present(alert, animated: true, completion: nil)
		}
	}
}
extension FileDownLoadPopup : FileDownLoadDelegate{
	
	/// 요청 완료 시 호출
	///
	/// - Parameter error: nil이 아닐시 에러
	func didCompleteWithError(error: String?) {
		guard error == nil else {
			errorPopup(title: error!)
			return
		}
	
		self.addFileShowButton()
	}
	
	/// 데이터 다운로드 중 호출
	///
	/// - Parameters:
	///   - percentage: 진행율
	///   - size: 전체 파일 예상 크기
	func didreciveDataLenght(percentage : Float, size : Float) {
		DispatchQueue.main.async {
			self.progressBar?.progress = percentage
			self.lblFileName?.text = "파일이름 : " + self.fileName!
			self.lblFileSize?.text = "파일크기 : " + String(size) + " KB"
		}
	}
	
	/// 파일 다운로드 저장 완료시 호출
	///
	/// - Parameter location: 다운로드 경로
	func didFinishDownWithLoaction(location : String?){
		guard location != nil else {
			errorPopup(title: "파일 저장 경로가 없습니다.")
			return
		}
		self.location = location
	}
}
