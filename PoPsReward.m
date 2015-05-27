
%----------------------------------------------------------------
%  PoPsReward.m
%
%  Zachary Roper
%  
%  Reward the primed pop-out stimulus
%  
%  April 29, 2013
%
% Edits By James Kent May 22, 2015
%----------------------------------------------------------------
AssertOpenGL;
clc; 
clear all 

KbName('UnifyKeyNames') %so that key bindings work across operating systems.

%---------------------------------------------
%EXPERIMENTAL VARIABLES YOU MAY WISH TO CHANGE
%---------------------------------------------

%SCREEN SET UP
%--------------------------------
%X dimension of screen
Screen_X_dim = 1280;

%Y dimension of screen
Screen_Y_dim = 1024;
%--------------------------------


%Image Presentation
%--------------------------------
%radius is defined by the smallest dimension of the window
%You can scale the radius to bring the stimuli closer to the center
Scale_radius = 0.2;

%This scales the size of the objects appearing on the screen.
Scale_Obj = 1;

%This determines how many distractors are present (max=5)
Num_Distractors = 2;
%---------------------------------

%Reward Presentation
%---------------------------------
%High reward
High_Reward_Img = 'test_bill00006.png';

%Low reward
Low_Reward_Img = 'test_bill00002.png';
%--------------------------------

%Key press bindings
%--------------------------------
%To check available names, type KbName('KeyNamesOSX')
Left_Key_Press = 'LeftArrow';
Right_Key_Press = 'RightArrow';

%TIMING INFORMATION
%---------------------------------
%How long will stimulus show (seconds)?
StimTimeOut=2;

%How long between response and reward (seconds)?
RewardWait= 0.2;

%How long to present the reward (seconds)?
RewardTime = 2;

%What range will the inter stimulus interval be (seconds)?
MinISI = 1.0;
MaxISI = 1.5;
%-------------------------------


%PRACTICE VARIABLES
%-------------------------------
%number of practice trials
Prac_Trials=20;
%-------------------------------


%-----------------------------------------------------------------
%USER CHANGES END, CONTINUE AT YOUR OWN RISK
%-----------------------------------------------------------------

%-----------------------------------------------------------------
%	Set up subject number and data file
%-----------------------------------------------------------------

exptype = input('Practice(p) or Experiment(e)?','s');

SN = input('Enter Subject Number:' ,'s');
ID = str2double(SN);

if exptype == 'e'
    FileName =  strcat(SN, '_PoPsReward.csv'); 
    if exist(FileName,'file')
        resp=input(['the file ' FileName ' already exists. do you want to overwrite it? [Type ok for overwrite]'], 's');
        if ~strcmp(resp,'ok') %abort experiment if overwriting was not confirmed
            disp('experiment aborted')
            return
        end
    end
    FID = fopen(FileName, 'w');
    fprintf(FID, 'Order, Trial, TRep, TColor, TRepCount, TOrient, TLoc, Subject, Block, Reward, HighRewardRepCount, LowRewardRepCount, Response, Accuracy, RT, ScanStartHour, ScanStartMin, ScanStartSec, Hour, Min, Sec, ElapsedTime, SOA\n');
    fclose(FID);
elseif exptype == 'p'
	FileName =  strcat(SN, '_PoPsReward_practice.csv'); 
    if exist(FileName,'file')
        resp=input(['the file ' FileName ' already exists. do you want to overwrite it? [Type ok for overwrite]'], 's');
        if ~strcmp(resp,'ok') %abort experiment if overwriting was not confirmed
            disp('experiment aborted')
            return
        end
    end
    FID = fopen(FileName, 'w');
    fprintf(FID, 'Order, Trial, TRep, TColor, TRepCount, TOrient, TLoc, Subject, Block, Reward, HighRewardRepCount, LowRewardRepCount, Response, Accuracy, RT, ScanStartHour, ScanStartMin, ScanStartSec, Hour, Min, Sec, ElapsedTime, SOA\n');
    fclose(FID);
end 

%-----------------------------------------------------------------
%	Setting up random seed, screen, and colors
%-----------------------------------------------------------------


