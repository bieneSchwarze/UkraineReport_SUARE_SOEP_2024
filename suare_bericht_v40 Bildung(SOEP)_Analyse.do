*** UKR-BILDUNG. Bericht für Ukrainische Geflüchteten aus der ersten SUARE-Welle 2023 (in SOEP-Core integriert)
* # Sabine Zinn, Andrea Marchitto, Jaques Matteo Büsche 
 
/*
- THEMEN

1) Kinderbetreuungsbedarfe und Prävalenz
2) Verteilung Kinder Schultypen (Schulsystem/Bundeslandgruppe)
3) Weiterführende Bildung und Bildungsbeteiligung: Ausbildung / Uni


- VERWENDETE ITEMS

HH-Fragebogen (Betreeuungsbatterie / Schultyp)
Personenfragebogen (Weiterführende Bildung, Soziodemoghraphische Infos über Eltern)

- STATISTISCHER ANSATZ

Deskriptive, gewichtete Auswertung
Stratifizierung nach 
	- Alter, Geschlecht Kind,
	- Region (DEU) [auch Herkunftsregion in Ukriane?]
	- Familienstand Eltern bzw. Angehörige Vorort
	- Erwerbsstatus und Bildung Eltern
*/

clear all
set maxvar 10000
capture log close
	
* setting globals for working directory and log_files

global in "\\hume\rdc-arch\consolidate\soep-core\v40\Enddaten\SOEP-2023-Enddaten_REF_7709_Update_1_20240904"
global AVZ "I:\MA\amarchitto\SUARE\Bericht_finale_dataset"
global do "$AVZ\do"
global out_log "$AVZ\log"
global out_data "$AVZ\output"
global out_temp "$AVZ\temp"

log using $out_log\suare_bericht_v40_Bildung_SOEP_Analyse.log, text replace

	/* --------------------------------------   
                 UPLOADING DATA
    --------------------------------------- */
use $out_temp/suare_bericht_v40_Bildung_relmatrix.dta, clear


/* --------------------------------------   
       KINDERBETREUUNGSBEDARF UND PRÄVALENZ
    --------------------------------------- */

* overall situation of childrencare and school attendance: keeping only one child observation! weighted

distinct hid pid hknr_ // unique
	// hid observed = 1121
	// pid observed = 1758
	// hkrn_ observed = 1719

bysort hknr_: gen n_children = _n
br hknr_ n_children
fre n_children

* age, gender and region of residence description of ukr children: unweighted and weighted
tab1 age_k_categ_ sex_k_new bula if n_children==1
tab1 age_k_categ_ sex_k_new bula [aw=gewicht_kinder] if n_children==1

