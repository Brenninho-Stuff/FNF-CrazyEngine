package backend.misc;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
	var stepCrochet:Float;
}

class Conductor
{
	public static var bpm(default, set):Float = 100;

	public static var crochet:Float = 60000 / bpm;
	public static var stepCrochet:Float = crochet / 4;

	public static var songPosition:Float = 0;
	public static var offset:Float = 0;
	public static var safeZoneOffset:Float = 0;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function set_bpm(newBPM:Float):Float
	{
		bpm = newBPM;
		crochet = 60000 / bpm;
		stepCrochet = crochet / 4;
		return bpm;
	}

	public static function getBPMFromSeconds(time:Float):BPMChangeEvent
	{
		var result = bpmChangeMap.length > 0 ? bpmChangeMap[0] : defaultEvent();

		for (event in bpmChangeMap)
		{
			if (time >= event.songTime)
				result = event;
			else
				break;
		}

		return result;
	}

	public static function getBPMFromStep(step:Float):BPMChangeEvent
	{
		var result = bpmChangeMap.length > 0 ? bpmChangeMap[0] : defaultEvent();

		for (event in bpmChangeMap)
		{
			if (step >= event.stepTime)
				result = event;
			else
				break;
		}

		return result;
	}

	private static function defaultEvent():BPMChangeEvent
	{
		return {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			stepCrochet: stepCrochet
		};
	}

	public static function beatToSeconds(beat:Float):Float
	{
		var step = beat * 4;
		var data = getBPMFromStep(step);

		var deltaSteps = step - data.stepTime;
		return data.songTime + (deltaSteps * data.stepCrochet);
	}

	public static function getStep(time:Float):Float
	{
		var data = getBPMFromSeconds(time);
		return data.stepTime + ((time - data.songTime) / data.stepCrochet);
	}

	public static function getStepRounded(time:Float):Int
	{
		return Math.floor(getStep(time));
	}

	public static function getBeat(time:Float):Float
	{
		return getStep(time) / 4;
	}

	public static function getBeatRounded(time:Float):Int
	{
		return Math.floor(getBeat(time));
	}

	public static function getCrotchetAtTime(time:Float):Float
	{
		return getBPMFromSeconds(time).stepCrochet * 4;
	}

	public static function mapBPMChanges(song:SwagSong):Void
	{
		bpmChangeMap = [];

		var curBPM = song.bpm;
		var totalSteps = 0;
		var totalTime:Float = 0;

		for (section in song.notes)
		{
			if (section.changeBPM && section.bpm != curBPM)
			{
				curBPM = section.bpm;

				bpmChangeMap.push({
					stepTime: totalSteps,
					songTime: totalTime,
					bpm: curBPM,
					stepCrochet: (60000 / curBPM) / 4
				});
			}

			var beats = section.sectionBeats != null ? section.sectionBeats : 4;
			var steps = Math.round(beats * 4);

			totalSteps += steps;
			totalTime += steps * ((60000 / curBPM) / 4);
		}
	}

	public static function judgeNote(ratings:Array<Rating>, diff:Float = 0):Rating
	{
		for (i in 0...ratings.length)
		{
			if (diff <= ratings[i].hitWindow)
				return ratings[i];
		}
		return ratings[ratings.length - 1];
	}
}
