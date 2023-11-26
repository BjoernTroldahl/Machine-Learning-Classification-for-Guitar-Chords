classdef PlayChord < audioPlugin                                % <== (1) Inherit from audioPlugin.

    properties
        Fs       = 44100;
        A        = 110; % The A string of a guitar is normally tuned to 110 Hz
        Eoffset  = -5;
        Doffset  = 5;
        Goffset  = 10;
        Boffset  = 14;
        E2offset = 19;
        
    end
    properties (Access = private)
        
    end
 
    methods
        function out = process(plugin, in)                           %< == (4) Define audio processing.
            udpr = dsp.UDPReceiver('LocalIPPort', 14550);
            % plugin.udpr = dsp.UDPReceiver('LocalIPPort', 14550);
            chord = udpr();
            if chord == 0 %"Am"
                fret = [5 7 7 5 5 5];
            % elseif chord == "C"
            %     fret = [8 10 10 9 8 8];
            % elseif chord == "Dm"
            %     fret = [10 12 12 10 10 10];
            % elseif chord == "Em"
            %     fret = [0 2 2 0 0 0];
            % elseif chord == "F"
            %     fret = [1 3 3 2 1 1];
            % elseif chord == "G"
            %     fret = [3 2 0 0 0 3];
            else
                out = in;
                return
            end


            %Generate the frequency vector that we will use for analysis.
            F = linspace(1/plugin.Fs, 1000, 2^12);

            %Generate 4 seconds of zeros to be used to generate the guitar notes.
            x = zeros(plugin.Fs*4, 1);            
           
           
           %Get the delays for each note based on the frets and the string offsets.
           delay = [round(plugin.Fs/(plugin.A*2^((fret(1)+plugin.Eoffset)/12))), ...
                    round(plugin.Fs/(plugin.A*2^(fret(2)/12))), ...
                    round(plugin.Fs/(plugin.A*2^((fret(3)+plugin.Doffset)/12))), ...
                    round(plugin.Fs/(plugin.A*2^((fret(4)+plugin.Goffset)/12))), ...
                    round(plugin.Fs/(plugin.A*2^((fret(5)+plugin.Boffset)/12))), ...
                    round(plugin.Fs/(plugin.A*2^((fret(6)+plugin.E2offset)/12)))];

  
            b = cell(length(delay),1);
            a = cell(length(delay),1);
            note = zeros(length(x),length(delay));
            for indx = 1:length(delay)
    
                % Build a cell array of numerator and denominator coefficients.
                b{indx} = firls(42, [0 1/delay(indx) 2/delay(indx) 1], [0 0 1 1]).';
                a{indx} = [1 zeros(1, delay(indx)) -0.5 -0.5].';
    
                % Populate the states with random numbers and filter the input zeros.
                zi = rand(max(length(b{indx}),length(a{indx}))-1,1);
    
                note(:, indx) = filter(b{indx}, a{indx}, x, zi);
    
                % Make sure that each note is centered on zero.
                note(:, indx) = note(:, indx) - mean(note(:, indx));
    
                % [H(indx,:),~] = freqz(b{indx}, a{indx}, F, plugin.Fs);
            end

            
            %Combine the notes and normalize them.
            combinedNote = sum(note,2);
            combinedNote = combinedNote/max(abs(combinedNote));

            % To hear, type: 
            % hplayer = audioplayer(combinedNote, plugin.Fs); 
            % out = play(hplayer);
            out = [combinedNote combinedNote];

        end
    end
end