HideCursor; 
screen = 0;
[window,rect] = Screen('OpenWindow', screen, [], [0 0 Screen_X_dim Screen_Y_dim]);
CX=rect(3)/2;		
CY=rect(4)/2;
Framerate = Screen('FrameRate', screen);
%rand('twister',sum(100*clock)); %is this necessary?
black=BlackIndex(window);
white=WhiteIndex(window);

%-----------------------------------------------------------------
%	Present Instruction/Start Window
%-----------------------------------------------------------------
Instructions1 = imread('CRcaptureInst1.jpg');
Instructions2 = imread('PopsReward_INST.jpg');

Screen('PutImage', window, Instructions1, rect);
Screen(window, 'Flip');
KbWait([],2);

Screen('PutImage', window, Instructions2, rect);
Screen(window, 'Flip');
KbWait([],2);
 

%-----------------------------------------------------------------
% Read Images
%-----------------------------------------------------------------

%Current Stimuli

[Gt , ~, alpha] = imread('Gt.png');
Gt(:,:,4) = alpha(:,:);
[Gb , ~, alpha] = imread('Gb.png');
Gb(:,:,4) = alpha(:,:);
[Gr , ~, alpha] = imread('Gr.png');
Gr(:,:,4) = alpha(:,:);
[Gl , ~, alpha] = imread('Gl.png');
Gl(:,:,4) = alpha(:,:);

[Rt , ~, alpha] = imread('Rt.png');
Rt(:,:,4) = alpha(:,:);
[Rb , ~, alpha] = imread('Rb.png');
Rb(:,:,4) = alpha(:,:);
[Rr , ~, alpha] = imread('Rr.png');
Rr(:,:,4) = alpha(:,:);
[Rl , ~, alpha] = imread('Rl.png');
Rl(:,:,4) = alpha(:,:);

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%-----------------------------------------------------------------
%  Condition Distribution
%-----------------------------------------------------------------

TReward = 2; %High vs. Low
TRep = 2; %Switch or Repeat
TColor = 2; %Red vs. Green
TOrient = 2; %Right vs. Left 
TLoc = 6; %Loc1 = 12:00; Loc4 = 6:00
Repetition = 5; 
TotalTrial = (TRep*TColor*TOrient*TLoc*TReward*Repetition)+Repetition; % Total Trials = 960+Repetition
blockSize = (TRep*TColor*TOrient*TLoc*TReward)+1; %blockSize = 96+1
if exptype == 'p' 
	TotalTrial = Prac_Trials;
	blockSize = Prac_Trials;
	Repetition = 1;
end

%-----------------------------------------------------------------
%  Ancillary controls
%-----------------------------------------------------------------
%use to seed random number generator to replicate results
%rng(0,'twister'); %not available in octave

MasterISI = (MaxISI - MinISI).*rand(TotalTrial,1) + MinISI;



%-----------------------------------------------------------------
% Condition Initialization
%-----------------------------------------------------------------
TargetReward = zeros(1,TotalTrial);
TargetRepetition = zeros(1, TotalTrial); 
TargetColor = zeros(1, TotalTrial);
TargetOrientation = zeros(1, TotalTrial);
TargetLocation = zeros(1, TotalTrial);
Block = zeros(1, TotalTrial);
Reward = zeros(1, TotalTrial);
RT = zeros(1, TotalTrial);
Response = zeros(1, TotalTrial);
Accuracy = zeros(1, TotalTrial);
order = zeros(1, TotalTrial);
MasterDistLoc=zeros(Num_Distractors,4,TotalTrial);
MasterDist=cell(TotalTrial,Num_Distractors);
MasterTarLoc=zeros(TotalTrial,4);
%Draw Prompt

Screen('FillRect', window, black);
Screen(window,'TextSize', 24); 
Screen('TextFont', window, 'Helvetica');
BeginText = ('Prepare to Start');
DrawFormattedText(window, BeginText, 'center', 'center', white);
Screen(window, 'Flip');
WaitSecs(1);

