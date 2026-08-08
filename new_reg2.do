clear
clear matrix
cls

use "${user_dir}/results/reg1_local_max.dta", clear
levelsof Trddt_date if local_max != ., local(date_list)

use "${user_dir}/many_ad_pre_reg", clear
drop if Trddt_date < date("01sep2006", "DMY") 
drop if Trddt_date > date("01mar2011", "DMY")
gen t = Trddt_date - date("01sep2006", "DMY")
foreach date in `date_list' {
	local z = "`=string(`date', "%td")'"
	quietly summarize ad_`z', meanonly
	local mean_value = r(mean)
	if `mean_value' == 1 | `mean_value' == 0 {
		drop ad_`z'
		continue
	}
	rename ad_`z' ad_`z'_stock		
	egen mean_ad_`z'_stock = mean(ad_`z'_stock), by(Stkcd)
	gen ad_`z' = ad_`z'_stock - mean_ad_`z'_stock
}
rename y y_stock
egen mean_y_stock = mean(y_stock), by(Stkcd)
gen y = y_stock - mean_y_stock
rename t t_stock
egen mean_t_stock = mean(t_stock), by(Stkcd)
gen t = t_stock - mean_t_stock
rename pe_d1 pe_d1_stock
egen mean_pe_d1_stock = mean(pe_d1_stock), by(Stkcd)
gen pe_d1 = pe_d1_stock - mean_pe_d1_stock
rename pb_d1 pb_d1_stock
egen mean_pb_d1_stock = mean(pb_d1_stock), by(Stkcd)
gen pb_d1 = pb_d1_stock - mean_pb_d1_stock
rename ps_d1 ps_d1_stock
egen mean_ps_d1_stock = mean(ps_d1_stock), by(Stkcd)
gen ps_d1 = ps_d1_stock - mean_ps_d1_stock
rename market_cap_d1 market_cap_d1_stock
egen mean_market_cap_d1_stock = mean(market_cap_d1_stock), by(Stkcd)
gen market_cap_d1 = market_cap_d1_stock - mean_market_cap_d1_stock
rename DJIA_d1 DJIA_d1_stock
egen mean_DJIA_d1_stock = mean(DJIA_d1_stock), by(Stkcd)
gen DJIA_d1 = DJIA_d1_stock - mean_DJIA_d1_stock
rename rf rf_stock		
egen mean_rf_stock = mean(rf_stock), by(Stkcd)
gen rf = rf_stock - mean_rf_stock
drop *_stock
save "${user_dir}/temp_data_reg2.dta", replace
eststo clear
eststo reg1: reg y c.ad* c.t c.pe_d1 c.pb_d1 c.ps_d1 c.market_cap_d1 c.DJIA_d1 c.rf

predict y_bar
egen y_mean_daily = mean(y), by(Trddt_date)
egen y_bar_mean_daily = mean(y_bar), by(Trddt_date)
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
    replace y_mean_daily_interval = `sum' / (`after' - `before' + 1) if _n == `i'
}
gen y_bar_mean_daily_interval = .
forval i = 1/`=_N' {
    local sum = 0
    forval n = `before'/`after' {
        if `i' + `n' > 0 & `i' + `n' <= _N {
            local sum = `sum' + y_bar_mean_daily[`i' + `n']
        }
    }
    replace y_bar_mean_daily_interval = `sum' / (`after' - `before' + 1) if _n == `i'
}
graph twoway (scatter y_mean_daily_interval Trddt_date, msize(0.1) ///
              xtitle("Trading date", size(medium)) ///
              ytitle("Coefficient", size(medium)) ///
              legend(order(1 "Moving average of daily returns average" 2 "Moving average of predicted daily returns average") size(small))) ///
	   	   (line y_bar_mean_daily_interval Trddt_date), ///
	   xlabel(, labsize(tiny) angle(vertical) grid) ///
       ylabel(, labsize(small) grid) ///
       name(graph2_1, replace)
graph export "${user_dir}/graph2_1.png", replace	   

