import Cocoa

// NOTE: The Swift compiler found this too hard to deal with while the pattern array is being generated,
// but it's actually better to hide what's going on by preprocessing the bits.

let mess = "CHOCK WAS HERE DUH".compactMap { character in
	character.asciiValue
}

var code = ""
mess.forEach { value in
	code += "0b0" + String(value, radix: 2) + ",\n"
}
code += "\n"

print(code)

String.init(decoding: mess, as: UTF8.self)
