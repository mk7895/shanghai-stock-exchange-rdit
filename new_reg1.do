clear
clear matrix
cls

tempname tstat_results

local start_date = date("${start_date_global}", "DMY")
local end_date = date("${end_date_global}", "DMY")

use "${user_dir}/new_final_pre_reg", clear
keep if Trddt_date > `start_date' - 1
keep if Trddt_date < `end_date' + 1
levelsof Trddt_date, local(date_list)

foreach d in `date_list' {
	quietly {
		local current_date = "`=string(`d', "%td")'"

		use "${user_dir}/new_final_pre_reg", clear
		gen ad = Trddt_date > `d'
		drop if Trddt_date - `d' > $before_date
		drop if `d' - Trddt_date > $after_date
		gen t = Trddt_date - `d'
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
		rename ad ad_stock		
		egen mean_ad_stock = mean(ad_stock), by(Stkcd)
		gen ad = ad_stock - mean_ad_stock
		drop *_stock
		reg y c.ad c.t c.pe_d1 c.pb_d1 c.ps_d1 c.market_cap_d1 c.DJIA_d1 c.rf
		matrix A = r(table)
		matrix coef = A[1, 1..colsof(A)]'
		matrix tstat = A[3, 1..colsof(A)]'
		matrix colnames tstat = `current_date'
		matrix colnames coef = `current_date'		
		capture matrix list tstat_results  
		if _rc == 0 {
			matrix tstat_results = (tstat_results \ coef' \ tstat')
		} 
		else {
			matrix tstat_results = (coef' \ tstat')
		}
	}
	di "`current_date'"
}
clear
matrix tstat_results_trans = tstat_results
matrix list tstat_results_trans

svmat tstat_results_trans

local colnames : colnames tstat_results_trans

local clean_colnames
foreach col of local colnames {
    local clean_col = strtoname("`col'")
    local clean_colnames "`clean_colnames' reg1`clean_col'"
}

local i = 1
foreach clean_col of local clean_colnames {
    rename tstat_results_trans`i' `clean_col'
    local i = `i' + 1
}

local rownames : rownames tstat_results_trans
gen Trddt = ""
gen id = _n
local i = 1

foreach row of local rownames {
    replace Trddt = "`row'" if id == `i'
    local i = `i' + 1
}

gen Trddt_date = date(Trddt, "DMY")
format Trddt_date %td
drop Trddt id

save "${user_dir}/results/reg1_new_tstats_${start_date_global}_${end_date_global}.dta", replace
