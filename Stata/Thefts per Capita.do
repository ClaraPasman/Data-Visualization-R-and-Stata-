global DATA = "/Users/rochipodesta/Desktop/maestría/Herramientas/Semana 4/videos 2 y 3/data" 
cd "$DATA"

* Leer la información shape en Stata
shp2dta using london_sport.shp, database(ls) coord(coord_ls) genc(c) genid(id) replace


* Importamos y transformamos los datos de Excel a formato Stata *
import delimited "$DATA/mps-recordedcrime-borough.csv", clear 
* En Stata necesitamos que la variable tenga el mismo nombre en ambas bases para juntarlas
rename borough name 
*Dejamos solo los thefts
gen theft=1 if crimetype=="Theft & Handling"
keep if theft==1
collapse (sum) crimecount, by(name)
save "crime.dta", replace

*Ahora unimos las bases
use ls, clear
merge 1:1 name using crime.dta
drop _m

*Creamos la variable per capita
gen theft_percap=(crimecount/Pop_2001)*1000
replace theft_percap=round(theft_percap, 0.001)

save london_crime_shp.dta, replace

*Finalmente, hacemos el mapa con la nueva base
use london_crime_shp.dta, clear


spmap theft_percap using coord_ls, id(id) clmethod(q) cln(6) title("London's thefts per capita") legend(size(small) position(5) xoffset(17)) legtitle(Thefts per capita) fcolor(BuRd) plotregion(margin(b+15)) ndfcolor(gray) name(g1,replace)  