esttab reg1 using "${user_dir}/table_results_2007-2010.tex", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) r2 nogaps noconstant compress ///
        title("Regression Results 2007-2010") ///
        align(Variable) ///
        label varwidth(30)
		
use "${user_dir}/many_ad_pre_reg", clear
drop if Trddt_date < date("01sep2012", "DMY") 
drop if Trddt_date > date("01mar2017", "DMY")
gen t = Trddt_date - date("01sep2012", "DMY")
foreach date in `date_list' {
	local z = "`=string(`date', "%td")'"
	quietly summarize ad_`z', meanonly
	local mean_value = r(mean)
	if `mean_value' == 1 | `mean_value' == 0 {
		drop ad_`z'
		continue
	}
	rename ad_`z' ad_`z'_stock		
	egen mean_ad_`z'_stock = mean(ad_`z'_stock), by(Stkcd)
	gen ad_`z' = ad_`z'_stock - mean_ad_`z'_stock
}
rename y y_stock
egen mean_y_stock = mean(y_stock), by(Stkcd)
gen y = y_stock - mean_y_stock
rename t t_stock
egen mean_t_stock = mean(t_stock), by(Stkcd)
gen t = t_stock - mean_t_stock
rename pe_d1 pe_d1_stock
egen mean_pe_d1_stock = mean(pe_d1_stock), by(Stkcd)
gen pe_d1 = pe_d1_stock - mean_pe_d1_stock
rename pb_d1 pb_d1_stock
egen mean_pb_d1_stock = mean(pb_d1_stock), by(Stkcd)
gen pb_d1 = pb_d1_stock - mean_pb_d1_stock
rename ps_d1 ps_d1_stock
egen mean_ps_d1_stock = mean(ps_d1_stock), by(Stkcd)
gen ps_d1 = ps_d1_stock - mean_ps_d1_stock
rename market_cap_d1 market_cap_d1_stock
egen mean_market_cap_d1_stock = mean(market_cap_d1_stock), by(Stkcd)
gen market_cap_d1 = market_cap_d1_stock - mean_market_cap_d1_stock
rename DJIA_d1 DJIA_d1_stock
egen mean_DJIA_d1_stock = mean(DJIA_d1_stock), by(Stkcd)
gen DJIA_d1 = DJIA_d1_stock - mean_DJIA_d1_stock
rename rf rf_stock		
egen mean_rf_stock = mean(rf_stock), by(Stkcd)
gen rf = rf_stock - mean_rf_stock
drop *_stock
save "${user_dir}/temp_data_reg2.dta", replace
eststo clear
eststo reg1: reg y c.ad* c.t c.pe_d1 c.pb_d1 c.ps_d1 c.market_cap_d1 c.DJIA_d1 c.rf

predict y_bar
egen y_mean_daily = mean(y), by(Trddt_date)
egen y_bar_mean_daily = mean(y_bar), by(Trddt_date)
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
    replace y_mean_daily_interval = `sum' / (`after' - `before' + 1) if _n == `i'
}
gen y_bar_mean_daily_interval = .
forval i = 1/`=_N' {
    local sum = 0
    forval n = `before'/`after' {
        if `i' + `n' > 0 & `i' + `n' <= _N {
            local sum = `sum' + y_bar_mean_daily[`i' + `n']
        }
    }
    replace y_bar_mean_daily_interval = `sum' / (`after' - `before' + 1) if _n == `i'
}
graph twoway (scatter y_mean_daily_interval Trddt_date, msize(0.1) ///
              xtitle("Trading date", size(medium)) ///
              ytitle("Coefficient", size(medium)) ///
              legend(order(1 "Moving average of daily returns average" 2 "Moving average of predicted daily returns average") size(small))) ///
	   	   (line y_bar_mean_daily_interval Trddt_date), ///
	   xlabel(, labsize(tiny) angle(vertical) grid) ///
       ylabel(, labsize(small) grid) ///
       name(graph2_2, replace)
graph export "${user_dir}/graph2_2.png", replace

esttab reg1 using "${user_dir}/table_results_2013-2016.tex", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) r2 nogaps noconstant compress ///
        title("Regression Results 2013-2016") ///
        align(Variable) ///
        label varwidth(30)

