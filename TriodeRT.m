classdef TriodeRT < audioPlugin
    
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
        
        R0
        C0
        
        A1
        V
        
        A2
        
        Rk
        
        Ck
        
        A3
        
        A4
        
        triodePortRes
        
        Vk = 0;
        Vpk = 0;
        
    end
    
    methods
        function obj = TriodeRT()
            obj.pSR = getSampleRate(obj);
            Fs = obj.pSR;
            obj.R0 = Resistor(1e6);
            obj.C0 = Capacitor(10e-9, Fs);
            
            obj.A1 = Series(obj.C0,obj.R0);
            
            obj.V = TerminatedVs(250,100e3);
            
            obj.A2 = Parallel(obj.V, obj.A1);
            
            obj.Rk = Resistor(1e3);
            
            obj.Ck = Capacitor(10e-6,Fs);
            
            obj.A3 = Parallel(obj.Ck,obj.Rk);
            
            obj.A4 = Series(obj.A3,obj.A2);
            obj.triodePortRes = obj.A1.PortRes;%(A4.KidLeft.PortRes *  A4.KidRight.PortRes)/(A4.KidLeft.PortRes + A4.KidRight.PortRes);
            
        end
%         function b = solveNL(obj, a, R, Vgk)
%             maxIter = 5;   % maximun number of iterations
%             dx = 1e-6;      % delta x
%             err =  1e-6;    % error
%             epsilon = 1e-9; % a value close to 0 to stop the iteration if the equation is converging
%             
%             iter = 1;        % reset iter to 1
%             % Newton-Raphson algorithm
%             x = obj.Vpk;
%             while (abs(err) / abs(x) > epsilon )
%                 diffX = x + dx;
%                 f = x + R * getIp(Vgk, x) - a; % (7)
%                 df = diffX + R * getIp(Vgk, diffX) - a;
%                 newVpk = x - (dx*f)/(df - f);
%                 x = newVpk;
%                 iter = iter + 1;
%                 if (iter > maxIter)         % if iter is larger than the maximum nr of iterations
%                     break;                  % break out from the while loop
%                 end
%             end
%             obj.Vpk = x;
%             %plot(pVpk);
%             b = obj.Vpk - R * getIp(Vgk,obj.Vpk);
%         end
        
        function reset(obj)
            obj.pSR = getSampleRate(obj);
            
        end
        
        function out = process(obj, x)
            [numSamples,m] = size(x);
            output = zeros(size(x));
            input = obj.gain*sum(x,m)/m;
            %input = x(:,1);
            Vg = obj.dist;
            
            for n = 1:numSamples % run each time sample until N
                obj.V.E = input(n); % read the input signal for the voltage source
                a = WaveUp(obj.A4);
                
                Vgk = Vg - obj.Vk;
                
                [b, z] = triodeNL(a, obj.triodePortRes, Vgk, complex(obj.Vpk));
                obj.Vpk = real(z);
             
                WaveDown(obj.A4, real(b));
                % update Vk, unit delay
                obj.Vk = Voltage(obj.Rk);
                
                output(n,:) = Voltage(obj.R0);
            end
            %oScale = output/max(abs(output));
            %output = [oScale, oScale];
            out = output*obj.mix + (1-obj.mix)*x;
        end
    end
end
