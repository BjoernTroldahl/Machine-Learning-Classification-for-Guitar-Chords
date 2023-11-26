% fret = [3 2 0 0 0 3];
% Fs = 44100;
% A = 110; % The A string of a guitar is normally tuned to 110 Hz
% Eoffset  = -5;
% Doffset  = 5;
% Goffset  = 10;
% Boffset  = 14;
% E2offset = 19;
% 
% %Generate the frequency vector that we will use for analysis.
% F = linspace(1/Fs, 1000, 2^12);
% 
% %Generate 4 seconds of zeros to be used to generate the guitar notes.
% x = zeros(Fs*4, 1);            
% 
% 
% %Get the delays for each note based on the frets and the string offsets.
% delay = [round(Fs/(A*2^((fret(1)+Eoffset)/12))), ...
%         round(Fs/(A*2^(fret(2)/12))), ...
%         round(Fs/(A*2^((fret(3)+Doffset)/12))), ...
%         round(Fs/(A*2^((fret(4)+Goffset)/12))), ...
%         round(Fs/(A*2^((fret(5)+Boffset)/12))), ...
%         round(Fs/(A*2^((fret(6)+E2offset)/12)))];
% 
% 
% b = cell(length(delay),1);
% a = cell(length(delay),1);
% H = zeros(length(delay),4096);
% note = zeros(length(x),length(delay));
% for indx = 1:length(delay)
% 
%     % Build a cell array of numerator and denominator coefficients.
%     b{indx} = firls(42, [0 1/delay(indx) 2/delay(indx) 1], [0 0 1 1]).';
%     a{indx} = [1 zeros(1, delay(indx)) -0.5 -0.5].';
% 
%     % Populate the states with random numbers and filter the input zeros.
%     zi = rand(max(length(b{indx}),length(a{indx}))-1,1);
% 
%     note(:, indx) = filter(b{indx}, a{indx}, x, zi);
% 
%     % Make sure that each note is centered on zero.
%     note(:, indx) = note(:, indx) - mean(note(:, indx));
% 
%     [H(indx,:),~] = freqz(b{indx}, a{indx}, F, Fs);
% end
% 
% 
% %Combine the notes and normalize them.
% combinedNote = sum(note,2);
% combinedNote = combinedNote/max(abs(combinedNote));
u = udpport("IPV4");
data = read(u,count)