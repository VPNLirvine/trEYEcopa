clear; clc;
close all


data = importfile('selected videos');
type = data.mainCategory;
subtype = data.subcategory;
an = data.extentOfAnimacy;
anTypes = unique(an);

% plot OO scores
ooIn = find(type == 'OO');
figure; plot(data.DevFromPredOfPhysModel(ooIn), data.Intention(ooIn), 'bo');
hold on;

%plot HH scores by type
colors = {'r', 'g', 'c'};
hhIn = find(type == 'HH');
for i = 1:3
    anIn = find(an == anTypes{i});
    in = intersect(hhIn, anIn);
    plot(data.DevFromPredOfPhysModel(in), data.Intention(in), strcat(colors{i}, 'o'));
    hold on;
end

xlabel('Violation of Physics');
ylabel('Intentionality')
legend(cat(1, {'OO'}, anTypes(1:3)))