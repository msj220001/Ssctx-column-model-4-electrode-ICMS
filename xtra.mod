: $Id: xtra.mod,v 1.4 2014/08/18 23:15:25 ted Exp ted $
: 2018/05/20 Modified by Aman Aberra 

NEURON {
	SUFFIX xtra
	RANGE es1 : (es1 = max amplitude of the potential)		
	RANGE es2 : (es2 = max amplitude of the potential)
	RANGE es3 : (es3 = max amplitude of the potential)
	RANGE es4 : (es4 = max amplitude of the potential)
	RANGE ampratio12
	RANGE ampratio13
	RANGE ampratio14
	RANGE x, y, z, type, order
	GLOBAL stim : (stim = normalized waveform)
	POINTER ex 
}

PARAMETER {	
	es1 = 0 (mV)
    es2 = 0 (mV)
	es3 = 0 (mV)
	es4 = 0 (mV)
	x = 0 (1) : spatial coords
	y = 0 (1)
	z = 0 (1)		
	type = 0 (1) : numbering system for morphological category of section - unassigned is 0
	order = 0 (1) : order of branch/collateral.
    ampratio12 = 1
	ampratio13 = 1
	ampratio14 = 1	
}

ASSIGNED {
	v (millivolts)
	ex (millivolts)
	stim (unitless) 		
	area (micron2)
}

INITIAL {
	ex = (stim*es1)+(stim*ampratio12*es2)+(stim*ampratio13*es3)+(stim*ampratio14*es4)
}


BEFORE BREAKPOINT { : before each cy' = f(y,t) setup
  ex = (stim*es1)+(stim*ampratio12*es2)+(stim*ampratio13*es3)+(stim*ampratio14*es4)
}