/* variables:
	- ks_pre_v6_*      --> "Kinder (<16) im HH: Besuch Betreuungseinrichtung (1-10)"
	- kc_kindbetr_*    --> "Kinder (<16) im HH: Besuch Betreuungseinrichtung (Std./Woche) (1-10)"
	- ks_hasc_*        --> "Kinder (<16) im HH: Wochenstunden Schulbetreuung (1-10)"
	- ks_asc_v2_*      --> "Kinder (<16) im HH: Hortbesuch (1-10)"
	- kc_wselbst_*     --> "Kinder (<16) im HH: Eigene Betreuung (1-10)"
	- kc_wpart_*       --> "Kinder (<16) im HH: Partner betreut (1-10)"
	- kc_weltern_*     --> "Kinder (<16) im HH: Elternteil des Kindes betreut (1-10)"
	- kc_wgeltern_*    --> "Kinder (<16) im HH: Großeltern des Kindes betreuen (1-10)"
	- kc_wgesch_*      --> "Kinder (<16) im HH: Ältere Geschwister betreuen (1-10)"
	- kc_wverw_*       --> "Kinder (<16) im HH: Andere Verwandte betreuen (1)"
	- kc_wtagm_*       --> "Kinder (<16) im HH: Bezahlte Betreuungsperson betreut außerhalb des HH (1-10)"
	- kc_wbezb_*       --> "Kinder (<16) im HH: Bezahlte Betreuungsperson betreut im HH (1-10)"
	- kc_wfreund_*     --> "Kinder (<16) im HH: Freunde/Bekannte/Nachbarn betreuen (1-10)"
	- kc_wnone_*       --> "Kinder (<16) im HH: Keine Betreuung (1-10)"
	     
		 / - - - /
		 
	- ks_gen_v8_*      --> "Kinder (<16) im HH: Schule (1-10)"
	- ks_spe_*         --> "Kinder (<16) im HH: Schule mit speziellem Konzept (1-10)"
	- kd_time_v2_*     --> "Kinder (<16) im HH: Schule ganzttags (1-10)"
	- ks_stufe_*       --> "Kinder (<16) im HH: Klassenstufe (1-10)"
	- ks_none_v3_*     --> "Kinder (<16) im HH: Kein Schulbesuch (1-10)"
	- ks_usch1_*       --> "Kinder (<16) im HH: Onlineunterricht ukrainische Schule (1-10)"
	- ks_usch2_*       --> "Kinder (<16) im HH: Besuch ukrainische Schule online (1-10)"
	  
		 / - - - /
		 
	- kc_vorsch_*      --> "Kinder (<16) im HH: Geht gerne in Betreuungseinrichtung (1-10)"
	- ka16_slang_v1_*  --> "Kinder (<16) im HH: Spezielle Sprachförderung in Schule (1-10)"
	- ka16_lang_v1_ *  --> "Kinder (<16) im HH: Spezielle Sprachförderung außerhalb der Schule (1-10)"
	- ka16_hlang_v3_*  --> " Kinder (<16) im HH: Spezielle Sprachförderung außerhalb der Schule (Std./Woche) (1-10)"
   	*/

lab var ks_pre_v6_ "Kinder (<16) im HH: Besuch Betreuungseinrichtung (1-10)"
lab var kc_kindbetr_ "Kinder (<16) im HH: Besuch Betreuungseinrichtung (Std./Woche) (1-10)"
lab var ks_hasc_ "Kinder (<16) im HH: Wochenstunden Schulbetreuung (1-10)"
lab var ks_asc_v2_ "Kinder (<16) im HH: Hortbesuch (1-10)"
lab var kc_wselbst_ "Kinder (<16) im HH: Eigene Betreuung (1-10)"
lab var kc_wpart_ "Kinder (<16) im HH: Partner betreut (1-10)"
lab var kc_weltern_ "Kinder (<16) im HH: Elternteil des Kindes betreut (1-10)"
lab var kc_wgeltern_ "Kinder (<16) im HH: Großeltern des Kindes betreuen (1-10)"
lab var kc_wgesch_ "Kinder (<16) im HH: Ältere Geschwister betreuen (1-10)"
lab var kc_wverw_ "Kinder (<16) im HH: Andere Verwandte betreuen (1)"
lab var kc_wtagm_ "Kinder (<16) im HH: Bezahlte Betreuungsperson betreut außerhalb des HH (1-10)"
lab var kc_wbezb_ "Kinder (<16) im HH: Bezahlte Betreuungsperson betreut im HH (1-10)"
lab var kc_wfreund_ "Kinder (<16) im HH: Freunde/Bekannte/Nachbarn betreuen (1-10)"
lab var kc_wnone_ "Kinder (<16) im HH: Keine Betreuung (1-10)"

lab var ks_gen_v8_ "Kinder (<16) im HH: Schule (1-10)"
lab var ks_spe_ "Kinder (<16) im HH: Schule mit speziellem Konzept (1-10)"
lab var kd_time_v2_ "Kinder (<16) im HH: Schule ganzttags (1-10)"
lab var ks_stufe_ "Kinder (<16) im HH: Klassenstufe (1-10)"
lab var ks_none_v3_ "Kinder (<16) im HH: Kein Schulbesuch (1-10)"
lab var ks_usch1_ "Kinder (<16) im HH: Onlineunterricht ukrainische Schule (1-10)"
lab var ks_usch2_ "Kinder (<16) im HH: Besuch ukrainische Schule online (1-10)"
		 
