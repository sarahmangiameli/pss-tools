function natsortrows_test()
% Test function for NATSORTROWS.
%
% (c) 2014-2022 Stephen Cobeldick
%
% See also NATSORTROWS TESTFUN NATSORT_TEST NATSORTFILES_TEST

fnh = @natsortrows;
chk = testfun(fnh);
%
try categorical(0); isc=true; catch isc=false; warning('No categorical class.'), end %#ok<WNTAG,CTCH>
try cell2table({}); ist=true; catch ist=false; warning('No (time)table class.'), end %#ok<WNTAG,CTCH>
try pad(strings()); iss=true; catch iss=false; warning('No string class.'), end %#ok<CTCH,WNTAG>
%
if iss
	txf = @string;
else
	txf = @cellstr;
end
%
%% Mfile Examples %%
%
chk(txf({'A2','X';'A10','Y';'A10','X';'A1','X'}), fnh,... X
	txf({'A1','X';'A2','X';'A10','X';'A10','Y'}))
%
A = {'B','2','X';'A','100','X';'B','10','X';'A','2','Y';'A','20','X'};
Z = {'A','2','Y';'B','2','X';'B','10','X';'A','20','X';'A','100','X'};
chk(A, fnh,...
	{'A','2','Y';'A','20','X';'A','100','X';'B','2','X';'B','10','X'})
chk(A, [], 'ascend', fnh,... not in help
	{'A','2','Y';'A','20','X';'A','100','X';'B','2','X';'B','10','X'})
chk(A, [], 'descend', fnh,...
	{'B','10','X';'B','2','X';'A','100','X';'A','20','X';'A','2','Y'})
chk(A, [], [2,-3], fnh, Z)
chk(A, [], [false,true,true], {'ascend','descend'}, fnh, Z)
chk(A, [], {'ascend','descend'}, [false,true,true], fnh, Z) % not in help
chk(A, [], {'ignore','ascend','descend'}, fnh, Z)
%
if ist
	T = cell2table(A);
	chk(T, [], [2,-3], fnh, T([4,1,3,5,2],:))
	chk(T, [], [2,-3], fnh, T([4,1,3,5,2],:), [4;1;3;5;2]) % not in help
	chk(T, [], {'A2','A3'},{'ascend','descend'}, fnh, T([4,1,3,5,2],:))
	chk(T, [], {'A2','A3'},{'ascend','descend'}, fnh, T([4,1,3,5,2],:), [4;1;3;5;2]) % not in help
end
%
B = {'ABCD';'3e45';'67.8';'+Inf';'-12';'+9';'NaN'};
chk(B, '[-+]?(NaN|Inf|\d+\.?\d*(E[-+]?\d+)?)', fnh,...
	{'-12';'+9';'67.8';'3e45';'+Inf';'NaN';'ABCD'})
%
C = {'A2',2;'A10',1;'A2',1};
chk(C, [], 'sortnum', fnh, {'A2',1;'A2',2;'A10',1})
chk(C, [], 'sortnum', {'ascend','descend'}, fnh, {'A2',2;'A2',1;'A10',1})
%
%% HTML Examples %%
%
X = {'A2','X';'A10','Y';'A10','X';'A1','X'};
chk(X, fnh, {'A1','X';'A2','X';'A10','X';'A10','Y'})
%
A = {'B','2','X';'A','100','X';'B','10','X';'A','2','Y';'A','20','X'};
if isc
	chk(categorical(A), fnh, categorical(...
		{'A','2','Y';'A','20','X';'A','100','X';'B','2','X';'B','10','X'}))
