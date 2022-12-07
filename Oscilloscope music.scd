(
s = Server.local;
// GUI Window
~sthN = 4; // number of synths to create
~initHgt = 30;
~windowWdt = 600;
~windowHgt = ~initHgt+(~sthN*40);
if(w!=nil){w.close};
w = Window("osc controls", Rect(
	Window.screenBounds.width-~windowWdt,
	Window.screenBounds.height-~windowHgt,
	~windowWdt,
	~windowHgt
))
.front;
w.view.background_(Color.black);
// OSC SEL AND POWER BUTTONS
// Globals...
~sin = true!~sthN; ~saw = false!~sthN; ~pul = false!~sthN; // booleans
// GUI Objects
~power = nil!~sthN;
~oscSel = nil!~sthN; ~synths = nil!~sthN; ~hzBox = nil!~sthN; ~ampSliders = nil!~sthN; ~panKnobs = nil!~sthN;
~pan0Knobs = nil!~sthN; ~pan1Knobs = nil!~sthN; ~ph0Knobs = nil!~sthN; ~ph1Knobs = nil!~sthN;
~phKnobs = nil!~sthN; ~widKnobs = nil!~sthN;
// GUI control
~leftMem = 0; ~indent = 10; ~buttonWdt = 30; ~ctrlHgt = 30; ~nbWdt = 50; ~sliderWdt = 60;
// Controls
~hzs = Array.series(~sthN, 200, 200); ~amps = 0.3!~sthN; ~pans = 0!~sthN; ~pan0 = -1!~sthN;
~pan1 = 1!~sthN; ~phases = 0!~sthN; ~ph0 = 0!~sthN; ~ph1 = pi/2!~sthN; ~wdts = 0.5!~sthN;

// Labels
~powLabel = StaticText(w.view, Rect(10, 10, 30, 10))
.string_("Pow")
.align_(\center)
.font_(Font("Jura", 10, true))
.stringColor_(Color.white)
.background_(Color.black);
~selLabel = StaticText(w.view, Rect(10+30+10, 10, 30, 10))
.string_("OSC")
.align_(\center)
.font_(Font("Jura", 10, true))
.stringColor_(Color.white)
.background_(Color.black);
~hzLabel = StaticText(w.view, Rect(50+30+10, 10, 50, 10))
.string_("Hz")
.align_(\center)
.font_(Font("Jura", 10, true))
.stringColor_(Color.white)
.background_(Color.black);
~ampLabel = StaticText(w.view, Rect(90+50+10, 10, 60, 10))
.string_("Amp")
.align_(\center)
.font_(Font("Jura", 10, true))
.stringColor_(Color.white)
.background_(Color.black);
~panLabel = StaticText(w.view, Rect(150+60+10, 10, 25+10+25+10+30, 10))
.string_("Pan")
.align_(\center)
.font_(Font("Jura", 10, true))
.stringColor_(Color.white)
.background_(Color.black);
~phaseLabel = StaticText(w.view, Rect(220+100+10, 10, 25+10+25+10+30, 10))
.string_("Sin phase")
.align_(\center)
.font_(Font("Jura", 10, true))
.stringColor_(Color.white)
.background_(Color.black);
~wdtLabel = StaticText(w.view, Rect(330+100+10, 10, 30, 10))
.string_("Wdt")
.align_(\center)
.font_(Font("Jura", 10, true))
.stringColor_(Color.white)
.background_(Color.black);

// REPEATED CONTROLS
~sthN.do{
	| i |
	~leftMem = ~indent;
	~power = Button(w.view, Rect(~leftMem, ~initHgt+(i*40), ~buttonWdt, ~ctrlHgt)) // ON/OFF
	.states_([
		["sth"++i.asString, Color.white, Color.red],
		["sth"++i.asString, Color.black, Color.green]
	])
	.font_(Font("Jura", 10, true))
	.action_({
		| msg |
		if(msg.value == 1) {
			case
			{~sin[i]} {~synths[i] = Synth(\xyzSin, [
				\freq, ~hzs[i],
				\amp, ~amps[i]
			]).register}
			{~saw[i]} {~synths[i] = Synth(\xyzSaw, [
				\freq, ~hzs[i],
				\amp, ~amps[i]
			]).register}
			{~pul[i]} {~synths[i] = Synth(\xyzPul, [
				\freq, ~hzs[i],
				\amp, ~amps[i]
			]).register};
		} {~synths[i].set(\gate, 0)}
	}); ~leftMem = ~leftMem + ~buttonWdt + ~indent;
	~oscSel[i] = Button(w.view, Rect(~leftMem, ~initHgt+(i*40), ~buttonWdt, ~ctrlHgt)) // Selector
	.states_([
		["sin", Color.black, Color.white],
		["saw", Color.black, Color.white],
		["pul", Color.black, Color.white]
	])
	.font_(Font("Jura", 10, true))
	.action_({
		| msg |
		case
		{msg.value == 0} {
			~sin[i] = true; ~saw[i] = false; ~pul[i] = false;
			if(~synths[i].isPlaying) {
				~synths[i].set(\gate, 0);
				~synths[i] = Synth(\xyzSin, [
					\freq, ~hzs[i],
					\amp, ~amps[i]
				]).register;
			}
		}
		{msg.value == 1} {
			~sin[i] = false; ~saw[i] = true; ~pul[i] = false;
			if(~synths[i].isPlaying) {
				~synths[i].set(\gate, 0);
				~synths[i] = Synth(\xyzSaw, [
					\freq, ~hzs[i],
					\amp, ~amps[i]
				]).register;
			}
		}
		{msg.value == 2} {
			~sin[i] = false; ~saw[i] = false; ~pul[i] = true;
			if(~synths[i].isPlaying) {
				~synths[i].set(\gate, 0);
				~synths[i] = Synth(\xyzPul, [
					\freq, ~hzs[i],
					\amp, ~amps[i]
				]).register;
			}
		};
	}); ~leftMem = ~leftMem + ~buttonWdt + ~indent;
	~hzBox[i] = NumberBox(w.view, Rect(~leftMem, ~initHgt+(i*40), ~nbWdt, ~ctrlHgt)) // Freq control
	.font_(Font("Jura", 10, true))
	.value_(~hzs[i])
	.clipLo_(20).clipHi_(2e4)
	.action_({
		| msg |
		if(~synths[i].isPlaying) {~synths[i].set(\freq, msg.value)};
		~hzs[i] = msg.value;
	}); ~leftMem = ~leftMem + ~nbWdt + ~indent;
	~ampSliders[i] = Slider(w.view, Rect(~leftMem, ~initHgt+(i*40), ~sliderWdt, ~ctrlHgt)) // Amp control
	.value_(~amps[i])
	.action_({
		| msg |
		if(~synths[i].isPlaying) {~synths[i].set(\amp, msg.value)};
		~amps[i] = msg.value;
	}); ~leftMem = ~leftMem + ~sliderWdt + ~indent;
	~pan0Knobs[i] = Knob(w.view, Rect(~leftMem, ~initHgt+2.5+(i*40), ~buttonWdt-5, ~ctrlHgt-5)) // Pan0
	.centered_(true)
	.value_(~pan0[i]/2+0.5)
	.action_({
		| msg |
		~pan0[i] = msg.value*2-1;
		if(~synths[i].isPlaying) {~synths[i].set(\pan0, ~pan0[i])}
	}); ~leftMem = ~leftMem + ~buttonWdt-5 + ~indent;
	~pan1Knobs[i] = Knob(w.view, Rect(~leftMem, ~initHgt+2.5+(i*40), ~buttonWdt-5, ~ctrlHgt-5)) // Pan1
	.centered_(true)
	.value_(~pan1[i]/2+0.5)
	.action_({
		| msg |
		~pan1[i] = msg.value*2-1;
		if(~synths[i].isPlaying) {~synths[i].set(\pan1, ~pan1[i])}
	}); ~leftMem = ~leftMem + ~buttonWdt-5 + ~indent;
	~panKnobs[i] = Knob(w.view, Rect(~leftMem, ~initHgt+(i*40), ~buttonWdt, ~ctrlHgt)) // Both pans (WIP)
	.value_(~pans[i]/2+0.5)
	.centered_(true)
	.action_({
		// | msg |
		// a = ~panKnobs[i].value;
		// b =
		// y = ~pan0Knobs[i].value + x;
		// ~pan0Knobs[i].valueAction_(y);
		// x.postln;
	}); ~leftMem = ~leftMem + ~buttonWdt + ~indent;
	~ph0Knobs[i] = Knob(w.view, Rect(~leftMem, ~initHgt+2.5+(i*40), ~buttonWdt-5, ~ctrlHgt-5)) // Ph0
	.value_(~ph0[i]) // Needs ctrlSpec
	.action_({
		| msg |
		~ph0[i] = msg.value.linlin(0, 1, 0, 2pi);
		if(~synths[i].isPlaying) {~synths[i].set(\ph0, ~ph0[i])}
	}); ~leftMem = ~leftMem + ~buttonWdt-5 + ~indent;
	~ph1Knobs[i] = Knob(w.view, Rect(~leftMem, ~initHgt+2.5+(i*40), ~buttonWdt-5, ~ctrlHgt-5)) // Ph1
	.value_(~ph1[i]) // Needs ctrlSpec
	.action_({
		| msg |
		~ph1[i] = msg.value.linlin(0, 1, 0, 2pi);
		if(~synths[i].isPlaying) {~synths[i].set(\ph1, ~ph1[i])}
	}); ~leftMem = ~leftMem + ~buttonWdt-5 + ~indent;
	~phKnobs[i] = Knob(w.view, Rect(~leftMem, ~initHgt+(i*40), ~buttonWdt, ~ctrlHgt)) // Both phases (WIP)
	.value_(~phases[i]) // Needs ctrlSpec
	.action_({
		// | msg |
		// a = ~panKnobs[i].value;
		// b =
		// y = ~pan0Knobs[i].value + x;
		// ~pan0Knobs[i].valueAction_(y);
		// x.postln;
	}); ~leftMem = ~leftMem + ~buttonWdt + ~indent;
	~widKnobs[i] = Knob(w.view, Rect(~leftMem, ~initHgt+(i*40), ~buttonWdt, ~ctrlHgt)) // Widths
	.centered_(true)
	.value_(~wdts[i])
	.action_({
		| msg |
		~wdts[i] = msg.value.linlin(0, 1, 0.01, 0.99);
		if(~synths[i].isPlaying) {~synths[i].set(\wdt, ~wdts[i])}
	}); ~leftMem = ~leftMem + ~buttonWdt + ~indent;
};
// ~pan0Knobs[0].value
// SINGLE CONTROLS
~startup = Button(w.view, Rect(w.view.bounds.width-40, 10, 30, 30)) // Boot and load
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
			env = Env.asr(0.1, 1, 0.2).kr(2, \gate.kr(1));
			sig = SinOsc.ar(\freq.kr(~hzs[0]), [\ph0.kr(~ph0[0]), \ph1.kr(~ph1[0])], env);
			sig = Pan2.ar(sig, [\pan0.kr(~pan0[0]), \pan1.kr(~pan1[0])], \amp.kr(~amps[0]));
			Out.ar(\out.kr(0), sig)
		}).add;
		SynthDef(\xyzSaw, {
			var sig, env;
			env = Env.asr(0.1, 1, 0.2).kr(2, \gate.kr(1));
			sig = VarSaw.ar(\freq.kr(~hzs[0]), [\ph0.kr(0), \ph1.kr(pi/2)], \wdt.kr(0.5), env);
			sig = Pan2.ar(sig, [\pan0.kr(-1), \pan1.kr(1)], \amp.kr(0.3));
			Out.ar(\out.kr(0), sig)
		}).add;
		SynthDef(\xyzPul, {
			var sig, env, hz;
			env = Env.asr(0.1, 1, 0.2).kr(2, \gate.kr(1));
			sig = Pulse.ar(\freq.kr(200), \wdt.kr(0.5), env);
			sig = Pan2.ar(sig, [\pan0.kr(-1), \pan1.kr(1)], \amp.kr(0.3));
			Out.ar(\out.kr(0), sig)
		}).add;
		s.scope;
		if(m == nil) {m = s.meter};
	};
});
)

// Next steps...
// 1. Complete functional sample - that includes all the controls to be used
// 1.1 Master amp beneath boot button?
// 1.2 Amp value relative to ~sthN?
// 1.3 Additional ctrls (other windows?)
// 1.4 Ctrl automation?
// 2. Organize the layout (multiple windows, stack windows...?)
// 3. Create TouchOSC interface?
// 4. Final tweaks on interface behavior (for better UX) - ie disabling controls when unrelevant