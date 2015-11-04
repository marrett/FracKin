
% TO DO:
%
% CONCEPTUAL:
% analysis of residuals:
% determine uncertainty cones ?
% determine contour lines ?
%
% analysis of vorticity ?
%
% GUI:
% feature list to toggle on/off:
%	fracture-by-fracture list
% graphical elements to toggle on/off
%	fracture planes and movement directions
%	movement planes ? (normal to int. axis)
%	individual kinematic axes
%	population principal axes
%	best-fit eliptical cones of zero strain ?
%	contour lines ?
%
% select subset of input data
%
% control size of graphics window


% DONE:
%
% fix abort segments of code
%
% add buttons for save numerical results and quit
%
% disambiguate implicated senses of movement
%
% add user feedback regarding ambiguous input data
%
% trap ambiguous cases for sense of movement
% and account for special cases
%
% add user feedback regarding format of input data
%
% vectorize numerical code
%
% plot intermediate axes (black)
%
% color-code shortening (red) and extension (green)
% with saturation value as a function of eigenvalue


% FracKin v 1.2, Randall Marrett copyright 2015
% saved 6 June 2015
%
% execute analysis using the following observations:
% fracture strike/dip, movement direction trend/plunge, sense of movement;
% input fracture strike must be reported using right-hand rule;
% input movement direction must be reported in lower hemisphere;
% observation regarding sense of movement (SoM):
%	T = thrust slip (default)
%	N = normal slip
%	R = right slip
%	L = left slip
%	O = opening movement
%	C = closing movement
%
% execute analysis with the following assumptions:
% assume infinitesimal strain theory;
% assume scale-invariant kinematics
%	(i.e., ignore movement magnitudes of individual fractures)
%
% note: for a general fracture orientation and movement direction, 
% any one of the six SoM indicators uniquely constrains kinematics; 
% however, there are situations where two or more SoM input are ambiguous: 
% T or N are ambiguous if resolved shear on a fracture is horizontal; 
% R or L are ambiguous if movement plane is vertical; 
% O or C are ambiguous if movement direction parallels fracture
%
% note: footwall is ambiguous in the case of vertical fractures; 
% input of 90° dip will NOT crash FracKin, but such fractures WILL have 
% a 50% likelihood for shortening and extension axes to be interchanged; 
% the problem can be averted by input of 89.9° dip; 
% if a tenth of a degree matters, then you must be up to evil;
% sense of shear is ambiguous in the case of horizontal fractures; 
% input of 0° dip will NOT crash FracKin, and input of O or C works okay, 
% but input of T N R or L movement WILL result in a 50% likelihood 
% for shortening and extension axes to be interchanged; 
% the problem can be averted by input of 0.1° dip; 
% if a 1° difference substantially changes your interpretation, 
% then you probably are up to no good


% clear memory before starting
clear
Abort = 0;

% record the directory containing FracKin.m
originalpath = cd;

% open input file and read data
[inputfile, inputpath] = uigetfile('*.txt', 'Choose an INPUT .txt file:');
[inputID, message] = fopen([inputpath, inputfile], 'r');
if inputID == -1
	disp(message)
end

clear message;

Bedding = fscanf(inputID, '%g %g %g %g %g', [5 1]);
input = fscanf(inputID, '%g %g %g %g %s', [5 inf]);
input = input';

% check for aborted fscanf due to non-numeric input
Test = textscan(inputID, '%s');
TestSize = size(Test{1,1});
Test = TestSize(1,1);

% close input file
fclose(inputID);