end
chk(A, fnh, @i, [4;5;2;1;3]) % not in help
chk(A, fnh, @i, @i, {{'B';'A';'B';'A';'A'},{2;100;10;2;20},{'X';'X';'X';'Y';'X'}}) % not in help
%
B =                      {'1.3','X';'1.10','X';'1.2','X'};
chk(B,              fnh, {'1.2','X';'1.3','X';'1.10','X'}, [3;1;2])
chk(B, '\d+\.?\d*', fnh, {'1.10','X';'1.2','X';'1.3','X'}, [2;3;1])
%
Z = {'A','2','Y';'B','2','X';'B','10','X';'A','20','X';'A','100','X'};
chk(A, [], [2,-3], fnh, Z, [4;1;3;5;2])
chk(A, [], [2,3], {'ascend','descend'}, fnh, Z, [4;1;3;5;2])
chk(A, [], [false,true,true], {'ascend','descend'}, fnh, Z, [4;1;3;5;2])
chk(A, [], {'ignore','ascend','descend'}, fnh, Z, [4;1;3;5;2])
%
if ist
	T = cell2table(A,'RowNames',{'R20','R1','R10','R2','R9'},'VariableNames',{'V1','V2','V3'});
	chk(T, [], 'Row',      fnh, T([2,4,5,3,1],:), [2;4;5;3;1]) % First Dimension Name
	chk(T, [], 'RowNames', fnh, T([2,4,5,3,1],:), [2;4;5;3;1])
	chk(T, [], {'V2','V3'},{'ascend','descend'}, fnh, T([4,1,3,5,2],:), [4;1;3;5;2])
	chk(T, [],       [2,3],{'ascend','descend'}, fnh, T([4,1,3,5,2],:), [4;1;3;5;2])
	chk(T, [],    {'ignore','ascend','descend'}, fnh, T([4,1,3,5,2],:), [4;1;3;5;2]) % not in help
end
%
C = {'A2',2;'A10',1;'A2',1};
chk(C, [], 'sortnum', fnh, {'A2',1;'A2',2;'A10',1})
%
D = {'B','X';'10','X';'1','X';'A','X';'2','X'};
chk(D, [],  'descend', fnh, {'B','X';'A','X';'10','X';'2','X';'1','X'}, [1;4;2;5;3])
chk(D, [], 'char<num', fnh, {'A','X';'B','X';'1','X';'2','X';'10','X'}, [4;1;3;5;2])
%
E = {'abc2xyz','Y';'abc10xy99','X';'abc2xyz','X';'abc1xyz','X'};
chk(E, fnh, {'abc1xyz','X';'abc2xyz','X';'abc2xyz','Y';'abc10xy99','X'}, [4;3;1;2])
chk(E, fnh, {'abc1xyz','X';'abc2xyz','X';'abc2xyz','Y';'abc10xy99','X'}, [4;3;1;2], ...
	{{'abc',2,'xyz',[];'abc',10,'xy',99;'abc',2,'xyz',[];'abc',1,'xyz',[]},...
	{'Y';'X';'X';'X'}})
