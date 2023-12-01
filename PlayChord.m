classdef PlayChord < audioPlugin % Inherit from audioPluginSource (one that only generates sound)

    properties
        % Music Logic
        lastChord uint8 = 0;
        buffer = zeros(48000 * 3, 2); % buffer for storing generated sound, sort of circular buffer  

        udpr
    end
    properties (Constant)
        % Music Consts
        AFreq    = 110; % The A string of a guitar is normally tuned to 110 Hz
        Eoffset  = -5;
        Doffset  = 5;
        Goffset  = 10;
        Boffset  = 14;
        E2offset = 19;
        LengthOfNote = 3;

        minChord = 0;
        maxChord = 25;
    end
    methods
        function plugin = PlayChord % constructor
            plugin.udpr = dsp.UDPReceiver('LocalIPPort', 1108); % initialize UDP Receive object
        end

        function note = generateNote(plugin, fret, FS)
            % Generate zeros to be used to generate the guitar notes.
            x = zeros(FS * plugin.LengthOfNote, 1);      
            A = linspace(0,1,FS/100).';
            S = ones(FS,1);
            R = linspace(1,0,FS*(plugin.LengthOfNote - 1.01)).';
            ADSR = [A;S;R]; % ADSR envelope

            % Get the delays for each note based on the frets and the string offsets.
            % D = Fs/F0 where Fs = sampling rate and F0 = fundamental frequency
            stringDelays = [round(FS/(plugin.AFreq*2^((fret(1)+plugin.Eoffset)/12))), ...
                    round(FS/(plugin.AFreq*2^(fret(2)/12))), ...
                    round(FS/(plugin.AFreq*2^((fret(3)+plugin.Doffset)/12))), ...
                    round(FS/(plugin.AFreq*2^((fret(4)+plugin.Goffset)/12))), ...
                    round(FS/(plugin.AFreq*2^((fret(5)+plugin.Boffset)/12))), ...
                    round(FS/(plugin.AFreq*2^((fret(6)+plugin.E2offset)/12)))];

            bCoefs = cell(length(stringDelays), 1); % struct for b filter coefficients for each string
            aCoefs = cell(length(stringDelays), 1); % struct for a filter coefficients for each string
            
            notes = zeros(length(x), length(stringDelays)); % array for each generated string/note

            % generate sound of every string/note
            for stringId = 1:length(stringDelays)
                % Build a cell array of numerator and denominator coefficients.
                bCoefs{stringId} = firls(42, [0 1/stringDelays(stringId) 2/stringDelays(stringId) 1], [0 0 1 1]).';
                aCoefs{stringId} = [1 zeros(1, stringDelays(stringId)) -0.5 -0.5].';
    
                % Populate the states with random numbers and filter the input zeros.
                zi = rand(max(length(bCoefs{stringId}),length(aCoefs{stringId})) - 1, 1);
                
                % Filter
                notes(:, stringId) = filter(bCoefs{stringId}, aCoefs{stringId}, x, zi);
    
                % Make sure that each note is centered on zero.
                notes(:, stringId) = notes(:, stringId) - mean(notes(:, stringId));
            end

            note = sum(notes, 2); % Combine the notes
            note = note/max(abs(note)); % Normalize the sound

            note = note .* ADSR;
        end % generateNote() 

        function out = process(plugin, in) % Define audio processing 
            sampleRate = plugin.getSampleRate(); % read host's sample rate 
            bufferLen = size(in,1); % read host's buffer length 
            
            chord = plugin.udpr();

            % We only generate a new sound if the chord was changed!
            % checks if a new chord was played
            if ~isempty(chord) && chord(1) ~= plugin.lastChord
                plugin.lastChord = chord(1); % save the new chord
                if plugin.minChord < plugin.lastChord && plugin.lastChord < plugin.maxChord
                    newFret = plugin.getFretsFromChordNumber(plugin.lastChord); % get frets number of this chord
                    
                    newNote = plugin.generateNote(newFret, sampleRate); % generate new note's sound
                    newNoteLength = plugin.LengthOfNote * sampleRate;
    
                    plugin.buffer(1:newNoteLength,:) = plugin.buffer(1:newNoteLength,:) + newNote;
                end
            end
            
            % Assing output and circulate our buffer
            out = plugin.buffer(1:bufferLen, :); % assing next "samples" to the output buffer
    
            L = length(plugin.buffer);
            plugin.buffer(1:L - bufferLen, :) = plugin.buffer(bufferLen + 1:L,:); % shift samples - "circular buffer"

        end % process()  
        
        % system object initialization
        function s = saveobj(obj)
            s = saveobj@audioPlugin(obj);
            s.udpr = matlab.System.saveObject(obj.udpr);
        end
        % system object initialization
        function obj = reload(obj,s)
            obj = reload@audioPlugin(obj,s);
            obj.udpr = matlab.System.loadObject(s.udpr);
        end

    end
    methods(Static)
        % system object initialization
        function obj = loadobj(s)
            if isstruct(s)
                obj = audiopluginexample.PlayChord;
                obj = reload(obj,s);
            end
        end     
    
        function frets = getFretsFromChordNumber(no)
            chordMappings = {"A","Am","A#","A#m"...
                             "B","Bm",...
                             "C","Cm", "C#","C#m",...
                             "D","Dm","D#","D#m"...
                             "E","Em",...
                             "F","Fm","F#","F#m"...
                             "G","Gm","G#","G#m"};

            switch chordMappings{no}
                case "A"
                    frets = [5 7 7 3 5 5];
                case "Am"
                    frets = [5 7 7 5 5 5];
                case "A#"
                    frets = [6 4 4 5 6 6];
                case "A#m"
                    frets = [6 4 4 6 6 6];
                case "B"
                    frets = [7 9 9 8 7 7];
                case "Bm"
                    frets = [7 9 9 7 7 7];
                case "C"
                    frets = [8 10 10 9 8 8];
                case "Cm"
                    frets = [8 10 10 8 8 8];
                case "C#"
                    frets = [9 11 11 10 9 9];
                case "C#m"
                    frets = [9 11 11 9 9 9];
                case "D"
                    frets = [10 12 12 11 10 10];
                case "Dm"
                    frets = [10 12 12 10 10 10];
                case "D#"
                    frets = [11 13 13 12 11 11];
                case "D#m"
                    frets = [11 13 13 11 11 11];
                case "E"
                    frets = [0 2 2 1 0 0];
                case "Em"
                    frets = [0 2 2 0 0 0];
                case "F"
                    frets = [1 3 3 2 1 1];
                case "Fm"
                    frets = [1 3 3 1 1 1];
                case "F#"
                    frets = [2 4 4 3 2 2];
                case "F#m"
                    frets = [2 4 4 2 2 2];
                case "G"
                    frets = [3 2 0 0 0 3];
                case "Gm"
                    frets = [3 5 5 3 3 3];
                case "G#"
                    frets = [4 6 6 5 4 4];
                case "G#m"
                    frets = [4 6 6 4 4 4];
                otherwise
                    frets = [5 7 7 3 5 5]; % just in case defaults to A
            end
        end % getFretsFromChord() 

    end
end