
import Foundation
import UIKit
import Combine

enum ImageDownloader {
  
  // 1
  static func download(url: String) -> AnyPublisher<UIImage, GameError> {
    guard let url = URL(string: url) else {
      return Fail(error: GameError.invalidUrl)
        .eraseToAnyPublisher()
    }
    
    //2
    return URLSession.shared.dataTaskPublisher(for: url)
      //3
      .tryMap { response -> Data in
        guard
          let httpURLResponse = response.response as? HTTPURLResponse,
          httpURLResponse.statusCode == 200
        else {
          throw GameError.statusCode
        }
        
        return response.data
      }
      //4
      .tryMap { data in
        guard let image = UIImage(data: data) else {
          throw GameError.invalidImage
        }
        return image
      }
      //5
      .mapError { GameError.map($0) }
      //6
      .eraseToAnyPublisher()
  }
}
