clc
clear all
resis=load('Resistance.txt');
an=load('Angle.txt');
fs=256;
%emg=xlsread('data.xlsx',1,'A1:A972');
%res=xlsread('data.xlsx',1,'B1:B972');
clc
Fs=1000;
x=load('EMG.txt');
%x=emg;
emg1=x;
t=0:length(x)-1/Fs;
figure(1)
subplot(2,1,1)
plot(t,emg1)
%removing 50 hz noise
BW = 0.1/1; % Bandwidth = Cutoff Frequency (0.1) / Quality Factor (1)
[bn,an] = iirnotch(0.1,0.1,1); % bn and an are the vectors of the numerator
filt_emg = filter(bn,an,emg1);
% wavelet transform
[C,L]=wavedec(filt_emg,2,'db7');
d2=wrcoef('d',C,L,'db7',2);
emgg=filt_emg - d2;
subplot(2,1,2)
plot(t,emgg)
Fc=3; % Cut-off frequency (from 2 Hz to 6 Hz depending to the electrode)
N=4; % Filter Order
[B, A] = butter(N,Fc*2/Fs, 'low'); %filter's parameters
EMG=filtfilt(B, A, emgg);
EMG1=filter(B, A, emgg);
t11=0:length(EMG)-1/Fs;
figure(2)
plot(t11,EMG)
t21=0:length(EMG1)-1/Fs;
hold on
plot(t21,EMG1,'r')
% Band pass filter lp & hp
[b,a]=butter(7,(20/500),'high');
x2 = filtfilt(b,a,emgg);
[B1,A1]=butter(7,450/500,'low');
x3=filtfilt(B1,A1,x2);
t3=0:length(x3)-1;
%rectification
figure(3)
x4=abs(x2);%ABS(X) is the absolute value of the elements of X3
t4=0:length(x4)-1/Fs ;
subplot(2,1,1)
plot(t3,x2)
xlim([0 1300])
subplot(2,1,2)
plot(t4,x4)
xlim([0 1300])
% averaging
N=length(x);
h=ones(1,150)/150;
delay=15;
x5=conv(x4,h);
x5=x5(15+(1:N));
t5=0:length(x5)-1/Fs ;
figure(4)
subplot(2,1,1)
plot(t3,x3)
xlim([0 1300])
subplot(2,1,2)
plot(t5,x5)
xlim([0 1300])
% linear envelope emg
[b1,a1]=butter(6,4/500,'low');
x6=filter(b1,a1,x4);
t6=0:length(x6)-1/Fs ;
figure(5)
subplot(2,1,1)
plot(t3,x3)
xlim([0 1300])
subplot(2,1,2)
plot(t6,x6)
xlim([0 1300])

[pks,locidx] = findpeaks(-x6);                  % Peaks & Peak Indices In Vector
pks = -pks;
plen=length(pks);
loc=[1 ;locidx ;length(emg1)];

for i=1:plen+1
    start=loc(i);
    last=loc(i+1);
    em=emg1(start:last,:);
% Taking FFT
fft1= fft(em,1024);
Mag= fft1.*conj(fft1)/1024;
f= 1000/1024*(1:512);
figure(6)
plot(f,Mag(1:512))
m(i)=medfreq(em);
R_C=resis(start:last,:);
m_r(i)=min(R_C);
end
figure(7)
disp(m);
plot(m);
figure(8)
plot(m_r);
disp(m_r);
