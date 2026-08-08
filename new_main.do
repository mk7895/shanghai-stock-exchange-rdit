cls
clear all
global user_dir "/Users/mateuszklepacki/Desktop/advanced_econ/Final"
//do "${user_dir}/new_simulation_model.do"
global before_date 60
global after_date 30
//do "${user_dir}/new_simulation_methodology.do"

//do "${user_dir}/new_merger"
forval z = 2005 / 2024 {
	global start_date_global "01jan`z'"
	global end_date_global "31dec`z'"
	do "${user_dir}/new_reg1"
}

use "${user_dir}/results/reg1_new_tstats_01jan2005_31dec2005", clear
forval z = 2006 / 2024 {
	append using "${user_dir}/results/reg1_new_tstats_01jan`z'_31dec`z'"
}

gen coef_tstat = 0
replace coef_tstat = 1 if mod(_n, 2) == 0

replace reg1rf = reg1o_rf if reg1rf == .
drop reg1o_rf
rename reg1ad reg1ad1
gen abs_reg1ad1 = abs(reg1ad1)


local before = - $before_date
local after = $after_date

gen max = reg1ad1 
forval n = `before' / `after' {
    replace max = . if ///
        reg1ad1 < reg1ad1[_n + 2 * `n'] | ///
        mod(_n, 2) == 0 | ///
        abs_reg1ad1[_n + 1] < 3.3
}

gen min = reg1ad1
forval n = `before' / `after' {
    replace min = . if ///
        reg1ad1 > reg1ad1[_n + 2 * `n'] | ///
        mod(_n, 2) == 0 | ///
        abs_reg1ad1[_n + 1] < 3.3
}

gen local_max = .
replace local_max = min if min != .
replace local_max = max if max != .

gen local_max_round = round(local_max, 0.001)

drop if reg1ad1 == .

sort Trddt_date coef_tstat

save "${user_dir}/results/reg1_local_max_with_sse.dta", replace
use "${user_dir}/results/reg1_local_max_with_sse.dta", clear

graph set window fontface "Times New Roman"
graph set window 
graph twoway (scatter reg1ad1 Trddt_date, msize(0.1) color(blue) ///
              xtitle("Trading date", size(medium)) ///
              ytitle("Coefficient", size(medium)) ///
              legend(order(1 "Treatment Coefficient" 2 "Crucial Trading Dates") size(small))) ///
       (scatter local_max_round Trddt_date, msize(1)  mlabel(local_max_round) mlabposition(3) mlabsize(1.8) mlabcolor(black))  ///
       if mod(_n, 2) == 1 & Trddt_date > date("01jan2007", "DMY") & Trddt_date < date("01jan2011", "DMY"), ///
       xlabel(, labsize(tiny) angle(vertical) grid) ///
       ylabel(-7(1)7, labsize(small) grid) ///
       name(graph1_1, replace)
graph export "${user_dir}/graph1_1.png", replace

graph twoway (scatter reg1ad1 Trddt_date, msize(0.1) color(blue) ///
              xtitle("Trading date", size(medium)) ///
              ytitle("Coefficient", size(medium)) ///
              legend(order(1 "Treatment Coefficient" 2 "Crucial Trading Dates") size(small))) ///
       (scatter local_max_round Trddt_date, msize(1)  mlabel(local_max_round) mlabposition(3) mlabsize(1.8) mlabcolor(black))  ///
       if mod(_n, 2) == 1 & Trddt_date > date("01jan2013", "DMY") & Trddt_date < date("01jan2017", "DMY"), ///
       xlabel(, labsize(tiny) angle(vertical) grid) ///
       ylabel(-7(1)7, labsize(small) grid) ///
       name(graph1_2, replace)
graph export "${user_dir}/graph1_2.png", replace

graph twoway (scatter reg1ad1 Trddt_date, msize(0.1) color(blue) ///
              xtitle("Trading date", size(medium)) ///
              ytitle("Coefficient", size(medium)) ///
              legend(order(1 "Treatment Coefficient" 2 "Crucial Trading Dates") size(small))) ///
       (scatter local_max_round Trddt_date, msize(1)  mlabel(local_max_round) mlabposition(3) mlabsize(1.8) mlabcolor(black))  ///
       if mod(_n, 2) == 1 & Trddt_date > date("01jan2019", "DMY") & Trddt_date < date("01jan2024", "DMY"), ///
       xlabel(, labsize(tiny) angle(vertical) grid) ///
       ylabel(-7(1)7, labsize(small) grid) ///
       name(graph1_3, replace)
graph export "${user_dir}/graph1_3.png", replace

levelsof Trddt_date if local_max != ., local(date_list)

local n_dates: word count `date_list'
matrix dates_matrix = J(`n_dates', 1, .)

local i = 1
foreach date in `date_list' {
    matrix dates_matrix[`i', 1] = `date'
    local ++i
}

save "${user_dir}/results/reg1_local_max.dta", replace
use "${user_dir}/results/reg1_new_tstats_01jan2005_31dec2005", clear
forval z = 2006 / 2024 {
	append using "${user_dir}/results/reg1_new_tstats_01jan`z'_31dec`z'"
}

replace reg1rf = reg1o_rf if reg1rf == .
drop reg1o_rf
rename reg1ad reg1ad1
gen abs_reg1ad1 = abs(reg1ad1)

local before = - $before_date
local after = $after_date

gen max = reg1ad1 
forval n = `before' / `after' {
    replace max = . if ///
        reg1ad1 < reg1ad1[_n + 2 * `n'] | ///
        mod(_n, 2) == 0 | ///
        abs_reg1ad1[_n + 1] < 3.3
}

gen min = reg1ad1
forval n = `before' / `after' {
    replace min = . if ///
        reg1ad1 > reg1ad1[_n + 2 * `n'] | ///
        mod(_n, 2) == 0 | ///
        abs_reg1ad1[_n + 1] < 3.3
}

gen local_max = .
replace local_max = min if min != .
replace local_max = max if max != .
keep if local_max != .
keep Trddt_date local_max
sort Trddt_date

gen Trddt_date_str = string(Trddt_date, "%td")
mkmat local_max, matrix(my_matrix)
local row_names
forval i = 1/`=_N' {
    local row_names `row_names' "`=Trddt_date_str[`i']'"
}
matrix rownames my_matrix = `row_names'
matrix list my_matrix
outtable using "${user_dir}/local_max_table", mat(my_matrix) replace nobox center 

use "${user_dir}/new_final_pre_reg", clear 

foreach date in `date_list' {
	local z = "`=string(`date', "%td")'"
	gen ad_`z' = (Trddt_date > `date' )
}	

save "${user_dir}/many_ad_pre_reg", replace

use "${user_dir}/many_ad_pre_reg", clear
drop if Trddt_date < date("01sep2006", "DMY") 
drop if Trddt_date > date("01mar2011", "DMY")
eststo clear
estpost tabstat y rf DJIA_d1 market_cap_d1 pe_d1 pb_d1 ps_d1 , c(stat) stat(mean sd min max n)
esttab using "${user_dir}/summary_1.tex", replace cells("mean sd min max count") nonumber nomtitle booktabs noobs title("Summary table for 2007-2010") collabels("Mean" "SD" "Min" "Max" "N") coeflabels(y "y" rf "RF" DJIA_d1 "DJIA" market_cap_d1 "market_cap" pe_d1 "pe" pb_d1 "pb" ps_d1 "ps") 

use "${user_dir}/many_ad_pre_reg", clear
drop if Trddt_date < date("01sep2012", "DMY") 
drop if Trddt_date > date("01mar2017", "DMY")
eststo clear
estpost tabstat y rf DJIA_d1 market_cap_d1 pe_d1 pb_d1 ps_d1 , c(stat) stat(mean sd min max n)
esttab using "${user_dir}/summary_2.tex", replace cells("mean sd min max count") nonumber nomtitle booktabs noobs title("Summary table for 2013-2016") collabels("Mean" "SD" "Min" "Max" "N") coeflabels(y "y" rf "RF" DJIA_d1 "DJIA" market_cap_d1 "market_cap" pe_d1 "pe" pb_d1 "pb" ps_d1 "ps") 

use "${user_dir}/many_ad_pre_reg", clear
drop if Trddt_date < date("01sep2018", "DMY") 
drop if Trddt_date > date("01mar2024", "DMY")
eststo clear
estpost tabstat y rf DJIA_d1 market_cap_d1 pe_d1 pb_d1 ps_d1 , c(stat) stat(mean sd min max n)
esttab using "${user_dir}/summary_3.tex", replace  cells("mean sd min max count") nonumber nomtitle booktabs noobs title("Summary table for 2019-2023") collabels("Mean" "SD" "Min" "Max" "N") coeflabels(y "y" rf "RF" DJIA_d1 "DJIA" market_cap_d1 "market_cap" pe_d1 "pe" pb_d1 "pb" ps_d1 "ps") 

do "${user_dir}/new_reg2" //Main
do "${user_dir}/new_reg3" //Appendix A - high polynomial

use "${user_dir}/many_ad_pre_reg", clear

egen y_mean_daily = mean(y), by(Trddt_date)
duplicates drop Trddt_date, force
sort Trddt_date

gen y_mean_daily_interval = .
local before = -$before_date
local after = $after_date

forval i = 1/`=_N' {
    local sum = 0
    forval n = `before'/`after' {
        if `i' + `n' > 0 & `i' + `n' <= _N {
            local sum = `sum' + y_mean_daily[`i' + `n']
        }
    }
    qui replace y_mean_daily_interval = `sum' / (`after' - `before' + 1) if _n == `i'
}

save "${user_dir}/many_ad_pre_reg_with_sse", replace
use "${user_dir}/many_ad_pre_reg_with_sse", clear

graph twoway (scatter y_mean_daily_interval Trddt_date, msize(0.2) ///
              xtitle("Trading date", size(medium)) ///
              ytitle("Return", size(medium)) ///
              legend(order(1 "Moving average of daily return average") size(small))) ///
       if mod(_n, 2) == 1 & Trddt_date > date("01jan2007", "DMY") & Trddt_date < date("01jan2011", "DMY"), ///
       xlabel(, labsize(tiny)) name(graph2, replace)
graph export "${user_dir}/graph2.png", replace 

graph twoway (scatter y_mean_daily_interval Trddt_date, msize(0.2) ///
              xtitle("Trading date", size(medium)) ///
              ytitle("Return", size(medium)) ///
              legend(order(1 "Moving average of daily return average") size(small))) ///
       if mod(_n, 2) == 1 & Trddt_date > date("01jan2013", "DMY") & Trddt_date < date("01jan2017", "DMY"), ///
       xlabel(, labsize(tiny)) name(graph3, replace)
graph export "${user_dir}/graph3.png", replace 

graph twoway (scatter y_mean_daily_interval Trddt_date, msize(0.2) ///
              xtitle("Trading date", size(medium)) ///
              ytitle("Return", size(medium)) ///
              legend(order(1 "Moving average of daily return average") size(small))) ///
       if mod(_n, 2) == 1 & Trddt_date > date("01jan2019", "DMY") & Trddt_date < date("01mar2024", "DMY"), ///
       xlabel(, labsize(tiny)) name(graph4, replace)    
graph export "${user_dir}/graph4.png", replace 