tic
ScanStartTime=datevec(now);

FlushEvents('keydown');

Screen('FillRect', window, black);
Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
Screen(window, 'Flip');

%CHANGE?
WaitSecs(1);



%-----------------------------------------------------------------
% Initialization of repeat counters
%-----------------------------------------------------------------
%Counts number of consecutive color repeats
Rep_Color_Count = 0;

%Counts number of consecutive high reward repeats
Rep_Low_Reward = 0;

%Counts number of consecutive high reward repeats
Rep_High_Reward = 0;

%-----------------------------------------------------------------
%  Location Coordinates, Selecting Locations  
%-----------------------------------------------------------------


radius = min(rect(3:4))*Scale_radius;

%How big will the Distractors/Targets be?
Obj_X_Dim = 100*Scale_Obj;
Obj_Y_Dim = 106.66*Scale_Obj;

%Fun Geometry, how to calculate sides of a 90-60-30 triangle.
Corner_Translation_X = (radius/2)*sqrt(3);
Corner_Translation_Y = radius/2;

%Matlab specifies location in top left corner of object or something weird
%like that so I need to offset the object to find its center coordinates.
Coordinate_Correction_X = -((Obj_X_Dim)/2);
Coordinate_Correction_Y = ((Obj_Y_Dim)/2);
Obj_Center_X = CX + Coordinate_Correction_X;
Obj_Center_Y = CY + Coordinate_Correction_Y;

%Yay Geometry! If someone has a more concise solution to fitting 6 objects
%around a circle equidistant to the center, I welcome them to it.
Top = [(Obj_Center_X) ((Obj_Center_Y - Obj_Y_Dim)-radius) (Obj_Center_X + Obj_X_Dim) (Obj_Center_Y - radius) ];
TopLeft = [(Obj_Center_X - Corner_Translation_X) ((Obj_Center_Y - Obj_Y_Dim) - Corner_Translation_Y) ((Obj_Center_X + Obj_X_Dim) - Corner_Translation_X) (Obj_Center_Y - Corner_Translation_Y)];
TopRight = [(Obj_Center_X + Corner_Translation_X) ((Obj_Center_Y - Obj_Y_Dim) - Corner_Translation_Y) ((Obj_Center_X + Obj_X_Dim) + Corner_Translation_X) (Obj_Center_Y - Corner_Translation_Y)];
Bottom = [(Obj_Center_X) ((Obj_Center_Y - Obj_Y_Dim) + radius) (Obj_Center_X + Obj_X_Dim) (Obj_Center_Y+radius)];
BottomLeft = [(Obj_Center_X - Corner_Translation_X) ((Obj_Center_Y - Obj_Y_Dim) + Corner_Translation_Y) ((Obj_Center_X + Obj_X_Dim) - Corner_Translation_X) (Obj_Center_Y + Corner_Translation_Y) ];
BottomRight = [(Obj_Center_X + Corner_Translation_X) ((Obj_Center_Y - Obj_Y_Dim) + Corner_Translation_Y) ((Obj_Center_X + Obj_X_Dim) + Corner_Translation_X) (Obj_Center_Y + Corner_Translation_Y) ];

%CHANGE?
%number of trials  in a block must be a factor of 96
if exptype == 'e'
	for i=1 : TotalTrial

		TargetReward(i) = mod((i-1), TReward);
		TargetReward(i) = floor(TargetReward(i))+1;

	    TargetRepetition(i) = mod((i-1)/2, TRep);
		TargetRepetition(i) = floor(TargetRepetition(i))+1; 
	    
	    %Is this necessary since it is defined by Repetition?
	    %Only has an effect on the first trial of a block
	    %WARNING: Does not guarantee balance, due to above comments
	    TargetColor(i) = mod((i-1)/4, TColor);
		TargetColor(i) = floor(TargetColor(i))+1;
	    
		TargetOrientation(i) = mod((i-1)/8, TOrient);
		TargetOrientation(i) = floor(TargetOrientation(i))+1;
	        
	    TargetLocation(i) = mod((i-1)/16, TLoc);
		TargetLocation(i) = floor(TargetLocation(i))+1;
	      
		order(i) = i;

    end
    %Right now, Practice is completely random, everyone's practice will be
    %a bit different.