% display a dialog box reporting to user about problems reading input file:
if  Test ~= 0
	
	Oops = figure('Name', 'Oops ...', 'NumberTitle', 'off');
	
	message1 = sprintf('One or more of your input values has the wrong format.  You might have opened the wrong file.');
	
	h(1) = uicontrol('Style', 'text', ...
		'Position', [20 365 520 35], ...
		'String', message1, ...
		'FontSize', 14, ...
		'HorizontalAlignment', 'left', ...
		'BackgroundColor', [0.8 0.8 0.8]);
	
	message2 = sprintf('If you are unfamiliar with FracKin, then you should read the requirements below for input files.');
	
	h(2) = uicontrol('Style', 'text', ...
		'Position', [20 310 520 35], ...
		'String', message2, ...
		'FontSize', 14, ...
		'HorizontalAlignment', 'left', ...
		'BackgroundColor', [0.8 0.8 0.8]);
	
	message3 = sprintf('Each line of the input xxx.txt file represents an individual fracture.  Four numbers and a single letter (all space or tab delimited) define fracture kinematics, in the following order: strike of fracture surface (right-hand rule), dip of fracture surface, trend of movement direction (lower hemisphere), plunge of movement direction.  The trailing letter must be T (thrust slip), N (normal slip), R (right slip), L (left slip), O (opening movement), or C (closing movement).  Here are a couple of examples:');
	
	h(3) = uicontrol('Style', 'text', ...
		'Position', [20 180 520 110], ...
		'String', message3, ...
		'FontSize', 14, ...
		'HorizontalAlignment', 'left', ...
		'BackgroundColor', [0.8 0.8 0.8]);
	
	message4 = sprintf('110	80	100	20	R');

	h(4) = uicontrol('Style', 'text', ...
		'Position', [20 140 520 20], ...
		'String', message4, ...
		'FontSize', 14, ...
		'HorizontalAlignment', 'left', ...
		'BackgroundColor', [0.8 0.8 0.8]);
	
	message5 = sprintf('190	60	0	17	L');
	
	h(5) = uicontrol('Style', 'text', ...
		'Position', [20 120 520 20], ...
		'String', message5, ...
		'FontSize', 14, ...
		'HorizontalAlignment', 'left', ...
		'BackgroundColor', [0.8 0.8 0.8]);
	
	h(6) = uicontrol('Position', [20 20 250 40], ...
		'String', 'Save Instructions', ...
		'FontSize', 14, ...
		'Callback', 'uiresume(gcbf)');
	
	h(7) = uicontrol('Position', [290 20 250 40], ...
		'String', 'Abort', ...
		'FontSize', 14, ...
		'Callback', 'Abort = 1; uiresume(gcbf)');
	
	uiwait(gcf);
	
	close(gcf);
	
	if Abort == 1
		clear Oops h message1 message2 message3 message4 message5;
		cd(originalpath);
		return;
	end
	
	
	% write FracKin instructions in output text file:
	
	% change directory to source of input
	cd(inputpath);
	
	% open output file for FracKin instructions
	[outputfile, outputpath] = uiputfile('FracKin_info.txt', ...
		'Choose an OUTPUT file for FracKin instructions:');
	[outputID, message] = fopen([outputpath, outputfile], 'a');
	if outputID == -1
		disp(message)
		return;
	end
	
	% write FracKin instructions in output text file
	fprintf(outputID, '%s\n\n', message1);
	fprintf(outputID, '%s\n\n', message2);
	fprintf(outputID, '%s\n\n', message3);
	fprintf(outputID, '%s\n', message4);
	fprintf(outputID, '%s\n', message5);
	
	fprintf(outputID, '\n\n');
	
	clear Oops h message message1 message2 message3 message4 message5;
	
	% close output file
	fclose(outputID);
	
	% reset directory to original
	cd(originalpath);
	
	% stop program
	clear Test TestSize;
	return;
end

clear Test TestSize;


% determine number of input fractures
FracCount = size(input,1);

% parse fracture kinematic data
FracStrike(1:FracCount,1) = input(1:FracCount,1);
FracDip(1:FracCount,1) = input(1:FracCount,2);
MoveTrend(1:FracCount,1) = input(1:FracCount,3);
MovePlunge(1:FracCount,1) = input(1:FracCount,4);
Sense(1:FracCount,1) = char(input(1:FracCount,5));

% eliminate input array
clear input;


% determine vectors for fracture pole and movement direction:
% Pole = (footwall) pole to fracture (points downward in all cases),
% Move = movement direction of footwall relative to hanging wall;
%	T = thrust slip; hanging wall shear up, footwall shear down (default)
%	N = normal slip; hanging wall shear down, footwall shear up
%	R = right slip; Pole cross Move is downward
%	L = left slip; Pole cross Move is upward
%	O = opening movement; Pole dot Move > 0
%	C = closing movement; Pole dot Move < 0
%
% catch ambiguous sense-of-movement input;
% flip Move into the upper hemisphere where appropriate;
% disambiguate implicated components of movement
Pole = zeros(FracCount,3);
Move = zeros(FracCount,3);

