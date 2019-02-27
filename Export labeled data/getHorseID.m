function hID = getHorseID(filename)

IDTABLE = cell2table({
'Viva',	'CCDC3016AE9D6B4';
'Driekus',	'CCDC3016C04F558';
'Galoway',	'CCDC301688BDC0C';
'Barino',	'CCDC3016A3F89FE';
'Zonnerante',	'CCDC301653728E4';
'Patron',	'CCDC29BCF3C';
'Duke',	'CCDC3016A17897C';
'Porthos',	'CCDC3016401B78B';
'Bacardi',	'CCDC3016FC0FDE2';
'Happy',	'CCDC3016D45EA09';
'Clever',	'CCDC30169DF220E';
'Noortje',	'CCDC3016707B61E';
'Flower',	'CCDC301683589E7';
'Peter Pan',	'CCDC30169E66C48';
'Niro',	'CCDC30164C847DF';
'Sense',	'CCDC301661B33D7';
});
IDTABLE.Properties.VariableNames = {'name','SN'};
idx = strfind(filename,'_');
SN = filename(idx(2)+1:end-4);
hID = IDTABLE.name(strcmp(IDTABLE.SN,SN));
hID = hID{1};

end

