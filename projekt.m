% Kompresja Danych Multimedialnych 19/20
% Zadanie projektowe
% 
% Prowadz�cy: dr Leszek Grad
% Wykona�: Pawe� Kierski I7M1S1

clear all;

%Pobranie od u�ytkownika skryptu potrzebnych informacji
disp('Kompresja LPC');
fileName = input('Nazwa pliku z rozszerzeniem .wav: ', 's');
coefAmount = input('Ilo�� wsp�czynnik�w filtra LPC: ');
sampleBits = input('Ilosc bit�w na pr�bk�: ');

%Odczytanie zawarto�ci pliku i przygotowanie zawarto�ci pliku
[input, fs] = audioread(fileName);
input = input(:,1);
input = input(2600:11150);
input = input';

%Wyznaczenie wspolczynnikow liniowych
N = length(input);
f = 0 : fs/N : fs - fs/N;
t = 0 : 1/fs : 1/fs * N - 1/fs;

%Przygotowanie filtra LPC
lpcSample = randn(100, 1);
lpcFilter = lpc(lpcSample, coefAmount);

%Wykonanie filtracji na sygnale wejsciowym i obliczenie roznicy
filteredInput = filter(lpcFilter, 1, input);
signalDiff = input - filteredInput;

%obliczenie wzmocnienia
force = max(input)/max(signalDiff);

%Kwantyzacja warto�ci pomi�dzy szczytami r�nicy
quantum = abs(max(signalDiff) - min(signalDiff)) / 2.^sampleBits;
quantumVector = min(signalDiff) + quantum /2 : quantum : max(signalDiff) - quantum /2;

compSignal = zeros( [1 length(signalDiff)]); %Alokacja pami�ci

%p�tla okre�laj�ca do kt�rej warto�ci zostanie "przydzielona pr�bka"
for i = 1 : length(signalDiff)
   [val, idx] = min(abs(quantumVector - signalDiff(i)));
   compSignal(i) = idx-1;
end

%alokacja pami�ci 
uncompSignal = compSignal;

%dekompresja; przydzielenie warto�ci dla konkretnego wsp�czynnika
for i = 1 : length(uncompSignal)
    uncompSignal(i) = quantumVector(compSignal(i) + 1);
end

%Defiltracja sygna�u zdekompresowanego
outputSignal = filter(lpcFilter, 1, uncompSignal);

%Analiza 1
figure(2);
subplot(221);
stem(uncompSignal(3800:4500), 'MarkerSize', 0.001);
title('Wykres slupkowy skwantowanego sygnalu');
subplot(222);
stem(compSignal(300 : 600), 'MarkerSize', 0.001);
title('Wykres slupkowy index�w kwantyzacji');
subplot(212);
hold on;
plot(signalDiff(3800:4500));
plot(outputSignal(3800:4500));
title('Por�wnanie sygna��w');
legend('Przed', 'Po dekompresji');
hold off;


%Wzmocnienie sygnalu po dekompresji
outputS = outputSignal * force;

%Analiza 2
figure(1);
subplot(221)
plot(t, input)
xlabel('Czas t[s]');
ylabel('Wartosc sygnalu');
title('Wykres przebiegu czasowego sygnalu  po dekompresji');
subplot(222)
plot(f, abs(fft(input)));
xlabel('Cz�stotliwo�� f[Hz]');
ylabel('Amplituda');
title('Wykres widma aplitudowego sygnalu po dekompresji');
subplot(223);
plot(t, outputS);
xlabel('Czas t[s]');
ylabel('Wartosc sygnalu');
title('Wykres przebiegu czasowego sygnalu  po dekompresji');
subplot(224)
plot(f ,abs(fft(outputS)));
xlabel('Cz�stotliwo�� f[Hz]');
ylabel('Amplituda');
title('Wykres widma aplitudowego sygnalu po dekompresji');









