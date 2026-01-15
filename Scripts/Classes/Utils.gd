extends RefCounted
class_name Utils

static func find_nearest(target: float, sortedArray: Array) -> Dictionary:
	"""
	Static method to find nearest float in sorted array using binary search.
	Returns a Dictionary with 'value' and 'index' keys.
	Returns {'value': null, 'index': -1} if array is empty.
	"""
	if sortedArray.is_empty():
		return {"value": null, "index": -1}
	
	var leftIndex: int = 0
	var rightIndex: int = sortedArray.size() - 1
	
	# Handle edge cases
	if target <= sortedArray[0]:
		return {"value": sortedArray[0], "index": 0}
	if target >= sortedArray[rightIndex]:
		return {"value": sortedArray[rightIndex], "index": rightIndex}
	
	# Binary search for insertion point
	while leftIndex <= rightIndex:
		var midIndex: int = (leftIndex + rightIndex) / 2
		
		if sortedArray[midIndex] == target:
			return {"value": sortedArray[midIndex], "index": midIndex}
		elif sortedArray[midIndex] < target:
			leftIndex = midIndex + 1
		else:
			rightIndex = midIndex - 1
	
	# At this point, rightIndex < leftIndex
	# sortedArray[rightIndex] < target < sortedArray[leftIndex]
	var leftDiff: float = abs(target - sortedArray[rightIndex])
	var rightDiff: float = abs(target - sortedArray[leftIndex])
	
	if leftDiff <= rightDiff: 
		return {"value": sortedArray[rightIndex], "index":  rightIndex}
	else: 
		return {"value": sortedArray[leftIndex], "index": leftIndex}
