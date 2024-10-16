
****************************************************************************
*** Gemeinsamer Bericht 2024 zu ukrainischen Geflüchteten - Bleibeabsichten ***
****************************************************************************

	
	*Informationen zum Bleibewunsch zusammenfassen	
	gen bleibewunsch = .
	replace bleibewunsch = 1 if plj0085_v1==1
	replace bleibewunsch = 2 if (plj0085_v1==2 & plj0086_v1==1) | (plj0085_v1==.a & plj0086_v1==1)
	replace bleibewunsch = 3 if (plj0085_v1==2 & plj0086_v1==2) | (plj0085_v1==.a & plj0086_v1==2)
	replace bleibewunsch = 4 if (plj0085_v1==2 & plj0086_v1==.a)
	
	label define bleiben_lbl 1"für immer in D" 2"höchstens noch 1 Jahr" 3"noch einige Jahre" 4"nicht für immer, k.A. zur Rückkehr"
	label values bleibewunsch bleiben_lbl
	tab bleibewunsch, m
	
	*Person will für immer in Deutschland bleiben
	gen fuerimmer = .
	replace fuerimmer=1 if bleibewunsch==1
	replace fuerimmer=0 if bleibewunsch > 1 & bleibewunsch<.
	
	tab fuerimmer,m
	tab forever_de_v40 fuerimmer,m ///Bei der hier generierten Variable weniger Missings
	
	*Person will für immer oder noch mehrere Jahre in Deutschland bleiben
	gen fuerlange = .
	replace fuerlange=1 if bleibewunsch==1 | bleibewunsch==3
	replace fuerlange=0 if bleibewunsch == 2 | bleibewunsch==4
	tab fuerlange,m
	
	
	
	