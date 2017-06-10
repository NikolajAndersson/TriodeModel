classdef TriodeRT < audioPlugin
% Vacuum-tube model from WAVE DIGITAL SIMULATION OF A VACUUM-TUBE AMPLIFIER by Matti Karjalainen and Jyri Pakarinen    
    properties
        gain = 1
        dist = 1
        mix = 0.5
    end
    
    properties (Constant)
        % audioPluginInterface manages the number of input/output channels
        % and uses audioPluginParameter to generate plugin UI parameters.
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('mix','DisplayName','Mix','Label','','Mapping',{'lin',0 1}),...
            audioPluginParameter('dist','DisplayName','Distortion','Label','','Mapping',{'lin',0.1 20}),...
            audioPluginParameter('gain','DisplayName','Gain','Label','','Mapping',{'lin',0 3}));
    end
    
    properties (Access = private)
        pSR
        % initialise component variables
        R0
        C0       
        A1
        V       
        A2
        Rk        
        Ck
        A3
        A4
        % and other private variables
        triodePortRes
        
        Vk = 0;
        Vpk = 0;      
    end
    
    methods
        function obj = TriodeRT()
            obj.pSR = getSampleRate(obj);
            Fs = obj.pSR;
            % Build Circuit
            obj.R0 = Resistor(1e6);
            obj.C0 = Capacitor(10e-9, Fs);
            
            obj.A1 = Series(obj.C0,obj.R0);
            
            obj.V = TerminatedVs(250,100e3);
            
            obj.A2 = Parallel(obj.V, obj.A1);
            
            obj.Rk = Resistor(1e3);
            
            obj.Ck = Capacitor(10e-6,Fs);
            
            obj.A3 = Parallel(obj.Ck,obj.Rk);
            
            obj.A4 = Series(obj.A3,obj.A2);
            % R0 port resistance
            obj.triodePortRes = obj.A1.PortRes;
        end      
        function reset(obj)
            obj.pSR = getSampleRate(obj);   
        end
        
        function out = process(obj, x)
            [numSamples,m] = size(x);
            output = zeros(size(x));
            input = obj.gain*sum(x,m)/m;
            Vg = obj.dist;            
            for n = 1:numSamples % run each time sample until N
                obj.V.E = input(n); % read the input signal for the voltage source
                % Calculate up-going waves
                a = WaveUp(obj.A4); 
                % Calculate Vgk
                Vgk = Vg - obj.Vk;
                % Nonlinear triode calculations goes in here
                [b, z] = triodeNL(a, obj.triodePortRes, Vgk, complex(obj.Vpk));
                obj.Vpk = real(z);
                % Send the wave down the tree
                WaveDown(obj.A4, real(b));
                % update Vk, unit delay
                obj.Vk = Voltage(obj.Rk);
                % Read output voltage at R0
                output(n,:) = Voltage(obj.R0);
            end
            % Mix clean and dirty sound
            out = output*obj.mix + (1-obj.mix)*x;
        end
    end
end
