//
//  NetworkService.swift
//  iOS_UTILL
//
//  Created by 영관 on 2018. 7. 24..
//  Copyright © 2018년 Ji Young-Kwan. All rights reserved.
//

import Foundation

class NetworkService : NSObject {
	var fileName : String?
	var delegate : FileDownLoadDelegate?
	
	init(delegate : FileDownLoadDelegate) {
		super.init()
		self.delegate = delegate
	}
	
	/// 요청된 URL로 다운로드 요청
	///
	/// - Parameters:
	///   - url: 다운로드 URL
	///   - fileName: 파일명
	func requestFromFileURL(url : String, fileName : String){
		self.fileName = fileName
		let urlString = url + fileName
		let session : URLSession = URLSession.init(configuration: .default, delegate: self, delegateQueue: nil)
		
		let url = URL(string:urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
	
		if let nnUrl = url{
			let req = URLRequest.init(url: nnUrl)
			let connect = session.downloadTask(with: req)
			connect.resume()
		}
	}
}

//MARK: - URLSessionDownloadDelegate
extension NetworkService : URLSessionDownloadDelegate{
	/// 요청 완료 시
	///
	/// - Parameters:
	///   - session: 요청 세션
	///   - task: 요청 테스크
	///   - error: nil 아닐 시 다운로드 실패
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if error != nil{
			delegate?.didCompleteWithError(error: error.debugDescription)
		}else{
			delegate?.didCompleteWithError(error: nil)
		}
	}
	
	/// 파일 다운로드 완료 시
	///
	/// - Parameters:
	///   - session: 요청 세션
	///   - downloadTask: 요청 테스크
	///   - location: 저장된 위치 (임시폴더)
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
		let tmpDicPath = location.deletingLastPathComponent()
		let newFilePath = tmpDicPath.path + "/" + fileName!

		do{
			if FileManager.default.fileExists(atPath: newFilePath){
				try FileManager.default.removeItem(atPath: newFilePath)
			}
			try FileManager.default.moveItem(atPath: location.path, toPath: newFilePath)
		}catch{
			delegate?.didCompleteWithError(error: "파일 저장에 실패하였습니다.")
			return
		}
	
		delegate?.didFinishDownWithLoaction(location: newFilePath)
	}
	
	/// 다운로드 중 데이터 받을 시
	///
	/// - Parameters:
	///   - session: 요청 세션
	///   - downloadTask: 요청 테스크
	///   - bytesWritten: 이번에 받은 바이트
	///   - totalBytesWritten: 현재 까지 받은 바이트
	///   - totalBytesExpectedToWrite: 예상 총 바이트
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
		if totalBytesExpectedToWrite > 0 {
			let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
			let kbSize : Float = Float(totalBytesExpectedToWrite / 1000)
			delegate?.didreciveDataLenght(percentage: progress, size: kbSize)
		}else{
			delegate?.didCompleteWithError(error: "파일이 존재하지 않습니다.")
		}
	}
}

