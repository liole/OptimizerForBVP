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

% Last Modified by GUIDE v2.5 25-Dec-2018 16:28:31

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


% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
x = get(handles.bInit,'String')
while strfind(x, '  ')
%% while contains(x, '  ')%% use this for versions of matlab 2016b+
  x = strrep(x, '  ', ' ');
end
b0 =str2double(strsplit(x,' '))

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
q = Problem(b0, j, optO, method, bcType, d, funcs);
popup_sel_index = get(handles.problemMethod, 'Value');
switch popup_sel_index
    case 1
        q = Problem(b0, j, optO, method, bcType, d, funcs);
    case 2
        q = ProblemFDM(b0, j, optO, method, bcType, d, funcs);
    case 3
        q = ProblemAM(b0, j, optO, method, bcType, d, funcs);
    case 4
        q = ProblemDDM(b0, j, optO, method, bcType, d, funcs);   
end

withConstr = handles.withConstrintsCheckbox;

if popup_sel_index == 1
    q2 = ProblemFDM(b0, j, optO, method, bcType, d, funcs);
    gradInitial = q2.Gradient(0);
else
    gradInitial = q.Gradient(0);
end

initStr = sprintf('Initial criteria = %s\n  Initial constraint = %s\n\n Gradient at initial point = %s\n',...
    mat2str(q.criteria()),mat2str(q.constraint()), mat2str(gradInitial));
set(handles.result, 'String', initStr);
drawnow;

tic;
if get(withConstr,'Value') == 1
    q.optimize(true, true);
else
    q.optimize(false, true);
end
calcTime = toc;

if popup_sel_index == 1
    q3 = ProblemFDM(q.b, j, optO, method, bcType, d, funcs);
    gradOptimal = q3.Gradient(0);
else
    gradOptimal = q.Gradient(0);
end
    
% str=strcat('Optimal criteria = ',mat2str(q.criteria()),sprintf('\n'),'Optimal contraint = ',mat2str(q.constraint()));

str = sprintf('%s\nOptimal criteria = %s\n  Optimal constraint = %s\n bOptimal = %s\n Gradient at optimal point = %s\n\n Optimization time = %s s\n',...
    initStr, mat2str(q.criteria()),mat2str(q.constraint()),mat2str(q.b),mat2str(gradOptimal), num2str(calcTime,'%.2f'));

set(handles.result, 'String', str);

plot2(q);

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject, 'Value', 0);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on key press with focus on calculate and none of its controls.
function calculate_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

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

% --- Executes during object creation, after setting all properties.
function uibuttongroup1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function right_d_CreateFcn(hObject, eventdata, handles)
% hObject    handle to right_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function left_d_CreateFcn(hObject, eventdata, handles)
% hObject    handle to left_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function problemMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to problemMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function opt_func_CreateFcn(hObject, eventdata, handles)
% hObject    handle to opt_func (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function optO_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optO_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function bInit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to g3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function g1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to g3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function g3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to g3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function fu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in withConstrintsCheckbox.
function withConstrintsCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to withConstrintsCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of withConstrintsCheckbox
