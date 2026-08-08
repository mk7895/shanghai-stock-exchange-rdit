clear
clear matrix
cls

local filelist_upper : dir "${user_dir}/wind" files "*.CSV"
local filelist "`filelist_upper'"

local count = 0
foreach file in `filelist' {
    display "`file'"
    local filepath = "${user_dir}/wind/`file'"

    if `count' == 0 {
        import delimited using "`filepath'", clear
        drop shortname
    } 
    else {
        import delimited using "`filepath'", clear
        
        if date[1] == "LTD" | date[1] == "Ltd." {
            replace shortname = shortname + ", " + date if strpos(date, "LTD") > 0
            drop date
            rename preclosecny date
            rename closingpricecny preclosecny
            rename totalmktcapcny closingpricecny
            rename pe totalmktcapcny
            rename pb pe
            rename ps pb
            rename v10 ps

            di "Corrected misaligned data in file: `file'"
        }
        drop shortname
		
		capture confirm variable ps
        if _rc == 0 {
            capture confirm string variable ps
            if _rc == 0 {
                replace ps = "." if ps == "--"
                destring ps, replace force
            }
        }

		
		capture confirm variable pb
        if _rc == 0 {
            capture confirm string variable pb
            if _rc == 0 {
                replace pb = "." if pb == "--"
                destring pb, replace force
            }
        }		
		
		capture confirm variable preclosecny
        if _rc == 0 {
            capture confirm string variable preclosecny
            if _rc == 0 {
                replace preclosecny = "." if preclosecny == "--"
                destring preclosecny, replace force
            }
        }
		
        append using temp_data
		
    }
    save temp_data, replace
    local count = `count' + 1
}
drop v10 v11

save "${user_dir}/new_wind", replace

use "${user_dir}/new_wind", clear

sort symbol date
gen Stkcd = substr(symbol, 1, strpos(symbol, ".") - 1)
drop symbol
gen Trddt_date = date(date, "YMD")
format Trddt_date %td
drop date

gen market_cap = totalmktcapcny/10^10
drop totalmktcapcny
tempfile daily_data
save `daily_data', replace
use "${user_dir}/company_profile/TRD_Co", clear

sort Stkcd
merge 1:m Stkcd using `daily_data'
tab _merge
drop _merge

sort Stkcd Trddt_date
drop if market_cap == .
drop Markettype Stknme_en
drop if Statco == "N"
drop Statco

sort Stkcd Trddt

tempfile daily_data
save `daily_data', replace

use "${user_dir}/riskfree/TRD_Nrrate", clear
drop Nrr1_en
gen Trddt = Clsdt
sort Trddt
gen Trddt_date = date(Trddt, "YMD")
format Trddt_date %td
drop Trddt

merge 1:m Trddt_date using `daily_data'
tab _merge
drop _merge

sort Stkcd Trddt_date

drop if market_cap == .
drop Clsdt

tempfile daily_data
save `daily_data', replace
import delimited "${user_dir}/DJIA/DJI.GI.CSV", clear
drop symbol shortname v6
gen Trddt_date = date(date, "YMD")
format Trddt_date %td
drop date


rename prevclose DJIprevclose
rename closed DJIclosed

merge 1:m Trddt_date using `daily_data'
tab _merge
drop _merge
destring Stkcd, generate(Stkcd_num) ignore("")
drop Stkcd
rename Stkcd_num Stkcd
encode Indnme_en, gen(industry_code)
encode OWNERSHIPTYPE_EN, gen(ownership_code)
drop Indnme_en OWNERSHIPTYPE_EN
sort Stkcd Trddt_date

replace DJIclosed = DJIclosed[_n-1] if DJIclosed == . & Stkcd == Stkcd[_n-1]
replace DJIprevclose = DJIprevclose[_n-1] if DJIprevclose == . & Stkcd == Stkcd[_n-1]
replace DJIclosed = DJIclosed[_n-1] if DJIclosed == . & Stkcd == Stkcd[_n-1]
replace DJIprevclose = DJIprevclose[_n-1] if DJIprevclose == . & Stkcd == Stkcd[_n-1]

gen market_cap_d1 = market_cap[_n-1] if Stkcd == Stkcd[_n-1]
gen pe_d1 = pe[_n-1] if Stkcd == Stkcd[_n-1]
gen pb_d1 = pb[_n-1] if Stkcd == Stkcd[_n-1]
gen ps_d1 = ps[_n-1] if Stkcd == Stkcd[_n-1]
gen DJIA_d1 = (DJIclosed[_n-1] / DJIprevclose[_n-1] - 1)* 100 if Stkcd == Stkcd[_n-1]
gen rf = Nrrdata
drop Nrrdata
drop Listdt

gen y = ((closingpricecny / preclosecny) - 1)*100

drop DJIprevclose DJIclosed preclosecny closingpricecny pe pb ps market_cap

drop if market_cap_d1 == .

tempfile daily_data
save `daily_data', replace

use "${user_dir}/sse/SSE1", clear
append using "${user_dir}/sse/SSE2"
append using "${user_dir}/sse/SSE3"
append using "${user_dir}/sse/SSE4"
append using "${user_dir}/sse/SSE5"
drop Indexcd 
rename Idxtrd01 Trddt
rename Idxtrd08 sse
sort Trddt
gen Trddt_date = date(Trddt, "YMD")
format Trddt_date %td
drop Trddt

merge 1:m Trddt_date using `daily_data'
tab _merge
drop _merge

sort Stkcd Trddt_date
drop if Trddt_date == .
save "${user_dir}/new_wind_pre_beta", replace

use "${user_dir}/new_wind_pre_beta", clear


gen rf_daily = ((1+rf/100)^(1/252)-1)*100
gen risk_premium = sse - rf_daily
gen excessive_return = y - rf_daily
gen beta = .
levelsof Stkcd, local(stocks)

foreach s of local stocks {
    qui sum Trddt_date if Stkcd == `s'
    local start = r(min)
    local end = r(max)

    * Compute covariance between y and sse for stock `s`
	// Calculate covariance and variance only for the relevant period
    qui reg excessive_return risk_premium if Stkcd == `s' & Trddt_date >= `start' & Trddt_date <= `end'
    
    // Store beta
    replace beta = _b[risk_premium] if Stkcd == `s'
}

gen expected_return = rf_daily + beta * (sse - rf_daily)
gen abnormal_return = y - expected_return
drop rf_daily excessive_return risk_premium

save "${user_dir}/new_final_pre_reg", replace
use "${user_dir}/new_final_pre_reg", clear

rename y y_actual
rename abnormal_return y

save "${user_dir}/new_final_pre_reg", replace
