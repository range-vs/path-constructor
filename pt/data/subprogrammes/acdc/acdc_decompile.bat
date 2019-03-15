if exist ..\all del ..\all /Q
universal_acdc.pl -d ..\all.spawn -out ..\all -scan ..\..\config -graph ..\..\
copy guids.ltx ..\all\guids.ltx
pause