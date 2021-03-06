function varargout = GUI_Spec_Register(varargin)

% GUI_SPEC_REGISTER M-file for GUI_Spec_Register.fig
%      GUI_SPEC_REGISTER, by itself, creates a new GUI_SPEC_REGISTER or raises the existing
%      singleton*.
%
%      H = GUI_SPEC_REGISTER returns the handle to a new GUI_SPEC_REGISTER or the handle to
%      the existing singleton*.
%
%      GUI_SPEC_REGISTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_SPEC_REGISTER.M with the given input arguments.
%
%      GUI_SPEC_REGISTER('Property','Value',...) creates a new GUI_SPEC_REGISTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imageProc_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Spec_Register_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help GUI_Spec_Register

% Last Modified by GUIDE v2.5 17-Apr-2015 14:40:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Spec_Register_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Spec_Register_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before GUI_Spec_Register is made visible.
function GUI_Spec_Register_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Spec_Register (see VARARGIN)

% Choose default command line output for GUI_Spec_Register


global Mainfigure
 addpath(genpath('..\tools\MatlabFns'));
 mainGuiInput = find(strcmp(varargin, 'GUI_Spec'));
 if (~isempty(mainGuiInput))
     % Remember the handle, and adjust our position
    handles.Main = varargin{mainGuiInput+1}; 
    %  Obtain handles using GUIDATA with the caller's handle 
    mainHandles = guidata(handles.Main);
    img1 = squeeze(mainHandles.datacube(:,:,mainHandles.reference));
    handles.reference = mainHandles.reference;
    handles.anchor = img1;
    handles.oldanchor = img1;
    axes(handles.axes1); cla; imshow(img1);
    axes(handles.axes1Overview); cla; handles.anchorHandle = imshow(img1);
    set(handles.anchorHandle,'ButtonDownFcn', @(s,e) undoanchor());
    targetNo = floor((mainHandles.reference + length(mainHandles.bandname))/2);
    img2 = squeeze(mainHandles.datacube(:,:,targetNo));
    handles.target = img2;
    handles.oldtarget = img2;
    axes(handles.axes2); cla; imshow(img2);
    axes(handles.axes2Overview); cla; handles.targetHandle = imshow(img2);
    set(handles.targetHandle,'ButtonDownFcn', @(s,e) undotarget());
     
    bandname = mainHandles.bandname;
    handles.datacube = mainHandles.datacube; 
    handles.bandname = mainHandles.bandname; 
    handles.fileLoaded1 = 1;
    handles.fileLoaded2 = 1;
    set(handles.editReference,'String',num2str(bandname(mainHandles.reference)));
    set(handles.editTarget,'String',num2str(bandname(targetNo)));
    interval = bandname(2) - bandname(1);
    slidermin = bandname(1);
    slidermax = bandname(end);
    sliderstep = [interval interval] / (slidermax - slidermin);
    set (handles.SliderWavelength,'Min',slidermin);
    set (handles.SliderWavelength,'Max',slidermax);
    set (handles.SliderWavelength,'SliderStep',sliderstep);
    set (handles.SliderWavelength,'Value',bandname(targetNo));
    set (handles.editWavelength, 'String', bandname(targetNo));

 else 
    handles.datacube = [];
    handles.fileLoaded1  = 0;
    handles.fileLoaded2 = 0;
 end     

handles.anchorCORNERS = 0;
handles.anchorDESCRIPS = 0;
handles.anchorPOINTS = 0;
handles.f = 0;
handles.x1 = [];
handles.x2 = [];

set(handles.editError, 'Visible', 'on');
set(handles.sliderBright, 'Enable', 'on');
set(handles.sliderContrast, 'Enable', 'on');
set(handles.sliderRotate, 'Enable', 'off');
set(handles.editBright,'String', sprintf('%10s:%4.0f%%', 'Brightness', 100*get(handles.sliderBright,'Value')));
set(handles.editContrast,'String', sprintf('%10s:%4.0f%%', 'Contrast', 100*get(handles.sliderContrast,'Value')));
set(handles.editRotate,'String', sprintf('%10s:%4.0f', 'Rotate', get(handles.sliderRotate,'Value')));
handles.output = [];

Mainfigure = handles.figure1;

% Update handles structure
guidata(hObject, handles);

%when we need to output the registration results
%uiwait(hObject);

% UIWAIT makes GUI_Spec_Register wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_Spec_Register_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% when we need to output the registration results, uncomment this sentense
% if ~isempty(handles.output)
%     delete(hObject);
% end

