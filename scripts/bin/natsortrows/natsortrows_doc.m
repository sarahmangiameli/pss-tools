%% NATSORTROWS Examples
% The function <https://www.mathworks.com/matlabcentral/fileexchange/47433
% |NATSORTROWS|> sorts the rows of an array (cell/string/categorical/table)
% taking into account number values within the text. This is known as
% _natural order_ or _alphanumeric order_. Note that MATLAB's inbuilt
% <https://www.mathworks.com/help/matlab/ref/sortrows.html |SORTROWS|>
% function sorts text by character code.
%
% To sort filenames, foldernames, or filepaths use
% <https://www.mathworks.com/matlabcentral/fileexchange/47434 |NATSORTFILES|>.
%
% To sort the elements of a string/cell/categorical array use
% <https://www.mathworks.com/matlabcentral/fileexchange/34464 |NATSORT|>.
%
%% Basic Usage:
% By default |NATSORTROWS| interprets consecutive digits as being part of
% a single integer, any remaining substrings are treated as text.
X = {'A2','X';'A10','Y';'A10','X';'A1','X'};
sortrows(X) % Wrong number order
natsortrows(X) % Correct number order
%% Input 1: Array to Sort
% The first input must be one of the following array types:
%
% * a character matrix,
% * a cell array of character row vectors,
% * a cell array with columns consisting either exclusively of character row
% vectors or exclusively of numeric scalars: see |"SortNum"| option below.
% * a <https://www.mathworks.com/help/matlab/ref/table.html table array>,
% * a <https://www.mathworks.com/help/matlab/matlab_prog/create-string-arrays.html string array>,
% * a <https://www.mathworks.com/help/matlab/categorical-arrays.html categorical array>,
% * any other array type that can be converted by
%   <https://www.mathworks.com/help/matlab/ref/cellstr.html |CELLSTR|>
%
% The first input must be a matrix (i.e. two dimensions only).
%
% The sorted array is returned as the first output argument, for example:
A = {'B','2','X';'A','100','X';'B','10','X';'A','2','Y';'A','20','X'};
natsortrows(categorical(A)) % see also REORDERCATS
%% Input 2: Regular Expression
% The optional second input argument is a regular expression which
% specifies the number matching (see "Regular Expressions" section below):
B = {'1.3','X';'1.10','X';'1.2','X'}
natsortrows(B) % By default match integers only.
natsortrows(B, '\d+\.?\d*') % Match decimal fractions.
%% Input 3+: Specify the Columns to Sort
% If required the columns to be sorted may be specified using one of:
%
% * Logical vector of indices into the columns of the input array.
% * Numeric vector of indices into the columns of the input array, where a
%   positive integer sorts the corresponding column in ascending order, and
%   a negative integer sorts the corresponding column in descending order.
%   This corresponds to |SORTROWS| |columns| option.
%
% For example, the second column is sorted ascending and the third descending:
sortrows(A, [2,-3]) % Wrong number order.
natsortrows(A, [], [2,-3]) % Correct number order.
%% Input 3+: Specify the Sort Directions
% |SORTROWS| |direction| option is supported, where a cell array of the
% character vectors |'ascend'|, |'descend'|, and/or |'ignore'| specify the
% sort directions of the columns to be sorted (this means either all of
% the columns or the columns specified by the |column| or |vars| option).
%
% In these examples the second column is sorted ascending and the third descending:
natsortrows(A, [], [2,3], {'ascend','descend'})
natsortrows(A, [], [false,true,true], {'ascend','descend'})
natsortrows(A, [], {'ignore','ascend','descend'})
%% Input 3+: Table Row Names
% |SORTROWS| |'RowNames'| option is supported for tables, either as the
% literal text |'RowNames'| or as the name of table's first dimension
% (i.e. |SORTROWS| |rowDimName| option).
T = cell2table(A,'RowNames',{'R20','R1','R10','R2','R9'},'VariableNames',{'V1','V2','V3'})
natsortrows(T, [], 'RowNames')
natsortrows(T, [], 'Row') % First Dimension Name
%% Input 3+: Table Variable Names
% |SORTROWS| |vars| option is supported for tables, i.e. one of:
%
% * a logical or numeric vector of indices into the table variables.
% * the name of one table variable to sort by.
% * a cell array of one or more names of the table variables to sort by.
natsortrows(T, [], {'V2','V3'},{'ascend','descend'})
natsortrows(T, [], [2,3], {'ascend','descend'})
%% Input 3+: Numeric Scalars in a Cell Array
% When sorting a cell array any columns consisting exclusively of numeric
% or logical scalars may be sorted by selecting the |'SortNum'| option.
%
% An example of a mixed cell array, where 1st column consists entirely of
% character row vectors and 2nd column consists entirely of numeric scalars:
C = {'A2',2;'A10',1;'A2',1}
natsortrows(C,[],'SortNum')
%% Inputs 3+: Optional Arguments
% Further inputs are passed directly to |NATSORT|, thus giving control
% over the case sensitivity, sort direction, and other options. See the
% |NATSORT| help for explanations and examples of the supported options:
D = {'B','X';'10','X';'1','X';'A','X';'2','X'}
natsortrows(D, [], 'descend')
natsortrows(D, [], 'char<num')
%% Output 2: Sort Index
% The second output argument is a numeric array of the sort indices |ndx|,
% such that |Y = X(ndx,:)| where  for |Y = natsortrows(X)|:
E = {'abc2xyz','Y';'abc10xy99','X';'abc2xyz','X';'abc1xyz','X'}
[out,ndx] = natsortrows(E)
%% Output 3: Debugging Array
% The third output is a cell vector of cell arrays, where the cell arrays
% correspond to the columns of the input cell array |X|.
% The cell arrays contain all matched numbers (after converting to
% numeric using the specified |SSCANF| format) and all non-number
% substrings. These cell arrays are useful for confirming that the
% numbers are being correctly identified by the regular expression.
[~,~,dbg] = natsortrows(E);
dbg{:}
%% Regular Expression: Decimal Fractions, E-notation, +/- Sign.
% |NATSORTROWS| number matching can be customized to detect numbers with
% a decimal fraction, E-notation, a +/- sign, binary/hexadecimal, or other
% required features. The number matching is specified using an
% appropriate regular expression, see |NATSORT| for details and examples.
F = {'v10.2','b'; 'v2.5','b'; 'v2.40','a'; 'v1.9','b'}
natsortrows(F) % by default match integers, e.g. version numbers.
natsortrows(F,'\d+\.?\d*') % match decimal fractions.
%% Bonus: Interactive Regular Expression Tool
% Regular expressions are powerful and compact, but getting them right is
% not always easy. One assistance is to download my interactive tool
% <https://www.mathworks.com/matlabcentral/fileexchange/48930 |IREGEXP|>,
% which lets you quickly try different regular expressions and see all of
% <https://www.mathworks.com/help/matlab/ref/regexp.html |REGEXP|>'s
% outputs displayed and updated as you type.