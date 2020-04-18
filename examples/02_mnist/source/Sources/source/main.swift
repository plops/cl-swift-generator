// timing 
import Dispatch
import Foundation
import Just
import Path
import TensorFlow

let _code_git_version = "ddd86a3335b8853f889bfafa625f84cb3cc91e5f"
let _code_generation_time = "13:44:06 of Saturday, 2020-04-18 (GMT+1)"
extension String {
  @discardableResult public func shell(_ args: String...) -> String {
    let (task, pipe) = (Process(), Pipe())
    task.executableURL = URL(fileURLWithPath: self)
    (task.arguments, task.standardOutput) = (args, pipe)
    do {
      try task.run()
    } catch {
      print("unexpected error: \(error).")
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return (String(data: data, encoding: String.Encoding.utf8)) ?? ("")
  }
}
print("/bin/ls".shell("-lh"))
public func downloadFile(_ url: String, dest: String? = nil, force: Bool = false) {
  let dest_name = (dest) ?? (((Path.cwd) / (url.split(separator: "/").last!)).string)
  let url_dest = URL(
    fileURLWithPath: (dest) ?? (((Path.cwd) / (url.split(separator: "/").last!)).string))
  if (!(force)) && ((Path(dest_name))!.exists) {
    return
  }
  print("Downloading \(url)...")
  if let cts = Just.get(url).content {
    do {
      try cts.write(to: URL(fileURLWithPath: dest_name))
    } catch {
      print("Can't write to \(url_dest).\n \(error)")
    }
  } else {
    print("Can't reach \(url).")
  }
}
protocol ConvertibleFromByte: TensorFlowScalar {
  init(_ d: UInt8)
}
extension Float: ConvertibleFromByte {}
extension Int32: ConvertibleFromByte {}
extension Data {
  func asTensor<T: ConvertibleFromByte>() -> Tensor<T> {
    return Tensor(map(T.init))
  }
}
func loadMNIST<T: ConvertibleFromByte>(training: Bool, labels: Bool, path: Path, flat: Bool)
  -> Tensor<T>
{
  let split = (training) ? ("train") : ("t10k")
  let kind = (labels) ? ("labels") : ("images")
  let batch = (training) ? (60000) : (10000)
  let shape: TensorShape = (labels) ? ([batch]) : ((flat) ? ([batch, 784]) : ([batch, 28, 28]))
  let dropK = (labels) ? (8) : (16)
  let baseURL = "https://storage.googleapis.com/cvdf-datasets/mnist/"
  let fname = (split + "-" + kind + "-idx\(labels ? 1 : 3)-ubyte")
  let file = ((path) / (fname))
  print("file: \(file)")
  print("file.exists: \(file.exists)")
  if !(file.exists) {
    let gz = ((path) / ("\(fname).gz")).string
    downloadFile("\(baseURL)\(fname).gz", dest: gz)
    "/bin/gunzip".shell("-fq", gz)
  }
  let data = try! Data(contentsOf: URL(fileURLWithPath: file.string)).dropFirst(dropK)
  if labels {
    return data.asTensor()
  } else {
    return data.asTensor().reshaped(to: shape)
  }
}
public func loadMNIST(path: Path, flat: Bool = false) -> (
  Tensor<Float>, Tensor<Int32>, Tensor<Float>, Tensor<Int32>
) {
  try! path.mkdir(.p)
  return (
    ((loadMNIST(training: true, labels: false, path: path, flat: flat)) * (3.921569e-3)),
    loadMNIST(training: true, labels: true, path: path, flat: flat),
    ((loadMNIST(training: false, labels: false, path: path, flat: flat)) * (3.921569e-3)),
    loadMNIST(training: false, labels: true, path: path, flat: flat)
  )
}
public let mnistPath = ((Path.home) / (".fastai") / ("data") / ("mnist_tst"))
public func time(repeating: Int = 1, _ f: () -> Void) {
  guard 0 < repeating else {
    return
  }
  if 1 < repeating {
    f()
  }
  var times = [Double]()
  for _ in 1...repeating {
    let start = DispatchTime.now()
    f()
    let end = DispatchTime.now()
    let nanoseconds = Double((end.uptimeNanoseconds - start.uptimeNanoseconds))
    let milliseconds = ((nanoseconds) * (1.000e-6))
    times.append(milliseconds)
  }
  let avg = ((times.reduce(0.0, +)) / (Double(times.count)))
  let mi = times.reduce(times[0], min)
  let ma = times.reduce(times[0], max)
  print("avg: \(avg)")
  print("mi: \(mi)")
  print("ma: \(ma)")
}
// matmul example https://github.com/fastai/course-v3/blob/master/nbs/swift/01_matmul.ipynb
let zeros = Tensor<Float>(zeros: [1, 4, 5])
let ones = Tensor<Float>(ones: [12, 4, 5])
let twos = Tensor<Float>(repeating: 2.00, shape: [2, 3, 4, 5])
let range = Tensor<Int32>(rangeFrom: 0, to: 32, stride: 1)
let xTrain = Tensor<Float>(randomNormal: [5, 784])
var weights = ((Tensor<Float>(randomNormal: [784, 10])) / (sqrt(784)))
print(weights[0])
func swiftMatmul(a: [Float], b: [Float], aDims: (Int, Int), bDims: (Int, Int)) -> [Float] {
  assert((aDims.1) == (bDims.0), "matmul shape mismatch")
  var res = Array(repeating: Float(0.0), count: ((aDims.0) * (aDims.1)))
  for i in (0)..<(aDims.0) {
    for j in (0)..<(bDims.1) {
      for k in (0)..<(aDims.1) {
        res[(((i) * (bDims.1)) + j)] +=
          ((a[(((i) * (aDims.1)) + k)]) * (b[(((k) * (bDims.1)) + j)]))
      }
    }
  }
  return res
}
let flatA = xTrain[(0)..<(5)].scalars
let flatB = weights.scalars
let (aDims, bDims) = ((5, 784), (784, 10))
var resultArray = swiftMatmul(a: flatA, b: flatB, aDims: aDims, bDims: bDims)

time(repeating: 100) {
  _ = swiftMatmul(a: flatA, b: flatB, aDims: aDims, bDims: bDims)
}
// 