elseif exptype == 'p'
		TargetReward = randi(2,1,Prac_Trials);
		TargetRepetition = randi(2,1,Prac_Trials);
		TargetColor = randi(2,1,Prac_Trials);
		TargetOrientation = randi(2,1,Prac_Trials);
		TargetLocation = randi(6,1,Prac_Trials);
		order = randperm(Prac_Trials);
end

%-----------------------------------------------------------------
% Randomization of Trials
%-----------------------------------------------------------------
    %Randomize trials within blocks, so blocks are equivalent.
    %Quirk: First trials of each block are not randomized.
    %We want to make sure the first trial (which cannot be a repeat/switch)
    %is repeated again in the block so that there are an equal number of...
    %of switch and repeat trials.
    %WARNING: this means each block will start with the same trial (i.e
    %green target with red distractors at certain locations.
    for j=1 : Repetition
    	order(((j*blockSize)-(blockSize-2)):(j*blockSize)) = Shuffle(order(((j*blockSize)-(blockSize-2)):(j*blockSize)));
	end

%set up Distractor and target locations
for i=1:TotalTrial
	%-----------------------------------------------------------------
	%  Search Locations
	%-----------------------------------------------------------------
    
    %6 possible locations to choose from
	LocationPossibilities = [[Top];[TopLeft];[TopRight];[Bottom];[BottomLeft];[BottomRight]];
	LocationIndex = [1:6];
    
    %find the target location for the particular trial
	TarLoc=LocationPossibilities(TargetLocation(order(i)),1:4);
    
    %Distractors can only be where the target isn't (makes sense)
	DistLocIndex = Shuffle(LocationIndex(LocationIndex~=TargetLocation(order(i))));
    
    %Assign distractors posistions
	for j=1:Num_Distractors
		DistLoc(j,1:4) = LocationPossibilities(DistLocIndex(j),1:4);
    end
    
    %pass variables into master vectors/arrays
	MasterTarLoc(i,1:4) = TarLoc;
	MasterDistLoc(1:Num_Distractors,1:4,i) = DistLoc(1:Num_Distractors,1:4);
    
	%-----------------------------------------------------------------
	%  Selecting Distractor Identities
	%-----------------------------------------------------------------

    %This is pretty crappy, but I don't know how else to make sure the
    %distractors are the right color and to randomly generate their
    %orientation (while making sure orientation is relatively evenly
    %balanced)
	PossibleDistIndex=[1 2];
	DistIndex=repmat(Shuffle(PossibleDistIndex),1,3);
	DistIndex=DistIndex(1:end-1);

	if i == 1 || mod((i-1),blockSize) == 0

		if TargetColor(order(i)) == 1 %Red CHANGE Right=Up/Left=Down
			PossibleDists{1,1}=Gt;
			PossibleDists{2,1}=Gb;
			Dists=cell(Num_Distractors,1);
			for j=1:Num_Distractors
					Dists{j,1} = PossibleDists{DistIndex(j),1};
					MasterDist{i,j} = Dists{j,1};
			end
				
		else %Green CHANGE Right=Up/Left=Down
			PossibleDists{1,1}=Rt;
			PossibleDists{2,1}=Rb;
			Dists=cell(Num_Distractors,1);
			for j=1:Num_Distractors
					Dists{j,1} = PossibleDists{DistIndex(j),1};
					MasterDist{i,j} = Dists{j,1};
			end
		end
	else	
   	 	if TargetRepetition(order(i)) == 1 %Repeat
        	if TargetColor(order(i-1)) == 1 %Red/Red
            	TargetColor(order(i)) = 1;
            	PossibleDists{1,1}=Gt;
				PossibleDists{2,1}=Gb;
				Dists=cell(Num_Distractors,1);
				for j=1:Num_Distractors
					Dists{j,1} = PossibleDists{DistIndex(j),1};
					MasterDist{i,j} = Dists{j,1};
			    end
        	elseif TargetColor(order(i-1)) == 2 %Green/Green
           		TargetColor(order(i)) = 2;
            	PossibleDists{1,1}=Rt;
				PossibleDists{2,1}=Rb;
				Dists=cell(Num_Distractors,1);
				for j=1:Num_Distractors
					Dists{j,1} = PossibleDists{DistIndex(j),1};
					MasterDist{i,j} = Dists{j,1};
				end
       		end
    	elseif TargetRepetition(order(i)) == 2 % Switch
      		if TargetColor(order(i-1)) == 1 %Red/Green
           		TargetColor(order(i)) = 2;
           		PossibleDists{1,1}=Rt;
				PossibleDists{2,1}=Rb;
				Dists=cell(Num_Distractors,1);
				for j=1:Num_Distractors
					Dists{j,1} = PossibleDists{DistIndex(j),1};
					MasterDist{i,j} = Dists{j,1};
				end
        	elseif TargetColor(order(i-1)) == 2 %Green/Red
           	    TargetColor(order(i)) = 1;
            	PossibleDists{1,1}=Gt;
				PossibleDists{2,1}=Gb;
				Dists=cell(Num_Distractors,1);
				for j=1:Num_Distractors
					Dists{j,1} = PossibleDists{DistIndex(j),1};
					MasterDist{i,j} = Dists{j,1};
				end
        	end
   	    end
	end
end



%ACTUAL START OF SCRIPT (FOR PARTICIPANT)
%As much as possible is defined beforehand to reduce the overhead of the
%calculations that occur in the script, so that the timings of the stimuli
%will be more accurate.
for Trial = 1 : TotalTrial
    

%-----------------------------------------------------------------
%  Choosing Target Type
%-----------------------------------------------------------------


%Change TargetRepetition after breaks.
if Trial == 1 || mod((Trial-1),blockSize) == 0
	TargetRepetition(order(Trial)) = 0;
	Rep_Color_Count = 0;
	Rep_High_Reward = 0;
	Rep_Low_Reward = 0;
    if TargetColor(order(Trial)) == 1 %Red
        if TargetOrientation(order(Trial)) == 1 %Down CHANGE Left
            Target = Rl;
        elseif TargetOrientation(order(Trial)) == 2 %Up CHANGE Right
            Target = Rr;
        end
    elseif TargetColor(order(Trial)) == 2 %Green
        if TargetOrientation(order(Trial)) == 1 %Down CHANGE Left
            Target = Gl;
        elseif TargetOrientation(order(Trial)) == 2 %Up CHANGE Right
            Target = Gr;
        end
    end
elseif Trial > 1 && mod((Trial-1),blockSize) ~= 0
    if TargetRepetition(order(Trial)) == 1 %Repeat
    	Rep_Color_Count = Rep_Color_Count + 1;
        if TargetColor(order(Trial-1)) == 1 %Red/Red
            TargetColor(order(Trial)) = 1;
            if TargetOrientation(order(Trial)) == 1 %Down CHANGE Left
                Target = Rl;
            elseif TargetOrientation(order(Trial)) == 2 %Up CHANGE Right
                Target = Rr;
            end
        elseif TargetColor(order(Trial-1)) == 2 %Green/Green
            TargetColor(order(Trial)) = 2;
            if TargetOrientation(order(Trial)) == 1 %Down CHANGE Left
                Target = Gl;
            elseif TargetOrientation(order(Trial)) == 2 %Up CHANGE Right
                Target = Gr;
            end
        end
    elseif TargetRepetition(order(Trial)) == 2 % Switch
    	Rep_Color_Count = 0;
        if TargetColor(order(Trial-1)) == 1 %Red/Green
            TargetColor(order(Trial)) = 2;
            if TargetOrientation(order(Trial)) == 1 %Down CHANGE Left
                Target = Gl;
            elseif TargetOrientation(order(Trial)) == 2 %Up CHANGE Right
                Target = Gr;
            end
        elseif TargetColor(order(Trial-1)) == 2 %Green/Red
            TargetColor(order(Trial)) = 1;
            if TargetOrientation(order(Trial)) == 1 %Down CHANGE Left
                Target = Rl;
            elseif TargetOrientation(order(Trial)) == 2 %Up CHANGE Right
                Target = Rr;
            end 
        end
    end
end

            


if mod((Trial-1),blockSize) ~= 0
Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
Screen('Flip', window);
WaitSecs(MasterISI(Trial));
FlushEvents('keydown');
end



FlushEvents('keydown');
        
%---------------------------------------------------
% Presenting the Stimuli
%---------------------------------------------------
Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
Screen('PutImage', window, Target, MasterTarLoc(Trial,1:4));
for i=1:Num_Distractors
	Screen('PutImage', window, MasterDist{Trial,i}, MasterDistLoc(i,1:4,Trial));
end

[VBLTimestamp Begin_Time]=Screen('Flip', window);%flips target window, presenting target to subject, and timestamps this to use for RT calculaions below
ElapsedTime = toc * 1000;
cTime=datevec(now);


if exptype == 'e'   

    
    while (GetSecs-Begin_Time) < StimTimeOut
        [keyIsDown, End_Time, KeyCode]=KbCheck;
        
        if keyIsDown
            Key = KbName(KeyCode); %find out which key was pressed
            if ~isequal(Key,'=+')
            	for i=1:Num_Distractors
					Screen('PutImage', window, MasterDist{Trial,i}, MasterDistLoc(i,1:4,Trial));
				end
            Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
            Screen('Flip', window);
            break;
            end
        end
        WaitSecs(0.0001);
    end
    
    if (GetSecs-Begin_Time) >= StimTimeOut
        Resp = 't';
    else
        Resp = KbName(KeyCode);
    end
else % response terminated during practice
    while 1
        [keyIsDown, End_Time, KeyCode]=KbCheck;
        
        if keyIsDown
            break
        end
        WaitSecs(0.0001);
    end   
        Resp = KbName(KeyCode);

end 




%---------------------------------------------------
% Response Coding
%---------------------------------------------------

if strcmp(Resp,Left_Key_Press) %Down CHANGE LEFT '7&'
    Response(Trial) = 1;
elseif strcmp(Resp,Right_Key_Press) %Up CHANGE RIGHT '2@'
	Response(Trial) = 2;
elseif strcmp(Resp,'t') %Timeout
	Response(Trial) = 3;
else
    Response(Trial) = 0; %Invalid response
end
	
if TargetOrientation(order(Trial)) == 1 %Down target CHANGE LEFT TARGET
	if Response(Trial) == 1 %Down Response CHANGE LEFT
		Accuracy(Trial) = 1;
	else %Up Response CHANGE RIGHT RESPONSE
		Accuracy(Trial) = 0;
	end
elseif TargetOrientation(order(Trial)) == 2 %Up Target CHANGE RIGHT TARGET
	if Response(Trial) == 2 %Up Response CHANGE RIGHT RESPONSE
		Accuracy(Trial) = 1;
	else %Down Response CHANGE LEFT RESPONSE
		Accuracy(Trial) = 0;
	end
end

%---------------------------------------------------
% Clear screen between trials
%---------------------------------------------------

Screen(window, 'FillRect', black);
Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
Screen('Flip', window);

%-------------------------------------------------------------------
%James Reward Display
%-------------------------------------------------------------------

if exptype == 'e'

HighBill = imread(High_Reward_Img);
LowBill = imread(Low_Reward_Img);

WaitSecs(RewardWait); %separate response from reward

if TargetReward(order(Trial)) == 1 && Accuracy(Trial) == 1
	Reward(Trial) = 1;
	Rep_High_Reward = 0;
	Screen('PutImage', window, LowBill);           
    Screen(window, 'Flip');
	if Trial ~= 1 && TargetReward(order(Trial-1)) == 1 && Accuracy(Trial-1) == 1
		Rep_Low_Reward=Rep_Low_Reward+1;
	end
elseif TargetReward(order(Trial)) == 2 && Accuracy(Trial) == 1
	Reward(Trial) = 2;
	Rep_Low_Reward = 0;
	Screen('PutImage', window, HighBill);           
    Screen(window, 'Flip');
	if Trial ~= 1 && TargetReward(order(Trial-1)) == 2 && Accuracy(Trial-1) == 1
		Rep_High_Reward=Rep_High_Reward+1;
	end
elseif Accuracy(Trial) == 0
	Rep_High_Reward = 0;
	Rep_Low_Reward = 0;
	Reward(Trial) = 0;
end




WaitSecs(RewardTime);

end

Screen(window, 'FillRect', [0 0 0]);
Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
Screen('Flip', window);   

Screen(window,'TextSize', 24); 

%---------------------------------------------------
% Clear screen after Reward
%---------------------------------------------------

Screen(window, 'FillRect', black);
Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
Screen('Flip', window);               

 
%---------------------------------------------------
% Saving the file
%---------------------------------------------------
   Block(Trial) = ceil(Trial/blockSize);

   RT(Trial)=(End_Time-Begin_Time)*1000; 


    if (Trial>=1) %starts saving data if subject has completed at least 1 trial
       
        Subject = ID;

        FID = fopen(FileName, 'a');
        
        Save = [ order(Trial); Trial; TargetRepetition(order(Trial)); TargetColor(order(Trial)); Rep_Color_Count; TargetOrientation(order(Trial)); TargetLocation(order(Trial)); Subject; Block(Trial); Reward(Trial); Rep_High_Reward; Rep_Low_Reward; Response(Trial); Accuracy(Trial); RT(Trial); ScanStartTime(4); ScanStartTime(5); ScanStartTime(6); cTime(4); cTime(5); cTime(6); ElapsedTime; MasterISI(Trial) ];
        %fprintf(FID, 'order, TSize, TColor, TOrient, TLoc, Subject, Block, Response, Accuracy, RT\n'); 
        fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f, %3.4f, %3.4f, %3.4f, %3.4f, %3.4f, %3.4f, %3.4f\n', Save);
        fclose(FID);
    end

 %-------------------------------------------------------------------
 % Breaks
 %-------------------------------------------------------------------

if exptype == 'e'
 BreakText = ['Take a break.\n\n\n\n\n\n' 'Press SPACEBAR to continue.'];

 if mod(Trial,blockSize) == 0
    DrawFormattedText (window, BreakText, 'center', 'center', white);
    Screen('Flip', window);
    
    FlushEvents('keydown');
    
    while 1
        [keyIsDown, End_Time, KeyCode]=KbCheck;
        Proceed = KbName(KeyCode);
        if strcmp(Proceed,'space')
            break
        end
        WaitSecs(0.0001);
    end
    
    FlushEvents('keydown');
    
    BeginText = ('Prepare to Start');
    DrawFormattedText(window, BeginText, 'center', 'center', white);
    Screen(window, 'Flip');

    tic
    ScanStartTime=datevec(now);
        
    Screen(window, 'FillRect', black);
    Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
    Screen('Flip', window);
    
    WaitSecs(1);
  end
end
  %-------------------End Loop-----------------------------------------    
    
end %closes the for Trial=1:TotalTrial loop

%END OF SCRIPT FOR PARTICIPANT



%----------------------------------------------
% Final conditionals
%----------------------------------------------

if exptype == 'p'
       
    Screen(window,'TextFont', 'Helvetica');
    Screen(window,'TextSize', 24);  
    EndText = ('You have completed practice.');
    DrawFormattedText (window, EndText, 'center', 'center', [255 255 255]);
    Screen('Flip', window);
    KbWait([],2);

    ShowCursor;
    Screen('CloseAll');
    
elseif exptype == 'e'  
    
    Screen(window,'TextFont', 'Helvetica');
    Screen(window,'TextSize', 24);  
    EndText = ['You have completed the experiment.\n' 'Please see experimenter.'];
    DrawFormattedText (window, EndText, 'center', 'center', [255 255 255]);
    Screen('Flip', window);
    KbWait([],2);

    ShowCursor;
    Screen('CloseAll');
end