lab var kc_vorsch_ "Kinder (<16) im HH: Geht gerne in Betreuungseinrichtung (1-10)"
lab var ka16_slang_v1_ "Kinder (<16) im HH: Spezielle Sprachförderung in Schule (1-10)"
lab var ka16_lang_v1_ "Kinder (<16) im HH: Spezielle Sprachförderung außerhalb der Schule (1-10)"
lab var ka16_hlang_v3_ " Kinder (<16) im HH: Spezielle Sprachförderung außerhalb der Schule (Std./Woche) (1-10)"
	
		
/* --------------------------------------   
  KINDERBETREUUNGSBEDARF UND PRÄVALENZ: counting
    --------------------------------------- */
* exploring...
br hid hknr_ age_k_new age_k_categ_ sex_k_new bula kc_wnone_ ks_pre_v6_ ks_asc_v2_ kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ if n_children==1

* only children eligible for childcare and institutional childcare [age_k_categ_ 1, 2]
br hid hknr_ age_k_new age_k_categ_ sex_k_new bula kc_wnone_ ks_pre_v6_ ks_asc_v2_ kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ if n_children==1 & (age_k_categ_==1 | age_k_categ_==2)
		// n= 386

*                  _____________               ____________                 *
		
* COUNTING........
		
* 1. General description of children and childcare/school situation without stratification 
	* unweighted and with missings 
tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ if n_children==1, m

	* weighted
tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ [aw=gewicht_kinder] if n_children==1	

	* weighted with missings
tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ [aw=gewicht_kinder] if n_children==1, m	
*_______________________________________________________________________________


* 2. Stratification by children age-groups: age_k_categ_ [1,...,4]
	* distribution of var age_k_categ_ (unweighted)
tab age_k_categ_ if n_children==1
/*
                           age_k_categ_ |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
[1] Age 0-3 (excl.). Children eligible  |        151        8.78        8.78
[2] Age 3-6 (excl.). Children eligible  |        235       13.67       22.45
[3] Age 6-12. Children eligible for Gru |        407       23.68       46.13
[4] Age 13-16,17. Pupils eligible for H |        926       53.87      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,719      100.00

*/

		* (weighted)
tab age_k_categ_ [aw=gewicht_kinder] if n_children==1
/*
	                       age_k_categ_ |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
[1] Age 0-3 (excl.). Children eligible  | 152.105673        8.86        8.86
[2] Age 3-6 (excl.). Children eligible  |  249.00009       14.50       23.36
[3] Age 6-12. Children eligible for Gru | 406.840321       23.69       47.06
[4] Age 13-16,17. Pupils eligible for H | 909.053916       52.94      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,717      100.00
*/

	* unweighted and with missings 
bysort age_k_categ_: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ if n_children==1, m

	* weighted
bysort age_k_categ_: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ [aw=gewicht_kinder] if n_children==1	

	* weighted with missings
bysort age_k_categ_: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ [aw=gewicht_kinder] if n_children==1, m	
*_______________________________________________________________________________


* 3. Stratification by children gender: sex_k_new [1, 2]
	* distribution of var sex_k_new (unweighted)
tab sex_k_new if n_children==1
/*
                              sex_k_new |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                               männlich |        775       51.60       51.60
                               weiblich |        727       48.40      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,502      100.00
*/

		* (weighted)
tab sex_k_new [aw=gewicht_kinder] if n_children==1

/*
                              sex_k_new |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                               männlich | 776.404988       51.76       51.76
                               weiblich | 723.595012       48.24      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,500      100.00
*/

	* unweighted and with missings 
bysort sex_k_new: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ if n_children==1, m

	* weighted
bysort sex_k_new: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ [aw=gewicht_kinder] if n_children==1	

	* weighted with missings
bysort sex_k_new: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ [aw=gewicht_kinder] if n_children==1, m	
*_______________________________________________________________________________


* 4. Stratification by children German region of residence: bula [1,...,16]
	* distribution of var bula (unweighted)
