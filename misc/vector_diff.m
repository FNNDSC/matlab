    function [av_diff] 	= vector_diff(av_X1, av_X2)
	v_sqdiff 	= (av_X2 - av_X1).^2;
	av_diff		= sqrt((v_sqdiff));
    end
