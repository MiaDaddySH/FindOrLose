import Foundation
import Combine

enum UnsplashAPI {
  static let accessToken = "mMfra-j_3FQEA3bs_dhTfG8VjqlqfrQhJhN1w77PqXM"

  static func randomImage() -> AnyPublisher<RandomImageResponse, GameError> {
    let url = URL(string: "https://api.unsplash.com/photos/random/?client_id=\(accessToken)")!
    
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.urlCache = nil
    let session = URLSession(configuration: config)
    
    var urlRequest = URLRequest(url: url)
    urlRequest.addValue("Accept-Version", forHTTPHeaderField: "v1")

    // 1 You get a publisher from the URL session for your URL request. This is a URLSession.DataTaskPublisher, which has an output type of (data: Data, response: URLResponse). That’s not the right output type, so you’re going to use a series of operators to get to where you need to be.
    return session.dataTaskPublisher(for: urlRequest)
      // 2 Apply the tryMap operator. This operator takes the upstream value and attempts to convert it to a different type, with the possibility of throwing an error. There is also a map operator for mapping operations that can’t throw errors.
      .tryMap { response in
        guard
          // 3 Check for 200 OK HTTP status.
          let httpURLResponse = response.response as? HTTPURLResponse,
          httpURLResponse.statusCode == 200
        else {
          // 4
          throw GameError.statusCode
        }
        // 5 When everything is ok, return the data as output type.
        return response.data
      }
      // 6
      .decode(type: RandomImageResponse.self, decoder: JSONDecoder())
      // 7 处理 Decode时候的错误
      .mapError { GameError.map($0) }
      // 8
      .eraseToAnyPublisher()
  }
}
