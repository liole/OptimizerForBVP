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

% Last Modified by GUIDE v2.5 22-Dec-2018 15:35:57

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
b0 = [0 0 0];

j = str2double(handles.jVal.String);    % index of u in [r g1 g3 fu]
optO = str2double(handles.optOVal.String); % index of Omega to minimize on
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

 q = Problem(b0, j, optO, method, bcType, d);
 q.optimize(true, true);
 plot2(q);



function jVal_Callback(hObject, eventdata, handles)
% hObject    handle to jVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jVal as text
%        str2double(get(hObject,'String')) returns contents of jVal as a double


% --- Executes during object creation, after setting all properties.
function jVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
set(hObject, 'Value', 0);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function optOVal_Callback(hObject, eventdata, handles)
% hObject    handle to optOVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of optOVal as text
%        str2double(get(hObject,'String')) returns contents of optOVal as a double


% --- Executes during object creation, after setting all properties.
function optOVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optOVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

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


% --- Executes during object creation, after setting all properties.
function uibuttongroup1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function right_d_Callback(hObject, eventdata, handles)
% hObject    handle to right_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of right_d as text
%        str2double(get(hObject,'String')) returns contents of right_d as a double


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



function left_d_Callback(hObject, eventdata, handles)
% hObject    handle to left_d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of left_d as text
%        str2double(get(hObject,'String')) returns contents of left_d as a double


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
