(
s.reboot { // server options are only updated on reboot
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
	s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
	s.options.numWireBufs = 64; // increase this if you get "exceeded number of interconnect buffers" messages
	s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
	s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
	s.options.numInputBusChannels = 0; // set this to your hardware output channel size, if necessary
	// boot the server and start SuperDirt
	s.waitForBoot {
		~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
		~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)

		// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
		// s.sync; // optionally: wait for samples to be read
		~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0
	};

	s.latency = 0.3; // increase this if you get "late" messages
};
);

(
// Create encoder and decoder
e = FoaEncoderMatrix.newOmni;
d = FoaDecoderKernel.newCIPIC(12);
)

(
DirtPan.defaultPanningFunction = { |signals, numChannels, pan, mul|
	var sig = FoaEncode.ar(signals.sum * mul, e);
	// angle=pi/2 -> push to plane wave
	sig = FoaPush.ar(sig, angle: pi/2, theta: pan * pi, phi: 0);
	// sig = FoaPush.ar(sig, angle: pi/2, theta: pan * 2*pi, phi: SinOsc.kr(0.25).range(0, pi/2));
	FoaDecode.ar(sig, d);
};

// Reload synthdefs after replacing panning function
~dirt.loadSynthDefs;
)

// Load custom samples
~dirt.loadSoundFiles(Document.current.dir +/+ "samples/*");