DotProd = zeros(FracCount,1);
CrossProdZ = zeros(FracCount,1);
MoveProjZ = zeros(FracCount,1);

Flip = zeros(FracCount,1);
Ambiguity = zeros(FracCount,1);
SoM = char(zeros(FracCount,3));

for i = 1:FracCount
	% decimate angular resolution of input data to 1°
% 	OneDegreeResolution = 1/360 * 2*pi;
	
	% determine downward-pointing Pole vector in Cartesian coordinates:
	%	(+x = north; +y = east; +z = down)
	Pole(i,3) = cosd(FracDip(i));
	Pole(i,2) = sind(FracDip(i)) * sind(FracStrike(i)-90);
	Pole(i,1) = sind(FracDip(i)) * cosd(FracStrike(i)-90);
	
	% determine downward-pointing Move vector in Cartesian coordinates:
	Move(i,3) = sind(MovePlunge(i));
	Move(i,2) = cosd(MovePlunge(i)) * sind(MoveTrend(i));
	Move(i,1) = cosd(MovePlunge(i)) * cosd(MoveTrend(i));
	
	% round-off extreme values to resolution level
% 	if Pole(i,3) < OneDegreeResolution
% 		Pole(i,3) = 0;
% 	elseif Pole(i,3) > sqrt(1 - OneDegreeResolution^2)
% 		Pole(i,3) = 1;
% 	end
	
% 	if Move(i,3) < OneDegreeResolution
% 		Move(i,3) = 0;
% 	elseif Move(i,3) > sqrt(1 - OneDegreeResolution^2)
% 		Move(i,3) = 1;
% 	end
	
	% determine vectorial criteria that distinguish SoM
	DotProd(i) = Pole(i,1) * Move(i,1) ...
			+ Pole(i,2) * Move(i,2) ...
			+ Pole(i,3) * Move(i,3);
		
% 	if abs(DotProd(i)) < OneDegreeResolution
% 		DotProd(i) = 0;
% 	end
	
	CrossProdZ(i) = Pole(i,1) * Move(i,2) - Pole(i,2) * Move(i,1);
	
% 	if abs(CrossProdZ(i)) < OneDegreeResolution
% 		CrossProdZ(i) = 0;
% 	end
	
	MoveProjZ(i) = Move(i,3) - DotProd(i) * Pole(i,3);
	
