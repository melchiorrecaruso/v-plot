{
  Description: vPlot layout check form.

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

unit checkfrm;

{$mode objfpc}

interface

uses
  classes, sysutils, forms, controls, graphics, dialogs, spin, extctrls,
  buttons, valedit, vpdriver, vpmath, vpsetting;

type

  { tcheckform }

  tcheckform = class(tform)
    resetbtn: tbitbtn;
    checkbtn: tbitbtn;
    image: timage;
    layoutlist: TValueListEditor;
    procedure resetbtnclick(sender: tobject);
    procedure drawbtnclick(sender: tobject);
    procedure formcreate(sender: tobject);
    procedure formdestroy(sender: tobject);
  private

  public

  end;

var
  driverengine1: tvpdriverengine;
  driverengine2: tvpdriverengine;
  setting1:      tvpsetting;
  setting2:      tvpsetting;
  checkform:     tcheckform;

implementation

{$R *.lfm}

uses
   fgl, reportfrm;

type
  tintegerlist = specialize tfpglist<integer>;

{ tcheckform }

procedure tcheckform.formcreate(sender: tobject);
begin
  setting1 := tvpsetting.create;
  setting2 := tvpsetting.create;
  resetbtnclick(sender);

  driverengine1 := tvpdriverengine.create(setting1);
  driverengine2 := tvpdriverengine.create(setting2);
end;

procedure tcheckform.formdestroy(sender: tobject);
begin
  setting1.destroy;
  setting2.destroy;
end;

procedure tcheckform.drawbtnclick(sender: tobject);
var
        i: longint;
  c00, c0: longint;
  c11, c1: longint;
        l: tvpline;
  l00, l0: vpfloat;
  l11, l1: vpfloat;
  offset0: vpfloat;
  offset1: vpfloat;
    path0: tvppolygonal;
    path1: tvppolygonal;
    pp, p: tvppoint;
begin
  // update setting2
  p.x := strtofloat(layoutlist.values['POINT-0.X']);
  p.y := strtofloat(layoutlist.values['POINT-0.Y']); setting2.point0 := p;
  p.x := strtofloat(layoutlist.values['POINT-1.X']);
  p.y := strtofloat(layoutlist.values['POINT-1.Y']); setting2.point1 := p;
  p.x := strtofloat(layoutlist.values['POINT-8.X']);
  p.y := strtofloat(layoutlist.values['POINT-8.Y']); setting2.point8 := p;

  setting2.pulley0radius := strtofloat(layoutlist.values['PULLEY-0.RADIUS']);
  setting2.pulley1radius := strtofloat(layoutlist.values['PULLEY-1.RADIUS']);
  setting2.pulley0ratio  := strtofloat(layoutlist.values['PULLEY-0.RATIO']);
  setting2.pulley1ratio  := strtofloat(layoutlist.values['PULLEY-1.RATIO']);

  // create paths
  setlength(path0, 9);
  setlength(path1, 9);

  path0[0].x := -setting1.pagewidth  / 2;
  path0[0].y := +setting1.pageheight / 2;
  path0[1].x := +0;
  path0[1].y := +setting1.pageheight / 2;
  path0[2].x := +setting1.pagewidth  / 2;
  path0[2].y := +setting1.pageheight / 2;

  path0[3].x := -setting1.pagewidth  / 2;
  path0[3].y := +0;
  path0[4].y := +0;
  path0[4].y := +0;
  path0[5].x := +0;
  path0[5].x := +setting1.pagewidth  / 2;

  path0[6].x := -setting1.pagewidth  / 2;
  path0[6].y := -setting1.pageheight / 2;
  path0[7].x := +0;
  path0[7].y := -setting1.pageheight / 2;
  path0[8].x := +setting1.pagewidth  / 2;
  path0[8].y := -setting1.pageheight / 2;

  for i := 0 to high(path0) do
  begin
    path1[i] := path0[i]
  end;

  // run
  offset0 := setting1.point8.x;
  offset1 := setting1.point8.y +
    setting1.pageheight   *
    setting1.point9factor +
    setting1.point9offset;

  driverengine1.calcsteps  (setting1.point8, c00, c11);
  driverengine2.calclengths(setting2.point8, l00, l11);
  for i := 0 to high(path0) do
  begin
    p   := path0[i];
    p.x := p.x + offset0;
    p.y := p.y + offset1;

    driverengine1.calcsteps(p, c0, c1);
    l0 := l00 + ((c0-c00) * setting2.pulley0ratio);
    l1 := l11 + ((c1-c11) * setting2.pulley1ratio);
    driverengine2.calcpoint(l0, l1, pp);

    path1[i] := pp;
  end;

  reportform.reportclear;
  reportform.reportappend('');
  reportform.reportappend('  Results:');
  reportform.reportappend('');

  l00 := path1[2].x - path1[0].x;
  l11 := path1[2].x - path1[0].x - setting1.pagewidth;
  reportform.reportappend(format('  Page.TopWidth               = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[5].x - path1[3].x;
  l11 := path1[5].x - path1[3].x - setting1.pagewidth;
  reportform.reportappend(format('  Page.MiddleWidth            = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[8].x - path1[6].x;
  l11 := path1[8].x - path1[6].x - setting1.pagewidth;
  reportform.reportappend(format('  Page.BottomWidth            = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[0].y - path1[6].y;
  l11 := path1[0].y - path1[6].y - setting1.pageheight;
  reportform.reportappend(format('  Page.LeftHeight             = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[1].y - path1[7].y;
  l11 := path1[1].y - path1[7].y - setting1.pageheight;
  reportform.reportappend(format('  Page.MiddleHeight           = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[2].y - path1[8].y;
  l11 := path1[2].y - path1[8].y - setting1.pageheight;
  reportform.reportappend(format('  Page.RightHeight            = %8.1f mm   Error = %4.1f mm', [l00, l11]));
  reportform.reportappend(' --- ');

  l00 := path1[1].x - path1[0].x;
  l11 := path1[1].x - path1[0].x - setting1.pagewidth/2;
  reportform.reportappend(format('  Page.TopWidth/Left          = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[2].x - path1[1].x;
  l11 := path1[2].x - path1[1].x - setting1.pagewidth/2;
  reportform.reportappend(format('  Page.TopWidth/Right         = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[4].x - path1[3].x;
  l11 := path1[4].x - path1[3].x - setting1.pagewidth/2;
  reportform.reportappend(format('  Page.MiddleWidth/Left       = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[5].x - path1[4].x;
  l11 := path1[5].x - path1[4].x - setting1.pagewidth/2;
  reportform.reportappend(format('  Page.MiddleWidth/Right      = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[7].x - path1[6].x;
  l11 := path1[7].x - path1[6].x - setting1.pagewidth/2;
  reportform.reportappend(format('  Page.RightWidth/Left        = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[8].x - path1[7].x;
  l11 := path1[8].x - path1[7].x - setting1.pagewidth/2;
  reportform.reportappend(format('  Page.RightWidth/Right       = %8.1f mm   Error = %4.1f mm', [l00, l11]));
  reportform.reportappend(' --- ');

  l00 := path1[0].y - path1[3].y;
  l11 := path1[0].y - path1[3].y - setting1.pageheight/2;
  reportform.reportappend(format('  Page.LeftHeight/Up          = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[3].y - path1[6].y;
  l11 := path1[3].y - path1[6].y - setting1.pageheight/2;
  reportform.reportappend(format('  Page.LeftHeight/Down        = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[1].y - path1[4].y;
  l11 := path1[1].y - path1[4].y - setting1.pageheight/2;
  reportform.reportappend(format('  Page.MiddleHeight/UP        = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[4].y - path1[7].y;
  l11 := path1[4].y - path1[7].y - setting1.pageheight/2;
  reportform.reportappend(format('  Page.MiddleHeight/Down      = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[2].y - path1[5].y;
  l11 := path1[2].y - path1[5].y - setting1.pageheight/2;
  reportform.reportappend(format('  Page.RightHeight/Up         = %8.1f mm   Error = %4.1f mm', [l00, l11]));

  l00 := path1[5].y - path1[8].y;
  l11 := path1[5].y - path1[8].y - setting1.pageheight/2;
  reportform.reportappend(format('  Page.RightHeight/Down       = %8.1f mm   Error = %4.1f mm', [l00, l11]));
  reportform.reportappend(' --- ');

  l00 := distance_from_point_and_line(path1[1], line_by_two_points(path1[0], path1[2]));
  reportform.reportappend(format('  Page.TopWidth/Alignment     = %8.1f mm', [l00]));

  l00 := distance_from_point_and_line(path1[4], line_by_two_points(path1[3], path1[5]));
  reportform.reportappend(format('  Page.MiddleWidth/Alignment  = %8.1f mm', [l00]));

  l00 := distance_from_point_and_line(path1[7], line_by_two_points(path1[6], path1[8]));
  reportform.reportappend(format('  Page.BottomWidth/Alignment  = %8.1f mm', [l00]));
  reportform.reportappend(' --- ');

  l00 := distance_from_point_and_line(path1[3], line_by_two_points(path1[0], path1[6]));
  reportform.reportappend(format('  Page.LeftHeight/Alignment   = %8.1f mm', [l00]));

  l00 := distance_from_point_and_line(path1[4], line_by_two_points(path1[1], path1[7]));
  reportform.reportappend(format('  Page.MiddleHeight/Alignment = %8.1f mm', [l00]));

  l00 := distance_from_point_and_line(path1[5], line_by_two_points(path1[2], path1[8]));
  reportform.reportappend(format('  Page.RightHeight/Alignment  = %8.1f mm', [l00]));

  reportform.showmodal;
  path0 := nil;
  path1 := nil;
end;

procedure tcheckform.resetbtnclick(sender: tobject);
begin
  setting1.load(getsettingfilename(true));
  setting2.load(getsettingfilename(true));

  layoutlist.strings.clear;
  layoutlist.titlecaptions.clear;
  layoutlist.titlecaptions.add('KEY');
  layoutlist.titlecaptions.add('VALUE');

  layoutlist.insertrow('POINT-0.X',       floattostr(setting1.point0.x),      true);
  layoutlist.insertrow('POINT-0.Y',       floattostr(setting1.point0.y),      true);
  layoutlist.insertrow('POINT-1.X',       floattostr(setting1.point1.x),      true);
  layoutlist.insertrow('POINT-1.Y',       floattostr(setting1.point1.y),      true);
  layoutlist.insertrow('POINT-8.X',       floattostr(setting1.point8.x),      true);
  layoutlist.insertrow('POINT-8.Y',       floattostr(setting1.point8.y),      true);

  layoutlist.insertrow('PULLEY-0.RADIUS', floattostr(setting1.pulley0radius), true);
  layoutlist.insertrow('PULLEY-0.RATIO',  floattostr(setting1.pulley0ratio),  true);
  layoutlist.insertrow('PULLEY-1.RADIUS', floattostr(setting1.pulley1radius), true);
  layoutlist.insertrow('PULLEY-1.RATIO',  floattostr(setting1.pulley1ratio),  true);

  layoutlist.toprow := 1;
end;

end.