use "${user_dir}/many_ad_pre_reg", clear
drop if Trddt_date < date("01sep2018", "DMY") 
drop if Trddt_date > date("01mar2024", "DMY")
gen t = Trddt_date - date("01sep2018", "DMY")
foreach date in `date_list' {
	local z = "`=string(`date', "%td")'"
	quietly summarize ad_`z', meanonly
	local mean_value = r(mean)
	if `mean_value' == 1 | `mean_value' == 0 {
		drop ad_`z'
		continue
	}
	rename ad_`z' ad_`z'_stock		
	egen mean_ad_`z'_stock = mean(ad_`z'_stock), by(Stkcd)
	gen ad_`z' = ad_`z'_stock - mean_ad_`z'_stock
}
rename y y_stock
egen mean_y_stock = mean(y_stock), by(Stkcd)
gen y = y_stock - mean_y_stock
rename t t_stock
egen mean_t_stock = mean(t_stock), by(Stkcd)
gen t = t_stock - mean_t_stock
rename pe_d1 pe_d1_stock
egen mean_pe_d1_stock = mean(pe_d1_stock), by(Stkcd)
gen pe_d1 = pe_d1_stock - mean_pe_d1_stock
rename pb_d1 pb_d1_stock
egen mean_pb_d1_stock = mean(pb_d1_stock), by(Stkcd)
gen pb_d1 = pb_d1_stock - mean_pb_d1_stock
rename ps_d1 ps_d1_stock
egen mean_ps_d1_stock = mean(ps_d1_stock), by(Stkcd)
gen ps_d1 = ps_d1_stock - mean_ps_d1_stock
rename market_cap_d1 market_cap_d1_stock
egen mean_market_cap_d1_stock = mean(market_cap_d1_stock), by(Stkcd)
gen market_cap_d1 = market_cap_d1_stock - mean_market_cap_d1_stock
rename DJIA_d1 DJIA_d1_stock
egen mean_DJIA_d1_stock = mean(DJIA_d1_stock), by(Stkcd)
gen DJIA_d1 = DJIA_d1_stock - mean_DJIA_d1_stock
rename rf rf_stock		
egen mean_rf_stock = mean(rf_stock), by(Stkcd)
gen rf = rf_stock - mean_rf_stock
drop *_stock
save "${user_dir}/temp_data_reg2.dta", replace
eststo clear
eststo reg1: reg y c.ad* c.t c.pe_d1 c.pb_d1 c.ps_d1 c.market_cap_d1 c.DJIA_d1 c.rf

predict y_bar
egen y_mean_daily = mean(y), by(Trddt_date)
egen y_bar_mean_daily = mean(y_bar), by(Trddt_date)
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
    replace y_mean_daily_interval = `sum' / (`after' - `before' + 1) if _n == `i'
}
gen y_bar_mean_daily_interval = .
forval i = 1/`=_N' {
    local sum = 0
    forval n = `before'/`after' {
        if `i' + `n' > 0 & `i' + `n' <= _N {
            local sum = `sum' + y_bar_mean_daily[`i' + `n']
        }
    }
    replace y_bar_mean_daily_interval = `sum' / (`after' - `before' + 1) if _n == `i'
}
graph twoway (scatter y_mean_daily_interval Trddt_date, msize(0.1) ///
              xtitle("Trading date", size(medium)) ///
              ytitle("Coefficient", size(medium)) ///
              legend(order(1 "Moving average of daily returns average" 2 "Moving average of predicted daily returns average") size(small))) ///
	   	   (line y_bar_mean_daily_interval Trddt_date), ///
	   xlabel(, labsize(tiny) angle(vertical) grid) ///
       ylabel(, labsize(small) grid) ///
       name(graph2_3, replace)
graph export "${user_dir}/graph2_3.png", replace

esttab reg1 using "${user_dir}/table_results_2019-2023.tex", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) r2 nogaps noconstant compress ///
        title("Regression Results 2019-2023") ///
        align(Variable) ///
        label varwidth(30)
