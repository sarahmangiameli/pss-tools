function f = draw_cell_outline(rl)

hold on;

nc = max( rl(:) );

props = regionprops( rl, 'PixelList' );

% Sets color depending on cell ID
for ii = 1:nc

    cc = 'y';

    % Mask for current region
    tmp = rl;
    tmp(tmp ~= ii) = 0;
    
    % Increase size of mask by 1 px and find boundary
    se = strel('disk',1);
    tmp2 = logical(imdilate(tmp,se));
    [y,x] = find(tmp2 == 1);
    k = boundary(x,y,1);


    hold on;
    skip = 1;
    kk = k([1:skip:end]);
    kk = kk([end-3:end,1:end,1:4]);

    n = 1:numel(kk);
    nn = 5:1:(numel(kk)-1);

    p = 0.1; %smaller value of p gives more smoothing

    xx = fnval(csaps( n, x(kk),p), nn);
    yy = fnval(csaps( n, y(kk),p), nn);


    % Plots outline on image
    plot( xx, yy, 'LineStyle','-','Color',cc,'LineWidth', .5 );

end

end