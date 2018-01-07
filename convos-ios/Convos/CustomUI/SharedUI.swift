import UIKit

protocol CustomViewData {
    var uuid: String? { get }
    var name: String { get }
    var photo: UIImage? { get }
}


protocol CustomViewDataOwner {
    var viewDataModels: [CustomViewData] { get set }
}
