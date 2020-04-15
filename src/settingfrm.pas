{
  Description: vPlot setting form.

  Copyright (C) 2020 Melchiorre Caruso <melchiorrecaruso@gmail.com>

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

unit settingfrm;

{$mode objfpc}

interface

uses
  classes, sysutils, forms, controls, graphics, dialogs,
  valedit, extctrls, buttons, stdctrls, vpmath, vpsetting;

type
  { tsettingform }

  tsettingform = class(tform)
    closebtn: TBitBtn;
    btnok: TBitBtn;
    image: timage;
    settinglist: tvaluelisteditor;
  private
  public
    procedure load(asetting: tvpsetting);
    procedure save(asetting: tvpsetting);
  end;

var
  settingform: tsettingform;

implementation

{$R *.lfm}

{ tsettingform }

procedure tsettingform.load(asetting: tvpsetting);
begin
  settinglist.strings.clear;
  settinglist.titlecaptions.clear;
  settinglist.titlecaptions.add('KEY');
  settinglist.titlecaptions.add('VALUE');

  settinglist.insertrow('POINT-0.X',       floattostr(asetting.point0.x),      true);
  settinglist.insertrow('POINT-0.Y',       floattostr(asetting.point0.y),      true);
  settinglist.insertrow('POINT-1.X',       floattostr(asetting.point1.x),      true);
  settinglist.insertrow('POINT-1.Y',       floattostr(asetting.point1.y),      true);
  settinglist.insertrow('POINT-8.X',       floattostr(asetting.point8.x),      true);
  settinglist.insertrow('POINT-8.Y',       floattostr(asetting.point8.y),      true);
  settinglist.insertrow('POINT-9.OFFSET',  floattostr(asetting.point9offset),  true);
  settinglist.insertrow('POINT-9.FACTOR',  floattostr(asetting.point9factor),  true);

  settinglist.insertrow('PULLEY-0.RADIUS', floattostr(asetting.pulley0radius), true);
  settinglist.insertrow('PULLEY-0.RATIO',  floattostr(asetting.pulley0ratio),  true);
  settinglist.insertrow('PULLEY-1.RADIUS', floattostr(asetting.pulley1radius), true);
  settinglist.insertrow('PULLEY-1.RATIO',  floattostr(asetting.pulley1ratio),  true);

  settinglist.insertrow('SERVO-Z.MIN',     floattostr(asetting.servozmin),     true);
  settinglist.insertrow('SERVO-Z.MAX',     floattostr(asetting.servozmax),     true);

  settinglist.insertrow('PAGE.HEIGHT',     floattostr(asetting.pageheight),    true);
  settinglist.insertrow('PAGE.WIDTH',      floattostr(asetting.pagewidth),     true);

  settinglist.insertrow('RAMP.KB',         floattostr(asetting.rampkb),        true);
  settinglist.insertrow('RAMP.KL',         floattostr(asetting.rampkl),        true);
  settinglist.insertrow('RAMP.KM',         floattostr(asetting.rampkm),        true);

  settinglist.insertrow('WAVE-0.X',        floattostr(asetting.wavepoint0.x),  true);
  settinglist.insertrow('WAVE-0.Y',        floattostr(asetting.wavepoint0.y),  true);
  settinglist.insertrow('WAVE-1.X',        floattostr(asetting.wavepoint1.x),  true);
  settinglist.insertrow('WAVE-1.Y',        floattostr(asetting.wavepoint1.y),  true);
  settinglist.insertrow('WAVE-2.X',        floattostr(asetting.wavepoint2.x),  true);
  settinglist.insertrow('WAVE-2.Y',        floattostr(asetting.wavepoint2.y),  true);
  settinglist.insertrow('WAVE-3.X',        floattostr(asetting.wavepoint3.x),  true);
  settinglist.insertrow('WAVE-3.Y',        floattostr(asetting.wavepoint3.y),  true);
  settinglist.insertrow('WAVE-4.X',        floattostr(asetting.wavepoint4.x),  true);
  settinglist.insertrow('WAVE-4.Y',        floattostr(asetting.wavepoint4.y),  true);
  settinglist.insertrow('WAVE-5.X',        floattostr(asetting.wavepoint5.x),  true);
  settinglist.insertrow('WAVE-5.Y',        floattostr(asetting.wavepoint5.y),  true);
  settinglist.insertrow('WAVE-6.X',        floattostr(asetting.wavepoint6.x),  true);
  settinglist.insertrow('WAVE-6.Y',        floattostr(asetting.wavepoint6.y),  true);
  settinglist.insertrow('WAVE-7.X',        floattostr(asetting.wavepoint7.x),  true);
  settinglist.insertrow('WAVE-7.Y',        floattostr(asetting.wavepoint7.y),  true);
  settinglist.insertrow('WAVE-8.X',        floattostr(asetting.wavepoint8.x),  true);
  settinglist.insertrow('WAVE-8.Y',        floattostr(asetting.wavepoint8.y),  true);
  settinglist.insertrow('WAVE.SCALE',      floattostr(asetting.wavescale),     true);
  settinglist.insertrow('WAVE.OFF',        floattostr(asetting.waveoff),       true);

  settinglist.toprow := 1;
end;

procedure tsettingform.save(asetting: tvpsetting);
var
  p: tvppoint;
begin
  p.x := strtofloat(settinglist.values['POINT-0.X']);
  p.y := strtofloat(settinglist.values['POINT-0.Y']); asetting.point0 := p;
  p.x := strtofloat(settinglist.values['POINT-1.X']);
  p.y := strtofloat(settinglist.values['POINT-1.Y']); asetting.point1 := p;
  p.x := strtofloat(settinglist.values['POINT-8.X']);
  p.y := strtofloat(settinglist.values['POINT-8.Y']); asetting.point8 := p;


  asetting.point9offset  := strtofloat(settinglist.values['POINT-9.OFFSET' ]);
  asetting.point9factor  := strtofloat(settinglist.values['POINT-9.FACTOR' ]);
  asetting.pulley0radius := strtofloat(settinglist.values['PULLEY-0.RADIUS']);
  asetting.pulley0ratio  := strtofloat(settinglist.values['PULLEY-0.RATIO' ]);
  asetting.pulley1radius := strtofloat(settinglist.values['PULLEY-1.RADIUS']);
  asetting.pulley1ratio  := strtofloat(settinglist.values['PULLEY-1.RATIO' ]);
  asetting.servozmin     := strtoint  (settinglist.values['SERVO-Z.MIN'    ]);
  asetting.servozmax     := strtoint  (settinglist.values['SERVO-Z.MAX'    ]);

  asetting.pageheight    := strtofloat(settinglist.values['PAGE.HEIGHT'    ]);
  asetting.pagewidth     := strtofloat(settinglist.values['PAGE.WIDTH'     ]);

  asetting.rampkb        := strtoint  (settinglist.values['RAMP.KB'        ]);
  asetting.rampkl        := strtoint  (settinglist.values['RAMP.KL'        ]);
  asetting.rampkm        := strtoint  (settinglist.values['RAMP.KM'        ]);

  p.x := strtofloat(settinglist.values['WAVE-0.X']);
  p.y := strtofloat(settinglist.values['WAVE-0.Y']);
  asetting.wavepoint0 := p;

  p.x := strtofloat(settinglist.values['WAVE-1.X']);
  p.y := strtofloat(settinglist.values['WAVE-1.Y']);
  asetting.wavepoint1 := p;

  p.x := strtofloat(settinglist.values['WAVE-2.X']);
  p.y := strtofloat(settinglist.values['WAVE-2.Y']);
  asetting.wavepoint2 := p;

  p.x := strtofloat(settinglist.values['WAVE-3.X']);
  p.y := strtofloat(settinglist.values['WAVE-3.Y']);
  asetting.wavepoint3 := p;

  p.x := strtofloat(settinglist.values['WAVE-4.X']);
  p.y := strtofloat(settinglist.values['WAVE-4.Y']);
  asetting.wavepoint4 := p;

  p.x := strtofloat(settinglist.values['WAVE-5.X']);
  p.y := strtofloat(settinglist.values['WAVE-5.Y']);
  asetting.wavepoint5 := p;

  p.x := strtofloat(settinglist.values['WAVE-6.X']);
  p.y := strtofloat(settinglist.values['WAVE-6.Y']);
  asetting.wavepoint6 := p;

  p.x := strtofloat(settinglist.values['WAVE-7.X']);
  p.y := strtofloat(settinglist.values['WAVE-7.Y']);
  asetting.wavepoint7 := p;

  p.x := strtofloat(settinglist.values['WAVE-8.X']);
  p.y := strtofloat(settinglist.values['WAVE-8.Y']);
  asetting.wavepoint8 := p;

  asetting.wavescale := strtofloat(settinglist.values['WAVE.SCALE']);
  asetting.waveoff   := strtoint  (settinglist.values['WAVE.OFF'  ]);
end;

end.

