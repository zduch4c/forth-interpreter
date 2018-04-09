Red [
	Title: "Forth interpreter"
	Date: 8-April-2018
	File: %forth.red
	Author: "zduch4c"
	Version: 0.0.1
]

;; STACK OPERATION FUNCTIONS

forth-stack-push: func [stack [series!] value [integer!]] [
	"Push value on stack."
	append stack value
]

forth-stack-pop: func [stack [series!]] [
	"Pop value from stack; return popped value."
	ret: last stack
	remove skip stack (length? stack) - 1
	ret
]

;; FORTH FUNCTIONS

forth-arithmetic: func [stack [series!] op [string!]] [
	"Handles arithmetic operations."
	arg1: forth-stack-pop stack
	arg2: forth-stack-pop stack
	result: switch op [
		"+" [arg1 + arg2]
		"-" [arg1 - arg2]
		"*" [arg1 * arg2]
		"/" [arg1 / arg2]
		"%" [arg1 % arg2]
	]
	forth-stack-push stack result
]

forth-stack-operation: func [stack [series!] op [string!]] [
	"Handles stack operations."
	switch op [
		"dup" [forth-stack-push stack last stack]
		"drop" [forth-stack-pop stack]
		"swap" [
			arg1: forth-stack-pop stack
			arg2: forth-stack-pop stack
			forth-stack-push stack arg2
			forth-stack-push stack arg1
		]
	]
]

;; INTERPRETER FUNCTIONS

forth-tokenize: func [code [string!]] [
	"Tokenizes CODE."
	tokens: copy []
	foreach word split code " " [
		is-integer: not error? try [to-integer word]
		token: either is-integer [
			reduce [reduce ["integer" to-integer word]]
		][
			reduce [reduce ["function" word]]
		]
		append tokens token
	]
	tokens
]

forth-parse: func [tokens [series!] stack [series!]] [
	"Goes through the list of TOKENS, acts accordingly on STACK."
	repeat ip length? tokens [
		type: tokens/:ip/1
		value: tokens/:ip/2
		switch type [
			"integer" [forth-stack-push stack value]
			"function" [
				switch value [
					"+" [forth-arithmetic stack "+"]
					"-" [forth-arithmetic stack "-"]
					"*" [forth-arithmetic stack "*"]
					"/" [forth-arithmetic stack "/"]
					"%" [forth-arithmetic stack "%"]
					
					"dup" [forth-stack-operation stack "dup"]
					"drop" [forth-stack-operation stack "drop"]
					"swap" [forth-stack-operation stack "swap"]
				]
			]
		]
	]
]

forth-execute: func [code [string!]] [
	"Execute given code."
	stack: copy []
	forth-parse forth-tokenize code stack
]