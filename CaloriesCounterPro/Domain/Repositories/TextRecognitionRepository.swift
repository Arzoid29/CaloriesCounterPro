import Foundation
import UIKit

protocol TextRecognitionRepository {
    func recognizeText(from image: UIImage) async throws -> String
}
