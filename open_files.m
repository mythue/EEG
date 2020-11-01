function [data] = open_files()
 % Prompt user for filename
   [fname, fdir] = uigetfile( ...
   {'*.csv', 'CSV Files (*.csv)'; ...
   '*.xlsx', 'Excel Files (*.xlsx)'; ...
   '*.txt*', 'Text Files (*.txt*)'}, ...
   'Pick a file');

 % Create fully-formed filename as a string
   filename = fullfile(fdir, fname);

 % Check that file exists
   assert(exist(filename, 'file') == 2, '%s does not exist.', filename);

 % Read in the data, skipping the first row (lebal)
   data = csvread(filename,1,0);
end