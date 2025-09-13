extends Node

var _subs := {} # {name: Array[Callable]}

func subscribe(name: String, fn: Callable) -> void:
	if not _subs.has(name):
		_subs[name] = []
	_subs[name].append(fn)

func emit(name: String, payload: Variant = null) -> void:
	if not _subs.has(name):
		return
	for fn in _subs[name]:
		if payload == null:
			fn.call()
		else:
			fn.call(payload)