tab bula if n_children==1
/*
               Bundesland lt. Statistik |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                     Schleswig-Holstein |         65        3.78        3.78
                                Hamburg |         63        3.66        7.45
                          Niedersachsen |        146        8.49       15.94
                                 Bremen |          5        0.29       16.23
                    Nordrhein-Westfalen |        417       24.26       40.49
                                 Hessen |        166        9.66       50.15
                        Rheinland-Pfalz |         92        5.35       55.50
                      Baden-Württemberg |        149        8.67       64.17
                                 Bayern |        253       14.72       78.88
                               Saarland |         23        1.34       80.22
                                 Berlin |        126        7.33       87.55
                            Brandenburg |         31        1.80       89.35
                 Mecklenburg-Vorpommern |         30        1.75       91.10
                                Sachsen |         80        4.65       95.75
                         Sachsen-Anhalt |         38        2.21       97.96
                              Thüringen |         35        2.04      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,719      100.00
*/

		* (weighted)
tab bula [aw=gewicht_kinder] if n_children==1

/*
               Bundesland lt. Statistik |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                     Schleswig-Holstein | 78.6203729        4.58        4.58
                                Hamburg | 34.7361512        2.02        6.60
                          Niedersachsen | 185.705828       10.82       17.42
                                 Bremen | 3.79180887        0.22       17.64
                    Nordrhein-Westfalen | 364.888685       21.25       38.89
                                 Hessen | 143.717511        8.37       47.26
                        Rheinland-Pfalz | 84.3876347        4.91       52.18
                      Baden-Württemberg | 198.300998       11.55       63.72
                                 Bayern |  239.70596       13.96       77.69
                               Saarland |21.61065896        1.26       78.94
                                 Berlin |46.78773959        2.72       81.67
                            Brandenburg | 44.8520609        2.61       84.28
                 Mecklenburg-Vorpommern | 51.6401944        3.01       87.29
                                Sachsen | 99.7139667        5.81       93.10
                         Sachsen-Anhalt | 62.2864267        3.63       96.72
                              Thüringen | 56.2540037        3.28      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,717      100.00
*/

	* unweighted and with missings 
bysort bula: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ if n_children==1, m

	* weighted
bysort bula: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ [aw=gewicht_kinder] if n_children==1	

	* weighted with missings
bysort bula: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ [aw=gewicht_kinder] if n_children==1, m	
*_______________________________________________________________________________


* 5. Stratification by children family situation:
	* distribution of var sex_k_new (unweighted)
tab bula if n_children==1
/*
               Bundesland lt. Statistik |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                     Schleswig-Holstein |         65        3.78        3.78
                                Hamburg |         63        3.66        7.45
                          Niedersachsen |        146        8.49       15.94
                                 Bremen |          5        0.29       16.23
                    Nordrhein-Westfalen |        417       24.26       40.49
                                 Hessen |        166        9.66       50.15
                        Rheinland-Pfalz |         92        5.35       55.50
                      Baden-Württemberg |        149        8.67       64.17
                                 Bayern |        253       14.72       78.88
                               Saarland |         23        1.34       80.22
                                 Berlin |        126        7.33       87.55
                            Brandenburg |         31        1.80       89.35
                 Mecklenburg-Vorpommern |         30        1.75       91.10
                                Sachsen |         80        4.65       95.75
                         Sachsen-Anhalt |         38        2.21       97.96
                              Thüringen |         35        2.04      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,719      100.00
*/

		* (weighted)
tab bula [aw=gewicht_kinder] if n_children==1

/*
               Bundesland lt. Statistik |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                     Schleswig-Holstein | 78.6203729        4.58        4.58
                                Hamburg | 34.7361512        2.02        6.60
                          Niedersachsen | 185.705828       10.82       17.42
                                 Bremen | 3.79180887        0.22       17.64
                    Nordrhein-Westfalen | 364.888685       21.25       38.89
                                 Hessen | 143.717511        8.37       47.26
                        Rheinland-Pfalz | 84.3876347        4.91       52.18
                      Baden-Württemberg | 198.300998       11.55       63.72
                                 Bayern |  239.70596       13.96       77.69
                               Saarland |21.61065896        1.26       78.94
                                 Berlin |46.78773959        2.72       81.67
                            Brandenburg | 44.8520609        2.61       84.28
                 Mecklenburg-Vorpommern | 51.6401944        3.01       87.29
                                Sachsen | 99.7139667        5.81       93.10
                         Sachsen-Anhalt | 62.2864267        3.63       96.72
                              Thüringen | 56.2540037        3.28      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,717      100.00
*/

	* unweighted and with missings 
