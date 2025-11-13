import Foundation
import simd
import RoomPlan

struct SerializableCapturedRoom: Codable {
    struct Wall: Codable {
        let start: [Float]
        let end: [Float]
        let length: Float
    }

    struct Opening: Codable {
        let type: String
        let position: [Float]
    }

    struct Object: Codable {
        let category: String
        let position: [Float]
        let dimensions: [Float]
    }

    let walls: [Wall]
    let openings: [Opening]
    let objects: [Object]
}

private extension simd_float4x4 {
    var translation: SIMD3<Float> {
        SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }

    var right: SIMD3<Float> { // local X axis (width direction)
        let v = SIMD3<Float>(columns.0.x, columns.0.y, columns.0.z)
        return simd_normalize(v)
    }
}

extension CapturedRoom {
    func toSerializable() -> SerializableCapturedRoom {
        // Walls: CapturedRoom.Surface doesn't expose start/end/length directly.
        // Derive them from transform (center + orientation) and dimensions (width).
        let walls: [SerializableCapturedRoom.Wall] = self.walls.map { wall in
            let center = wall.transform.translation
            let width = wall.dimensions.x
            let halfWidth = width / 2
            let axis = wall.transform.right // direction along the wall's width

            let startVec = center - axis * halfWidth
            let endVec = center + axis * halfWidth

            return SerializableCapturedRoom.Wall(
                start: [startVec.x, startVec.y, startVec.z],
                end: [endVec.x, endVec.y, endVec.z],
                length: width
            )
        }

        // Openings (doors + windows): use world center from transform
        let openings: [SerializableCapturedRoom.Opening] = (self.doors + self.windows).map { opening in
            let pos = opening.transform.translation
            return SerializableCapturedRoom.Opening(
                type: String(describing: opening.category),
                position: [pos.x, pos.y, pos.z]
            )
        }

        // Objects: center from transform, dimensions from object.dimensions
        let objects: [SerializableCapturedRoom.Object] = self.objects.map { object in
            let pos = object.transform.translation
            let dims = object.dimensions
            return SerializableCapturedRoom.Object(
                category: String(describing: object.category),
                position: [pos.x, pos.y, pos.z],
                dimensions: [dims.x, dims.y, dims.z]
            )
        }

        return SerializableCapturedRoom(walls: walls, openings: openings, objects: objects)
    }

    func toJSONData() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(toSerializable())
    }

    func toJSONString() -> String? {
        guard let data = toJSONData() else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
