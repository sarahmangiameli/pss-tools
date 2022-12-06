function l2enr = get_enr(sel,inp,l2)

sel_norm = sel/sum(sel);
inp_norm = inp/sum(inp);

if l2
    l2enr = log2(sel_norm./inp_norm);
else
    l2enr=sel_norm./inp_norm;
end

end
