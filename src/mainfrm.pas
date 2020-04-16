{
  Description: vPlot main form.

  Copyright (C) 2017-2020 Melchiorre Caruso <melchiorrecaruso@gmail.com>

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

unit mainfrm;

{$mode objfpc}

interface

uses
  bgrabitmap, bgrabitmaptypes, bgragradientscanner, bgravirtualscreen, bgrapath,
  buttons, classes, comctrls, controls, dialogs, extctrls, forms, graphics,
  menus, spin, stdctrls, shellctrls, XMLPropStorage, dividerbevel, spinex,
  vpdriver, vppaths, vpmath, vpserial, vpsetting, vpwave;

type
  { tmainform }

  tmainform = class(tform)
    beginbtn: tbitbtn;
    decstepsbtn: tbitbtn;
    layoutmi: tmenuitem;
    checkmi: tmenuitem;
    aboutmi: tmenuitem;
    wavemi: tmenuitem;
    popupn1: tmenuitem;
    incstepsbtn: tbitbtn;
    deczoombtn: tbitbtn;
    inczoombtn: tbitbtn;
    endbtn: tbitbtn;
    fitbtn: tbitbtn;
    btnimages: timagelist;
    pagesizebtn: tbitbtn;
    popup: tpopupmenu;
    stepslb: tlabel;
    propstorage: TXMLPropStorage;
    zoomlb: tlabel;
    nextbtn: tbitbtn;
    backbtn: tbitbtn;
    aboutbtn: tbitbtn;
    homebtn: tbitbtn;
    startbvl: tbitbtn;
    killbtn: tbitbtn;
    controlbvl: tdividerbevel;
    calibrationbvl: tdividerbevel;
    clearbtn: tbitbtn;
    pagesizecb: tcombobox;
    portbtn: tbitbtn;
    connectionbvl: tdividerbevel;
    controlpnl: tpanel;
    drawingbvl: tdividerbevel;
    editingbvl: tdividerbevel;
    importbtn: tbitbtn;
    pagesizelb: tlabel;
    leftdownbtn: tbitbtn;
    leftupbtn: tbitbtn;
    mainformbevel: tbevel;
    editingbtn: tbitbtn;
    editingcb: tcombobox;
    editinhlb: tlabel;
    editingedt: tfloatspinedit;
    editingvaluelb: tlabel;
    pagesizebvl: tdividerbevel;
    pendownbtn: tbitbtn;
    penupbtn: tbitbtn;
    portcb: tcombobox;
    portlb: tlabel;
    rightdownbtn: tbitbtn;
    rightupbtn: tbitbtn;
    savedialog: tsavedialog;
    opendialog: topendialog;
    screen: tbgravirtualscreen;
    stepnumberedt: tspinedit;
    stepnumberlb: tlabel;
    // FORM EVENTS
    procedure formcreate (sender: tobject);
    procedure formdestroy(sender: tobject);
    procedure formclose  (sender: tobject; var closeaction: tcloseaction);
    // CONNECTION
    procedure connectbtnclick(sender: tobject);
    // CALIBRATION
    procedure motorbtnclick(sender: tobject);
    procedure penbtnclick  (sender: tobject);
    // IMPORT/CLEAR
    procedure importbtnclick(sender: tobject);
    procedure clearbtnclick (sender: tobject);
    // EDITING
    procedure editingbtnclick(sender: tobject);
    // PAGE SIZE
    procedure pagesizebtnclick(sender: tobject);
    // CONTROL
    procedure startmiclick     (sender: tobject);
    procedure killmiclick      (sender: tobject);
    procedure movetohomemiclick(sender: tobject);
    // PREVIEW STEP BY STEP
    procedure stepsbtnclick      (sender: tobject);
    procedure changestepsbtnclick(sender: tobject);
    // ZOOM
    procedure editingcbchange   (sender: tobject);
    procedure changezoombtnclick(sender: tobject);
    procedure fitmiclick        (sender: tobject);
    // ABOUT POPUP
    procedure aboutbtnclick (sender: tobject);
    procedure layoutbtnclick(sender: tobject);
    procedure checkbtnclick (sender: tobject);
    procedure wavemiclick   (sender: tobject);
    procedure aboutmiclick  (sender: tobject);
    // VIRTUAL SCREEN EVENTS
    procedure screenredraw(sender: tobject; bitmap: tbgrabitmap);
    // MOUSE EVENTS
    procedure imagemouseup  (sender: tobject; button: tmousebutton; shift: tshiftstate; x, y: integer);
    procedure imagemousedown(sender: tobject; button: tmousebutton; shift: tshiftstate; x, y: integer);
    procedure imagemousemove(sender: tobject; shift: tshiftstate; x, y: integer);
  private
    screenimage: tbgrabitmap;
    mouseisdown: boolean;
             px: longint;
             py: longint;

           page: tvpelementlist;
      pagecount: longint;
      pagesteps: longint;
      pagewidth: longint;
     pageheight: longint;

           zoom: vpfloat;
          movex: longint;
          movey: longint;
    procedure onplottererror;
    procedure onplotterinit;
    procedure onplotterstart;
    procedure onplotterstop;
    procedure onplotterstopraise;
    procedure onplottertick;
    procedure lockinternal(value: boolean);
  public
    procedure lock;
    procedure unlock;
    procedure updatescreen;
  end;

var
  driver:       tvpdriver       = nil;
  driverengine: tvpdriverengine = nil;
  mainform:     tmainform;
  setting:      tvpsetting      = nil;
  wave:         tvpwave         = nil;

implementation

{$R *.lfm}

uses
  math, sysutils, importfrm, aboutfrm, layoutfrm, checkfrm, settingfrm,
  vpsketcher, vpsvgreader, vpdxfreader;

// FORM EVENTS

procedure tmainform.formcreate(sender: tobject);
var
  i: longint;
  list: tstringlist;
  wavemesh: tvpwavemesh;
begin
  // propstorage
  propstorage.filename := getclientsettingfilename(false);
  // load setting
  setting := tvpsetting.create;
  setting.load(getsettingfilename(true));
  // open serial port
  serialstream := tvpserialstream.create;
  // init space wave
  wavemesh[0] := setting.wavepoint0;
  wavemesh[1] := setting.wavepoint1;
  wavemesh[2] := setting.wavepoint2;
  wavemesh[3] := setting.wavepoint3;
  wavemesh[4] := setting.wavepoint4;
  wavemesh[5] := setting.wavepoint5;
  wavemesh[6] := setting.wavepoint6;
  wavemesh[7] := setting.wavepoint7;
  wavemesh[8] := setting.wavepoint8;
  wave := tvpwave.create(setting, wavemesh);
  wave.enabled := not (setting.waveoff = 1);
  {$IFOPT D+} wavedebug(wave); {$ENDIF}
  // init driver-engine
  driverengine := tvpdriverengine.create(setting);
  {$IFOPT D+} driverenginedebug(driverengine); {$ENDIF}
  // create preview and empty page
  page        := tvpelementlist.create;
  screenimage := tbgrabitmap.create(screen.width, screen.height);
  // update port combobox
  list := getserialportnames;
  for i := 0 to list.count -1 do
  begin
    portcb.items.add(list[i]);
  end;
  list.destroy;
  portcb.itemindex := 0;
  // main form updates
  pagesizebtnclick(nil);
  fitmiclick(nil);
  changestepsbtnclick(nil);
  editingcbchange(nil);
end;

procedure tmainform.aboutbtnclick(sender: tobject);
begin
  with aboutbtn.clienttoscreen(point(0, 0)) do
  begin
    popup.popup(x + aboutbtn.width, y + aboutbtn.height + 2);
  end;
end;

procedure tmainform.formdestroy(sender: tobject);
begin
  propstorage.save;
  page.destroy;
  serialstream.destroy;
  setting.destroy;
  screenimage.destroy;
  driverengine.destroy;
  wave.destroy;
end;

procedure tmainform.formclose(sender: tobject; var closeaction: tcloseaction);
begin
  if assigned(driver) then
  begin
    messagedlg('vPlot Client', 'There is an active process !', mterror, [mbok], 0);
    closeaction := canone;
  end else
    closeaction := cafree;
end;

// CONNECTION

procedure tmainform.connectbtnclick(sender: tobject);
begin
  lock;
  if serialstream.connected then
  begin
    serialstream.close;
    portbtn.caption := 'Connect';
  end else
  begin
    portcb.enabled := not serialstream.open(portcb.text);
    if serialstream.connected then
    begin
      portbtn.caption := 'Disconnect';
    end else
    begin
      portbtn.caption := 'Connect';
      messagedlg('vPlot Client', 'Unable connecting to server !', mterror, [mbok], 0);
    end;
  end;
  unlock;
end;

// CALIBRATION

procedure tmainform.motorbtnclick(sender: tobject);
var
  cx: longint = 0;
  cy: longint = 0;
begin
  if not serialstream.connected then exit;
  if not assigned(driver) then
  begin
    lock;
    if sender = leftupbtn    then cx := -stepnumberedt.value;
    if sender = leftdownbtn  then cx := +stepnumberedt.value;
    if sender = rightupbtn   then cy := -stepnumberedt.value;
    if sender = rightdownbtn then cy := +stepnumberedt.value;

    driver         := tvpdriver.create(setting, serialstream);
    driver.onerror := @onplottererror;
    driver.oninit  := @onplotterinit;
    driver.onstart := @onplotterstart;
    driver.onstop  := @onplotterstop;
    driver.ontick  := @onplottertick;
    driver.init;
    driver.movez(setting.servozmax);
    driver.move (cx + driver.xcount,
                 cy + driver.ycount);
    driver.start;
  end;
end;

procedure tmainform.penbtnclick(sender: tobject);
begin
  if not serialstream.connected then exit;
  if not assigned(driver) then
  begin
    lock;
    driver         := tvpdriver.create(setting, serialstream);
    driver.onerror := @onplottererror;
    driver.oninit  := nil;
    driver.onstart := @onplotterstart;
    driver.onstop  := @onplotterstop;
    driver.ontick  := @onplottertick;
    driver.init;
    if sender = pendownbtn then
      driver.movez(setting.servozmin)
    else
      driver.movez(setting.servozmax);
    driver.start;
  end;
end;

// DRAWING IMPORT/CLEAR

procedure tmainform.importbtnclick(sender: tobject);
var
  sk: tvpsketcher;
begin
  opendialog.filter := 'Supported files (*.svg, *.dxf, *.png, *.bmp)|*.svg; *.dxf; *.png; *.bmp';
  if opendialog.execute then
  begin
    caption := 'vPlot Client - ' + opendialog.filename;

    lock;
    if (lowercase(extractfileext(opendialog.filename)) = '.dxf') then
    begin
      dxf2paths(opendialog.filename, page);
      page.createtoolpath;
    end else
    if (lowercase(extractfileext(opendialog.filename)) = '.svg') then
    begin
      svg2paths(opendialog.filename, page);
      page.createtoolpath;
    end else
    if (lowercase(extractfileext(opendialog.filename)) = '.bmp') or
       (lowercase(extractfileext(opendialog.filename)) = '.png') then
    begin
      importform.imcb.itemindex := 0;
      importform.imcb .enabled  := true;
      importform.ipwse.enabled  := true;
      importform.pwse .enabled  := true;
      importform.dsfse.enabled  := true;
      if importform.showmodal = mrok then
      begin
        page.clear;
        screen.canvas.clear;
        screen.bitmap.loadfromfile(opendialog.filename);
        case (importform.imcb.itemindex + 1) of
          1: sk := tvpsketchersquare.create(screen.bitmap);
          2: sk := tvpsketcherroundedsquare.create(screen.bitmap);
          3: sk := tvpsketchertriangular.create(screen.bitmap);
        else sk := tvpsketchersquare.create(screen.bitmap);
        end;
        sk.patternbw := importform.ipwse.value;
        sk.patternbh := importform.ipwse.value;
        sk.patternw  := importform. pwse.value;
        sk.patternh  := importform. pwse.value;
        sk.dotsize   := importform.dsfse.value;
        sk.update(page);
        sk.destroy;
      end;
    end;
    pagecount := page.count;
    updatescreen;
    unlock;
  end;
end;

procedure tmainform.clearbtnclick(sender: tobject);
begin
  lock;
  page.clear;
  pagecount := page.count;
  caption := 'vPlot Client';
  fitmiclick(sender);
  unlock;
end;

// DRAWING EDITING

procedure tmainform.editingcbchange(sender: tobject);
begin
  editingedt.enabled := editingbtn.enabled;
  if sender = editingcb then
    case editingcb.itemindex of
      0: editingedt.value   := 1.0;   // SCALE
      1: editingedt.value   := 0.0;   // X-OFFSET
      2: editingedt.value   := 0.0;   // Y-OFFSET
      3: editingedt.enabled := false; // X-MIRROR
      4: editingedt.enabled := false; // Y-MIRROR
      5: editingedt.value   := 90.0;  // ROTATE
      6: editingedt.enabled := false; // MOVE TO ORIGIN
    end;
end;

procedure tmainform.editingbtnclick(sender: tobject);
begin
  lock;
  case editingcb.itemindex of
    0: page.scale(editingedt.value   ); // SCALE
    1: page.move (editingedt.value, 0); // X-OFFSET
    2: page.move (0, editingedt.value); // Y-OFFSET
    3: page.mirrorx;                    // X-MIRROR
    4: page.mirrory;                    // Y-MIRROR
    5: page.rotate(editingedt.value);   // ROTATE
    6: page.movetoorigin;               // MOVE TO ORIGIN
  end;
  updatescreen;
  unlock;
end;

// PAGE SIZE

procedure tmainform.pagesizebtnclick(sender: tobject);
begin
  lock;
  case pagesizecb.itemindex of
    0: begin pagewidth := 1189; pageheight :=  841; end; // A0-Landscape
    1: begin pagewidth :=  841; pageheight := 1189; end; // A0-Portrait
    2: begin pagewidth :=  841; pageheight :=  594; end; // A1-Landscape
    3: begin pagewidth :=  594; pageheight :=  841; end; // A1-Portrait
    4: begin pagewidth :=  594; pageheight :=  420; end; // A2-Landscape
    5: begin pagewidth :=  420; pageheight :=  594; end; // A2-Portrait
    6: begin pagewidth :=  420; pageheight :=  297; end; // A3-Landscape
    7: begin pagewidth :=  297; pageheight :=  420; end; // A3-Portrait
    8: begin pagewidth :=  297; pageheight :=  210; end; // A4-Landscape
    9: begin pagewidth :=  210; pageheight :=  297; end; // A4-Portrait
   10: begin pagewidth :=  210; pageheight :=  148; end; // A5-Landscape
   11: begin pagewidth :=  148; pageheight :=  210; end; // A5-Portrait
  else begin pagewidth :=  420; pageheight :=  297; end  // Default
  end;
  updatescreen;
  fitmiclick(sender);
  unlock;
end;

// CONTROL

procedure tmainform.startmiclick(sender: tobject);
var
   cx, cy: longint;
  element: tvpelement;
     i, j: longint;
     path: tvppolygonal;
   point1: tvppoint;
   point2: tvppoint;
  xoffset: single;
  yoffset: single;
begin
  if not serialstream.connected then exit;
  if not assigned(driver) then
  begin
    lock;
    driver         := tvpdriver.create(setting, serialstream);
    driver.onerror := @onplottererror;
    driver.oninit  := nil;
    driver.onstart := @onplotterstart;
    driver.onstop  := @onplotterstopraise;
    driver.ontick  := @onplottertick;
    driver.init;

    xoffset := setting.point8.x;
    yoffset := setting.point8.y +
      pageheight * setting.point9factor
                 + setting.point9offset;

    point1 := setting.point8;
    for i := 0 to page.count -1 do
    begin
      element := page.items[i];
      if element.hidden = false then
      begin
        element.interpolate(path, 0.05);
        for j := 0 to high(path) do
        begin
          point2 := path[j];
          if (abs(point2.x) < (pagewidth /2+2)) and
             (abs(point2.y) < (pageheight/2+2)) then
          begin
            point2.x := point2.x + xoffset;
            point2.y := point2.y + yoffset;

            if distance_between_two_points(point1, point2) > 0.2 then
              driver.movez(setting.servozmax)
            else
              driver.movez(setting.servozmin);

            driverengine.calcsteps(point2, cx, cy);
            driver.move(cx, cy);
            point1 := point2;
          end;
        end;
        path := nil;
      end;
    end;
    driver.start;
  end else
  begin
    driver.enabled := not driver.enabled;
    if driver.enabled then
    begin
      startbvl.caption    := 'Stop';
      startbvl.imageindex := 7;
    end else
    begin
      startbvl.caption    := 'Start';
      startbvl.imageindex := 6;
    end;
  end;
end;

procedure tmainform.killmiclick(sender: tobject);
begin
  if assigned(driver) then
  begin
    startbvl.enabled := false;
    killbtn .enabled := false;
    homebtn .enabled := false;
    driver.onerror   := nil;
    driver.enabled   := true;
    driver.terminate;
  end;
end;

procedure tmainform.movetohomemiclick(sender: tobject);
var
  cx, cy: longint;
begin
  if not serialstream.connected then exit;
  if not assigned(driver) then
  begin
    lock;
    driver         := tvpdriver.create(setting, serialstream);
    driver.onerror := @onplottererror;
    driver.oninit  := nil;
    driver.onstart := @onplotterstart;
    driver.onstop  := @onplotterstop;
    driver.ontick  := @onplottertick;
    driver.init;
    driver.movez(setting.servozmax);
    driverengine.calcsteps(setting.point8, cx, cy);
    driver.move(cx, cy);
    driver.start;
  end;
end;

// PREVIEW STEP BY STEP

procedure tmainform.changestepsbtnclick(sender: tobject);
begin
  if sender = nil then
  begin
    pagesteps := 1
  end else
  if sender = incstepsbtn then
  begin
    if pagesteps =   1 then pagesteps :=   2 else
    if pagesteps =   2 then pagesteps :=   5 else
    if pagesteps =   5 then pagesteps :=  10 else
    if pagesteps =  10 then pagesteps :=  25 else
    if pagesteps =  25 then pagesteps :=  50 else
    if pagesteps =  50 then pagesteps := 100 else
    if pagesteps = 100 then pagesteps := 250 else
    if pagesteps = 250 then pagesteps := 500;
  end else
  if sender = decstepsbtn then
  begin
    if pagesteps = 500 then pagesteps := 250 else
    if pagesteps = 250 then pagesteps := 100 else
    if pagesteps = 100 then pagesteps :=  50 else
    if pagesteps =  50 then pagesteps :=  25 else
    if pagesteps =  25 then pagesteps :=  10 else
    if pagesteps =  10 then pagesteps :=   5 else
    if pagesteps =   5 then pagesteps :=   2 else
    if pagesteps =   2 then pagesteps :=   1;
  end;
  stepslb.caption := format('Step x%d', [pagesteps]);
end;

procedure tmainform.stepsbtnclick(sender: tobject);
begin
  lock;
  if sender = beginbtn then
    pagecount := 0
  else
  if sender = backbtn then
    dec(pagecount, pagesteps)
  else
  if sender = nextbtn then
    inc(pagecount, pagesteps)
  else
    pagecount := page.count;

  pagecount := max(0, min(pagecount, page.count));
  updatescreen;
  unlock;
end;

// ZOOM BUTTONS

procedure tmainform.changezoombtnclick(sender: tobject);
var
  azoom: vpfloat;
begin
  azoom := zoom;
  if sender = inczoombtn then
  begin
    if zoom =  0.25 then zoom :=  0.50 else
    if zoom =  0.50 then zoom :=  0.75 else
    if zoom =  0.75 then zoom :=  1.00 else
    if zoom =  1.00 then zoom :=  1.25 else
    if zoom =  1.25 then zoom :=  1.50 else
    if zoom =  1.50 then zoom :=  1.75 else
    if zoom =  1.75 then zoom :=  2.00 else
    if zoom =  2.00 then zoom :=  4.00 else
    if zoom =  4.00 then zoom :=  6.00 else
    if zoom =  6.00 then zoom :=  8.00;
  end else
  if sender = deczoombtn then
  begin
    if zoom =  8.00 then zoom :=  6.00 else
    if zoom =  6.00 then zoom :=  4.00 else
    if zoom =  4.00 then zoom :=  2.00 else
    if zoom =  2.00 then zoom :=  1.75 else
    if zoom =  1.75 then zoom :=  1.50 else
    if zoom =  1.50 then zoom :=  1.25 else
    if zoom =  1.25 then zoom :=  1.00 else
    if zoom =  1.00 then zoom :=  0.75 else
    if zoom =  0.75 then zoom :=  0.50 else
    if zoom =  0.50 then zoom :=  0.25;
  end;

  if zoom <> azoom then
  begin
    fitmiclick(sender);
  end;
end;

procedure tmainform.fitmiclick(sender: tobject);
begin
  if (sender = nil   ) then zoom := 1.0 else
  if (sender = fitbtn) then zoom := 1.0;
  zoomlb.caption := format('Zoom %d%%', [trunc(zoom*100)]);

  lock;
  movex := (screen.width  div 2) - trunc((pagewidth /2)*zoom);
  movey := (screen.height div 2) - trunc((pageheight/2)*zoom);
  updatescreen;
  unlock;
end;

// ABOUT POPUP

procedure tmainform.layoutbtnclick(sender: tobject);
begin
  layoutform.showmodal;
end;

procedure tmainform.checkbtnclick(sender: tobject);
begin
  checkform.showmodal;
end;

procedure tmainform.wavemiclick(sender: tobject);
begin
  settingform.load(setting);
  if settingform.showmodal = mrok then
  begin
    try
      settingform.save(setting);
      setting.save(getsettingfilename(false));
    except
      setting.load(getsettingfilename(true));
      wavemiclick(sender);
    end;
  end;
end;

procedure tmainform.aboutmiclick(sender: tobject);
begin
  aboutform.showmodal;
end;

// MOUSE EVENTS

procedure tmainform.imagemousedown(sender: tobject;
  button: tmousebutton; shift: tshiftstate; x, y: integer);
var
     i: longint;
  elem: tvpelement;
    p0: tvppoint;
begin
  if assigned(driver) then exit;
  (*
  if (ssctrl in shift) then
  begin
    popup.autopopup := false;
    p0.x := ((x - pagewidth /2)*zoom) - movex;
    p0.y := ((y - pageheight/2)*zoom) - movey;

    for i := 0 to page.count -1 do
    begin
      elem := page.items[i];
      if elem.hidden = false then
        if elem.ispointon(p0) then
        begin
          elem.selected := true;
        end;
    end;
  end;
  *)

  if button = mbleft then
  begin
    mouseisdown := true;
    px := x - movex;
    py := y - movey;
  end;
end;

procedure tmainform.imagemousemove(sender: tobject;
  shift: tshiftstate; x, y: integer);
begin
  if assigned(driver) then exit;
  if mouseisdown then
  begin
    movex := x - px;
    movey := y - py;
    screen.redrawbitmap;
  end;
end;

procedure tmainform.imagemouseup(sender: tobject;
  button: tmousebutton; shift: tshiftstate; x, y: integer);
begin
  if assigned(driver) then exit;
  mouseisdown := false;
end;

// SCREEN EVENTS

procedure tmainform.updatescreen;
var
       a: arrayoftpointf;
       i: longint;
    elem: tvpelement;
  x0, x1: longint;
  y0, y1: longint;
    path: tbgrapath;
begin
  screenimage.setsize(trunc(pagewidth*zoom), trunc(pageheight*zoom));

  x0 := 0;
  y0 := 0;
  x1 := screenimage.width;
  y1 := screenimage.height;
  screenimage.fillrect(x0, y0, x1, y1, bgra(255, 255, 255), dmset);

  x0 := 0;
  y0 := 0;
  x1 := x0+trunc(pagewidth *zoom);
  y1 := y0+trunc(pageheight*zoom);
  screenimage.fillrect(x0, y0, x1, y1, bgra(255,   0,   0), dmset);

  x0 := 1;
  y0 := 1;
  x1 := x0+trunc(pagewidth *zoom)-2;
  y1 := y0+trunc(pageheight*zoom)-2;
  screenimage.fillrect(x0, y0, x1, y1, bgra(255, 255, 255), dmset);

  // updtare preview ...
  for i := 0 to min(pagecount, page.count) -1 do
  begin
    elem := page.items[i];
    if (elem.hidden = false) then
    begin
      x0 := trunc((pagewidth /2)*zoom);
      y0 := trunc((pageheight/2)*zoom);

      elem.mirrorx;
      elem.scale(zoom);
      elem.move(x0, y0);
      begin
        path := elem.interpolate;
        path.stroke(screenimage, bgra(0, 0, 0), 1.5);
        // draw red point
        if pagecount < page.count then
        begin
          a := path.topoints;
          path.beginpath;
          path.arc(
            trunc(a[high(a)].x),
            trunc(a[high(a)].y), 1.5, 0, 2*pi);
          path.stroke(screenimage, bgra(255, 0, 0), 1.0);
          path.fill  (screenimage, bgra(255, 0, 0));
        end;
        path.destroy;
      end;
      elem.move(-x0, -y0);
      elem.scale(1/zoom);
      elem.mirrorx;
    end;
  end;
  screen.redrawbitmap;
end;

procedure tmainform.screenredraw(sender: tobject; bitmap: tbgrabitmap);
begin
  bitmap.putimage(movex, movey, screenimage, dmset);
end;

// LOCK/UNLOCK ROUTINES

procedure tmainform.lockinternal(value: boolean);
begin
  if assigned(driver) then
  begin
    // connection
    portcb         .enabled := false;
    portbtn        .enabled := false;
    // calibration
    stepnumberedt  .enabled := false;
    leftupbtn      .enabled := false;
    leftdownbtn    .enabled := false;
    rightupbtn     .enabled := false;
    rightdownbtn   .enabled := false;
    penupbtn       .enabled := false;
    pendownbtn     .enabled := false;
    // drawing
    importbtn      .enabled := false;
    clearbtn       .enabled := false;
    // drawing editing
    editingcb      .enabled := false;
    editingedt     .enabled := false;
    editingbtn     .enabled := false;
    // page sizing
    pagesizecb     .enabled := false;
    pagesizebtn    .enabled := false;
    // control
    startbvl       .enabled := true;
    killbtn        .enabled := true;
    homebtn        .enabled := false;
    // about popup
    aboutbtn       .enabled := false;
    layoutmi       .enabled := false;
    checkmi        .enabled := false;
    wavemi         .enabled := false;
    aboutmi        .enabled := false;
    // zoom
    inczoombtn     .enabled := false;
    deczoombtn     .enabled := false;
    fitbtn         .enabled := false;
    nextbtn        .enabled := false;
    backbtn        .enabled := false;
    // steps
    beginbtn       .enabled := false;
    backbtn        .enabled := false;
    nextbtn        .enabled := false;
    endbtn         .enabled := false;
    decstepsbtn    .enabled := false;
    incstepsbtn    .enabled := false;
    // screen
    screen         .enabled := false;
  end else
  begin
    // connection
    portcb         .enabled := value and (not serialstream.connected);
    portbtn        .enabled := value;
    // calibration
    stepnumberedt  .enabled := value and serialstream.connected;
    leftupbtn      .enabled := value and serialstream.connected;
    leftdownbtn    .enabled := value and serialstream.connected;
    rightupbtn     .enabled := value and serialstream.connected;
    rightdownbtn   .enabled := value and serialstream.connected;
    penupbtn       .enabled := value and serialstream.connected;
    pendownbtn     .enabled := value and serialstream.connected;
    // drawing
    importbtn      .enabled := value;
    clearbtn       .enabled := value;
    // drawing editing
    editingcb      .enabled := value;
    editingedt     .enabled := value;
    editingbtn     .enabled := value;
    // page sizing
    pagesizecb     .enabled := value;
    pagesizebtn    .enabled := value;
    // control
    startbvl       .enabled := value and serialstream.connected;
    killbtn        .enabled := value and serialstream.connected;
    homebtn        .enabled := value and serialstream.connected;
    // about popup
    aboutbtn       .enabled := value;
    layoutmi       .enabled := value;
    checkmi        .enabled := value;
    wavemi         .enabled := value;
    aboutmi        .enabled := value;
    // zoom
    inczoombtn     .enabled := value;
    deczoombtn     .enabled := value;
    fitbtn         .enabled := value;
    nextbtn        .enabled := value;
    backbtn        .enabled := value;
    // steps
    beginbtn       .enabled := value;
    backbtn        .enabled := value;
    nextbtn        .enabled := value;
    endbtn         .enabled := value;
    decstepsbtn    .enabled := value;
    incstepsbtn    .enabled := value;
    // screen
    screen         .enabled := value;
  end;
  editingcbchange(nil);
  application.processmessages;
end;

procedure tmainform.lock;
begin
  lockinternal(false);
end;

procedure tmainform.unlock;
begin
  lockinternal(true);
end;

// DRIVER THREAD EVENTS

procedure tmainform.onplotterstart;
begin
  lock;
  startbvl.caption    := 'Stop';
  startbvl.imageindex := 7;
  application.processmessages;
end;

procedure tmainform.onplotterstopraise;
begin
  driver := nil;
  penbtnclick(penupbtn);
end;

procedure tmainform.onplotterstop;
begin
  driver := nil;
  unlock;
  startbvl.caption    := 'Start';
  startbvl.imageindex := 6;
  application.processmessages;
end;

procedure tmainform.onplotterinit;
var
  cx, cy, kb, km: longint;
begin
  setting.load(getsettingfilename(true));
  // ---
  driverengine.calcsteps(setting.point8, cx,  cy);
  if not serverset(serialstream, vpserver_setxcount, cx) then
    messagedlg('vPlot Client', 'Axis X syncing error !',   mterror, [mbok], 0);
  if not serverget(serialstream, vpserver_getxcount, cx) then
    messagedlg('vPlot Client', 'Axis X checking error !',  mterror, [mbok], 0);
  if not serverset(serialstream, vpserver_setycount, cy) then
    messagedlg('vPlot Client', 'Axis Y syncing error !',   mterror, [mbok], 0);
  if not serverget(serialstream, vpserver_getycount, cy) then
    messagedlg('vPlot Client', 'Axis Y checking error !',  mterror, [mbok], 0);
//if not serverset(serialstream, vpserver_setzcount, cz) then
//  messagedlg('vPlot Client', 'Axis Z syncing error !',   mterror, [mbok], 0);
//if not serverget(serialstream, vpserver_getzcount, cz) then
//  messagedlg('vPlot Client', 'Axis Z checking error !',  mterror, [mbok], 0);
  kb := setting.rampkb;
  if not serverset(serialstream, vpserver_setrampkb, kb) then
    messagedlg('vPlot Client', 'Ramp KB syncing error !',  mterror, [mbok], 0);
  if not serverget(serialstream, vpserver_getrampkb, kb) then
    messagedlg('vPlot Client', 'Ramp KB checking error !', mterror, [mbok], 0);
  km := setting.rampkm;
  if not serverset(serialstream, vpserver_setrampkm, km) then
    messagedlg('vPlot Client', 'Ramp KM syncing error !',  mterror, [mbok], 0);
  if not serverget(serialstream, vpserver_getrampkm, km) then
    messagedlg('vPlot Client', 'Ramp KM checking error !', mterror, [mbok], 0);
  application.processmessages;
end;

procedure tmainform.onplottertick;
begin
  application.processmessages;
end;

procedure tmainform.onplottererror;
begin
  messagedlg('vPlot Client', driver.message, mterror, [mbok], 0);
  application.processmessages;
end;

end.