% --- Executes on button press in ButtonHarris.
function ButtonHarris_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonHarris (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.fileLoaded1 == 1 %check the image is loaded
    handles.featuremode = 'Harris'; 
    %anchorC = RMScontrast(handles.anchor);
    %if handles.anchorCORNERS == 0 %it is not time-consuming so just leave it.
    handles.anchorCORNERS = DetectHarris(handles.anchor);
    %end
    axes(handles.axes1);  cla; imshow(handles.anchor);
    hold on;
    plot(floor(handles.anchorCORNERS(:,1)), floor(handles.anchorCORNERS(:,2)),'ro');
    set(handles.AnchorFeatureNo, 'String',sprintf('%10s: %d', 'Harris', size(handles.anchorCORNERS,1)));
else
    h = msgbox('No first file has been loaded!','file warning','warning');
end
if handles.fileLoaded2 == 1 %check the image is loaded
    %targetC = RMScontrast(handles.target); %this one is interesting
    %harrisThreshhold = 0.0005*(targetC/anchorC); 
%     handles.target = imadjust(handles.target); % this makes the features robust to different frames 
    harrisThreshhold = 0.001;
    handles.targetCORNERS = DetectHarris(handles.target, harrisThreshhold);    
%     handles.targetCORNERS = DetectHarris(handles.target); 
    axes(handles.axes2); cla; imshow(handles.target);
    hold on;
    plot(handles.targetCORNERS(:,1), floor(handles.targetCORNERS(:,2)),'g+');
    set(handles.TargetFeatureNo, 'String',sprintf('%10s: %d', 'Harris', size(handles.targetCORNERS,1)));
else
    h = msgbox('No second file has been loaded!','file warning','warning');   
end
guidata(hObject, handles);

function Corners = DetectHarris(img, varargin) %use peter's function

sigma = 3;radius = 1;disp = 0;   
if isempty(varargin) 
    thresh = 0.0005;
else thresh = varargin{1};
end
[~, ~, ~, rsubp, csubp] = harris(img, sigma, thresh, radius, disp);
while length(rsubp) <=3;
    thresh = thresh*0.1;
    [~, ~, ~, rsubp, csubp] = harris(img, sigma, thresh, radius, disp);
    if thresh < 0.000001
       break
    end
end        
Corners = [csubp rsubp];

% --- Executes on button press in ButtonSIFT.
function ButtonSIFT_Callback(hObject, eventdata, handles) 
% hObject    handle to ButtonSIFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%SIFT detection
handles.featuremode = 'SIFT';
if handles.anchorDESCRIPS == 0
    [image, descrips, locs] = sift(handles.anchor);
    handles.anchorDESCRIPS = descrips;
    handles.anchorLOCS = locs;
end
axes(handles.axes1);cla;
imshow(handles.anchor); 
hold on;
imsize = size(handles.anchor);
for i = 1: size(handles.anchorLOCS,1)
   % Draw an arrow, each line transformed according to keypoint parameters.
   TransformLine(imsize, handles.anchorLOCS(i,:), 0.0, 0.0, 1.0, 0.0, 'r');
   TransformLine(imsize, handles.anchorLOCS(i,:), 0.85, 0.1, 1.0, 0.0, 'r');
   TransformLine(imsize, handles.anchorLOCS(i,:), 0.85, -0.1, 1.0, 0.0, 'r');
end
hold off;
set(handles.AnchorFeatureNo, 'String',sprintf('%10s: %d', 'SIFT', size(handles.anchorLOCS,1)));

[image, descrips, locs] = sift(handles.target);
handles.targetDESCRIPS = descrips;
handles.targetLOCS = locs;
axes(handles.axes2);cla;
imshow(handles.target); 
hold on;
imsize = size(image);
for i = 1: size(locs,1)
    % Draw an arrow, each line transformed according to keypoint parameters.
    TransformLine(imsize, locs(i,:), 0.0, 0.0, 1.0, 0.0, 'g');
    TransformLine(imsize, locs(i,:), 0.85, 0.1, 1.0, 0.0, 'g');
    TransformLine(imsize, locs(i,:), 0.85, -0.1, 1.0, 0.0, 'g');
end
hold off;
set(handles.TargetFeatureNo, 'String',sprintf('%10s: %d', 'SIFT', size(handles.targetLOCS,1)));
guidata(hObject, handles);

function Features = DetectSIFT(img) %auther's SIFT codes

[~, ~, locs] = sift(img);
Features(:,1) = locs(:,2);
Features(:,2) = locs(:,1);

% --- Executes on button press in SharpButton.
function SharpButton_Callback(hObject, eventdata, handles)
% hObject    handle to SharpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%H = fspecial('unsharp');
%handles.target = imfilter( handles.target,H,'replicate');

handles.anchor = imsharpen(handles.anchor);
axes(handles.axes1); imshow(handles.anchor);

handles.target = imsharpen(handles.target);
axes(handles.axes2); imshow(handles.target);
guidata(hObject, handles);

% --- Executes on button press in ButtonMSER.
function ButtonMSER_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonMSER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%matlab mser detection
handles.featuremode = 'MSER';
anchor_REGIONS = detectMSERFeatures(handles.anchor);
handles.anchorREGIONS = anchor_REGIONS;
axes(handles.axes1); imshow(handles.anchor);
hold on;
plot(handles.anchorREGIONS);
set(handles.AnchorFeatureNo, 'String',sprintf('%10s: %d', 'MSER', length(handles.anchorREGIONS)));


target_REGIONS = detectMSERFeatures(handles.target);
handles.targetREGIONS = target_REGIONS;

axes(handles.axes2); imshow(handles.target);
hold on;
plot(target_REGIONS);
set(handles.TargetFeatureNo, 'String',sprintf('%10s: %d', 'MSER', length(handles.targetREGIONS)));
guidata(hObject, handles);

% --- Executes on button press in ButtonSURF.
function ButtonSURF_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonSURF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%matlab surf detection
handles.featuremode = 'SURF';
anchor_POINTS = detectSURFFeatures(handles.anchor);
handles.anchorPOINTS = anchor_POINTS;
axes(handles.axes1); imshow(handles.anchor);
hold on;
plot(handles.anchorPOINTS);
set(handles.AnchorFeatureNo, 'String',sprintf('%10s: %d', 'SURF', length(handles.anchorPOINTS)));


target_POINTS = detectSURFFeatures(handles.target);
handles.targetPOINTS = target_POINTS;

axes(handles.axes2); imshow(handles.target);
hold on;
plot(target_POINTS);
set(handles.TargetFeatureNo, 'String',sprintf('%10s: %d', 'SURF', length(handles.targetPOINTS)));
guidata(hObject, handles);

% --- Executes on button press in ButtonReplace.
function ButtonReplace_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonReplace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

register = handles.register;
band = get(handles.SliderWavelength, 'Value');
handles.target = register;
handles.oldtarget = register;
handles.datacube(:,:,floor((band-handles.bandname(1))/10+1)) = register;
%speed up the applyT procedure 
%axes(handles.axes2); imshow(handles.target); 
guidata(hObject, handles);

% --- Executes on button press in ButtonMatch.
function ButtonMatch_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonMatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (handles.fileLoaded1==1)
   anchor = handles.anchor;
   target = handles.target;
   maxerror = 8; %the square of the maxinum of the displacement
   switch handles.featuremode
       case 'Harris'
           indexPairs = matchFeatures(handles.anchorCORNERS, handles.targetCORNERS,'Method','NearestNeighborSymmetric') ;
           allmatched_pts1 = handles.anchorCORNERS(indexPairs(:, 1),:);
           allmatched_pts2 = handles.targetCORNERS(indexPairs(:, 2),:);
%            n2 = dist2(allmatched_pts1, allmatched_pts2);
%            index = find(n2 < maxerror);
%            matched_pts1 = allmatched_pts1(index,:);
%            matched_pts2 = allmatched_pts2(index,:); 
             matched_pts1 = allmatched_pts1;
             matched_pts2 = allmatched_pts2; 
           %figure; showMatchedFeatures(anchor,target, matched_pts1,matched_pts2, 'montage');        
       case 'SURF'
           [f1, vpts1] = extractFeatures(handles.anchor, handles.anchorPOINTS);
           [f2, vpts2] = extractFeatures(handles.target, handles.targetPOINTS);
           indexPairs = matchFeatures(f1, f2, 'Method','NearestNeighborSymmetric','MatchThreshold',50) ;
           matched_pts1 = vpts1(indexPairs(:, 1)).Location;
           matched_pts2 = vpts2(indexPairs(:, 2)).Location;
           %figure; showMatchedFeatures(anchor,target, matched_pts1,matched_pts2, 'montage'); 
       case 'SIFT'
           f1 = handles.anchorDESCRIPS;
           f2 = handles.targetDESCRIPS;
           %f1 = handles.anchorLOCS;
           %f2 = handles.targetLOCS;
           indexPairs = matchFeatures(f1, f2, 'Method','NearestNeighborSymmetric','MatchThreshold',90);
           matched_pts1 = [handles.anchorLOCS(indexPairs(:, 1),2) handles.anchorLOCS(indexPairs(:, 1),1)];
           matched_pts2 = [handles.targetLOCS(indexPairs(:, 2),2) handles.targetLOCS(indexPairs(:, 2),1)];
            %figure;showMatchedFeatures(anchor,target, matched_pts1,matched_pts2, 'montage'); 
       case 'MSER'
           [f1, vpts1] = extractFeatures(handles.anchor, handles.anchorREGIONS);
           [f2, vpts2] = extractFeatures(handles.target, handles.targetREGIONS);
           indexPairs = matchFeatures(f1, f2, 'Method','NearestNeighborSymmetric','MatchThreshold',2) ;
           matched_pts1 = vpts1(indexPairs(:, 1)).Location;
           matched_pts2 = vpts2(indexPairs(:, 2)).Location;
       otherwise      
   end    
   handles.anchorfeatures = matched_pts1;
   handles.targetfeatures = matched_pts2;
   disp(size(matched_pts1,1));
end

if ~isempty(matched_pts1) || ~isempty(matched_pts2)
     
     MaxNumTrials = 2000;
     Confidence = 99;
     MaxDistance = 3; 
     
     [tform, x2, x1, status] = estimateGeometricTransform(matched_pts2,matched_pts1, 'projective',...
         'MaxNumTrials',MaxNumTrials,'Confidence',Confidence, 'MaxDistance',MaxDistance ); % MSAC algorithm,a variant of the RANSAC algorithm
     
     
%       matched_pts1 = matched_pts1';
% %      matched_pts1(3,:) = ones(1, size(matched_pts1,2));
%       matched_pts2 = matched_pts2';
% %      matched_pts2(3,:) = ones(1, size(matched_pts2,2));
    
     
%      t = 0.05;
%      [H, inliers] = ransacfithomography(matched_pts2, matched_pts1, t);
%      x1 = matched_pts1(:,inliers);
% 	 x2 = matched_pts2(:,inliers);
     H = tform.T; 
     assignin('base', 'H',H);
%      handles.x1 = x1;
%      handles.x2 = x2; 
    
     axes(handles.axes1);cla;
     showMatchedFeatures(anchor, handles.target, x1, x2);
     legend('anchor', 'target');title(sprintf('%d %16s', length(x1), 'Features Matched'));
   
%      register = imTrans(target, H);
%      axes(handles.axes2);cla;
%      imshowpair(handles.anchor, register,'ColorChannels','red-cyan','Scaling','independent');
 
    register = imwarp(target, tform, 'OutputView', imref2d(size(anchor)));
    axes(handles.axes2);cla;
    imshowpair(handles.anchor, register,'ColorChannels','red-cyan','Scaling','independent');
    
    handles.register = register;
    handles.transform = tform;
    set(handles.UitableT, 'Data', H);
  %   disp(length(x1));
end
guidata(hObject, handles);    


function editError_Callback(hObject, eventdata, handles)
% hObject    handle to editError (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editError as text
%        str2double(get(hObject,'String')) returns contents of editError as a double

% --- Executes during object creation, after setting all properties.
function editError_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editError (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPath_Callback(hObject, eventdata, handles)
% hObject    handle to editPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPath as text
%        str2double(get(hObject,'String')) returns contents of editPath as a double

% --- Executes during object creation, after setting all properties.
function editPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sliderBright_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.editBright,'String', sprintf('%10s:%4.0f%%', 'Brightness', 100*get(handles.sliderBright,'Value')));

% --- Executes during object creation, after setting all properties.
function sliderBright_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function sliderContrast_Callback(hObject, eventdata, handles)
% hObject    handle to sliderContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.editContrast,'String', sprintf('%10s:%4.0f%%', 'Contrast', 100*get(handles.sliderContrast,'Value')));

% --- Executes during object creation, after setting all properties.
function sliderContrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editBright_Callback(hObject, eventdata, handles)
% hObject    handle to editBright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBright as text
%        str2double(get(hObject,'String')) returns contents of editBright as a double

% --- Executes during object creation, after setting all properties.
function editBright_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editContrast_Callback(hObject, eventdata, handles)
% hObject    handle to editContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editContrast as text
%        str2double(get(hObject,'String')) returns contents of editContrast as a double
% --- Executes during object creation, after setting all properties.
function editContrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbuttonContrastBrightness.
function pushbuttonContrastBrightness_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonContrastBrightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.target = imadjust(handles.target);%(handles.target, get(handles.sliderBright, 'Value'), get(handles.sliderContrast, 'Value'));
axes(handles.axes2); imshow(handles.target );
%handles = updateHistograms(handles);
guidata(hObject, handles);

function handlesNew = updateHistograms(handles)
handlesNew = handles;
if (handles.fileLoaded1 == 1)
    set(handles.textHist1, 'Visible', 'on');
    axes(handlesNew.axesHist1); 
    cla;
    ImageData1 = reshape(handlesNew.anchor, [size(handlesNew.RGB, 1) * size(handlesNew.RGB, 2) 1]);
    [H1, X1] = hist(ImageData1, 1:5:256);
    hold on;
    plot(X1, H1, 'r');   
    axis([0 256 0 max(H1)]);
end
if (handlesNew.fileLoaded2 == 1)
    set(handles.textHist2, 'Visible', 'on');
    axes(handlesNew.axesHist2); 
    cla;
    ImageData1 = reshape(handlesNew.target, [size(handlesNew.target, 1) * size(handlesNew.target, 2) 1]);
   
    [H1, X1] = hist(ImageData1, 1:5:256);
    hold on;
    plot(X1, H1, 'g');
 
    axis([0 256 0 max(H1)]);    
end

% --- Executes on button press in RotateButton.
function RotateButton_Callback(hObject, eventdata, handles)
% hObject    handle to RotateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.RGB2 = imrotate(handles.RGB, round(get(handles.sliderRotate,'Value')));
handles.fileLoaded1 = 1;

axes(handles.axes2); cla; imshow(handles.RGB2);

handles = updateHistograms(handles);

guidata(hObject, handles);

% --- Executes on slider movement.
function sliderRotate_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.editRotate,'String', sprintf('%10s:%4.0f', 'Rotate', round(get(handles.sliderRotate,'Value'))));

