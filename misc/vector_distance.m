    function [af] 	= vector_distance(av_X1, av_X2)
	v_sqdiff 	= (av_X2 - av_X1).^2;
	af 		= sqrt(sum(sum(v_sqdiff)));
    end
