function output = edfTranslate(data)
% Convert the output of edfmex to look like the output of edfMexImport.
% This means converting a 1x1 with 6 different 1x? structs into one 1xn.

% Essentially what's happening is that the data is not yet split by trial:
% it's all just one continuous stream of data.
% So this function reads data from edfmex's RECORDINGS struct,
% determines where the divisions between trials are (based on timestamps),
% then splits the data in FSAMPLE and FEVENT into one row per trial.

% init output var
output = struct('Header', [], 'Samples', [], 'Events', []);

% turn event struct into a table for easier manipulation
events = struct2table(data.FEVENT);

numRecs = length(data.RECORDINGS);
for i = 1:2:numRecs
    t = (i+1)/2; % index for output. i goes 1,3,5... but we want 1,2,3...
    % Get start and end time
    sttime = data.RECORDINGS(i).time;
    entime = data.RECORDINGS(i+1).time;
    % Find associated samples
    stsample = find(data.FSAMPLE.time == sttime);
    ensample = find(data.FSAMPLE.time <= entime, 1, 'last');
    % Find associated events, bc different
    stevent = find(strcmp(events.message, sprintf('TRIALID %i', t)));
    enevent = find(strcmp(events.codestring, 'ENDSAMPLES'),t,'first');
    enevent = enevent(end);
    
    % Fill in header info
    output(t).Header.rec = data.RECORDINGS(t);
    output(t).Header.starttime = events.sttime(stevent);
    output(t).Header.endtime = events.sttime(enevent);
    output(t).Header.duration = output(t).Header.endtime - output(t).Header.starttime;

    % Grab samples based on detected indices
    output(t).Samples.RealNumberOfSamples = length(stsample:ensample);
    output(t).Samples.time = data.FSAMPLE.time(:,stsample:ensample);
    output(t).Samples.px = data.FSAMPLE.px(:,stsample:ensample);
    output(t).Samples.py = data.FSAMPLE.py(:,stsample:ensample);
    output(t).Samples.hx = data.FSAMPLE.hx(:,stsample:ensample);
    output(t).Samples.hy = data.FSAMPLE.hy(:,stsample:ensample);
    output(t).Samples.pa = data.FSAMPLE.pa(:,stsample:ensample);
    output(t).Samples.gx = data.FSAMPLE.gx(:,stsample:ensample);
    output(t).Samples.gy = data.FSAMPLE.gy(:,stsample:ensample);
    output(t).Samples.rx = data.FSAMPLE.rx(:,stsample:ensample);
    output(t).Samples.ry = data.FSAMPLE.ry(:,stsample:ensample);
    output(t).Samples.gxvel = data.FSAMPLE.gxvel(:,stsample:ensample);
    output(t).Samples.gyvel = data.FSAMPLE.gyvel(:,stsample:ensample);
    output(t).Samples.hxvel = data.FSAMPLE.hxvel(:,stsample:ensample);
    output(t).Samples.hyvel = data.FSAMPLE.hyvel(:,stsample:ensample);
    output(t).Samples.rxvel = data.FSAMPLE.rxvel(:,stsample:ensample);
    output(t).Samples.ryvel = data.FSAMPLE.ryvel(:,stsample:ensample);
    output(t).Samples.fgxvel = data.FSAMPLE.fgxvel(:,stsample:ensample);
    output(t).Samples.fgyvel = data.FSAMPLE.fgyvel(:,stsample:ensample);
    output(t).Samples.fhxvel = data.FSAMPLE.fhxvel(:,stsample:ensample);
    output(t).Samples.fhyvel = data.FSAMPLE.fhyvel(:,stsample:ensample);
    output(t).Samples.frxvel = data.FSAMPLE.frxvel(:,stsample:ensample);
    output(t).Samples.fryvel = data.FSAMPLE.fryvel(:,stsample:ensample);
    output(t).Samples.hdata = data.FSAMPLE.hdata(:,stsample:ensample);
    output(t).Samples.flags = data.FSAMPLE.flags(:,stsample:ensample);
    output(t).Samples.input = data.FSAMPLE.input(:,stsample:ensample);
    output(t).Samples.buttons = data.FSAMPLE.buttons(:,stsample:ensample);
    output(t).Samples.htype = data.FSAMPLE.htype(:,stsample:ensample);
    output(t).Samples.errors = data.FSAMPLE.errors(:,stsample:ensample);

    % Grab all the event data
    % This is oriented vertically instead of horizontally,
    % which will take some effort to get through.
    output(t).Events.time = events.time(stevent:enevent)';
    output(t).Events.type = events.type(stevent:enevent)';
    output(t).Events.read = events.read(stevent:enevent)';
    output(t).Events.eye = events.eye(stevent:enevent)';
    output(t).Events.sttime = events.sttime(stevent:enevent)';
    output(t).Events.entime = events.entime(stevent:enevent)';
    output(t).Events.hstx = events.hstx(stevent:enevent)';
    output(t).Events.hsty = events.hsty(stevent:enevent)';
    output(t).Events.gstx = events.gstx(stevent:enevent)';
    output(t).Events.gsty = events.gsty(stevent:enevent)';
    output(t).Events.sta = events.sta(stevent:enevent)';
    output(t).Events.henx = events.henx(stevent:enevent)';
    output(t).Events.heny = events.heny(stevent:enevent)';
    output(t).Events.genx = events.genx(stevent:enevent)';
    output(t).Events.geny = events.geny(stevent:enevent)';
    output(t).Events.ena = events.ena(stevent:enevent)';
    output(t).Events.havx = events.havx(stevent:enevent)';
    output(t).Events.havy = events.havy(stevent:enevent)';
    output(t).Events.gavx = events.gavx(stevent:enevent)';
    output(t).Events.gavy = events.gavy(stevent:enevent)';
    output(t).Events.ava = events.ava(stevent:enevent)';
    output(t).Events.avel = events.avel(stevent:enevent)';
    output(t).Events.pvel = events.pvel(stevent:enevent)';
    output(t).Events.svel = events.svel(stevent:enevent)';
    output(t).Events.evel = events.evel(stevent:enevent)';
    output(t).Events.supd_x = events.supd_x(stevent:enevent)';
    output(t).Events.eupd_x = events.eupd_x(stevent:enevent)';
    output(t).Events.supd_y = events.supd_y(stevent:enevent)';
    output(t).Events.eupd_y = events.eupd_y(stevent:enevent)';
    output(t).Events.status = events.status(stevent:enevent)';
    output(t).Events.flags = events.flags(stevent:enevent)';
    output(t).Events.input = events.input(stevent:enevent)';
    output(t).Events.buttons = events.buttons(stevent:enevent)';
    output(t).Events.parsedby = events.parsedby(stevent:enevent)';
    output(t).Events.message = events.message(stevent:enevent)';

end

end % function