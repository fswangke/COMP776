function n2 = ncc2(x, c)
    [~, dimx] = size(x);
    [~, dimc] = size(c);
    if dimx ~= dimc
        error('Data dimension does not match dimension of centers')
    end

    n2 = x * c' ./ (diag(sqrt(x * x')) * diag(sqrt(c * c'))');
end