% 	if abs(MoveProjZ(i)) < OneDegreeResolution
% 		MoveProjZ(i) = 0;
% 	end
	
	% test for conditions that flip Move
	Flip(i) = false;
	
	% trap for shear on vertical or horizontal fracture surface
	if Pole(i,3) == 0
		if Sense(i) == 'T' || Sense(i) == 'N'
			SoM(i,1) = '-';
			Ambiguity(i) = 1;
		end
		
	elseif Pole(i,3) == 1
		if Sense(i) == 'T' || Sense(i) == 'N'
			SoM(i,1) = '-';
			Ambiguity(i) = 2;
			
		elseif Sense(i) == 'R' || Sense(i) == 'L'
			SoM(i,2) = '-';
			Ambiguity(i) = 2;
		end
	end
	
	% trap for horizontal shear movement in case of T or N input
	if SoM(i,1) ~= '-'
		if MoveProjZ(i) == 0
			SoM(i,1) = '-';
			if Sense(i) == 'T' || Sense(i) == 'N'
				Ambiguity(i) = 3;
			end

		elseif Sense(i) == 'T'
			SoM(i,1) = 'T';
			Flip(i) = false;

		elseif Sense(i) == 'N'
			SoM(i,1) = 'N';
			Flip(i) = true;
		end
	end
	
	% trap for vertical movement plane in case of R or L input
	if SoM(i,2) ~= '-'
		if CrossProdZ(i) == 0
			SoM(i,2) = '-';
			if Sense(i) == 'R' || Sense(i) == 'L'
				Ambiguity(i) = 4;
			end

		elseif Sense(i) == 'R'
			SoM(i,2) = 'R';
			if CrossProdZ(i) < 0
				Flip(i) = true;
			end

		elseif Sense(i) == 'L'
			SoM(i,2) = 'L';
			if CrossProdZ(i) > 0
				Flip(i) = true;
			end
		end
	end
	
	% trap for perfect simple shear in case of O or C input
	if DotProd(i) == 0
		SoM(i,3) = '-';
		if Sense(i) == 'O' || Sense(i) == 'C'
			Ambiguity(i) = 5;
		end

	elseif Sense(i) == 'O'
		SoM(i,3) = 'O';
		if DotProd(i) < 0
			Flip(i) = true;
		end

	elseif Sense(i) == 'C'
		SoM(i,3) = 'C';
		if DotProd(i) > 0
			Flip(i) = true;
		end
	end
	
	% flip Move if any conditions met
	if Flip(i) == true
		MovePlunge(i) = -MovePlunge(i);
		
		if MoveTrend(i) < 180
			MoveTrend(i) = MoveTrend(i) + 180;
		else
			MoveTrend(i) = MoveTrend(i) - 180;
		end
		
		Move(i,:) = -Move(i,:);
		
		DotProd(i) = -DotProd(i);
		
		CrossProdZ(i) = -CrossProdZ(i);
		
		MoveProjZ(i) = -MoveProjZ(i);
	end
	
	% disambiguate dip-slip component of movement
	if Sense(i) ~= 'T' && Sense(i) ~= 'N'
		
		if Pole(i,3) == 0 || Pole(i,3) == 1
			SoM(i,1) = '-';
		elseif MoveProjZ(i) > 0
			SoM(i,1) = 'T';
		elseif MoveProjZ(i) == 0
			SoM(i,1) = '-';
		else
			SoM(i,1) = 'N';
		end
		
	end
	
	% disambiguate strike-slip component of movement
	if Sense(i) ~= 'R' && Sense(i) ~= 'L'
		
		if Pole(i,3) == 1
			SoM(i,2) = '-';
		elseif CrossProdZ(i) > 0
			SoM(i,2) = 'R';
		elseif CrossProdZ(i) == 0
			SoM(i,2) = '-';
		else
			SoM(i,2) = 'L';
		end
		
	end
	
	% disambiguate opening component of movement
	if Sense(i) ~= 'O' && Sense(i) ~= 'C'
		
		if DotProd(i) > 0
			SoM(i,3) = 'O';
		elseif DotProd(i) == 0
			SoM(i,3) = '-';
		else
			SoM(i,3) = 'C';
		end
	
	end
		
end