% --- Executes during object creation, after setting all properties.
function sliderRotate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editRotate_Callback(hObject, eventdata, handles)
% hObject    handle to editRotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRotate as text
%        str2double(get(hObject,'String')) returns contents of editRotate as a double
% --- Executes during object creation, after setting all properties.
function editRotate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--- Executes on button press in ButtonAutoRegister.
function ButtonAutoRegister_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonAutoRegister (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
method = get(handles.popupmenu1, 'value');

 


if isempty(handles.datacube)
  %  handles.target = imadjust(handles.target); % this makes the features robust to different frames 
    switch method
        case 1
        ButtonHarris_Callback(hObject, eventdata, handles);
        handles = guidata(gcf);
        ButtonMatch_Callback(hObject, eventdata, handles);
        handles = guidata(gcf);
        ButtonTransform_Callback(hObject, eventdata, handles);
        handles = guidata(gcf);
        case 2
        ButtonIterate_Callback(hObject, eventdata, handles);
        handles = guidata(gcf);         
    end
            
else
    [~, ~, b] = size(handles.datacube);
    anchorNo = handles.reference;
    similarity = zeros(b,5);
    similarityold = zeros(b,5);
    scale = zeros(b,1);
    theta = zeros(b,1);
    tx = zeros(b,1);
    ty = zeros(b,1);
    betterTransform = affine2d([1 0 0;0 1 0;0 0 1]);
    bandname = handles.bandname';
    for i = anchorNo-1:-1: 1 % from middle to left 
        set(handles.SliderWavelength, 'Value',handles.bandname(i));
        set(handles.editWavelength, 'String', num2str(handles.bandname(i)));
        set(handles.editTarget,'String',num2str(handles.bandname(i)));
        handles.target = squeeze(handles.datacube(:,:,i));  
        handles.oldtarget = handles.target;
        similarityold(i,:) = updateSimilarity(handles.anchor,handles.target);
        
        switch method
        case 1
            ButtonHarris_Callback(hObject, eventdata, handles);
            handles = guidata(gcf);
            ButtonMatch_Callback(hObject, eventdata, handles);
            handles = guidata(gcf);


            ButtonTransform_Callback(hObject, eventdata, handles);
            handles = guidata(gcf);
            similarity(i,:) = handles.similarity;
            %check the tramform is good or not. if not good, use the former
            %good transform
            if similarity(i,2) < similarityold(i,2)
                ButtonReplace_Callback(hObject, eventdata, handles);
                betterTransform = handles.transform;
                handles = guidata(gcf);
            else
                handles.transform = betterTransform;
                ButtonTransform_Callback(hObject, eventdata, handles);
                handles = guidata(gcf);
                ButtonReplace_Callback(hObject, eventdata, handles);
                handles = guidata(gcf);
                similarity(i,:) = handles.similarity;
            end  
        
        case 2
            ButtonMI_Callback(hObject, eventdata, handles);
            handles = guidata(gcf); 
            similarity(i,:) = handles.similarity;
            
        end
                
        
         %get the real transform parameters
        T = handles.transform.T;
        ss = T(2,1);
        sc = T(1,1);
        scale(i) = sqrt(ss*ss + sc*sc);
        theta(i) = atan2(ss,sc)*180/pi;
        tx(i) = T(3,1);
        ty(i) = T(3,2);
        save('data_iteration.mat', 'bandname','scale','theta','tx','ty','similarityold','similarity');
        disp(i);
       % get(handles.textSSD, 'String',sprintf('%4s %4.1f','SSD:',ssd));  
    end
    betterTransform = affine2d([1 0 0;0 1 0;0 0 1]);
    for i = anchorNo: b % from middle to left 
        set(handles.SliderWavelength, 'Value',handles.bandname(i));
        set(handles.editWavelength, 'String', num2str(handles.bandname(i)));
        set(handles.editTarget,'String',num2str(handles.bandname(i)));
        handles.target = squeeze(handles.datacube(:,:,i));  
        handles.oldtarget = handles.target;
        similarityold(i,:) = updateSimilarity(handles.anchor,handles.target);
        %handles.target = imadjust(handles.target); % this makes the features robust to different frames 
       switch method
        case 1
            ButtonHarris_Callback(hObject, eventdata, handles);
            handles = guidata(gcf);
            ButtonMatch_Callback(hObject, eventdata, handles);
            handles = guidata(gcf);


            ButtonTransform_Callback(hObject, eventdata, handles);
            handles = guidata(gcf);
            similarity(i,:) = handles.similarity;
            %check the tramform is good or not. if not good, use the former
            %good transform
            if similarity(i,2) < similarityold(i,2)
                ButtonReplace_Callback(hObject, eventdata, handles);
                betterTransform = handles.transform;
                handles = guidata(gcf);
            else
                handles.transform = betterTransform;
                ButtonTransform_Callback(hObject, eventdata, handles);
                handles = guidata(gcf);
                ButtonReplace_Callback(hObject, eventdata, handles);
                handles = guidata(gcf);
                similarity(i,:) = handles.similarity;
            end  
        
        case 2
            ButtonMI_Callback(hObject, eventdata, handles);
            handles = guidata(gcf); 
            similarity(i,:) = handles.similarity;
            
        end
        
        
        T = handles.transform.T;
        ss = T(2,1);
        sc = T(1,1);
        scale(i) = sqrt(ss*ss + sc*sc);
        theta(i) = atan2(ss,sc)*180/pi;
        tx(i) = T(3,1);
        ty(i) = T(3,2);
         save('data_iteration.mat', 'bandname','scale','theta','tx','ty','similarityold','similarity');
         disp(i);
       % get(handles.textSSD, 'String',sprintf('%4s %4.1f','SSD:',ssd));  
    end
    
%     figure, plot(handles.bandname,similarityold(:,1),'r',handles.bandname,similarity(:,1),'g');
%     title('SSD');
    figure, plot(handles.bandname,similarityold(:,2),'r',handles.bandname,similarity(:,2),'g');
    title('SID');
%     figure, plot(handles.bandname,similarityold(:,3),'r',handles.bandname,similarity(:,3),'g');
%     title('SGD');
    figure, plot(handles.bandname,similarityold(:,4),'r',handles.bandname,similarity(:,4),'g');
    title('SMI');
    figure, plot(handles.bandname,similarityold(:,5),'r',handles.bandname,similarity(:,5),'g');
    title('CCRE');
    figure, plot(handles.bandname,scale','r');
    title('scale');
    figure, plot(handles.bandname,theta','r');
    title('theta');
    figure, plot(handles.bandname,tx','r');
    title('tx');
    figure, plot(handles.bandname,ty','r');
    title('ty');


end
guidata(hObject, handles); 
% 
% %%this function is for manually register all the bands
% % function ButtonAutoRegister_Callback(hObject, eventdata, handles)
% % % hObject    handle to ButtonAutoRegister (see GCBO)
% % % eventdata  reserved - to be defined in a future version of MATLAB
% % % handles    structure with handles and user data (see GUIDATA)
% % 
% load data.mat;
% 
% if isempty(handles.datacube)
%     handles.target = imadjust(handles.target); % this makes the features robust to different frames 
%     ButtonHarris_Callback(hObject, eventdata, handles);
%     handles = guidata(gcf);
%     ButtonMatch_Callback(hObject, eventdata, handles);
%     handles = guidata(gcf);
%     ButtonTransform_Callback(hObject, eventdata, handles);
%     handles = guidata(gcf);
% else
%     [~, ~, b] = size(handles.datacube);
%     anchorNo = handles.reference;
% %     similarity = zeros(b,5);
% %     similarityold = zeros(b,5);
% %     scale = zeros(b,1);
% %     theta = zeros(b,1);
% %     tx = zeros(b,1);
% %     ty = zeros(b,1);
%    % betterTransform = affine2d([1 0 0;0 1 0;0 0 1]);
%   %  for i = anchorNo-11:-1: 1 % from middle to left 
%    for i = anchorNo-1: 1 % from middle to left 
%         set(handles.SliderWavelength, 'Value',handles.bandname(i));
%         set(handles.editWavelength, 'String', num2str(handles.bandname(i)));
%         set(handles.editTarget,'String',num2str(handles.bandname(i)));
%         handles.target = squeeze(handles.datacube(:,:,i));  
%         handles.oldtarget = handles.target;
%         similarityold(i,:) = updateSimilarity(handles.anchor,handles.target);
%         handles.target = imadjust(handles.target); % this makes the features robust to different frames 
%       %  ButtonHarris_Callback(hObject, eventdata, handles);
%       %  handles = guidata(gcf);
%       %  ButtonMatch_Callback(hObject, eventdata, handles);
%         ButtonManual_Callback(hObject, eventdata, handles);
%         handles = guidata(gcf);
%         
%         %get the real transform parameters
%         T = handles.transform.T;
%         ss = T(2,1);
%         sc = T(1,1);
%         scale(i) = sqrt(ss*ss + sc*sc);
%         theta(i) = atan2(ss,sc)*180/pi;
%         tx(i) = T(3,1);
%         ty(i) = T(3,2);
%         
%         
%         
%         
%        % ButtonTransform_Callback(hObject, eventdata, handles);
%        % handles = guidata(gcf);
%         similarity(i,:) = handles.similarity;
%         save('data.mat', 'similarityold','similarity','scale','theta','tx','ty');
%         %check the tramform is good or not. if not good, use the former
%         %good transform
% %         if similarity(i,2) < similarityold(i,2)
% %             ButtonReplace_Callback(hObject, eventdata, handles);
% %             betterTransform = handles.transform;
% %             handles = guidata(gcf);
% %         else
% %             handles.transform = betterTransform;
% %             ButtonTransform_Callback(hObject, eventdata, handles);
% %             handles = guidata(gcf);
% %             ButtonReplace_Callback(hObject, eventdata, handles);
% %             handles = guidata(gcf);
% %             similarity(i,:) = handles.similarity;
% %         end  
%        % get(handles.textSSD, 'String',sprintf('%4s %4.1f','SSD:',ssd));  
%     end
%    % betterTransform = affine2d([1 0 0;0 1 0;0 0 1]);
%     for i = 24: b % from middle to left 
%         set(handles.SliderWavelength, 'Value',handles.bandname(i));
%         set(handles.editWavelength, 'String', num2str(handles.bandname(i)));
%         set(handles.editTarget,'String',num2str(handles.bandname(i)));
%         handles.target = squeeze(handles.datacube(:,:,i));  
%         handles.oldtarget = handles.target;
%         similarityold(i,:) = updateSimilarity(handles.anchor,handles.target);
%         handles.target = imadjust(handles.target); % this makes the features robust to different frames 
%       %  ButtonHarris_Callback(hObject, eventdata, handles);
%       %  handles = guidata(gcf);
%       %  ButtonMatch_Callback(hObject, eventdata, handles);
%         ButtonManual_Callback(hObject, eventdata, handles);
%         handles = guidata(gcf);
%         
%         %get the real transform parameters
%         T = handles.transform.T;
%         ss = T(2,1);
%         sc = T(1,1);
%         scale(i) = sqrt(ss*ss + sc*sc);
%         theta(i) = atan2(ss,sc)*180/pi;
%         tx(i) = T(3,1);
%         ty(i) = T(3,2);
%         
%         
%         
%         
%        % ButtonTransform_Callback(hObject, eventdata, handles);
%        % handles = guidata(gcf);
%         similarity(i,:) = handles.similarity;
%         %check the tramform is good or not. if not good, use the former
%         %good transform
% %         if similarity(i,2) < similarityold(i,2)
% %             ButtonReplace_Callback(hObject, eventdata, handles);
% %             betterTransform = handles.transform;
% %             handles = guidata(gcf);
% %         else
% %             handles.transform = betterTransform;
% %             ButtonTransform_Callback(hObject, eventdata, handles);
% %             handles = guidata(gcf);
% %             ButtonReplace_Callback(hObject, eventdata, handles);
% %             handles = guidata(gcf);
% %             similarity(i,:) = handles.similarity;
% %         end  
%        % get(handles.textSSD, 'String',sprintf('%4s %4.1f','SSD:',ssd));  
%        save('data.mat', 'similarityold','similarity','scale','theta','tx','ty');
%     end
%  
%     
% %     figure, plot(handles.bandname,similarityold(:,1),'r',handles.bandname,similarity(:,1),'g');
% %     title('SSD');
%     figure, plot(handles.bandname,similarityold(:,2),'r',handles.bandname,similarity(:,2),'g');
%     title('SID');
% %     figure, plot(handles.bandname,similarityold(:,3),'r',handles.bandname,similarity(:,3),'g');
% %     title('SGD');
%     figure, plot(handles.bandname,similarityold(:,4),'r',handles.bandname,similarity(:,4),'g');
%     title('SMI');
% %     figure, plot(handles.bandname,similarityold(:,5),'r',handles.bandname,similarity(:,5),'g');
% %     title('CCRE');
%     figure, plot(handles.bandname,scale','r');
%     title('scale');
%     figure, plot(handles.bandname,theta','r');
%     title('theta');
%     figure, plot(handles.bandname,tx','r');
%     title('tx');
%     figure, plot(handles.bandname,ty','r');
%     title('ty');
% 
% 
% end
% guidata(hObject, handles); 

function TransformLine(imsize, keypoint, x1, y1, x2, y2, color)

% The scaling of the unit length arrow is set to approximately the radius
%   of the region used to compute the keypoint descriptor.
len = 6 * keypoint(3);

% Rotate the keypoints by 'ori' = keypoint(4)
s = sin(keypoint(4));
c = cos(keypoint(4));

% Apply transform
r1 = keypoint(1) - len * (c * y1 + s * x1);
c1 = keypoint(2) + len * (- s * y1 + c * x1);
r2 = keypoint(1) - len * (c * y2 + s * x2);
c2 = keypoint(2) + len * (- s * y2 + c * x2);

line([c1 c2], [r1 r2], 'Color', color);

function editReference_Callback(hObject, eventdata, handles)
% hObject    handle to editReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editReference as text
%        str2double(get(hObject,'String')) returns contents of editReference as a double
% --- Executes during object creation, after setting all properties.
function editReference_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editTarget_Callback(hObject, eventdata, handles)
% hObject    handle to editTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTarget as text
%        str2double(get(hObject,'String')) returns contents of editTarget as a double


% --- Executes during object creation, after setting all properties.
function editTarget_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

delete(hObject);

%comment the following when output
%handles.output = [];
%guidata(hObject, handles);
%uiresume(handles.figure1);

% --- Executes on slider movement.
function SliderWavelength_Callback(hObject, eventdata, handles)
% hObject    handle to SliderWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
band = get(hObject, 'Value');
set(handles.editWavelength, 'String', num2str(band));
slice = squeeze(handles.datacube(:,:,floor((band-handles.bandname(1))/10+1)));
set(handles.editTarget,'String',num2str(handles.bandname(floor((band-handles.bandname(1))/10+1))));
axes(handles.axes2); cla; imshow(slice);
axes(handles.axes2Overview); cla; handles.targetHandle = imshow(slice);
set(handles.targetHandle,'ButtonDownFcn', @(s,e) undotarget());

handles.target = slice;
handles.oldtarget = slice;

if get(handles.radioSimilarityUpdate,'value')
    updateSimilarity(handles.anchor,handles.target);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SliderWavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function editWavelength_Callback(hObject, eventdata, handles)
% hObject    handle to editWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWavelength as text
%        str2double(get(hObject,'String')) returns contents of editWavelength as a double

% --- Executes during object creation, after setting all properties.
function editWavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in ButtonTransform.
function ButtonTransform_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to ButtonTransform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ButtonTransform
dispOptim = true;
if ~isempty(varargin)
    dispOptim = false;
end
target = handles.oldtarget;
tform = handles.transform;
register = imwarp(target, tform, 'OutputView', imref2d(size(target)));
handles.register = register;
axes(handles.axes2);cla;
imshowpair(handles.anchor, register, 'diff');
% similarityold = updateSimilarity(handles.anchor,handles.target);
% handles.similarity = updateSimilarity(handles.anchor,handles.register);
% if isempty(handles.x1)
%     % to speed up the procedure
%     if dispOptim
%         axes(handles.axes2);cla;
%         imshowpair(handles.anchor, imadjust(register),'ColorChannels','red-cyan','Scaling','independent');
%         set(handles.editError, 'String',sprintf('%4s %.0f %2s %.0f %4s %.4f %2s %.4f',...
%             'SID:', similarityold(2),'to',handles.similarity(2), 'SMI:', similarityold(4),'to',handles.similarity(4)));
%     end
% else    
%     x2p = transformPointsForward(tform, handles.x2);
%     axes(handles.axes2);cla;
%     showMatchedFeatures(handles.anchor, imadjust(register), handles.x1, x2p); 
%     legend('anchor', 'register');
%     title('Matched Features after registration');
%     %axes(handles.axes2); cla; imshow(register);
%     diff = (handles.x1-x2p).^2;
%     sumerr = sum(diff(:,1) + diff(:,2));    
%     err = sqrt(sumerr/size(x2p,1));
%     olderr = sscanf(get(handles.TextError, 'String'),'%*s %f %*s %f');
%     set(handles.editError, 'String',sprintf('%8s %2.3f %2s %2.3f %4s %.0f %2s %.0f %4s %.4f %2s %.4f',...
%     'F_error:', olderr(1),'to',err,...
%     'SID:', similarityold(2),'to',handles.similarity(2),...
%     'SMI:', similarityold(4),'to',handles.similarity(4)));
% end

%handles = guidata(gcf);
guidata(hObject, handles);    

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in ButtonOptimize.
function ButtonOptimize_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonOptimize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x1 = handles.x1;
x2 = handles.x2; 
xdata = [x1, ones(size(x1,1),1)];
ydata = [x2, ones(size(x2,1),1)];

t0 = handles.transform.T;
options = optimoptions('lsqcurvefit','Display','iter','TolFun',1e-10,'Algorithm','levenberg-marquardt');
[t, resnorm, residual, exitflag] = lsqcurvefit(@myfun,t0,xdata,ydata,-Inf,Inf,options);
t(:,3) = [0 0 1]';
tform = affine2d(t); 
set(handles.UitableT, 'Data', t);

band = get(handles.SliderWavelength, 'Value');
target = squeeze(handles.datacube(:,:,floor((band-handles.bandname(1))/10+1)));

register = imwarp(target, tform, 'OutputView', imref2d(size(target)));
x2p = transformPointsForward(tform, handles.x2);
figure(3);
showMatchedFeatures(handles.anchor, register, handles.x1, x2p);
legend('anchor', 'register');
handles.target = register;
axes(handles.axes2); cla; imshow(register);
diff = (handles.x1-x2p).^2;
sumerr = sum(diff(:,1) + diff(:,2));    
err = sqrt(sumerr/size(x2p,1));

[r, c, img2] = find(register);
linearInd = sub2ind(size(target), r, c);
img1 = handles.anchor(linearInd); 
pixelError = sqrt( sum(sum((img1 - img2).^2))/numel(img1));
olderr = sscanf(get(handles.TextError, 'String'),'%*s %f %*s %f');
set(handles.editError, 'String',sprintf('%8s %2.3f %2s %2.3f %8s %1.6f %2s %1.6f ',...
    'F_error:', olderr(1),'to',err, 'P_error:', olderr(2),'to',pixelError*255));

guidata(hObject, handles); 

function F = myfun(t,xdata)
F = xdata*t;

% --- Executes on button press in ButtonMI.
function ButtonMI_Callback(hObject, eventdata, handles, varargin)
% hObject    handle to ButtonMI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%band = get(handles.SliderWavelength, 'Value');
%target = squeeze(handles.datacube(:,:,floor((band-handles.bandname(1))/10+1)));
dispOptim = true;
if ~isempty(varargin)
    dispOptim = false;
end
anchor = handles.anchor;
% target = handles.target;
target = handles.register; % optimize the manual result

% optimizer = registration.optimizer.OnePlusOneEvolutionary;
% optimizer.GrowthFactor = 1.05;
% optimizer.Epsilon = 1.5e-6;
% optimizer.InitialRadius = 6.25e-3;
% optimizer.MaximumIterations = 300;
% metric = registration.metric.MattesMutualInformation;
% metric = registration.metric.MeanSquares;

% tic
% tform = imregtform(target, anchor, 'affine', optimizer, metric, ...
%         'DisplayOptimization', true, 'PyramidLevels', 2 );
% [optimizer, metric] = imregconfig('monomodal');
[optimizer, metric] = imregconfig('multimodal');
%  
optimizer.GrowthFactor = 1.01; % If you set GrowthFactor to a small value, the optimization is slower, but it is likely to convergeon a better solution. The default value of GrowthFactor is 1.05.
optimizer.InitialRadius = 6.25e-4; %   If you set InitialRadius toa large value, the computation time decreases. ...
%However, overly largevalues of InitialRadius might result in an optimizationthat fails to converge. The default value of InitialRadius is 6.25e-3.
optimizer.Epsilon = 1.5e-6; % If you set Epsilon to a small value, the optimization of the metric is more accurate, but the computation takeslonger. The defaultvalue of Epsilon is 1.5e-6.
optimizer.MaximumIterations = 300;

% tform = imregtform(target, anchor, 'affine', optimizer, metric,  'DisplayOptimization', true, 'InitialTransformation',handles.transform);

 tform = imregtform(target, anchor, 'affine', optimizer, metric,  'DisplayOptimization', true);
%tform = imregtform2(target, anchor);
register = imwarp(target, tform, 'OutputView', imref2d(size(anchor)));
handles.transform = tform;
handles.register = register;
assignin('base', 'register',register);
% similarityold = updateSimilarity(handles.anchor,handles.target);
% handles.similarity = updateSimilarity(handles.anchor,handles.register);
if dispOptim
    set(handles.UitableT, 'Data', tform.T);
    axes(handles.axes1);
    imshowpair(anchor, target, 'ColorChannels','red-cyan','Scaling','independent');
    title('falsecolor overlaid unregistered images');
    axes(handles.axes2);
    imshowpair(anchor, register, 'ColorChannels','red-cyan','Scaling','independent');
    title('falsecolor overlaid registered images');

%     set(handles.editError, 'String',sprintf('%2.2f %4s %.0f %2s %.0f %4s %.4f %2s %.4f',...
%             timeDefault, 'SID:', similarityold(2),'to',handles.similarity(2), 'SMI:', similarityold(4),'to',handles.similarity(4)));
    T = handles.transform.T;
    ss = T(2,1);
    sc = T(1,1);
    scale = sqrt(ss*ss + sc*sc);
    theta = atan2(ss,sc)*180/pi;
    tx = T(3,1);
    ty = T(3,2);
    disp(scale);
    disp(theta);
    disp(tx);
    disp(ty);    
end


guidata(hObject, handles); 

% --- Executes on button press in ButtonSID.
function ButtonSID_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonSID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

anchor = handles.anchor;
target = handles.target;

%[optimizer,metric] = imregconfig('multimodal');
% 
optimizer = registration.optimizer.OnePlusOneEvolutionary;
% optimizer.GrowthFactor = 0.01;
% optimizer.Epsilon = 1;
optimizer.MaximumIterations = 300;
%metric = registration.metric.MattesMutualInformation;
metric = registration.metric.MeanSquares;

tic
tform = imregtform(target, anchor, 'similarity', optimizer, metric, 'DisplayOptimization', true, 'PyramidLevels',2);
register = imwarp(target, tform, 'OutputView', imref2d(size(target)));
timeDefault = toc;
handles.transform = tform;
handles.register = register;
set(handles.UitableT, 'Data', tform.T);
axes(handles.axes1);
imshowpair(anchor, target, 'ColorChannels','red-cyan','Scaling','independent');
title('falsecolor overlaid unregistered images');
axes(handles.axes2); imshowpair(anchor, register, 'ColorChannels','red-cyan','Scaling','independent');
title('falsecolor overlaid registered images');
% similarityold = updateSimilarity(handles.anchor,handles.target);
% handles.similarity = updateSimilarity(handles.anchor,handles.register);
% set(handles.editError, 'String',sprintf('%2.2f %4s %.0f %2s %.0f %4s %.4f %2s %.4f',...
%         timeDefault, 'SID:', similarityold(2),'to',handles.similarity(2), 'SMI:', similarityold(4),'to',handles.similarity(4)));

T = handles.transform.T;
ss = T(2,1);
sc = T(1,1);
scale = sqrt(ss*ss + sc*sc);
theta = atan2(ss,sc)*180/pi;
tx = T(3,1);
ty = T(3,2);
disp(scale);
disp(theta);
disp(tx);
disp(ty);    
guidata(hObject, handles);

% --- Executes on button press in ButtonMultiFeature.
function ButtonMultiFeature_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonMultiFeature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Features = DetectSIFT(handles.target);
Corners = DetectHarris(handles.target);

figure, imshow(handles.target);
hold all,
plot(floor(Corners(:,1)), floor(Corners(:,2)),'r+');
plot(floor(Features(:,1)), floor(Features(:,2)),'go');

% --- Executes during object creation, after setting all properties.
function ButtonLoadR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ButtonLoadR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% --- Executes on button press in ButtonLoadR.
function ButtonLoadR_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonLoadR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentpath = cd();
[filename, pathname]= uigetfile({'*.tiff;*.tif;*.jpg;*.png;*.gif;*.mat;','All Image Files';...
          '*.*','All Files' },'Load Reference Image or Hyperspectral image');
if (filename==0) % cancel pressed
    return;
end
cd (pathname);   
if strcmp(filename(end-3:end), '.mat')
    dataCube = importdata(filename);
    [~, ~, b] = size(dataCube);
    focus = zeros(b,1);
    for i=1:b
        slice = squeeze(dataCube(:,:,i));
        focus(i) = fmeasure(slice, 'GDER',[]);   
    end
    [~,index] = max(focus);
    anchor = squeeze(dataCube(:,:,index));
    anchor = imadjust(anchor);
    anchor = imresize(anchor, 4);
    
else
    img = imread(filename);
    if ndims(img) == 3 
       img = rgb2gray(img);
    end
    anchor = img;
end
handles.fileLoaded1 = 1;
handles.anchor = anchor;
handles.oldanchor = anchor;
axes(handles.axes1); cla; imshow(anchor);
axes(handles.axes1Overview); cla; handles.anchorHandle = imshow(anchor);
set(handles.anchorHandle,'ButtonDownFcn', @(s,e) undoanchor());
if handles.fileLoaded1*handles.fileLoaded2 == 1
%    updateSimilarity(handles.anchor,handles.target);
end
cd (currentpath);
guidata(hObject, handles);

function undoanchor()
h = gcf;
handles = guidata(h);
handles.anchor = handles.oldanchor;
axes(handles.axes1); cla; imshow(handles.anchor);
guidata(h, handles);

% --- Executes on button press in ButtonLoadT.
function ButtonLoadT_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonLoadT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1); 
handles.anchorDESCRIPS = 0;
currentpath = cd();
[filename, pathname] = uigetfile({'*.tiff;*.tif;*.jpg;*.png;*.gif;*.mat','All Image Files';...
          '*.*','All Files' },'Load Target Image');
if (filename==0) % cancel pressed
    return;
end
cd (pathname);  
if strcmp(filename(end-3:end), '.mat')
    dataCube = importdata(filename);
    [~, ~, b] = size(dataCube);
    focus = zeros(b,1);
    for i=1:b
        slice = squeeze(dataCube(:,:,i));
        focus(i) = fmeasure(slice, 'GDER',[]);   
    end
    [~,index] = max(focus);
    target = squeeze(dataCube(:,:,index));
    target = imadjust(target);
    handles.fileLoaded2 = 1;
else
    img = imread(filename);
    if ndims(img) == 3 
       img = rgb2gray(img);
    end
    handles.fileLoaded2 = 1;
    target = img;
end
handles.target = target;
handles.oldtarget = target;
axes(handles.axes2); cla;  imshow(target);
axes(handles.axes2Overview); cla; handles.targetHandle = imshow(target);
set(handles.targetHandle,'ButtonDownFcn', @(s,e) undotarget());
if handles.fileLoaded1*handles.fileLoaded2 == 1
 %   updateSimilarity(handles.anchor,handles.target);
end
cd(currentpath);
guidata(hObject, handles); 

function undotarget()
h = gcf;
handles = guidata(h);
handles.target = handles.oldtarget;
axes(handles.axes2); cla; imshow(handles.target);
guidata(h, handles);

% --- Executes when entered data in editable cell(s) in UitableT.
function UitableT_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to UitableT (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

T = get(hObject,'Data');
anchor = handles.anchor;
target = handles.target;
tform_tune = affine2d(T);
register_tune = imwarp(target, tform_tune, 'OutputView', imref2d(size(target)));

[r, c, img2] = find(register_tune);
linearInd = sub2ind(size(target), r, c);
img1 = anchor(linearInd); 
handles.transform = tform_tune;
handles.register = register_tune;
axes(handles.axes2);cla;imshow(register_tune);
figure, imshowpair(anchor, imadjust(target), 'ColorChannels','red-cyan','Scaling','independent');
title('falsecolor overlaid unregistered images with manual parameters with');
figure, imshowpair(anchor, imadjust(register_tune), 'ColorChannels','red-cyan','Scaling','independent');
title('falsecolor overlaid registered images with manual parameters');
%set(handles.textSSD, 'String',sprintf('%4s %1.6f','SSD:',pixelError)); 
updateRegistration(handles);
similarityold = updateSimilarity(handles.anchor, handles.target);
similarity = updateSimilarity(handles.anchor, handles.register);

set(handles.editError, 'String',sprintf('%4s %.0f %2s %.0f %4s %.4f %2s %.4f',...
        'SID:', similarityold(2),'to',similarity(2), 'SMI:', similarityold(4),'to',similarity(4)));
guidata(hObject, handles); 

% --- Executes on button press in ButtonManual.
function ButtonManual_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if isempty(handles.datacube)
    anchor = handles.anchor;
    target = handles.target;
%     if ~exist('Testcontrolpoints.mat', 'file') % need fix
    [input_points, base_points] = cpselect(target, anchor,'Wait', true); %manually select corresponding points
%         save('Testcontrolpoints.mat', 'input_points', 'base_points');
%     else
%         load('Testcontrolpoints');
%     end
%     assignin('base', 'input_points',input_points);
%     assignin('base', 'base_points',base_points);
    %in terms of affine transform, Minimum Number of Control Point Pairs is 3
    
%     input_points = input_points';
%     base_points = base_points';
    
% these codes failed    
%      t = 0.05;
%      [H, inliers] = ransacfithomography(input_points, base_points, t);
%      x1 = base_points(:,inliers);
% 	   x2 = input_points(:,inliers);
%      assignin('base', 'H',H);
% 
%      axes(handles.axes1);cla;
%      showMatchedFeatures(anchor, handles.target, x1', x2');
%      legend('anchor', 'target');title(sprintf('%d %16s', length(x1), 'Features Matched'));
%      register = imTrans(target, H);

    
    axes(handles.axes1);cla;
    showMatchedFeatures(anchor, handles.target, base_points, input_points);
    
    tform = fitgeotrans(input_points, base_points, 'affine'); 
    H = tform.T;
    register= imwarp(target, tform, 'OutputView', imref2d(size(anchor)));
    axes(handles.axes2);cla;
    imshowpair(handles.anchor, register,'ColorChannels','red-cyan','Scaling','independent');
    set(handles.UitableT, 'Data', H);
    
    handles.transform = tform;
    handles.register = register;
    assignin('base', 'register',register);

%     updateRegistration(handles);
%     axes(handles.axes1);cla;
%     handles.imageleft = imshowpair(anchor, target, 'ColorChannels','red-cyan','Scaling','independent');
%     title('falsecolor overlaid unregistered images');
%     set(handles.imageleft,'ButtonDownFcn', @(s,e) imsave(handles.imageleft));
%     axes(handles.axes2);cla;
%     handles.imageright = imshowpair(anchor, register_manual, 'ColorChannels','red-cyan','Scaling','independent');
%     title('falsecolor overlaid registered images');
%     set(handles.imageright,'ButtonDownFcn', @(s,e) imsave(handles.imageright));
%     handles.similarity = updateSimilarity(handles.anchor, handles.register);
% else
%     scale = zeros(4,1);
%     theta = zeros(4,1);
%     tx = zeros(4,1);
%     ty = zeros(4,1);
%     similarity = zeros(4,5);
%     similarityold = zeros(4,5);
%     scale(2) = 1;
%     theta(2) = 0;
%     tx(2) = 0;
%     ty(2) = 0;
%     bandname = [600; handles.bandname(handles.reference); 800; 1000];
%     if exist('tempT.mat','file') == 2 
%         load('tempT.mat')
%     end
%     s = find(scale == 0,1);
%     anchor = handles.anchor;
%     
%     for i = s:4
%         if bandname(i) == handles.bandname(handles.reference);
%             scale(2) = 1;
%             theta(2) = 0;
%             tx(2) = 0;
%             ty(2) = 0;   
%         else    
%         target = squeeze(handles.datacube(:,:, find(handles.bandname == bandname(i),1)));
%         
%         [input_points, base_points] = cpselect(target, anchor,'Wait', true);
%         assignin('base', 'input_points',input_points);
%         assignin('base', 'base_points',base_points);
%         %in terms of affine transform, Minimum Number of Control Point Pairs is 3
%         tform = cp2tform(input_points, base_points, 'similarity'); 
%         tform = affine2d(tform.tdata.T); 
%         register_manual = imwarp(target, tform, 'OutputView', imref2d(size(target)));
%         handles.transform = tform;
%         handles.register = register_manual;
%         updateRegistration(handles);
%         axes(handles.axes1);cla;
%         handles.imageleft = imshowpair(anchor, target, 'ColorChannels','red-cyan','Scaling','independent');
%         title('falsecolor overlaid unregistered images');
%         axes(handles.axes2);cla;
%         imshowpair(anchor, register_manual, 'ColorChannels','red-cyan','Scaling','independent');
%         title('falsecolor overlaid registered images');
%         similarityold(i,:) = updateSimilarity(handles.anchor, target);
%         similarity(i,:) = updateSimilarity(handles.anchor, handles.register);
%         handles.similarity = similarity(i,:);
%         set(handles.editError, 'String',sprintf('%4s %.0f %2s %.0f %4s %.4f %2s %.4f',...
%         'SID:', similarityold(i,2),'to',similarity(i,2), 'SMI:', similarityold(i,4),'to',similarity(i,4)));
%         
%         T = tform.T;
%         ss = T(2,1);
%         sc = T(1,1);
%         scale(i) = sqrt(ss*ss + sc*sc);
%         theta(i) = atan2(ss,sc)*180/pi;
%         tx(i) = T(3,1);
%         ty(i) = T(3,2);
%         
%         end
%         save('tempT.mat', 'bandname','scale','theta','tx','ty','similarityold','similarity');
%     end
%     Tr = makeTransform(bandname,scale,theta,tx,ty);
%     handles.Transform_data = Tr;
% end


guidata(hObject, handles); 

function updateRegistration(handles)

set(handles.UitableT, 'Data', handles.transform.T);
axes(handles.axes2);cla;imshow(handles.register);

assignin('base', 'transformMatrix',handles.transform.T);

function [varargout] = updateSimilarity(anchor, img)
global Mainfigure

%SSD
ssd = cal_ssd(anchor, img);
%SSD relative
ssd_r = cal_ssd_r(anchor,img);
%SGD
sgd = cal_sgd(anchor,img);
%SMI
I1 = im2uint8(anchor);
I2 = im2uint8(img);
smi = cal_mi(I1, I2);
%CCRE
ccre = cal_ccre(I1, I2);
%NCC
ncc = cal_ncc(anchor,img);
handles = guidata(Mainfigure);
similarity = [ssd, ssd_r, sgd, smi, ncc];
varargout{1} = similarity;
set(handles.uitableSimilarity,'Data',similarity');

%guidata(gcf, handles); 

function editRegistration_Callback(hObject, eventdata, handles)
% hObject    handle to editRegistration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRegistration as text
%        str2double(get(hObject,'String')) returns contents of editRegistration as a double

% --- Executes during object creation, after setting all properties.
function editRegistration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRegistration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in radioSimilarityUpdate.
function radioSimilarityUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to radioSimilarityUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioSimilarityUpdate

if get(hObject,'value')
    updateSimilarity(handles.anchor, handles.target);
end 

% --------------------------------------------------------------------
function UitableT_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to UitableT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
T = get(hObject, 'Data');   %save the transform matrix
uisave('T')
% --- Executes on mouse press over axes background.

% --- Executes on key press with focus on UitableT and none of its controls.
function UitableT_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to UitableT (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in ButtonBlur.
function ButtonBlur_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonBlur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

H = fspecial('disk',10);
handles.anchor = imfilter(handles.anchor,H,'replicate');
axes(handles.axes1); imshow(handles.anchor);

handles.target = imfilter(handles.target,H,'replicate');
axes(handles.axes2); imshow(handles.target);
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --------------------------------------------------------------------
function MenuLoadT_Callback(hObject, eventdata, handles)
% hObject    handle to MenuLoadT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%currentpath = cd();
[filename, pathname] = uigetfile({'*.mat','Transform data (*.mat)'},'Load Transform File');
if (filename==0) % cancel pressed
    return;
end
%cd (pathname);
handles.transform = importdata(fullfile(pathname,filename));
H = handles.transform.T;
set(handles.UitableT, 'Data', H);
guidata(hObject, handles);

%--------------------------------------------------------------------
function MenuOutput_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = handles.datacube;
guidata(hObject, handles);
uiresume(handles.figure1); 

% --------------------------------------------------------------------
function MenuApplyT_Callback(hObject, eventdata, handles)
% hObject    handle to MenuApplyT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.target = imadjust(handles.target); % this makes the features robust to different frames 
tform = projective2d(handles.Transform_data);
register = imwarp(target, tform, 'OutputView', imref2d(size(target)));
handles.register = register;
similarityold = updateSimilarity(handles.anchor,handles.target);
handles.similarity = updateSimilarity(handles.anchor,handles.register);
imshowpair(handles.anchor, imadjust(register),'ColorChannels','red-cyan','Scaling','independent');
set(handles.editError, 'String',sprintf('%4s %.0f %2s %.0f %4s %.4f %2s %.4f',...
'SID:', similarityold(2),'to',handles.similarity(2), 'SMI:', similarityold(4),'to',handles.similarity(4)));
guidata(hObject, handles); 

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ButtonFit.
function ButtonFit_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%load ('data_iteration');
load ('data_fit');
Tr = makeTransform(bandname,scale,theta,tx,ty);
handles.Transform_data = Tr;
guidata(hObject, handles); 

function Tr = makeTransform(band,scale,theta,tx,ty, varargin)
if isempty(varargin)
    bandname = [400:10:1000]';
else bandname = varargin{1};
end
l = length(bandname);
theta = theta*pi/180;
f2 = fit(band,scale,'poly2');
scalefit = feval(f2,bandname);
figure, plot(band,scale,'r*',bandname,scalefit,'g');
title('scale');
xlabel('wavelength (nm)');
ylabel('scale');
thetafit = zeros(l,1);
figure, plot(band,theta,'r',bandname,thetafit,'g');
title('theta');
xlabel('wavelength (nm)');
ylabel('rotation (degree)');

f2 = fit(band,tx,'poly2');
txfit = feval(f2,bandname);

figure, plot(band,tx,'r*',bandname,txfit,'g');
title('tx');
xlabel('wavelength (nm)');
ylabel('shift (pixel)');


f2 = fit(band,ty,'poly2');
tyfit = feval(f2,bandname);
figure, plot(band,ty,'r*',bandname,tyfit,'g');
title('ty');
xlabel('wavelength (nm)');
ylabel('shift (pixel)');

T = cell(l,1);
for i=1:l
     T{i} = [scalefit(i)*cos(thetafit(i)) -scalefit(i)*sin(thetafit(i)) 0;...
             scalefit(i)*sin(thetafit(i)) scalefit(i)*cos(thetafit(i)) 0;...
             txfit(i)                     tyfit(i)                  1];
end
Tr = T;

% --- Executes on button press in ButtonSearch.
function ButtonSearch_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load ('data_fit');
scale_points = zeros(4,1);
theta_points = zeros(4,1);
tx_points = zeros(4,1);
ty_points = zeros(4,1);
similarity = zeros(4,5);
similarityold = zeros(4,5);
scale_points(2) = 1;
theta_points(2) = 0;
tx_points(2) = 0;
ty_points(2) = 0;
bandname_points = [600; handles.bandname(handles.reference); 800; 1000];
anchor = handles.anchor;
for i = 1:4
        set(handles.SliderWavelength, 'Value',bandname_points(i));
        set(handles.editWavelength, 'String', num2str(bandname_points(i)));
        set(handles.editTarget,'String',num2str(bandname_points(i)));
        if bandname_points(i) == handles.bandname(handles.reference);
            scale_points(2) = 1;
            theta_points(2) = 0;
            tx_points(2) = 0;
            ty_points(2) = 0;   
        else    
        scale_0 = scale( find(bandname == bandname_points(i),1)); 
        tx_0 = tx( find( bandname == bandname_points(i),1)); 
        ty_0 = ty( find( bandname == bandname_points(i),1)); 
        x0 = [scale_0 tx_0 ty_0];
        target = squeeze(handles.datacube(:,:, find(handles.bandname == bandname_points(i),1)));
        options = optimset;
        options = optimset(options,'PlotFcns', {  @optimplotx @optimplotfval });
        [x, fval, exitflag, output] = ...
        fminsearch(@objecfun,x0,options,anchor,target);    
        scale_points(i) = x(1);
        tx_points(i) = x(2);
        ty_points(i) = x(3);
        theta_points(i) = 0;
        
        t = [scale_points(i) 0               0;...
            0                scale_points(i) 0;...
            tx_points(i)     ty_points(i)    1];
        tform_manual = affine2d(t); 
        register_manual = imwarp(target, tform_manual, 'OutputView', imref2d(size(target)));
        handles.transform = tform_manual;
        handles.register = register_manual;
        updateRegistration(handles);
        axes(handles.axes1);cla;
        handles.imageleft = imshowpair(anchor, target, 'ColorChannels','red-cyan','Scaling','independent');
        title('falsecolor overlaid unregistered images');
        axes(handles.axes2);cla;
        imshowpair(anchor, register_manual, 'ColorChannels','red-cyan','Scaling','independent');
        title('falsecolor overlaid registered images');
        similarityold(i,:) = updateSimilarity(handles.anchor, target);
        similarity(i,:) = updateSimilarity(handles.anchor, handles.register);
        handles.similarity = similarity(i,:);
        set(handles.editError, 'String',sprintf('%4s %.0f %2s %.0f %4s %.4f %2s %.4f',...
        'SID:', similarityold(i,2),'to',similarity(i,2), 'SMI:', similarityold(i,4),'to',similarity(i,4)));
  
    
        end
        
end
Tr = makeTransform(bandname_points,scale_points,theta_points,tx_points,ty_points);
handles.Transform_data = Tr;
guidata(hObject, handles); 

% target = handles.target;
% anchor = handles.anchor;
% num = 20;
% tx = linspace(0,-6,num);
% ty = linspace(0,-6,num);
% sgd_x = zeros(num,1);
% sgd_y = zeros(num,1);
% scale = linspace(1,1.015,num);
% for s = 1:num
% for i = 1:num
%     T = [scale(s)     0 0;...
%          0     scale(s) 0;...
%          tx(i) ty(1) 1];
%     tform = affine2d(T); 
%     register = imwarp(target, tform, 'OutputView', imref2d(size(target)));
%     [aGx, ~] = imgradientxy(anchor);
%     [tGx, ~] = imgradientxy(register);
%     Gx = (abs(aGx) - abs(tGx)).^2;
%     sgd_x(i) = sum(Gx(:));
%     disp(i);
% end
% figure(2), plot(tx,sgd_x);
% hold all
% title('SGDX');
% for j = 1:num
%     T = [scale(s)     0 0;...
%          0     scale(s) 0;...
%          tx(1) ty(j) 1];
%     tform = affine2d(T); 
%     register = imwarp(target, tform, 'OutputView', imref2d(size(target))); 
%     [~, aGy] = imgradientxy(anchor);
%     [~, tGy] = imgradientxy(register);
%     Gy = (abs(aGy) - abs(tGy)).^2;
%     sgd_y(j) = sum(Gy(:));
%     disp(j);
% end
% figure(3), plot(ty,sgd_y);
% title('SGDY');
% hold all
% end


function f = objecfun(x,anchor,target)
% x represents scale, tx and ty
scale = x(1);
tx = x(2);
ty = x(3);
T = affine2d([scale 0 0;0 scale 0;tx ty 1]);
register = imwarp(target, T, 'OutputView', imref2d(size(target)));
%f = cal_ncc(anchor, register);
%f = cal_ssd_r(anchor, register);
f = cal_ncc(anchor, register);

% --------------------------------------------------------------------
function MenuInitialize_Callback(hObject, eventdata, handles)
% hObject    handle to MenuInitialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function MenuSpectral_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSpectral (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacube = handles.datacube;
anchor = handles.anchor;
[m, n] = size(anchor);
anchorCORNERS = DetectHarris(handles.anchor); % [colume row]
width = 9;
height = 9;
sigma_ssd = 0;
sigma_sad = 0;
sigma_cor = 0;
en = 0;
j = 0;


% for i = 1:size(datacube, 3)
%    % H = fspecial('disk',blurl(i));
%     slice = squeeze(datacube(:,:,i));
%     bslice = imadjust(slice);
%     datacube(:,:,i) = bslice; 
% end


for i = 1:size(anchorCORNERS,1)
    if anchorCORNERS(i,1) > n-10 || anchorCORNERS(i,1) < 10  || anchorCORNERS(i,2) > m-10 || anchorCORNERS(i,2) < 10
        continue;
    end
    rect = [anchorCORNERS(i,:)- [width, height]/2, width, height];
    rect = round(rect);
    axes(handles.axes1);
    hold on;
    rectangle('Position',rect,'EdgeColor','r', 'LineWidth',1);
    area = datacube(round(rect(2)):round(rect(2)+rect(4)-1),round(rect(1)):round(rect(1)+rect(3)-1),:);
    if j == 20
        rectangle('Position',rect,'EdgeColor','g', 'LineWidth',1);
        subregionSpec(area,9,9,handles.bandname);
    end 
    sigma_ssd = sigma_ssd + std3_SSD(area);  
    sigma_sad = sigma_sad + std3_SAD(area);
    sigma_cor = sigma_cor + std3_COR(area);
    en        = en        + entropy(area);
    j = j+1;
end

sigma_ssd = sigma_ssd/(j);
sigma_sad = sigma_sad/(j);
sigma_cor = sigma_cor/(j);
en = en/j;


set(handles.editRegistration, 'string', [' SAD: ' num2str(sigma_sad) ' COR: ' num2str(sigma_cor)]);
disp(sigma_ssd);
disp(sigma_sad);
disp(sigma_cor);
disp(en);
assignin('base', 'SAD',sigma_sad);
assignin('base', 'COR',sigma_cor);

handles.datacube = datacube;
guidata(hObject, handles); 

% --------------------------------------------------------------------
function MenuRegister_Callback(hObject, eventdata, handles)
% hObject    handle to MenuRegister (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic
global Mainfigure
Mainfigure = handles.figure1;
Num = 5; % the number of images which don't need to register
[m, n, b] = size(handles.datacube);
similarity = zeros(b-Num,5);
similarityold = zeros(b-Num,5);
bandname = handles.bandname(1+Num: b)';
anchor = handles.anchor;
width = n/2; 
height = m/2; 
rect = [ [1 1], height, width];
rect = round(rect);
anchorROI = anchor(rect(1):(rect(1)+rect(3)-1),rect(2):(rect(2)+rect(4)-1));

j = 1;
T = [1 0 0 0];
for i = 1:1:b-Num % from middle to left 
%    set(handles.SliderWavelength, 'Value',handles.bandname(i+Num));
%    set(handles.editWavelength, 'String', num2str(handles.bandname(i+Num)));
%    set(handles.editTarget,'String',num2str(handles.bandname(i+Num)));
    target = squeeze(handles.datacube(:,:,i+Num));  
   % targetROI = target(rect(1):(rect(1)+rect(3)-1),rect(2):(rect(2)+rect(4)-1));
    
%   similarityold(i,:) = updateSimilarity(anchor,target);
    %handles.target = imadjust(handles.target); % this makes the features robust to different frames 
    %tform = imregtform2(target, anchor);
    tform = imregtform2(target, anchor);
%    registerROI = imwarp(targetROI, tform, 'OutputView', imref2d(size(targetROI)));
%    similarity(i,:) = updateSimilarity(anchor,register);
    T = tform.T;
    ss = T(2,1);
    sc = T(1,1);
    scale(j,1) = sqrt(ss*ss + sc*sc);
    theta(j,1) = atan2(ss,sc)*180/pi;
    tx(j,1) = T(3,1);
    ty(j,1) = T(3,2);
    band(j,1) = handles.bandname(i+Num);
    j = j+1;
   % save('data_auto.mat', 'bandname','scale','theta','tx','ty','similarityold','similarity');
    disp(i);
end
%  figure, plot(bandname,similarityold(:,2),'r',bandname,similarity(:,2),'g');
%  title('SID');
%  figure, plot(bandname,similarityold(:,3),'r',bandname,similarity(:,3),'g');
%  title('SGD');
%  figure, plot(bandname,similarityold(:,4),'r',bandname,similarity(:,4),'g');
%  title('SMI');
%  figure, plot(bandname,similarityold(:,5),'r',bandname,similarity(:,5),'g');
%  title('NCC');
Tr = makeTransform(band,scale,theta,tx,ty, bandname);

for i = 1: b-Num % from middle to left 
%    set(handles.SliderWavelength, 'Value',handles.bandname(i+Num));
%    set(handles.editWavelength, 'String', num2str(handles.bandname(i+Num)));
%    set(handles.editTarget,'String',num2str(handles.bandname(i+Num)));
    target = squeeze(handles.datacube(:,:,i+Num));  
    tform = affine2d(Tr{i});
    register = imwarp(target, tform, 'OutputView', imref2d(size(target)));
    handles.datacube(:,:,i+Num) = register;
    disp(i);
end
MenuSpectral_Callback(hObject, eventdata, handles);
toc
guidata(hObject, handles); 

% --- Executes on button press in ButtonGabor.
function ButtonGabor_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonGabor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% gabor{1}=gabor_fn(1,0.5,0,2,0);
% gabor{2}=gabor_fn(1,0.5,0,2,pi/4);
% gabor{3}=gabor_fn(1,0.5,0,2,pi/2);
% gabor{4}=gabor_fn(1,0.5,0,2,pi*3/4);

gabor{1}=gabor_fn(1,0.5,0,2,0);
gabor{2}=gabor_fn(1,0.5,0,2,pi/8);
gabor{3}=gabor_fn(1,0.5,0,2,pi/4);
gabor{4}=gabor_fn(1,0.5,0,2,pi*3/8);
gabor{5}=gabor_fn(1,0.5,0,2,pi/2);
gabor{6}=gabor_fn(1,0.5,0,2,pi*5/8);
gabor{7}=gabor_fn(1,0.5,0,2,pi*3/4);
gabor{8}=gabor_fn(1,0.5,0,2,pi*7/8);
im = uint8(zeros(size(handles.anchor)));
%handles.target=imfilter(handles.target,gabor,'symmetric');
img = cell(8,1);
for o=1:8
   img{o}=imfilter(handles.anchor,gabor{o},'symmetric');
   im = im + img{o};
end
handles.anchor = im;
axes(handles.axes1); imshow(handles.anchor);


im(:) = 0;
for o=1:8
   img{o}=imfilter(handles.target,gabor{o},'symmetric');
   im = im + img{o};
end
handles.target = im;
axes(handles.axes2); imshow(handles.target);

guidata(hObject, handles);

% --- Executes on button press in ButtonEdge.
function ButtonEdge_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonEdge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% thresh = [0 0.5]';
% handles.anchor = edge(handles.anchor,'canny',thresh);%(handles.target, get(handles.sliderBright, 'Value'), get(handles.sliderContrast, 'Value'));
handles.anchor = edge(handles.anchor);
axes(handles.axes1); imshow(handles.anchor);

% handles.target = edge(handles.target,'canny',thresh);%(handles.target, get(handles.sliderBright, 'Value'), get(handles.sliderContrast, 'Value'));
handles.target = edge(handles.target)
axes(handles.axes2); imshow(handles.target);
guidata(hObject, handles);

% --- Executes on button press in ButtonSmooth.
function ButtonSmooth_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
H = fspecial('gaussian');
handles.anchor = imfilter(handles.anchor,H,'replicate');
%handles.target = histeq(handles.target);%(handles.target, get(handles.sliderBright, 'Value'), get(handles.sliderContrast, 'Value'));
axes(handles.axes1); imshow(handles.anchor);

handles.target = imfilter(handles.target,H,'replicate');
axes(handles.axes2); imshow(handles.target);
guidata(hObject, handles);

% --- Executes on button press in ButtonBrighten.
function ButtonBrighten_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonBrighten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gramer = 0.4;
handles.anchor = im2double(handles.anchor).^gramer;
%handles.target = histeq(handles.target);%(handles.target, get(handles.sliderBright, 'Value'), get(handles.sliderContrast, 'Value'));
axes(handles.axes1); imshow(handles.anchor);

handles.target = im2double(handles.target).^gramer;
axes(handles.axes2); imshow(handles.target);
guidata(hObject, handles);



% --- Executes on button press in ButtonSaveT.
function ButtonSaveT_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonSaveT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName, Path] = uiputfile({'*.mat';'*.dat'},'Save transform');
currentpath = cd();
if FileName == 0
    return
end
tform = handles.transform;
if strcmp(FileName(end-3:end),'.mat')
    cd (Path);
    save(FileName, 'tform');
end
cd (currentpath);
msgbox('new data cube has been saved.','save file');

