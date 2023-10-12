function [movieinf, rt0, rt90, rt180, rt270, lst, randmovie] = ...
    picksample(movieinf, rt0, rt90, rt180, rt270, lst, intn, sbtyp)

while 1
    randmovie = movieinf(datasample(find(movieinf.intents == intn & movieinf.subtypes == sbtyp & movieinf.playeds == 0), 1, 'Replace', false),:);
    if rt0 == 11 && rt90 == 11 && rt180 == 11 && rt270 == 11
        % if at the end of the run, it's ok -> just pick the 12th one
        break
    elseif (randmovie.orients == 0 && rt0 == 11) || (randmovie.orients == 90 && rt90 == 11) ...
            || (randmovie.orients == 180 && rt180 == 11) || (randmovie.orients == 270 && rt270 == 11)
        % have taken a rotation which is full -> pick another one
        continue
    else
        break
    end
end
% we now have our randmovie without rotation repetitions
lst = strvcat(lst, char(randmovie.names)); % first, add it to the playlist
if randmovie.orients == 0, rt0 = rt0+1; elseif randmovie.orients == 90, rt90 = rt90+1; ...
elseif randmovie.orients == 180, rt180 = rt180+1; elseif randmovie.orients == 270, rt270 = rt270+1; end
% mark this video together with its rotation sisters as played!
movieinf(find(strcmp(movieinf.types, randmovie.types) & movieinf.subtypes == randmovie.subtypes & ...
    movieinf.intents == randmovie.intents & movieinf.idents == randmovie.idents),:).playeds = [1;1;1;1];