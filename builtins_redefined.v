
/* clog2 redefinition for XST */
function integer _clog2;
    input integer value;
    begin
        value = value-1;
        for (_clog2='d0; value>'d0; _clog2=_clog2+1)
            value = value>>1;
    end
endfunction

/* max redefinition for XST */
function integer _max;
    input integer a,b;
    begin
        if (a>=b) _max = a;
        else      _max = b;
    end
endfunction
