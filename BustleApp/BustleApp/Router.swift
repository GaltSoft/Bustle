/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit

class Router: NSObject {

    let session = URLSession.shared

    /*
        Method: Constructs an HTTP GET request to the destination url
     */

    func onGet(url: String, callback: @escaping (Data?, Error?) -> Void) {

        var request: URLRequest = URLRequest(url: URL(string: url)!)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        taskManager(request: request) { data, error in
            callback(data, error)
        }
    }

    /*
        Method: Constructs an HTTP POST request to the destination url
        containing the given json serializable object
     */

    func onPost(url: String,
                jsonString: String,
                callback: @escaping (Data?, Error?) -> Void) {

        var request = buildRequest(url)

        request.httpMethod = "POST"
        request.httpBody = jsonString.data(using: String.Encoding.utf8)

        taskManager(request: request) { data, error in
            callback(data, error)
        }

    }

    /*
        Method: Constructs an HTTP Patch request to the destination url
        containing the given json serializable object
     */

    func onPatch(url: String,
                jsonString: String,
                callback: @escaping (Data?, Error?) -> Void) {

        var request = buildRequest(url)

        request.httpMethod = "PATCH"
        request.httpBody = jsonString.data(using: String.Encoding.utf8)

        taskManager(request: request) { data, error in
            callback(data, error)
        }

    }

    /*
        Method: Constructs an HTTP Delete request to the destination url
        containing the given json serializable object
     */

    func onDelete(url: String, callback: @escaping (Data?, Error?) -> Void) {

        var request = buildRequest(url)

        request.httpMethod = "DELETE"

        taskManager(request: request) { data, error in
            callback(data, error)
        }
    }

    /*
        Method: Executes the current http request asynchronously
     */

    func taskManager(request: URLRequest, callback: @escaping (Data?, Error?) -> Void) {

        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let task = session.dataTask(with: request) {
            data, response, error in

            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }

            if let error = error {
                print(error.localizedDescription)
                callback(nil, error)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    callback(data, error)
                }
            }


        }

        task.resume()
    }

    private func buildRequest(_ url: String) -> URLRequest {

        guard let url = URL(string: url) else {
            fatalError("Could not resolve URL")
        }
        
        var request: URLRequest = URLRequest(url: url)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        return request
    }
}
