%% Initialization
clear ; close all; clc

mtest_begin = 28
mtest_end = 28;
k = 100;
ntrees = 500;

load('knnData.mat');
load('testNeighbors.mat');
load('testPreds.mat');
load('trainingPreds.mat');

weightedPreds = zeros(mtest_end-mtest_begin+1,1);
voteWeights = zeros(ntrees);
neighborPreds = zeros(k,ntrees);
y_neighbors = zeros(k);

for i = mtest_begin:mtest_end,
	neighborPreds = pred(neighbors(i,:)',:);
	y_neighbors = y(neighbors(i,:)');
	nTarget = sum(y_neighbors)
	nBackground = k - nTarget;
	
	if nTarget == 0,
		sum(neighborPreds,1)' / k
		voteWeights = ones(ntrees,1) ./ (sum(neighborPreds,1)' / k);
	elseif nTarget == k,
		voteWeights = sum(neighborPreds,1)' / k;
	else,
		for j = 1:ntrees,
			voteWeights(j) = AUC(neighborPreds(:,j),y_neighbors,nTarget,nBackground);
		endfor
	end
	voteWeights = voteWeights / sum(voteWeights);
	voteWeights
	weightedPreds(i-mtest_begin+1) = testpred(i,:) * voteWeights
	if mod(i,100) == 0,
		i
		fflush(stdout);
	endif
endfor

%csvwrite('weightedpreds1.csv',[linspace(mtest_begin,mtest_end,mtest_end-mtest_begin+1)' , weightedPreds]);