% display a dialog box reporting to user about any ambiguous SoM input:
if nnz(Ambiguity(1:FracCount)) > 0
	Warning = figure('Name', 'Uh oh ...', 'NumberTitle', 'off'); %#ok<*NASGU>
	%	'Units', 'normalized', 'Position', [0.3, 0.5, 0.4, 0.4]);
	
	message = sprintf('One or more of your SoM inputs is ambiguous. You should review your notes and check the following fractures:');
	
	h(1) = uicontrol('Style', 'text', ...
		'Position', [20 365 520 35], ...
		'String', message, ...
		'FontSize', 14, ...
		'HorizontalAlignment', 'left', ...
		'BackgroundColor', [0.8 0.8 0.8]);
	
	% gather user feedback into a cell array
	counter = 0;
	CellFeedback = cell(nnz(Ambiguity(1:FracCount)),3);
	
	for i = 1:FracCount
		if Ambiguity(i) ~= 0
			if Ambiguity(i) == 1
				comment = 'fracture is vertical, so dip slip is ambiguous';
			elseif Ambiguity(i) == 2
				comment = 'fracture is horizontal, so shear movement is ambiguous';
			elseif Ambiguity(i) == 3
				comment = 'shear movement is horizontal, so dip slip is ambiguous';
			elseif Ambiguity(i) == 4
				comment = 'movement plane is vertical, so strike slip is ambiguous';
			elseif Ambiguity(i) == 5
				comment = 'movement parallels fracture surface, so opening is ambiguous';
			end
			counter = counter + 1;
			CellFeedback(counter, :) = {i, Sense(i), comment};
		end
	end
	
	% create table and insert user feedback
	h(2) = uitable('Position', [20 80 520 270], ...
		'ColumnName', {'fracture number', 'SoM', 'comment'}, ...
		'ColumnWidth', {100, 40, 460}, ...
		'ColumnFormat', {'char', 'char', 'char'}, ...
		'Data', CellFeedback, ...
		'FontSize', 14);
	
	h(3) = uicontrol('Position', [20 20 250 40], ...
		'String', 'Save Comments', ...
		'FontSize', 14, ...
		'Callback', 'uiresume(gcbf)');
		
	h(4) = uicontrol('Position', [290 20 250 40], ...
		'String', 'Abort', ...
		'FontSize', 14, ...
		'Callback', 'Abort = 1; uiresume(gcbf)');
	
	% disp('This will print immediately');
	uiwait(gcf); 
	% disp('This will print after you click Continue');
	
	close(gcf);
	
	clear Warning h comment;
	
	if Abort == 1
		clear counter CellFeedback;
		cd(originalpath);
		return
	end
	
	
	% write user feedback in output text file:
	
	% change directory to source of input
	cd(inputpath);
	
	% open output file for FracKin comments
	[outputfile, outputpath] = uiputfile('FracKin_comments.txt', ...
		'Choose an OUTPUT file for FracKin comments:');
	[outputID, message] = fopen([outputpath, outputfile], 'a');
	if outputID == -1
		disp(message)
	end
	
	fprintf(outputID, 'fracture number\tSoM\tcomment\n');
	
	% write content for FracKin comments
	for i = 1:counter
		fprintf(outputID, '%d\t%s\t%s\n', cell2mat(CellFeedback(i,1)), ...
			cell2mat(CellFeedback(i,2)), cell2mat(CellFeedback(i,3)));
	end
	
	fprintf(outputID, '\n\n');
	
	clear message counter CellFeedback;
	
	% close output file
	fclose(outputID);
	
	% reset directory to original
	cd(originalpath);
end


% quantify principal axes of inf strain in four steps; first, 
% determine symmetric part of displacement gradient tensors:
%	(dyad products)
DisplGrad = zeros(FracCount+1,3,3);

for i = 1:FracCount
	for j = 1:3
		for k = 1:3
			DisplGrad(i,j,k) = Pole(i,j) * Move(i,k);
		end
	end
	
	DisplGrad(i,1,2) = (DisplGrad(i,1,2) + DisplGrad(i,2,1)) / 2;
	DisplGrad(i,2,1) = DisplGrad(i,1,2);
	DisplGrad(i,1,3) = (DisplGrad(i,1,3) + DisplGrad(i,3,1)) / 2;
	DisplGrad(i,3,1) = DisplGrad(i,1,3);
	DisplGrad(i,2,3) = (DisplGrad(i,2,3) + DisplGrad(i,3,2)) / 2;
	DisplGrad(i,3,2) = DisplGrad(i,2,3);
end


% determine moment tensor sum for fracture population:
%	(tensor summation)
for j = 1:3
	for k = 1:3
		DisplGrad(FracCount+1,j,k) = sum(DisplGrad(1:FracCount,j,k));
		
		% new line of code below:
		DisplGrad(FracCount+1,j,k) = DisplGrad(FracCount+1,j,k) / FracCount;
		
	end
end


% determine principal strain directions and relative magnitudes:
%	(eigenvectors and eigenvalues)
EigVect = zeros(FracCount+1,3,3);
EigVal = zeros(FracCount+1,3,3);

for i = 1:(FracCount+1)
	[EigVect(i,1:3,1:3), EigVal(i,1:3,1:3)] = eig( ...
		[DisplGrad(i,1,1) DisplGrad(i,1,2) DisplGrad(i,1,3); ...
		DisplGrad(i,2,1) DisplGrad(i,2,2) DisplGrad(i,2,3); ...
		DisplGrad(i,3,1) DisplGrad(i,3,2) DisplGrad(i,3,3)]);
end


