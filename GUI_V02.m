function varargout = GUI_V02(varargin)
% GUI_V02 MATLAB code for GUI_V02.fig
%      GUI_V02, by itself, creates a new GUI_V02 or raises the existing
%      singleton*.
%
%      H = GUI_V02 returns the handle to a new GUI_V02 or the handle to
%      the existing singleton*.
%
%      GUI_V02('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_V02.M with the given input arguments.
%
%      GUI_V02('Property','Value',...) creates a new GUI_V02 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_V02_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_V02_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_V02

% Last Modified by GUIDE v2.5 26-Dec-2018 22:28:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_V02_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_V02_OutputFcn, ...
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


% --- Executes just before GUI_V02 is made visible.
function GUI_V02_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_V02 (see VARARGIN)

% Choose default command line output for GUI_V02
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
title(handles.control, 'Control function')
title(handles.state, 'State function')

% UIWAIT makes GUI_V02 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_V02_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function q = getProblem(handles)
x = get(handles.bInit,'String');
while strfind(x, '  ')
%% while contains(x, '  ')%% use this for versions of matlab 2016b+
  x = strrep(x, '  ', ' ');
end
b0 =str2double(strsplit(x,' '));

gammaU= str2double(get(handles.GammaU,'String'))
gammaY= str2double(get(handles.GammaY,'String'))
x0=str2double(get(handles.x0,'String'))
xE=str2double(get(handles.xE,'String'))
uMin=str2double(get(handles.uMin,'String'))
uMax=str2double(get(handles.uMax,'String'))
p1=str2double(get(handles.p1,'String'))
p2=str2double(get(handles.p2,'String'))
k=str2double(get(handles.k,'String'))
yd=str2double(get(handles.yd,'String'))
yMax=str2double(get(handles.yMax,'String'))
isKSelected=true;
if(handles.yParams.Value == 1)
    isKSelected=false;
end

j = get(handles.opt_func, 'Value');% index of u in [r g1 g3 fu]
optO = get(handles.optO_menu, 'Value');

method = 'linear';

if (handles.constant.Value == 1)
    method = 'constant';
end

 % linear or constant

left_constraint = Utils.Dirichlet;
right_constraint = Utils.Dirichlet;

if (handles.right_neuman.Value == 1)
    right_constraint= Utils.Neumann;
end
if (handles.left_neuman.Value == 1)
    left_constraint  = Utils.Neumann;
end

bcType = [left_constraint; right_constraint];
d = [str2double(handles.left_d.String) str2double(handles.right_d.String)]; % boundary condition values

funcs = {handles.r.String,handles.g1.String, handles.g3.String, handles.fu.String};
q = Problem(b0, j, optO, method, bcType, d, funcs,gammaU,gammaY,x0,xE,uMin,uMax,p1,p2,k,yd,yMax,isKSelected);
popup_sel_index = get(handles.problemMethod, 'Value');
switch popup_sel_index
    case 1
        q = Problem(b0, j, optO, method, bcType, d, funcs,gammaU,gammaY,x0,xE,uMin,uMax,p1,p2,k,yd,yMax,isKSelected);
    case 2
        q = ProblemFDM(b0, j, optO, method, bcType, d, funcs,gammaU,gammaY,x0,xE,uMin,uMax,p1,p2,k,yd,yMax,isKSelected);
    case 3
        q = ProblemAM(b0, j, optO, method, bcType, d, funcs,gammaU,gammaY,x0,xE,uMin,uMax,p1,p2,k,yd,yMax,isKSelected);
    case 4
        q = ProblemDDM(b0, j, optO, method, bcType, d, funcs,gammaU,gammaY,x0,xE,uMin,uMax,p1,p2,k,yd,yMax,isKSelected);   
end

function setInitialInfo(handles, q)
popup_sel_index = get(handles.problemMethod, 'Value');
if popup_sel_index == 1
    q2 = ProblemFDM(q.b0, q.j, q.optO, q.method, q.bcType, q.d, q.funcStrings,...
        q.gammaU,q.gammaY,q.x0,q.xE,q.uMin,q.uMax,q.p(1),q.p(2),q.k,q.yd,q.yMax,q.isKSelected);
    grad = q2.Gradient(0);
else
    grad = q.Gradient(0);
end

initStr = sprintf('Initial criteria   = %s\n        constraint = %s\n        gradient   = %s\n',...
    mat2str(q.criteria()), mat2str(q.constraint()), mat2str(grad, 4));
set(handles.result, 'String', initStr);

function setFullInfo(handles, q, time)
initStr = get(handles.result, 'String');
initStr = sprintf('%s\n%s\n%s\n\n',initStr(1,:),initStr(2,:),initStr(3,:));

popup_sel_index = get(handles.problemMethod, 'Value');
if popup_sel_index == 1
    q2 = ProblemFDM(q.b, q.j, q.optO, q.method, q.bcType, q.d, q.funcStrings,...
        q.gammaU,q.gammaY,q.x0,q.xE,q.uMin,q.uMax,q.p(1),q.p(2),q.k,q.yd,q.yMax,q.isKSelected);
    grad = q2.Gradient(0);
else
    grad = q.Gradient(0);
end

optStr = sprintf('Optimal criteria   = %s\n        constraint = %s\n        gradient   = %s\n        point      = %s\nTime elapsed: %.3f s',...
    mat2str(q.criteria()), mat2str(q.constraint()), mat2str(grad, 4), mat2str(q.b, 4),time);
set(handles.result, 'String', [initStr optStr]);

function updatePlot(handles)
q = getProblem(handles);
cla(handles.control);
cla(handles.state);
plot2(q,'', handles.control, handles.state);
setInitialInfo(handles, q);


% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)

