   function [] = cprints(astr_LC, astr_RC, varargin)
	
	LC = 40;
	RC = 40;

	if length(varargin) >= 1; LC	= varargin{1}; end
	if length(varargin) >= 2; RC	= varargin{2}; end
        
        if length(astr_LC) 
            fprintf(1, '%s', sprintf('%*s',   LC, astr_LC));
        end
        if length(astr_RC)
            fprintf(1, '%s', sprintf('%*s\n', RC, astr_RC));
        end
    end