% unfold principal strain directions by restoring bedding to horizontal:
%	(transformation matrix)
if Bedding(3) == 1
	Rotation = zeros(3,3);
	Rotation = [cosd(Bedding(1)) -sind(Bedding(1)) 0
		sind(Bedding(1)) cosd(Bedding(1)) 0
		0 0 1] * ...
		[1 0 0
		0 cosd(Bedding(2)) sind(Bedding(2))
		0 -sind(Bedding(2)) cosd(Bedding(2))] * ...
		[cosd(Bedding(1)) sind(Bedding(1)) 0
		-sind(Bedding(1)) cosd(Bedding(1)) 0
		0 0 1];
	
	for i = 1:(FracCount+1)
		temp(1:3,1:3) = EigVect(i,1:3,1:3);
		EigVect(i,1:3,1:3) = Rotation * temp;
	end
end


% convert eigenvectors to lower-hemisphere trends and plunges:
%	(1 = shortening; 2 = intermediate; 3 = extension)
KinTrend = zeros(FracCount+1,3);
KinPlunge = zeros(FracCount+1,3);

for i = 1:(FracCount+1)
	for j = 1:3
		
		% enforce downward direction of principal kinematic axes
		if EigVect(i,3,j) < 0
			EigVect(i,1:3,j) = -EigVect(i,1:3,j);
		end
		
		% determine trends and plunges of principal kinematic axes
		KinPlunge(i,j) = asind(EigVect(i,3,j));
		if EigVect(i,1,j) == 0
			if EigVect(i,2,j) > 0
				KinTrend(i,j) = 90;
			elseif EigVect(i,2,j) == 0
				KinTrend(i,j) = 0;
			else
				KinTrend(i,j) = 270;
			end
		elseif EigVect(i,1,j) < 0 
			KinTrend(i,j) = 180 + atand(EigVect(i,2,j) / EigVect(i,1,j));
		elseif EigVect(i,2,j) < 0
			KinTrend(i,j) = 360 + atand(EigVect(i,2,j) / EigVect(i,1,j));
		else
			KinTrend(i,j) = atand(EigVect(i,2,j) / EigVect(i,1,j));
		end

	end
end


% unfold fracture planes and movement directions by 
%	restoring bedding to horizontal:
%	(transformation matrix)
if Bedding(3) == 1
	Rotation = zeros(3,3);
	Rotation = [cosd(Bedding(1)) -sind(Bedding(1)) 0
		sind(Bedding(1)) cosd(Bedding(1)) 0
		0 0 1] * ...
		[1 0 0
		0 cosd(Bedding(2)) sind(Bedding(2))
		0 -sind(Bedding(2)) cosd(Bedding(2))] * ...
		[cosd(Bedding(1)) sind(Bedding(1)) 0
		-sind(Bedding(1)) cosd(Bedding(1)) 0
		0 0 1];
	
	for i = 1:FracCount
		temp(1:3) = Pole(i,1:3);
		temp = Rotation * temp;
		Pole(i,1:3) = temp(1:3);
		
		temp(1:3) = Move(i,1:3);
		temp = Rotation * temp;
		Move(i,1:3) = temp(1:3);
	end
	
	for i = 1:FracCount
		% enforce downward direction of Pole and Move vectors
		if Pole(i,3) < 0
			Pole(i,1:3) = -Pole(i,1:3);
		end
		if Move(i,3) < 0
			Move(i,1:3) = -Move(i,1:3);
		end

		% determine trends and plunges of Pole and Move vectors
		FracDip(i) = 90 - asind(Pole(i,3));
		if Pole(i,1) == 0
			if Pole(i,2) > 0
				FracStrike(i) = 90;
			elseif Pole(i,2) == 0
				FracStrike(i) = 0;
			else
				FracStrike(i) = 270;
			end
		elseif Pole(i,1) < 0 
			FracStrike(i) = 180 + atand(Pole(i,2) / Pole(i,1));
		elseif Pole(i,2) < 0
			FracStrike(i) = 360 + atand(Pole(i,2) / Pole(i,1));
		else
			FracStrike(i) = atand(Pole(i,2) / Pole(i,1));
		end
		
		FracStrike(i) = FracStrike(i) + 90;
		if FracStrike(i) > 360
			FracStrike(i) = FracStrike(i) - 360;
		end
		
		MovePlunge(i) = asind(Move(i,3));
		if Move(i,1) == 0
			if Move(i,2) > 0
				MoveTrend(i) = 90;
			elseif Move(i,2) == 0
				MoveTrend(i) = 0;
			else
				MoveTrend(i) = 270;
			end
		elseif Move(i,1) < 0 
			MoveTrend(i) = 180 + atand(Move(i,2) / Move(i,1));
		elseif Move(i,2) < 0
			MoveTrend(i) = 360 + atand(Move(i,2) / Move(i,1));
		else
			MoveTrend(i) = atand(Move(i,2) / Move(i,1));
		end
		
		% note: above algorithm fails to account for possible SoM changes
	end
