% not working yet
%----------------------Ideal Transformer Class------------------------
classdef IdealTransformer < Adaptor % the class for parallel 3-port adaptors
    properties
        WD = 0;% this is the down-going wave at the adapted port
        WU = 0;% this is the up-going wave at the adapted port
        N = 0; % turns ratio
    end
    methods
        function obj = IdealTransformer(KidRight, N) % constructor function
            obj.KidRight = KidRight; % connect the right 'child'
            obj.N = N;
            obj.PortRes = N^2*KidRight.PortRes;
        end
        function WU = WaveUp(obj) % the up-going wave at the adapted port
            A1 = WaveUp(obj.KidRight);
            WU = obj.N*A1;
            obj.WU = WU;
        end
        function WD = WaveDown(obj, WaveFromParent) % the up-going wave at the adapted port
            A2 = WaveFromParent;
            WD = (1/obj.N)*A2;
            obj.WD = WD;
            WaveDown(obj.KidRight, WD);
        end
    end
end
