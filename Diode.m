%----------------------Diode Class------------------------
classdef Diode < OnePort % the class for parallel 3-port adaptors
    properties
       
        
        b = 0;  % unit delay
        a = 0;
        kd = 0.005;
        ud = 2.1;
        Rd = 0;
    end
    methods
        function obj = Diode(PortRes) % constructor function
            obj.PortRes = PortRes; % connect the right 'child'
        end
        function WU = WaveUp(obj) % the up-going wave at the adapted port
            WU = 0;
            obj.WU = 0;
            
            Vrd = obj.a + WU;
            if Vrd > 10^-60
               obj.Rd = 1/obj.kd * Vrd^(1-obj.ud)
            else
               obj.Rd = 1/obj.kd *10^-60*(1-obj.ud)     
            end
           obj.PortRes = obj.Rd;
           % Adapt tree here with new port res
        end
        function WD = WaveDown(obj, WaveFromParent) % the up-going wave at the adapted port
            obj.a = WaveFromParent;
            WD = obj.a;
            obj.WD = WD;
            
        end
    end
end