end


% plot stereographic results in a graphics window using 
% stereographic functions from Allmendinger et al. (2012):

% define title of graphics window
Stereogram = gcf;
set(Stereogram, 'NumberTitle', 'off', 'Name', 'FracKin 1.2', ...
	'Toolbar', 'figure');

%
% define size of graphics window
%

% change directory to ACF2012 functions
% cd(strcat(originalpath,'/ACF2012'));

% plot lower-hemisphere stereonet (blue grid)
StereonetHackRM(0, 90*pi/180, 10*pi/180, 1);

hold on;

% plot bedding surface (bold black great circle)
if Bedding(3) == 0
	[path] = GreatCircle(Bedding(1)*pi/180, Bedding(2)*pi/180, 1);
	plot(path(:,1),path(:,2),'k','LineWidth',2);
end

% plot individual fracture data:
if Bedding(4) == 0
    
    for i = 1:FracCount
        % plot fracture surface (black great circle)
        [path] = GreatCircle(FracStrike(i)*pi/180, FracDip(i)*pi/180, 1);
        plot(path(:,1),path(:,2),'k');

        % plot movement direction (black asterisk)
        [xp,yp] = StCoordLine(MoveTrend(i)*pi/180, MovePlunge(i)*pi/180, 1);
        plot(xp,yp,'k*','MarkerFaceColor','k','MarkerSize',10);
    end
    
% plot individual fracture kinematics:
% saturation value defined by eigenvalues
elseif Bedding(4) == 1
    
    for i = 1:FracCount
        % plot shortening axis (red-intensity-filled circle)
        [xp,yp] = StCoordLine(KinTrend(i,1)*pi/180, KinPlunge(i,1)*pi/180, 1);
        Magnitude = sqrt(-EigVal(i,1,1));
        if Magnitude > 1
            Magnitude = 1;
        end
        if Magnitude < 0.3
            MarkerEdgeColor = 'w';
        else
            MarkerEdgeColor = 'k';		
        end
            plot(xp,yp,'ko', ...
                'MarkerFaceColor',[Magnitude 0 0], ...
                'MarkerEdgeColor', MarkerEdgeColor, ...
                'MarkerSize',10);

        % plot extension axis (green-intensity-filled circle)
        [xp,yp] = StCoordLine(KinTrend(i,3)*pi/180, KinPlunge(i,3)*pi/180, 1);
        Magnitude = sqrt(EigVal(i,3,3));
        if Magnitude > 1
            Magnitude = 1;
        end
        if Magnitude < 0.3
            MarkerEdgeColor = 'w';
        else
            MarkerEdgeColor = 'k';		
        end
            plot(xp,yp,'ko', ...
                'MarkerFaceColor',[0 Magnitude 0], ...
                'MarkerEdgeColor', MarkerEdgeColor, ...
                'MarkerSize',10);
    end
end
	
if (Bedding(4)+Bedding(5)) == 1
	
   % plot intermediate axis (black-filled circle)
   for i = 1:FracCount
        [xp,yp] = StCoordLine(KinTrend(i,2)*pi/180, KinPlunge(i,2)*pi/180, 1);
        plot(xp,yp,'ko', ...
            'MarkerFaceColor','k', ...
            'MarkerEdgeColor','w', ...
            'MarkerSize',10);
    end
end

% plot moment tensor sum for fracture population:
	% plot integrated shortening axis (red star)
	[xp,yp] = StCoordLine(KinTrend(FracCount+1,1)*pi/180, ...
		KinPlunge(FracCount+1,1)*pi/180, 1);
	plot(xp,yp,'kp','MarkerFaceColor','r','MarkerSize',20);

	% plot integrated intermediate axis (yellow diamond)
	[xp,yp] = StCoordLine(KinTrend(FracCount+1,2)*pi/180, ...
		KinPlunge(FracCount+1,2)*pi/180, 1);
	plot(xp,yp,'kd','MarkerFaceColor','y','MarkerSize',15);

	% plot integrated extension axis (green triangle)
	[xp,yp] = StCoordLine(KinTrend(FracCount+1,3)*pi/180, ...
		KinPlunge(FracCount+1,3)*pi/180, 1);
	plot(xp,yp,'k^','MarkerFaceColor','g','MarkerSize',15);