%
F = {'v10.2','b';'v2.5','b';'v2.40','a';'v1.9','b'};
chk(F,              fnh, {'v1.9','b';'v2.5','b';'v2.40','a';'v10.2','b'}, [4;2;3;1])
chk(F, '\d+\.?\d*', fnh, {'v1.9','b';'v2.40','a';'v2.5','b';'v10.2','b'}, [4;3;2;1])
%
%% Index Stability %%
%
rmf = @(s,r,c)repmat({s},r,c);
chk(rmf('',0,1), fnh, rmf('',0,1), (1:0).', {cell(0,0)})
chk(rmf('',1,1), fnh, rmf('',1,1), (1:1).', {cell(1,0)})
chk(rmf('',2,1), fnh, rmf('',2,1), (1:2).', {cell(2,0)})
chk(rmf('',3,1), fnh, rmf('',3,1), (1:3).', {cell(3,0)})
chk(rmf('',4,1), fnh, rmf('',4,1), (1:4).', {cell(4,0)})
chk(rmf('',5,1), fnh, rmf('',5,1), (1:5).', {cell(5,0)})
chk(rmf('',6,1), fnh, rmf('',6,1), (1:6).', {cell(6,0)})
chk(rmf('',7,1), fnh, rmf('',7,1), (1:7).', {cell(7,0)})
chk(rmf('',8,1), fnh, rmf('',8,1), (1:8).', {cell(8,0)})
chk(rmf('',9,1), fnh, rmf('',9,1), (1:9).', {cell(9,0)})
chk(rmf('',0,1), [],  'ascend', fnh, rmf('',0,1), (1:0).', {cell(0,0)})
chk(rmf('',1,1), [],  'ascend', fnh, rmf('',1,1), (1:1).', {cell(1,0)})
chk(rmf('',2,1), [],  'ascend', fnh, rmf('',2,1), (1:2).', {cell(2,0)})
chk(rmf('',3,1), [],  'ascend', fnh, rmf('',3,1), (1:3).', {cell(3,0)})
chk(rmf('',4,1), [],  'ascend', fnh, rmf('',4,1), (1:4).', {cell(4,0)})
chk(rmf('',5,1), [],  'ascend', fnh, rmf('',5,1), (1:5).', {cell(5,0)})
chk(rmf('',6,1), [],  'ascend', fnh, rmf('',6,1), (1:6).', {cell(6,0)})
chk(rmf('',7,1), [],  'ascend', fnh, rmf('',7,1), (1:7).', {cell(7,0)})
chk(rmf('',8,1), [],  'ascend', fnh, rmf('',8,1), (1:8).', {cell(8,0)})
chk(rmf('',9,1), [],  'ascend', fnh, rmf('',9,1), (1:9).', {cell(9,0)})
chk(rmf('',0,1), [], 'descend', fnh, rmf('',0,1), (1:0).', {cell(0,0)})
chk(rmf('',1,1), [], 'descend', fnh, rmf('',1,1), (1:1).', {cell(1,0)})
chk(rmf('',2,1), [], 'descend', fnh, rmf('',2,1), (1:2).', {cell(2,0)})
chk(rmf('',3,1), [], 'descend', fnh, rmf('',3,1), (1:3).', {cell(3,0)})
chk(rmf('',4,1), [], 'descend', fnh, rmf('',4,1), (1:4).', {cell(4,0)})
chk(rmf('',5,1), [], 'descend', fnh, rmf('',5,1), (1:5).', {cell(5,0)})
chk(rmf('',6,1), [], 'descend', fnh, rmf('',6,1), (1:6).', {cell(6,0)})
chk(rmf('',7,1), [], 'descend', fnh, rmf('',7,1), (1:7).', {cell(7,0)})
chk(rmf('',8,1), [], 'descend', fnh, rmf('',8,1), (1:8).', {cell(8,0)})
chk(rmf('',9,1), [], 'descend', fnh, rmf('',9,1), (1:9).', {cell(9,0)})
%
U = {'2';'3';'2';'1';'2'};
chk(U, [], 'ascend', fnh,...
	{'1';'2';'2';'2';'3'}, [4;1;3;5;2])
chk(U, [], 'descend', fnh,...
	{'3';'2';'2';'2';'1'}, [2;1;3;5;4])
%
V = {'x';'z';'y';'';'z';'';'x';'y'};
chk(V, [], 'ascend', fnh,...
	{'';'';'x';'x';'y';'y';'z';'z'},[4;6;1;7;3;8;2;5])
chk(V, [], 'descend', fnh,...
	{'z';'z';'y';'y';'x';'x';'';''},[2;5;3;8;1;7;4;6])
%
W = {'2x';'2z';'2y';'2';'2z';'2';'2x';'2y'};
chk(W, [], 'ascend', fnh,...
	{'2';'2';'2x';'2x';'2y';'2y';'2z';'2z'},[4;6;1;7;3;8;2;5])
chk(W, [], 'descend', fnh,...
	{'2z';'2z';'2y';'2y';'2x';'2x';'2';'2'},[2;5;3;8;1;7;4;6])
%
%% Column & Direction %%
%
inpA = {'B','2','X';'A','100','X';'B','10','X';'A','2','Y';'A','20','X'};
idaB = {'A','100','X';'A','20','X';'B','10','X';'B','2','X';'A','2','Y'};
iiiX = [1;2;3;4;5];
chk(inpA, [], 'ignore', fnh, inpA, iiiX)
chk(inpA, [], [-2,-3], {'ignore','ignore'}, fnh, inpA, iiiX)
chk(inpA, [], {'ignore','ignore','ignore'}, fnh, inpA, iiiX)
idaX = [2;5;3;1;4];
chk(inpA, [], [-2,+3], fnh, idaB, idaX)
chk(inpA, [], [-2,-3], {'descend','ascend'}, fnh, idaB, idaX)
chk(inpA, [], [+2,+3], {'descend','ascend'}, fnh, idaB, idaX)
chk(inpA, [], {'descend','ascend'}, [+2,-3], fnh, idaB, idaX)
chk(inpA, [], [false,true,true], {'descend','ascend'}, fnh, idaB, idaX)
chk(inpA, [], {'descend','ascend'}, [false,true,true], fnh, idaB, idaX)
chk(inpA, [], {'ignore','descend','ascend'}, fnh, idaB, idaX)
aaiB = {'A','2','Y';'A','20','X';'A','100','X';'B','2','X';'B','10','X'};
ddiB = {'B','10','X';'B','2','X';'A','100','X';'A','20','X';'A','2','Y'};
chk(inpA, [], [true,true], fnh, aaiB)
chk(inpA, [], 'ascend', [true,true], fnh, aaiB)
chk(inpA, [], [true,true], 'ascend', fnh, aaiB)
chk(inpA, [], [true,true], {'ascend','ascend'}, fnh, aaiB)
chk(inpA, [], 'descend', [true,true], fnh, ddiB)
chk(inpA, [], [true,true], 'descend', fnh, ddiB)
chk(inpA, [], [true,true], {'descend','descend'}, fnh, ddiB)
chk(inpA, [], [+1,+2], fnh, aaiB)
chk(inpA, [], 'ascend', [+1,+2], fnh, aaiB)
chk(inpA, [], [+1,+2], 'ascend', fnh, aaiB)
chk(inpA, [], [+1,+2], {'ascend','ascend'}, fnh, aaiB)
chk(inpA, [], 'descend', [+1,+2], fnh, ddiB)
chk(inpA, [], [+1,+2], 'descend', fnh, ddiB)
chk(inpA, [], [+1,+2], {'descend','descend'}, fnh, ddiB)
%
%% SORTROWS Examples %%
%
% <https://www.mathworks.com/help/matlab/ref/double.sortrows.html>
%
n2c = @(C) cellfun(@num2str,C,'uni',0);
%
AN = {95,27,95,79,67,70,69;95,7,48,95,75,3,31;95,7,48,65,74,27,95;95,7,14,3,39,4,3;76,15,42,84,65,9,43;76,97,91,93,17,82,38};
AC = n2c(AN);
BN = {76,15,42,84,65,9,43;76,97,91,93,17,82,38;95,7,14,3,39,4,3;95,7,48,65,74,27,95;95,7,48,95,75,3,31;95,27,95,79,67,70,69};
BC = n2c(BN);
CN = {95,7,48,95,75,3,31;95,7,48,65,74,27,95;95,7,14,3,39,4,3;76,15,42,84,65,9,43;95,27,95,79,67,70,69;76,97,91,93,17,82,38};
CC = n2c(CN);
DN = {76,97,91,93,17,82,38;76,15,42,84,65,9,43;95,7,14,3,39,4,3;95,7,48,95,75,3,31;95,27,95,79,67,70,69;95,7,48,65,74,27,95};
DC = n2c(DN);
EN = {95,7,48,95,75,3,31;76,97,91,93,17,82,38;76,15,42,84,65,9,43;95,27,95,79,67,70,69;95,7,48,65,74,27,95;95,7,14,3,39,4,3};
EC = n2c(EN);
%
% Numeric:
chk(AN, [], 'sortnum', fnh, BN)
chk(AN, [], 'sortnum', 2, fnh, CN)
chk(AN, [], 'sortnum', [false,true], fnh, CN) % not in help
chk(AN, [], 'sortnum', [1,7], fnh, DN)
chk(AN, [], 'sortnum', [true,false(1,5),true], fnh, DN) % not in help
chk(AN, [], 'sortnum', -4, fnh, EN, [2;6;5;1;3;4]) % not in help
chk(AN, [], 'sortnum', 4, 'descend', fnh, EN, [2;6;5;1;3;4])
chk(AN, [], 'sortnum', [false(1,3),true], 'descend', fnh, EN, [2;6;5;1;3;4]) % not in help
chk(AN, [], 'sortnum', {'ignore','ignore','ignore','descend','ignore','ignore','ignore'}, fnh, EN, [2;6;5;1;3;4]) % not in help
% Character:
chk(AC, fnh, BC)
chk(AC, [], 2, fnh, CC)
chk(AC, [], [false,true], fnh, CC) % not in help
chk(AC, [], [1,7], fnh, DC)
chk(AC, [], [true,false(1,5),true], fnh, DC) % not in help
chk(AC, [], -4, fnh, EC, [2;6;5;1;3;4]) % not in help
chk(AC, [], 4, 'descend', fnh, EC, [2;6;5;1;3;4])
chk(AC, [], [false(1,3),true], 'descend', fnh, EC, [2;6;5;1;3;4]) % not in help
chk(AC, [], 'sortnum', {'ignore','ignore','ignore','descend','ignore','ignore','ignore'}, fnh, EC, [2;6;5;1;3;4]) % not in help
%
if ist
	% Table (modified to char vectors with different numbers of digits but same order):
	LastName = {'Smith';'Johnson';'Williams';'Jones';'Brown'};
	Age = {'38';'243';'38';'140';'1049'};
	Height = {'1071';'269';'64';'167';'64'};
	Weight = {'1076';'363';'131';'233';'19'};
	BloodPressure = {'124','93';'109','77';'125','83';'117','75';'122','80'};
	%BloodPressure = [124,93;109,77;125,83;117,75;122,80];
	tblA = table(Age,Height,Weight,BloodPressure,'RowNames',LastName);
	%
	chk(tblA, fnh, tblA([3,1,4,2,5],:))
	chk(tblA,[],'RowNames', fnh, tblA([5,2,4,1,3],:), [5;2;4;1;3]);
	chk(tblA,[],{'Height','Weight'},{'ascend','descend'}, fnh, tblA([3,5,4,2,1],:))
end
%
%% Table Systematic One %%
%
if ist
	%
	chk(tblA, [], 'ignore', fnh, tblA)
	chk(tblA, [], {'ignore','ignore','ignore','ignore'}, fnh, tblA)
	%
	X1a = [1,3,4,2,5];
	X1d = [5,2,4,1,3];
	X2a = [3,5,4,2,1];
	X2d = [1,2,4,3,5];
	X3a = [5,3,4,2,1];
	X3d = [1,2,4,3,5];
	%
	chk(tblA,[], +1, fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[], +2, fnh, tblA(X2a,:), X2a(:));
	chk(tblA,[], +3, fnh, tblA(X3a,:), X3a(:));
	chk(tblA,[], -1, fnh, tblA(X1d,:), X1d(:));
	chk(tblA,[], -2, fnh, tblA(X2d,:), X2d(:));
	chk(tblA,[], -3, fnh, tblA(X3d,:), X3d(:));
	%
	chk(tblA,[], -1,  'ascend', fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[], -1, 'descend', fnh, tblA(X1d,:), X1d(:));
	chk(tblA,[], -2,  'ascend', fnh, tblA(X2a,:), X2a(:));
	chk(tblA,[], -2, 'descend', fnh, tblA(X2d,:), X2d(:));
	chk(tblA,[], -3,  'ascend', fnh, tblA(X3a,:), X3a(:));
	chk(tblA,[], -3, 'descend', fnh, tblA(X3d,:), X3d(:));
	chk(tblA,[],  'ascend', -1, fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[], 'descend', -1, fnh, tblA(X1d,:), X1d(:));
	chk(tblA,[],  'ascend', -2, fnh, tblA(X2a,:), X2a(:));
	chk(tblA,[], 'descend', -2, fnh, tblA(X2d,:), X2d(:));
	chk(tblA,[],  'ascend', -3, fnh, tblA(X3a,:), X3a(:));
	chk(tblA,[], 'descend', -3, fnh, tblA(X3d,:), X3d(:));
	%
	chk(tblA,[],    'Age', fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[], 'Height', fnh, tblA(X2a,:), X2a(:));
	chk(tblA,[], 'Weight', fnh, tblA(X3a,:), X3a(:));
	%
	chk(tblA,[],    'Age',  'ascend', fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[],    'Age', 'descend', fnh, tblA(X1d,:), X1d(:));
	chk(tblA,[], 'Height',  'ascend', fnh, tblA(X2a,:), X2a(:));
	chk(tblA,[], 'Height', 'descend', fnh, tblA(X2d,:), X2d(:));
	chk(tblA,[], 'Weight',  'ascend', fnh, tblA(X3a,:), X3a(:));
	chk(tblA,[], 'Weight', 'descend', fnh, tblA(X3d,:), X3d(:));
	chk(tblA,[],  'ascend',    'Age', fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[], 'descend',    'Age', fnh, tblA(X1d,:), X1d(:));
	chk(tblA,[],  'ascend', 'Height', fnh, tblA(X2a,:), X2a(:));
	chk(tblA,[], 'descend', 'Height', fnh, tblA(X2d,:), X2d(:));
	chk(tblA,[],  'ascend', 'Weight', fnh, tblA(X3a,:), X3a(:));
	chk(tblA,[], 'descend', 'Weight', fnh, tblA(X3d,:), X3d(:));
	%
	chk(tblA,[],   true,  'ascend', fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[],   true, 'descend', fnh, tblA(X1d,:), X1d(:));
	chk(tblA,[],  'ascend',   true, fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[], 'descend',   true, fnh, tblA(X1d,:), X1d(:));
	%
	chk(tblA,[], [true,false,false,false],  'ascend', fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[], [true,false,false,false], 'descend', fnh, tblA(X1d,:), X1d(:));
	chk(tblA,[], [false,true,false,false],  'ascend', fnh, tblA(X2a,:), X2a(:));
	chk(tblA,[], [false,true,false,false], 'descend', fnh, tblA(X2d,:), X2d(:));
	chk(tblA,[], [false,false,true,false],  'ascend', fnh, tblA(X3a,:), X3a(:));
	chk(tblA,[], [false,false,true,false], 'descend', fnh, tblA(X3d,:), X3d(:));
	chk(tblA,[],  'ascend', [true,false,false,false], fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[], 'descend', [true,false,false,false], fnh, tblA(X1d,:), X1d(:));
	chk(tblA,[],  'ascend', [false,true,false,false], fnh, tblA(X2a,:), X2a(:));
	chk(tblA,[], 'descend', [false,true,false,false], fnh, tblA(X2d,:), X2d(:));
	chk(tblA,[],  'ascend', [false,false,true,false], fnh, tblA(X3a,:), X3a(:));
	chk(tblA,[], 'descend', [false,false,true,false], fnh, tblA(X3d,:), X3d(:));
	%
	chk(tblA,[], { 'ascend','ignore','ignore','ignore'}, fnh, tblA(X1a,:), X1a(:));
	chk(tblA,[], {'descend','ignore','ignore','ignore'}, fnh, tblA(X1d,:), X1d(:));
	chk(tblA,[], {'ignore', 'ascend','ignore','ignore'}, fnh, tblA(X2a,:), X2a(:));
	chk(tblA,[], {'ignore','descend','ignore','ignore'}, fnh, tblA(X2d,:), X2d(:));
	chk(tblA,[], {'ignore','ignore', 'ascend','ignore'}, fnh, tblA(X3a,:), X3a(:));
	chk(tblA,[], {'ignore','ignore','descend','ignore'}, fnh, tblA(X3d,:), X3d(:));
	%
end
%
%% Table Systematic Two %%
%
if ist
	%
	X1a2a = [3,1,4,2,5];
	X1a2d = [1,3,4,2,5];
	X1a3a = [3,1,4,2,5];
	X1a3d = [1,3,4,2,5];
	X1d2a = [5,2,4,3,1];
	X1d2d = [5,2,4,1,3];
	X1d3a = [5,2,4,3,1];
	X1d3d = [5,2,4,1,3];
	X2a1a = [3,5,4,2,1];
	X2a1d = [5,3,4,2,1];
	X2a3a = [5,3,4,2,1];
	X2a3d = [3,5,4,2,1];
	X2d1a = [1,2,4,3,5];
	X2d1d = [1,2,4,5,3];
	X2d3a = [1,2,4,5,3];
	X2d3d = [1,2,4,3,5];
	X3a1a = [5,3,4,2,1];
	X3a1d = [5,3,4,2,1];
	X3a2a = [5,3,4,2,1];
	X3a2d = [5,3,4,2,1];
	X3d1a = [1,2,4,3,5];
	X3d1d = [1,2,4,3,5];
	X3d2a = [1,2,4,3,5];
	X3d2d = [1,2,4,3,5];
	%
	chk(tblA, [], [+1,+2], fnh, tblA(X1a2a,:), X1a2a(:))
	chk(tblA, [], [+1,-2], fnh, tblA(X1a2d,:), X1a2d(:))
	chk(tblA, [], [+1,+3], fnh, tblA(X1a3a,:), X1a3a(:))
	chk(tblA, [], [+1,-3], fnh, tblA(X1a3d,:), X1a3d(:))
	chk(tblA, [], [-1,+2], fnh, tblA(X1d2a,:), X1d2a(:))
	chk(tblA, [], [-1,-2], fnh, tblA(X1d2d,:), X1d2d(:))
	chk(tblA, [], [-1,+3], fnh, tblA(X1d3a,:), X1d3a(:))
	chk(tblA, [], [-1,-3], fnh, tblA(X1d3d,:), X1d3d(:))
	chk(tblA, [], [+2,+1], fnh, tblA(X2a1a,:), X2a1a(:))
	chk(tblA, [], [+2,-1], fnh, tblA(X2a1d,:), X2a1d(:))
	chk(tblA, [], [+2,+3], fnh, tblA(X2a3a,:), X2a3a(:))
	chk(tblA, [], [+2,-3], fnh, tblA(X2a3d,:), X2a3d(:))
	chk(tblA, [], [-2,+1], fnh, tblA(X2d1a,:), X2d1a(:))
	chk(tblA, [], [-2,-1], fnh, tblA(X2d1d,:), X2d1d(:))
	chk(tblA, [], [-2,+3], fnh, tblA(X2d3a,:), X2d3a(:))
	chk(tblA, [], [-2,-3], fnh, tblA(X2d3d,:), X2d3d(:))
	chk(tblA, [], [+3,+1], fnh, tblA(X3a1a,:), X3a1a(:))
	chk(tblA, [], [+3,-1], fnh, tblA(X3a1d,:), X3a1d(:))
	chk(tblA, [], [+3,+2], fnh, tblA(X3a2a,:), X3a2a(:))
	chk(tblA, [], [+3,-2], fnh, tblA(X3a2d,:), X3a2d(:))
	chk(tblA, [], [-3,+1], fnh, tblA(X3d1a,:), X3d1a(:))
	chk(tblA, [], [-3,-1], fnh, tblA(X3d1d,:), X3d1d(:))
	chk(tblA, [], [-3,+2], fnh, tblA(X3d2a,:), X3d2a(:))
	chk(tblA, [], [-3,-2], fnh, tblA(X3d2d,:), X3d2d(:))
	%
	%% Systematic Cell Array %%
	%
	txtA = tblA{:,1:3};
	%
	chk(txtA, [], 'ignore', fnh, txtA)
	chk(txtA, [], {'ignore','ignore','ignore'}, fnh, txtA)
	%
	chk(txtA, [], [+1,+2], fnh, txtA(X1a2a,:), X1a2a(:))
	chk(txtA, [], [+1,-2], fnh, txtA(X1a2d,:), X1a2d(:))
	chk(txtA, [], [+1,+3], fnh, txtA(X1a3a,:), X1a3a(:))
	chk(txtA, [], [+1,-3], fnh, txtA(X1a3d,:), X1a3d(:))
	chk(txtA, [], [-1,+2], fnh, txtA(X1d2a,:), X1d2a(:))
	chk(txtA, [], [-1,-2], fnh, txtA(X1d2d,:), X1d2d(:))
	chk(txtA, [], [-1,+3], fnh, txtA(X1d3a,:), X1d3a(:))
	chk(txtA, [], [-1,-3], fnh, txtA(X1d3d,:), X1d3d(:))
	chk(txtA, [], [+2,+1], fnh, txtA(X2a1a,:), X2a1a(:))
	chk(txtA, [], [+2,-1], fnh, txtA(X2a1d,:), X2a1d(:))
	chk(txtA, [], [+2,+3], fnh, txtA(X2a3a,:), X2a3a(:))
	chk(txtA, [], [+2,-3], fnh, txtA(X2a3d,:), X2a3d(:))
	chk(txtA, [], [-2,+1], fnh, txtA(X2d1a,:), X2d1a(:))
	chk(txtA, [], [-2,-1], fnh, txtA(X2d1d,:), X2d1d(:))
	chk(txtA, [], [-2,+3], fnh, txtA(X2d3a,:), X2d3a(:))
	chk(txtA, [], [-2,-3], fnh, txtA(X2d3d,:), X2d3d(:))
	chk(txtA, [], [+3,+1], fnh, txtA(X3a1a,:), X3a1a(:))
	chk(txtA, [], [+3,-1], fnh, txtA(X3a1d,:), X3a1d(:))
	chk(txtA, [], [+3,+2], fnh, txtA(X3a2a,:), X3a2a(:))
	chk(txtA, [], [+3,-2], fnh, txtA(X3a2d,:), X3a2d(:))
	chk(txtA, [], [-3,+1], fnh, txtA(X3d1a,:), X3d1a(:))
	chk(txtA, [], [-3,-1], fnh, txtA(X3d1d,:), X3d1d(:))
	chk(txtA, [], [-3,+2], fnh, txtA(X3d2a,:), X3d2a(:))
	chk(txtA, [], [-3,-2], fnh, txtA(X3d2d,:), X3d2d(:))
	%
end
%
chk() % display summary
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsortrows_test