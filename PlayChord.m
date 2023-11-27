classdef PlayChord < audioPluginSource % Inherit from audioPluginSource (one that only generates sound)

    properties
        % Music Consts
        A        = 110; % The A string of a guitar is normally tuned to 110 Hz
        Eoffset  = -5;
        Doffset  = 5;
        Goffset  = 10;
        Boffset  = 14;
        E2offset = 19;
        LengthOfNote = 1;
        MaxSampleRate = 192000;

        % Music Logic
        lastChord = "";
        buffer = zeros(LengthOfNote * MaxSampleRate, 2); % buffer for storing generated sound, sort of circular buffer

        % Technical
        UdpPort = 14550;

    end
    methods

        function note = generateNote(plugin, fret, FS)
            % Generate zeros to be used to generate the guitar notes.
            x = zeros(FS * plugin.LengthOfNote, 1);         

            % Get the delays for each note based on the frets and the string offsets.
            stringDelays = [round(FS/(plugin.A*2^((fret(1)+plugin.Eoffset)/12))), ...
                    round(FS/(plugin.A*2^(fret(2)/12))), ...
                    round(FS/(plugin.A*2^((fret(3)+plugin.Doffset)/12))), ...
                    round(FS/(plugin.A*2^((fret(4)+plugin.Goffset)/12))), ...
                    round(FS/(plugin.A*2^((fret(5)+plugin.Boffset)/12))), ...
                    round(FS/(plugin.A*2^((fret(6)+plugin.E2offset)/12)))];

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

            note = sum(notes,2); % Combine the notes
            note = note/max(abs(note)); % Normalize the sound
        end % generateNote() 

        function out = process(plugin) % Define audio processing 
            % udpr = dsp.UDPReceiver('LocalIPPort', 14550); 
            % if(udpr) % TODO check if UDP in the list 
            % chord = udpr();

            sampleRate = getSampleRate();
            bufferLen = getSamplesPerFrame();
            
            % We only generate a new sound if the chord was changed!
            % checks if a new chord was played
            if chord ~= plugin.lastChord
                plugin.lastChord = chord; % save the new chord
                newFret = getFretsFromChord(chord); % get frets number of this chord
                
                newNote = generateNote(plugin, newFret, sampleRate); % generate new note's sound
                newNoteLength = plugin.LengthOfNote * sampleRate;

                plugin.buffer(1:newNoteLength,:) = plugin.buffer(1:newNoteLength,:) + newNote;
            end
            
            % Assing output and circulate our buffer
            out = plugin.buffer(1:bufferLen, :); % assing next "samples" to the output buffer
    
            L = length(plugin.buffer);
            plugin.buffer(1:L - bufferLen, :) = plugin.buffer(bufferLen + 1:L,:); % shift samples - "circular buffer"

        end % process()  
        
    end

    methods(Static)
        function frets = getFretsFromChord(chordName)
            if chordName == "A"
                frets = [5 7 7 3 5 5];
            elseif chordName == "Am"
                frets = [5 7 7 5 5 5];
            elseif chordName == "A#"
                frets = [6 4 4 5 6 6];
            elseif chordName == "A#m"
                frets = [6 4 4 6 6 6];
            elseif chordName == "B"
                frets = [7 9 9 8 7 7];
            elseif chordName == "Bm"
                frets = [7 9 9 7 7 7];
            elseif chordName == "C"
                frets = [8 10 10 9 8 8];
            elseif chordName == "Cm"
                frets = [8 10 10 8 8 8];
            elseif chordName == "C#"
                frets = [9 11 11 10 9 9];
            elseif chordName == "C#m"
                frets = [9 11 11 9 9 9];
            elseif chordName == "D"
                frets = [10 12 12 11 10 10];
            elseif chordName == "Dm"
                frets = [10 12 12 10 10 10];
            elseif chordName == "D#"
                frets = [11 13 13 12 11 11];
            elseif chordName == "D#m"
                frets = [11 13 13 11 11 11];
            elseif chordName == "E"
                frets = [0 2 2 1 0 0];
            elseif chordName == "Em"
                frets = [0 2 2 0 0 0];
            elseif chordName == "F"
                frets = [1 3 3 2 1 1];
            elseif chordName == "Fm"
                frets = [1 3 3 1 1 1];
            elseif chordName == "F#"
                frets = [2 4 4 3 2 2];
            elseif chordName == "F#m"
                frets = [2 4 4 2 2 2];
            elseif chordName == "G"
                frets = [3 2 0 0 0 3];
            elseif chordName == "Gm"
                frets = [3 5 5 3 3 3];
            elseif chordName == "G#"
                frets = [4 6 6 5 4 4];
            elseif chordName == "G#m"
                frets = [4 6 6 4 4 4];
            else
                frets = [5 7 7 3 5 5]; % just in case defaults to A
            end
        end % getFretsFromChord() 

    end
end