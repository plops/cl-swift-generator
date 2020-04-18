import Foundation
import Just
import Path
import TensorFlow
let _code_git_version  = "800faf26daffa7110c3315931023b97b5d20dbf1"
let _code_generation_time  = "12:32:39 of Saturday, 2020-04-18 (GMT+1)"
public extension String {@discardableResult func shell (_ args: String...) -> String{
            let (task, pipe)  = (Process(), Pipe())
        task.executableURL=URL(fileURLWithPath: self)
    (task.arguments, task.standardOutput)=(args, pipe)
    do {
                try task.run()
}catch  {
                print("unexpected error: \(error).")
}
        let data  = pipe.fileHandleForReading.readDataToEndOfFile()
    return (String(data: data, encoding: String.Encoding.utf8)) ?? ("")
}}
print("/bin/ls".shell("-lh"))
public func downloadFile (_ url: String, dest: String? = nil, force: Bool = false){
            let dest_name  = (dest) ?? (((Path.cwd)/(url.split(separator: "/").last!)).string)
    let url_dest  = URL(fileURLWithPath: (dest) ?? (((Path.cwd)/(url.split(separator: "/").last!)).string))
    if  ((!(force))&&((Path(dest_name))!.exists))  {
                        return
}
    print("Downloading \(url)...")
        if      let cts  = Just.get(url).content  {
                do {
                        try cts.write(to: URL(fileURLWithPath: dest_name))
}catch  {
                        print("Can't write to \(url_dest).\n \(error)")
}
} else {
                print("Can't reach \(url).")
}
}
downloadFile("https://storage.googleapis.com/cvdf-datasets/mnist/train-images-idx3-ubyte.gz")
protocol ConvertibleFromByte: TensorFlowScalar {
        init(_ d: UInt8)
}
extension Float : ConvertibleFromByte {}
extension Int32 : ConvertibleFromByte {}
extension Data {
        func asTensor<T: ConvertibleFromByte> () -> Tensor<T>{
                return Tensor(map(T.init))
}
}
func loadMNIST<T: ConvertibleFromByte> (training: Bool, labels: Bool, path: Path, flat: Bool) -> Tensor<T>{
            let split  = (training) ? ("train") : ("t10k")
    let kind  = (labels) ? ("labels") : ("images")
    let batch  = (training) ? (60000) : (10000)
    let shape: TensorShape  = (labels) ? ([batch]) : ((flat) ? ([batch, 784]) : ([batch, 28, 28]))
    let dropK  = (labels) ? (8) : (16)
    let baseURL  = "https://storage.googleapis.com/cvdf-datasets/mnist/"
    let fname  = (split+"-"+kind+"-idx\(labels ? 1 : 3)-ubyte")
    let file  = ((path)/(fname))
    print("file: \(file)")
    print("file.exists: \(file.exists)")
    if  !(file.exists)  {
                                let gz  = ((path)/("\(fname).gz")).string
        downloadFile("\(baseURL)\(fname).gz", dest: gz)
        "/bin/gunzip".shell("-fq", gz)
}
        let data  = try! Data(contentsOf: URL(fileURLWithPath: file.string)).dropFirst(dropK)
    if  labels  {
                return data.asTensor()
} else {
                return data.asTensor().reshaped(to: shape)
}
}
public func loadMNIST (path: Path, flat: Bool = false) -> (Tensor<Float>, Tensor<Int32>, Tensor<Float>, Tensor<Int32>){
        try! path.mkdir(.p)
        return (((loadMNIST(training: true, labels: false, path: path, flat: flat))*(3.921569e-3)), loadMNIST(training: true, labels: true, path: path, flat: flat), ((loadMNIST(training: false, labels: false, path: path, flat: flat))*(3.921569e-3)), loadMNIST(training: false, labels: true, path: path, flat: flat))
}
public let mnistPath  = ((Path.home)/(".fastai")/("data")/("mnist_tst"))
let (xTrain, yTrain, xValid, yValid)  = loadMNIST(path: mnistPath)
print(xTrain.shape)
// timing
import Dispatch
public func time (repeating: Int = 1, _ f: () -> ()){
        guard 0<repeating  else {
                return
}
        if  1<repeating  {
                        f()
}
        var times = [Double]()
    for  _ in 1...repeating {
                        let start  = DispatchTime.now()
        f()
                let end  = DispatchTime.now()
        let nanoseconds  = Double((end.uptimeNanoseconds-start.uptimeNanoseconds))
        let milliseconds  = ((nanoseconds)*(1.000e-6))
        times.append(milliseconds)
}
        let avg  = ((times.reduce(0.0    , +))/(Double(times.count)))
    let mi  = times.reduce(times[0], min)
    let ma  = times.reduce(times[0], max)
    print("avg: \(avg)")
    print("mi: \(mi)")
    print("ma: \(ma)")
}
time(repeating: 10)
{
            _=(loadMNIST(training: false, labels: false, path: mnistPath, flat: false)) as (Tensor<Float>)
}
// 