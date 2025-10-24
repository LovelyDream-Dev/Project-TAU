extends Node

enum direction {
	LEFT = -1,
	RIGHT = 1
}

## Returns a direction from an enum. [member direction.LEFT] if [member rawValue] is [code]-1[/code], or [member direction.RIGHT] if it is [code]1[/code]. 
## Returns [member direction.LEFT] if [member rawValue] is not [code]-1[/code] or [code]1[/code].
## Directions are used for various direction based mechanics.
func direction_from_raw(rawValue:int):
	if rawValue == -1:
		return direction.LEFT
	elif rawValue == 1:
		return direction.RIGHT
	else:
		push_error("Invalid side %s; defaulting to LEFT" % str(rawValue))
		return direction.LEFT

## Returns a [HitObjectParser] class; used for calling hit object values such as; 
## [br][member HitObjectParser.hitTime], 
## [br][member HitObjectParser.releaseTime], 
## [br]or [member HitObjectParser.side].
func parse_hit_times(dict:Dictionary) -> HitObjectParser:
	var ParsedHitObject = HitObjectParser.new()
	ParsedHitObject.hitTime = dict["hitTime"]
	ParsedHitObject.releaseTime = dict["releaseTime"]
	ParsedHitObject.side = direction_from_raw(dict["side"] )
	return ParsedHitObject

## Returns the beat number at [member songPosition] within a song.
func get_beat_from_song_position(songPosition:float, beatsPerSecond:float) -> float:
	return songPosition * beatsPerSecond

## Returns the [Vector2] coordinates of a point on a circle's circumference.
func get_position_on_circumference(circleCenter:Vector2, circleRadius:float, angle:float) -> Vector2:
	return circleCenter + Vector2(cos(angle), sin(angle)) * circleRadius

## Returns a [float] value, representing an x position along a timeline, from a time in seconds. 
## Allows for an offset in position to account for a scrolling playhead.
func get_timeline_position_x_from_seconds(seconds:float, pixelsPerSecond:float, offset:float) -> float:
	var posx = (seconds * pixelsPerSecond) + offset
	return posx
