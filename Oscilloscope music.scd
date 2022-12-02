(
// GUI
if(w!=nil){w.close};
w = Window("osc controls", Rect(
	Window.screenBounds.width-400,
	Window.screenBounds.height-300,
	400,
	300
))
.front;
w.view.background_(Color.black);
// OSC SEL AND POWER BUTTONS -- corrigir o play dos synths (boolean) e problemas de fase
3.do{
	| i |
	~sin = nil!3; ~saw = nil!3; ~pul = nil!3; ~oscSel = nil!3; ~synths = nil!9; ~hzBox = nil!3;
	~sin[i] = true; ~saw[i] = false; ~pul[i] = false;
	~oscSel[i] = Button(w.view, Rect(50, 10+(i*40), 30, 30))
	.states_([
		["sin", Color.black, Color.white],
		["saw", Color.black, Color.white],
		["pul", Color.black, Color.white]
	])
	.font_(Font("Jura", 10, true))
	.action_({
		| msg |
		case
		{msg.value == 0} {~sin[i] = true; ~saw[i] = false; ~pul[i] = false}
		{msg.value == 1} {~sin[i] = false; ~saw[i] = true; ~pul[i] = false}
		{msg.value == 2} {~sin[i] = false; ~saw[i] = false; ~pul[i] = true};
	});
	~power = Button(w.view, Rect(10, 10+(i*40), 30, 30))
	.states_([
		["sth"++i.asString, Color.white, Color.red],
		["sth"++i.asString, Color.black, Color.green]
	])
	.font_(Font("Jura", 10, true))
	.action_({
		| msg |
		if(msg.value == 1) {
			case
			{~sin[i]} {~synths[i] = Synth(\xyzSin).register}
			{~saw[i]} {~synths[i] = Synth(\xyzSaw).register}
			{~pul[i]} {~synths[i] = Synth(\xyzPul).register};
		} {~synths[i].free}
	});
	~hzBox[i] = NumberBox(w.view, Rect(90, 10+(i*40), 70, 30))
	.font_(Font("Jura", 10, true))
	.value_(200)
	.action_({
		| msg |
		if(~synths[i].isPlaying) {~synths[i].set(\freq, msg.value)};
	});
};

~startup = Button(w.view, Rect(360, 10, 30, 30))
.states_([
	["boot", Color.white, Color.red],
	["load", Color.white, Color.green],
	["quit", Color.white, Color.blue]
])
.font_(Font("Jura", 10, true))
.action_({
	| msg |
	case
	{msg.value == 0} {s.quit}
	{msg.value == 1} {s.boot}
	{msg.value == 2} {
		SynthDef(\xyzSin, {
			var sig, env, hz;
			env = Env.asr(0.1).kr(2, \gate.kr(1));
			sig = SinOsc.ar(\freq.kr(200), [\ph0.kr(0), \ph1.kr(pi/2)], env);
			sig = Pan2.ar(sig, [\pan0.kr(-1), \pan1.kr(1)], \amp.kr(0.3));
			Out.ar(\out.kr(0), sig)
		}).add;
		SynthDef(\xyzSaw, {
			var sig, env;
			env = Env.asr(0.1).kr(2, \gate.kr(1));
			sig = VarSaw.ar(\freq.kr(200), [\ph0.kr(0), \ph1.kr(pi/2)], \wdt.kr(0.5), env);
			sig = Pan2.ar(sig, [\pan0.kr(-1), \pan1.kr(1)], \amp.kr(0.3));
			Out.ar(\out.kr(0), sig)
		}).add;
		SynthDef(\xyzPul, {
			var sig, env, hz;
			env = Env.asr(0.1).kr(2, \gate.kr(1));
			sig = Pulse.ar(\freq.kr(200), \wdt.kr(0.5), env);
			sig = Pan2.ar(sig, [\pan0.kr(-1), \pan1.kr(1)], \amp.kr(0.3));
			Out.ar(\out.kr(0), sig)
		}).add;
		s.scope;
		s.meter;
	};
});
// CONTROLS
// ~pan =
// ~phase =
)

