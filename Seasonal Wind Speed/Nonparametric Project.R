# data set
airquality
# ?airquality

# --------------------------- Cleaning ----------------------------------------
# Remove the Ozone column
airquality <- airquality[, !names(airquality) %in% "Ozone"]

# Remove the Solar.R column
airquality <- airquality[, !names(airquality) %in% "Solar.R"]

# Remove the Temp column
airquality <- airquality[, !names(airquality) %in% "Temp"]

# Remove months 5, 7, and 8
airquality <- subset(airquality, !(Month %in% c(5, 7, 8)))

# keep only months 6 and 9
airquality_filtered <- airquality[airquality$Month %in% c(6, 9), ]

# Split the dataset by Month
split_data <- split(airquality_filtered, airquality_filtered$Month)

# subset the days for each month
specific_days_data <- lapply(split_data, function(group) {
  if (unique(group$Month) == 6) {
    # Keep days 1 to 7 for month 6
    group[group$Day >= 1 & group$Day <= 7, ]
  } else if (unique(group$Month) == 9) {
    # Keep days 6 to 12 for month 9
    group[group$Day >= 6 & group$Day <= 12, ]
  }
})

# recombine
airquality <- do.call(rbind, specific_days_data)

# clean
row.names(airquality) <- NULL

airquality
# ------------------------------------------------------------------------------


# -------------------------------- Normality Test ------------------------------
par(mfrow = c(1, 2))
# filter the data to include only month 6
airquality_month6 <- airquality[airquality$Month == 6, ]
# filter the data to include only month 9
airquality_month9 <- airquality[airquality$Month == 9, ]

# plot of June
qqnorm(airquality_month6$Wind, pch = 19, 
       main = "Wind Normal Q-Q Plot (Month 6)", ylab = "Avg Wind Speed (mph)")
qqline(airquality_month6$Wind, lty = 2)

# plot of September
qqnorm(airquality_month9$Wind, pch = 19, 
       main = "Wind Normal Q-Q Plot (Month 9)", ylab = "Avg Wind Speed (mph)")
qqline(airquality_month9$Wind, lty = 2)


# normality tests
shapiro.test(airquality_month6$Wind)
shapiro.test(airquality_month9$Wind)
# ------------------------------------------------------------------------------


# --------------------------- Median Test --------------------------------------

# remove the Days column
airquality <- airquality[, !names(airquality) %in% "Day"]

airquality

# get grand median
GM = median(airquality$Wind)
GM
# make new group for above and not above GM
airquality$Group = ifelse(airquality$Wind>GM, "Above", "Not")
airquality

# make the contingency table
airquality.tb = table(airquality$Group,airquality$Month)
airquality.tb

# make better contingency table
table_data <- matrix(c(2, 5, 5, 2), nrow = 2, byrow = TRUE)
dimnames(table_data) <- list(c("Above", "Not"), c("June", "September"))
total_row <- colSums(table_data)
table_with_totals <- rbind(table_data, Total = total_row)
row_totals <- rowSums(table_with_totals)
airquality.tb <- cbind(table_with_totals, Total = row_totals)
airquality.tb

# manual test statistic
A = 2
B = 5
n = 7
T1 = (A/n) - (B/n)
phat = 0.5
T2 = sqrt(phat*(1-phat)*((1/7)+(1/7)))
T = T1/T2

# median test
library(coin)
median_test(Wind~as.factor(Month), data=airquality)
# ------------------------------------------------------------------------------

# ----------------------------- Ansari-Bradley Test ----------------------------

airquality

# sort the data to rank
sorted_airquality <- airquality[order(airquality$Wind), ]
print(sorted_airquality)

# Ansari-Bradley test
ansari.test(Wind~Month,data=airquality, exact=F)
# ------------------------------------------------------------------------------









