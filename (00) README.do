

* Readme- Do files available in GitHub
*  September 5th / 2024- SOEP Team
* Last Modified: September 5th 2024


*Database Creation- Only these 3 files need to be run to create the database

(01) suare_instrumentation.do
(02) p_ref pref_bef.do
(03) data suare_bericht_v40.do

Altogether they produce the dataset: suare_bericht_v40_data.dta- which is the BASE data set

Plus shorter version with selected variables : SOEP_v40_clean.dta

* Starting here : do files that create different versions of variables but are either not revised or are work in progres

(04) variables suare_bericht_v40.do /// 

*SOEP Do files- Work in progress
suare_bericht_v40 Bildung(SOEP) // Work in progress Children & Education
suare_bericht_v40 familie.do  // Work in Progress
suare_bericht_v40 reshape.do // Phili: Analyse auf Ebene der einzelnen Kinder
suare_bericht_v40_Bildung.Rmd // Work in progress in R

*Provided by IAB and/or SOEP (enthält Gesundheit)
suare_bericht_40 sociodemographic.do

*Provided by the IAB
suare_bericht_v40 education.do  
suare_bericht_v40 employment.do

*Provided by BAMF
suare_bericht_v40 sprache & kurse.do


*Other files: Household Questionnaire, Biography, P- Questionare

q_soep-core-2023-hh-ref_qa_de_20230131.pdf
q_soep-core-2023-ll-ref_qa_de_20230222_sr.pdf
q_soep-core-2023-p-ref_qa_de (2)-1 1.pdf