bysort bula: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ if n_children==1, m

	* weighted
bysort bula: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ [aw=gewicht_kinder] if n_children==1	

	* weighted with missings
bysort bula: tab1 kc_wnone_ ks_pre_v6 kc_wselbst_ kc_wpart_ kc_weltern_ kc_wgeltern_ kc_wgesch_ kc_wverw_ kc_wtagm_ kc_wbezb_ kc_wfreund_ ks_none_v3_ ks_gen_v8_ ks_spe_ kd_time_v2_ ks_stufe_ ks_usch1_ ks_usch2_ [aw=gewicht_kinder] if n_children==1, m	
*_______________________________________________________________________________


* 5. Stratification by family situation
	* familienstand --> pld0131_v3 [married, parter same sex, single, separated/divorced, widowed]
	* partner situation --> plj0629 [ja, nein]
	sort hid pid
	br hid pid age sex_bin hknr_ parents pld0131_v3 plj0629 n_pid_HH
	
	* generating a compehensive vars of fam situation of parents: including partner or same-sex unions
	tab pld0131_v3 plj0629, m
			// among 255 singles (pld0131_v3), 204 have no partner (plj0629), while 50 are without partner
	gen fam_sit=1 if pld0131_v3==1 | pld0131_v3==2
	replace fam_sit=1 if pld0131_v3==3 & plj0629==1
	replace fam_sit=1 if pld0131_v3==.a & plj0629==1
	replace fam_sit=2 if pld0131_v3==3 & plj0629!=1
	replace fam_sit=2 if pld0131_v3==.a & plj0629==2
	replace fam_sit=3 if pld0131_v3==4 
	replace fam_sit=4 if pld0131_v3==6
	lab def fam_sit 1 "married/partnership/same-sex union" 2 "single" 3 "separated/divorced" 4 "widowed"
	tab fam_sit, m
	
	tab fam_sit pld0131_v3, m
	tab fam_sit plj0629, m
	
	
	order hid hknr_ pid
	* fam_sit_mother
	gen fam_sit_mother = fam_sit if parents==1
	
	bys hknr_: egen fam_sit_mother_max = max(fam_sit_mother)
	lab var fam_sit_mother_max "Family situation: mother"
	lab values fam_sit_mother_max fam_sit

	br hid hknr_ pid sex_bin age n_pid_HH parents fam_sit fam_sit_mother fam_sit_mother_max n_children
	
	* fam_sit_father
	gen fam_sit_father = fam_sit if parents==2
	
	bys hknr_: egen fam_sit_father_max = max(fam_sit_father)
	lab var fam_sit_father_max "Family situation: fahter"
	lab values fam_sit_father_max fam_sit

	br hid hknr_ pid sex_bin age n_pid_HH parents fam_sit fam_sit_mother fam_sit_mother_max fam_sit_father fam_sit_father_max n_children
	
	br hid hknr_ pid sex_bin age n_pid_HH fam_sit_mother_max fam_sit_father_max n_children if n_children==1
	
	gen n_parents=.
	replace n_parents=0 if fam_sit_mother_max==. & fam_sit_father_max==. & n_children==1
	replace n_parents=1 if (fam_sit_mother_max!=. & fam_sit_father_max==.) | (fam_sit_mother_max==. & fam_sit_father_max!=.)
	replace n_parents=2 if (fam_sit_mother_max!=. & fam_sit_father_max!=.)
	
	tab n_parents if n_children==1, m
	/*
	  n_parents |      Freq.     Percent        Cum.
    ------------+-----------------------------------
              0 |        115        6.69        6.69   // 115 children without parent/s
              1 |        904       52.59       59.28   // 904 children with single parent
              2 |        700       40.72      100.00   // 700 children with both parents
    ------------+-----------------------------------
          Total |      1,719      100.00
	*/
	
* Bildung Eltern: 
	* isced 11 --> isced 11

* erwerbstätigkeit:
	* waren sie mal in DEU erwerbstätig? --> lb1421
	* derzeit erwerbstätig? --> lb0265
	
capture log close