%
% add buttons for save plot, XXX, open new data, XXX
%

h(1) = uicontrol('Position', [10 10 170 30], ...
	'String', 'Save Numerical Results', ...
	'FontSize', 14, ...
	'Callback', 'uiresume(gcbf)');

h(2) = uicontrol('Position', [380 10 170 30], ...
	'String', 'Quit', ...
	'FontSize', 14, ...
	'Callback', 'Abort = 1; uiresume(gcbf)');


uiwait(gcf); 

hold off;

clear h;

% reset directory to original
 cd(originalpath);

if Abort == 1
	return;
end


% write numerical results in output text file:

% change directory to source of input
cd(inputpath);

% open output file for FracKin
[outputfile, outputpath] = uiputfile('FracKin_output.txt', ...
	'Choose an OUTPUT file for FracKin:');
[outputID, message] = fopen([outputpath, outputfile], 'a');
if outputID == -1
	disp(message)
end

clear message;

% write header for individual fractures
fprintf(outputID, 'Input file:\t');
fprintf(outputID, inputfile);
fprintf(outputID, '\t\t\t\t\tKinematic results:\n');
fprintf(outputID, ...
	'Frac Strike\tFrac Dip\tMove Trend\tMove Plunge\tSoM\tN\tTheta\tGamma\tDeltaV\te1\tTrend\tPlunge\te2\tTrend\tPlunge\te3\tTrend\tPlunge\n');

% write results for individual fractures
for i = 1:1:FracCount
    
    Gamma = sqrt(1-DotProd(i)^2);
    if SoM(i,2) == 'L'
        Gamma = -Gamma;
    end
    
    Theta = atand(Gamma / DotProd(i));
    if SoM(i,3) == 'C'
        if Theta < 0
            Theta = Theta + 180;
        else
            Theta = Theta - 180;
        end;
        if Theta < -179.9
            Theta = -Theta;
        end;
    end
    
	fprintf(outputID, ...
		'%6.2f\t %6.2f\t %6.2f\t %6.2f\t %s\t %d\t %6.2f\t %6.4f\t %6.4f\t %6.4f\t %6.2f\t %6.2f\t %6.4f\t %6.2f\t %6.2f\t %6.4f\t %6.2f\t %6.2f\n', ...
		FracStrike(i), FracDip(i), MoveTrend(i), MovePlunge(i), ...
		SoM(i,:), i, Theta, Gamma, DotProd(i), ...
        EigVal(i,3,3), KinTrend(i,3), KinPlunge(i,3), ...
		EigVal(i,2,2), KinTrend(i,2), KinPlunge(i,2), ...
		EigVal(i,1,1), KinTrend(i,1), KinPlunge(i,1));
end

% write header for fracture population
fprintf(outputID, '\n');
fprintf(outputID, '\t\t\t\t\t\tMoment tensor sum:\n');
fprintf(outputID, ...
	'\t\t\t\t\t\te1\tTrend\tPlunge\te2\tTrend\tPlunge\te3\tTrend\tPlunge\n');

% write results for fracture population
fprintf(outputID, ...
	'\t\t\t\t\t\t %6.4f\t %6.2f\t %6.2f\t %6.4f\t %6.2f\t %6.2f\t %6.4f\t %6.2f\t %6.2f\n', ...
	EigVal(FracCount+1,3,3), ...
	KinTrend(FracCount+1,3), KinPlunge(FracCount+1,3), ...
	EigVal(FracCount+1,2,2), ...
	KinTrend(FracCount+1,2), KinPlunge(FracCount+1,2), ...
	EigVal(FracCount+1,1,1), ...
	KinTrend(FracCount+1,1), KinPlunge(FracCount+1,1));
fprintf(outputID, '\n\n');

% close output file
fclose(outputID);

% reset directory to original
cd(originalpath);
