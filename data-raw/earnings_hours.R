library(readxl)
library(curl)
library(data.table)
library(magrittr)

###################################
#### Aggregate data on earnings ###

#### Read in data from ONS website

url <- "https://www.ons.gov.uk/file?uri=/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/ashe1997to2015selectedestimates/current/selectedestimates19972022.xlsx"
temp <- tempfile()
temp <- curl_download(url = url, destfile = temp, quiet = FALSE, mode = "wb")

#### read in all data

### Notes:

### 2004, 2005, 2006 use updated methodology (weighting to LFS)
### 2007 methodology change
### 2011 change to SOC-10
### 2021 change to SOC-20
### 2022 results are provisional

earnings <- read_excel(temp, range="A3:AJ78", sheet = "Table 1", col_names = TRUE) %>% setDT

earnings[1:26, sex := "all"]
earnings[27:51, sex := "male"]
earnings[52:75, sex := "female"]

setnames(earnings,
         c("...1","2011 soc10","2021Soc20","2022p"),
         c("variable","2011","2021","2022"))

earnings <- earnings[, c("variable","sex",
                         "2004","2005","2006","2007","2008","2009","2010",
                         "2011","2012","2013","2014","2015","2016",
                         "2017","2018","2019","2020","2021","2022")]

earnings <- earnings[!(is.na(variable)) & !(variable == "Percentage annual increase")]

earnings[c(7,16,25) , variable := "Mean hourly earnings excluding overtime (£)"]
earnings[c(5,14,23) , variable := "Median hourly earnings excluding overtime (£)"]


earnings <- earnings[!(variable %in% c("Median hourly earnings","Mean hourly earnings"))]

earnings <- melt(earnings, id.vars = c("variable","sex"), variable.name = "year", value.name = "value")

earnings <- dcast(earnings, sex + year ~ variable, value.var = "value")

earnings_hours <- copy(earnings)

usethis::use_data(earnings_hours, overwrite = TRUE)
