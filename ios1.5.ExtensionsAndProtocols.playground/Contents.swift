import UIKit
import CoreGraphics

//4. В чем отличие класса от протокола?

//Протокол определяет структуру объекта: инициализаторы, свойства и функции, может иметь их в расширениях. Класс же имплементирует структуру протокола или содержит свою реализацию.

//5. Могут ли реализовывать несколько протоколов:
protocol Protocol {
    func useProtocol()
}
//a. классы (Class) - Да
class Class: Protocol {
    func useProtocol() {
        print("Class")
    }
}

//b. структуры (Struct) - Да
struct Struct: Protocol {
    func useProtocol() {
        print("Struct")
    }
}

//c. перечисления (Enum) - Да
enum Enum: Protocol {
    case one, two
    func useProtocol() {
        print("Enum")
    }
}

//d. кортежи (Tuples) - Нет
var x: (Int, Int) = (1, 2)

//6. Создайте протоколы для:

//     a. игры в шахматы против компьютера: протокол-делегат с функцией, через которую шахматный движок будет сообщать о ходе компьютера (с какой на какую клеточку); протокол для шахматного движка, в который передается ход фигуры игрока (с какой на какую клеточку), Double свойство, возвращающая текущую оценку позиции (без возможности изменения этого свойства) и свойство делегата;

struct Position: Hashable{
    var point: (x: Int, y: Int)
    static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.point.x == rhs.point.x &&
            lhs.point.y == rhs.point.y
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(point.x)
        hasher.combine(point.y)
    }
}

protocol PlayerProtocol {
    var name: String { get set }
    var position: Position { get set }
    var delegate: SaveMoveDelegate? { get set }
    mutating func setPosition(position: Position)
}

protocol GameBoardProtocol {
    var moves: [CFAbsoluteTime : (String,Position)] { get set }
    var delegate: PrintMoveDelegate? { get set }
}

protocol SaveMoveDelegate {
    func saveMove(player: String , position: Position)
}

protocol PrintMoveDelegate {
    func printMove(player: String , position: Position)
}

class GameBoard: GameBoardProtocol, SaveMoveDelegate {
    var moves: [CFAbsoluteTime : (String,Position)] = [:]
    var delegate: PrintMoveDelegate?
    
    func saveMove(player: String, position: Position) {
        let date = CFAbsoluteTimeGetCurrent()
        moves[date] = (player, position)
        delegate?.printMove(player: player, position: position)
    }
    
    init() {
        let comp = Player(name: "comp",
                          position: Position(point: (x: 8, y: 8)),
                          delegate: nil)
        self.delegate = comp
    }
}

struct Player : PlayerProtocol, PrintMoveDelegate, Hashable {
    var name: String
    var position: Position
    var delegate: SaveMoveDelegate?
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.name == rhs.name
            && lhs.position.point.x == rhs.position.point.x
            && lhs.position.point.y == rhs.position.point.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(position.point.x)
        hasher.combine(position.point.y)
    }
    
    mutating func setPosition(position: Position) {
        self.position = position
        delegate?.saveMove(player: self.name, position: self.position)
    }
    
    init(name: String, position: Position, delegate: GameBoard?) {
        self.name = name
        self.position = position
        self.delegate = delegate
        delegate?.saveMove(player: self.name, position: self.position)
    }
    
    func printMove(player: String , position: Position) {
        print("\(player) x:\(position.point.x) y: \(position.point.y)")
    }
}

let gameBoard = GameBoard()
var player = Player(name: "Human",
                    position: Position(point: (x: 1, y: 1)),
                    delegate: gameBoard)

player.setPosition(position: Position(point: (x: 2, y: 2)))
player.setPosition(position: Position(point: (x: 4, y: 4)))
gameBoard.moves

//     b. компьютерной игры: один протокол для всех, кто может летать (Flyable), второй – для тех, кого можно отрисовывать приложении (Drawable). Напишите класс, который реализует эти два протокола

protocol Flyable {
    func fly()
}

protocol Drawable {
    func draw()
}

class MyClass: Flyable, Drawable {
    func fly() {
        print("I can fly")
    }
    
    func draw() {
        print("I can draw")
    }
}

//7. Создайте расширение с функцией для:

//     a. CGRect, которая возвращает CGPoint с центром этого CGRect’а
extension CGRect {
    public func center() -> CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
//     b. CGRect, которая возвращает площадь этого CGRect’а
extension CGRect {
    public func area() -> CGFloat {
        return width * height
    }
}
//     c. UIView, которое анимированно её скрывает (делает alpha = 0)
extension UIView {
    public func animateHide(withDuration: TimeInterval) {
        self.alpha = 0
    }
}
//     d. протокола Comparable, на вход получает еще два параметра того же типа: первое ограничивает минимальное значение, второе – максимальное; возвращает текущее значение. ограниченное этими двумя параметрами. Пример использования:
//7.bound(minValue: 10, maxValue: 21) -> 10
//7.bound(minValue: 3, maxValue: 6) -> 6
//7.bound(minValue: 3, maxValue: 10) -> 7
extension Comparable{
    func bound<T: Comparable>(minValue: T, maxValue: T) -> T {
        guard let value = self as? T else {
            fatalError("It's not Comparable")
        }
        if value < minValue {
            return minValue
        }
        if value > maxValue {
            return maxValue
        }
        return value
    }
}
//     e. Array, который содержит элементы типа Int: функцию для подсчета суммы всех элементов
extension Array where Element == Int {
    func sumElements() -> Int {
        return self.reduce(0, { $0 + $1 })
    }
}
[1, 2, 3].sumElements()

//8. В чем основная идея Protocol oriented programming?

//При наследовании от класса, мы становися зависимы от реализации родительского класса. В случае наследования от интерфейса (протокола) мы имплементируем свою реализацию класса.