q = getProblem(handles);

setInitialInfo(handles, q);
drawnow;

tic;
if get(handles.checkboxConstr, 'Value') == 1
    q.optimize(true, true);
else
    q.optimize(false, true);
end
calcTime = toc;

setFullInfo(handles, q, calcTime);

cla(handles.control);
cla(handles.state);
plot2(q,'', handles.control, handles.state);

function opt_func_Callback(hObject, eventdata, handles)
handles.r.Enable = 'on';
handles.g1.Enable = 'on';
handles.g3.Enable = 'on';
handles.fu.Enable = 'on';
j = get(handles.opt_func, 'Value');
switch j
    case 1
        handles.r.Enable = 'off';
    case 2
        handles.g1.Enable = 'off';
    case 3
        handles.g3.Enable = 'off';
    case 4
        handles.fu.Enable = 'off';
end

% --- Executes on selection change in optO_menu.
function updatePlot_Callback(hObject, eventdata, handles)
% hObject    handle to optO_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns optO_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from optO_menu
updatePlot(handles)



function GammaU_Callback(hObject, eventdata, handles)
% hObject    handle to GammaY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GammaY as text
%        str2double(get(hObject,'String')) returns contents of GammaY as a double


% --- Executes during object creation, after setting all properties.
function GammaU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GammaY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GammaY_Callback(hObject, eventdata, handles)
% hObject    handle to GammaY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GammaY as text
%        str2double(get(hObject,'String')) returns contents of GammaY as a double


% --- Executes during object creation, after setting all properties.
function GammaY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GammaY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x0_Callback(hObject, eventdata, handles)
% hObject    handle to x0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x0 as text
%        str2double(get(hObject,'String')) returns contents of x0 as a double


% --- Executes during object creation, after setting all properties.
function x0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xE_Callback(hObject, eventdata, handles)
% hObject    handle to xE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xE as text
%        str2double(get(hObject,'String')) returns contents of xE as a double


% --- Executes during object creation, after setting all properties.
function xE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uMin_Callback(hObject, eventdata, handles)
% hObject    handle to uMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uMin as text
%        str2double(get(hObject,'String')) returns contents of uMin as a double


% --- Executes during object creation, after setting all properties.
function uMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function uMax_Callback(hObject, eventdata, handles)
% hObject    handle to uMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uMax as text
%        str2double(get(hObject,'String')) returns contents of uMax as a double


% --- Executes during object creation, after setting all properties.
function uMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function p1_Callback(hObject, eventdata, handles)
% hObject    handle to p1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of p1 as text
%        str2double(get(hObject,'String')) returns contents of p1 as a double


% --- Executes during object creation, after setting all properties.
function p1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function p2_Callback(hObject, eventdata, handles)
% hObject    handle to p2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of p2 as text
%        str2double(get(hObject,'String')) returns contents of p2 as a double


% --- Executes during object creation, after setting all properties.
function p2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in kParam.
function kParam_Callback(hObject, eventdata, handles)
% hObject    handle to kParam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of kParam


% --- Executes on button press in yParams.
function yParams_Callback(hObject, eventdata, handles)
% hObject    handle to yParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of yParams



function yd_Callback(hObject, eventdata, handles)
% hObject    handle to yd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yd as text
%        str2double(get(hObject,'String')) returns contents of yd as a double


% --- Executes during object creation, after setting all properties.
function yd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yMax_Callback(hObject, eventdata, handles)
% hObject    handle to yMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yMax as text
%        str2double(get(hObject,'String')) returns contents of yMax as a double


% --- Executes during object creation, after setting all properties.
function yMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function k_Callback(hObject, eventdata, handles)
% hObject    handle to k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of k as text
%        str2double(get(hObject,'String')) returns contents of k as a double


% --- Executes during object creation, after setting all properties.
function k_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
