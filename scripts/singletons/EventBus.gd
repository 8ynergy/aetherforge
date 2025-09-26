extends Node

var _subs := {} # {name: Array[Callable]}

func subscribe(EventName: String, fn: Callable) -> void:
	if not _subs.has(EventName):
		_subs[EventName] = []
	_subs[EventName].append(fn)

func emit(EventName: String, payload: Variant = null) -> void:
	if not _subs.has(EventName):
		return
	for fn in _subs[EventName]:
		if payload == null:
			fn.call()
		else:
			fn.call(payload)
