function output = postab2struct(input)
% Given position data in table format, convert to struct format
% Instead of having 16 columns of X, Y, R, name * 4 characters,
% Convert to a 1x4 struct where each layer has X, Y, R, name.
% Helpful for looping over number of characters.

output(1).Name = input.C1_Name{:};
output(1).X = input.X1_Values{:};
output(1).Y = input.Y1_Values{:};
output(1).R = input.R1_Values{:};
output(2).Name = input.C2_Name{:};
output(2).X = input.X2_Values{:};
output(2).Y = input.Y2_Values{:};
output(2).R = input.R2_Values{:};
output(3).Name = input.C3_Name{:};
output(3).X = input.X3_Values{:};
output(3).Y = input.Y3_Values{:};
output(3).R = input.R3_Values{:};
output(4).Name = input.C4_Name{:};
output(4).X = input.X4_Values{:};
output(4).Y = input.Y4_Values{:};
output(4).R = input.R4_Values{:};
end