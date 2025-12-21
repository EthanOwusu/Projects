# ----------------------------- Data Import and Set Up -------------------------
lol = read.csv(file.choose())
lol

# puts the necessary columns into a data frame for blue side
# data for red side included for kills comparison
lolb = data.frame(lol[,1],lol[,2],lol[,9],lol[,10],lol[,40])
lolr = data.frame(lol[,1],lol[,46],lol[,53],lol[,54],lol[,84])
colnames(lolb) = c("Game ID","Result","FB","Kills","Gold Diff")
colnames(lolr) = c("Game ID","Result","FB","Kills","Gold Diff")

head(lolb,30)

# ifelse to get the amount of games where the difference in gold is at least 4000
lolb$GD4k = ifelse(lolb$"Gold Diff" >= 4000, 1, 0)


# --------------------------- Array Formatting ---------------------------------
# turns the data frame into an array (2x2x2)
lolmat = table(lolb$Result, lolb$FB, lolb$GD4k)
dimnames(lolmat) = list("Result"=c("Lose","Win"), 
                        "FB"=c("No","Yes"), 
                        GD4k=c("No","Yes"))
lolmat = lolmat[c(2, 1), c(2, 1),]
# ----------------------Cochran-Mantel-Haenszel---------------------------------

# converts lolmat to a testable form for Cochran-Mantel-Haenszel Test
lolmat_num = as.table(array(as.numeric(lolmat), dim = dim(lolmat))) 

mantelhaen.test(lolmat_num) # 3rd factor = GD4k
# H0: OR_RF(Yes) = OR_RF(No) = 1, p-value < 2.2e-16

mantelhaen.test(aperm(lolmat_num, c(1,3,2))) # 3rd factor = "FB"
# H0: OR_R4k(Win) = OR_R4k(No) = 1, p-value < 2.2e-16


mantelhaen.test(aperm(lolmat_num, c(2,3,1))) # 3rd factor = "Result"
# H0: OR_F4k(Win) = OR_F4k(Lose) = 1, p-value < 2.2e-16

# ------------------------- Regression Modeling --------------------------------

lolb.glm1 = glm(Result ~ FB, data = lolb, family = binomial) 
summary(lolb.glm1)


lolb.glm2 = glm(Result ~ GD4k, data = lolb, family = binomial)
summary(lolb.glm2)


lolb.glm3 = glm(Result ~ FB + GD4k , data = lolb, family = binomial)
summary(lolb.glm3)

# data for kills
killdata = data.frame(Result = lolb$Result,kdiff = lolb$Kills - lolr$Kills,
                      total = lolb$Kills + lolr$Kills,
                      bk = lolb$Kills, rk = lolr$Kills)

lolb.glm4 = glm(Result ~  kdiff + total , data = killdata, family = binomial)
summary(lolb.glm4)

# ----------------------------- Kill Plot --------------------------------------

{
# grid of all combinations
newkill <- expand.grid(
  blue_kills = 0:40,
  red_kills = 0:35
)

# only keeps cases where blue is ahead or tied
newkill <- subset(newkill, blue_kills >= red_kills)

# kill difference and total
newkill$kdiff = newkill$blue_kills - newkill$red_kills
newkill$total = newkill$blue_kills + newkill$red_kills

# predict using model
newkill$pred = predict(lolb.glm4, newdata = newkill, type = "response")

# plot
library(ggplot2)

ggplot(newkill, aes(x = kdiff, y = total, fill = pred)) +
  geom_tile() +
  scale_fill_gradient(low = "darkred", high = "lightblue", name = "Win Probability") +
  labs(
    title = "Win Probability by Kill Advantage (Blue ≥ Red)",
    x = "Kill Difference",
    y = "Total Kills"
  ) +
  scale_x_continuous(limits = c(0, 40)) +  # Limit kill difference to 0-40
  scale_y_continuous(limits = c(0, 60)) +  # Limit total kills to 0-60
  theme_minimal()
}
# End




