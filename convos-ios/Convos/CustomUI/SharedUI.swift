import UIKit

protocol CustomViewData: Hashable {
    var uuid: String? { get }
    var text: String { get }
    var photo: UIImage? { get }
}
