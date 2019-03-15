if exist "H:\Program Files\S.T.A.L.K.E.R. - Zov Pripyati\gamedata\spawns\all" del "H:\Program Files\S.T.A.L.K.E.R. - Zov Pripyati\gamedata\spawns\all" /Q 
universal_acdc.pl -d "H:\Program Files\S.T.A.L.K.E.R. - Zov Pripyati\gamedata\spawns\all.spawn" -out "H:\Program Files\S.T.A.L.K.E.R. - Zov Pripyati\gamedata\spawns\all" -scan "H:\Program Files\S.T.A.L.K.E.R. - Zov Pripyati\config" -graph "H:\Program Files\S.T.A.L.K.E.R. - Zov Pripyati\gamedata"
copy guids.ltx "H:\Program Files\S.T.A.L.K.E.R. - Zov Pripyati\gamedata\spawns\all\guids.ltx" 
pause
