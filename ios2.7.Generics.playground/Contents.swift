import UIKit

//4. Для чего нужны дженерики?
//Дженерики позволяет нам писать гибкие, общего назначения функции и типы, которые могут работать с любыми другими типами, с учетом требований, которые вы определили. Мы можем написать код, который не повторяется и выражает свой контент в ясной абстрактной форме.


//5. Чем ассоциированные типы отличаются от дженериков?
// Ассоциированные типы используются в протоколах, для задания типа значений который будет использоваться в реализуемых протоколом свойствах и функциях. Дженнерики же в свою очередь, это аргумент типа функции, класса или структуры.


//6.A Создайте функцию, которая получает на вход два Equatable объекта и в зависимости от того, равны ли они друг другу, выводит разные сообщения в лог
func equal<T: Equatable>(left: T, right: T) {
    print(left == right ? "\(left) Equal \(right)" : "\(left) Not equal \(right)")
}
equal(left: 1.0, right: 1.0)
equal(left: "6A", right: "6a")


//6.B Создайте функцию, которая получает на вход два сравниваемых (Comparable) друг с другом значения, сравнивает их и выводит в лог наибольшее
func compare<T: Comparable>(left: T, right: T) {
    if left == right {
        print("\(left) Equal \(right)")
    } else {
        print(left > right ? "\(left) more \(right)" : "\(right) more \(left)")
    }
}
compare(left: 0, right: 0)
compare(left: "left", right: "right")
compare(left: 0.01, right: -0.99)

// 6.C Создайте функцию, которая получает на вход два сравниваемых (Comparable) друг с другом значения, сравнивает их и перезаписывает первый входной параметр меньшим из двух значений, а второй параметр – большим
func compareAndSwap<T: Comparable>(left: inout T, right: inout T) {
    let tmp: T
    if left > right {
        tmp = left
        left = right
        right = tmp
    }
}

var x = 1
var y = 2
compareAndSwap(left: &y, right: &x)
x
y

//6.D Создайте функцию, которая получает на вход две функции, которые имеют дженерик входной параметр Т и ничего не возвращают; сама функция должна вернуть новую функцию, которая на вход получает параметр с типом Т и при своем вызове вызывает две функции и передает в них полученное значение (по факту объединяет вместе две функции)
func sumFunc<T>(_ firstFunc: @escaping (T) -> Void, _ secondFunc: @escaping (T) -> Void) -> (T) -> Void {
    return { parametr in
        firstFunc(parametr)
        secondFunc(parametr)
    }
}

//7.A Создайте расширение для Array, у которого элементы имеют тип Comparable и добавьте генерируемое свойство, которое возвращает максимальный элемент
extension Array where Element: Comparable {
    var maxElement: Element? {
        if count == 0 { return nil }
        return self.reduce(self.first!, { $0 < $1 ? $1 : $0 })
    }
}
var arr: [Int] = []
arr.maxElement
arr.append(contentsOf: [4, 2, 3, 5, 1])
arr.maxElement

//7.B Создайте расширение для Array, у которого элементы имеют тип Equatable и добавьте функцию, которая удаляет из массива идентичные элементы
extension Array where Element: Equatable {
    mutating func removeEqualElement() {
        var newArray: [Element] = []
        
        for (_, item) in enumerated() {
            if !newArray.contains(item) { newArray.append(item) }
        }
        
        self = newArray
    }
}
arr.append(contentsOf: [3, 2, 1, 6])
arr.removeEqualElement()


//8.A Создайте специальный оператор для возведения Int числа в степень: оператор ^, работает 2^3 возвращает 8
infix operator ^
extension Int {
    static func ^(left: Int, right: Int) -> Int {
        return Int(pow(Float(left), Float(right)))
    }
}
2^3

// 8.B Создайте специальный оператор для копирования во второе Int число удвоенное значение первого 4 ~> a после этого a = 8
infix operator ~>
func ~>(left: Int, right: inout Int) {
    right = 2 * left
}
var a = 0
4 ~> a

// 8.C Создайте специальный оператор для присваивания в экземпляр tableView делегата: myController <* tableView поле этого myController становится делегатом для tableView
infix operator <*
func <*(left: UITableViewDelegate, right: UITableView) {
    right.delegate = left
}
class VCTableViewDelegate: UIViewController, UITableViewDelegate {
}
let tableView = UITableView()
let vcTableViewDelegate = VCTableViewDelegate()

tableView.delegate
vcTableViewDelegate <* tableView
tableView.delegate


// 8.D Создайте специальный оператор для суммирует описание двух объектов с типом CustomStringConvertable и возвращает их описание: 7 + “ string” вернет “7 string”
func +(left: CustomStringConvertible, right: CustomStringConvertible) -> String {
    return left.description + right.description
}
7 + " string"

// 9.A Напишите для библиотеки анимаций новый аниматор изменяющий фоновый цвет для UIView
protocol Animator {
    associatedtype Target
    associatedtype Value
    init(_ value: Value)
    func animate(target: Target)
}
class BackgroundColorAnimator: Animator {
    let newValue: UIColor
    required init(_ value: UIColor) {
        self.newValue = value
    }
    func animate(target: UIView) {
        UIView.animate(withDuration: 0.3) {
            target.backgroundColor = self.newValue
        }
    }
}
func ~><T: Animator>(left: T, right: T.Target) {
    left.animate(target: right)
}
BackgroundColorAnimator(.red) ~> UIView()

// 9.B Напишите для библиотеки анимаций новый аниматор изменяющий center UIView
class CenterAnimator: Animator {
    let newValue: CGPoint
    required init(_ value: CGPoint) {
        self.newValue = value
    }
    func animate(target: UIView) {
        UIView.animate(withDuration: 0.3) {
            target.center = self.newValue
        }
    }
}
CenterAnimator(CGPoint(x: 100, y: 100)) ~> UIView()

// 9.C Напишите для библиотеки анимаций новый аниматор делающий scale трансформацию для UIView
class ScaleAnimator: Animator {
    let newValue: CGFloat
    required init(_ value: CGFloat) {
        self.newValue = value
    }
    func animate(target: UIView) {
        UIView.animate(withDuration: 0.3) {
            target.contentScaleFactor = self.newValue
        }
    }
}
ScaleAnimator(0.5) ~> UIView()
