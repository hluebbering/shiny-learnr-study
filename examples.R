####################
#### Example 1. ####
####################
# Using Tidyverse to Manipulate Data
library(tidyverse)
who
who1 <- who %>% 
  pivot_longer(
    cols = new_sp_m014:newrel_f65, 
    names_to = "key", 
    values_to = "cases", 
    values_drop_na = TRUE
)

who1 %>% 
  count(key)

who2 <- who1 %>% 
  mutate(key = stringr::str_replace(key, "newrel", "new_rel"))

who3 <- who2 %>% 
  separate(key, c("new", "type", "sexage"), sep = "_")

who3 %>% 
  count(new)

who4 <- who3 %>% 
  select(-new, -iso2, -iso3)

who5 <- who4 %>% 
  separate(sexage, c("sex", "age"), sep = 1)

who %>%
  pivot_longer(
    cols = new_sp_m014:newrel_f65, 
    names_to = "key", 
    values_to = "cases", 
    values_drop_na = TRUE
  ) %>% 
  mutate(
    key = stringr::str_replace(key, "newrel", "new_rel")
  ) %>%
  separate(key, c("new", "var", "sexage")) %>% 
  select(-new, -iso2, -iso3) %>% 
  separate(sexage, c("sex", "age"), sep = 1)


####################
#### Example 2. ####
####################

library(simstudy)
library(data.table)
library(ggplot2)
library(clusterPower)
library(parallel)
library(lmerTest)
RNGkind("L'Ecuyer-CMRG") # enables seed for parallel process
set.seed(987)

#### Randomization by Student
# Randomization applied to entire group of students:
independentData <- function(N, d1) {
  di <- genData(N)
  di <- trtAssign(di, grpName = "rx")
  di <- addColumns(d1, di)
  di[]
}

# Outcome: intervention + effect of school and student:
defI1 <- defDataAdd(varname = "y", formula = "0.8 * rx", 
                    variance = 10, dist = "normal")
dx <- independentData(N = 30 * 50, defI1)

# Observed Effect Size and Variance 
dx[rx == 1, mean(y)] - dx[rx == 0, mean(y)] # 0.8
dx[, var(y)] # 10

# Plot of individual observations: 
ggplot(data=dx, aes(rx, y)) + 
  geom_jitter(aes(colour = rx), width = 0.25, size = 0.9) + 
  scale_x_continuous(limits = c(-0.51, 1.51)) + 
  theme_minimal() + theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(), 
    axis.title.x = element_blank(),
    legend.position = "none")


#### Randomization by Site
# Intervention Status assigned to each of k schools/clusters
clusteredData <- function(k, m, d1, d2) {
  dc <- genData(k, d1)
  dc <- trtAssign(dc, grpName = "rx")
  di <- genCluster(dc, "site", m, level1ID = "id")
  di <- addColumns(d2, di)
  di[]
}

defC <- defData(varname = "ceff", formula = 0, 
                variance = 0.5, id = "site", dist = "normal")

# Outcome of cluster, individual, and intervention effect
defI2 <- defDataAdd(varname = "y", formula = "ceff + 0.8 * rx", 
                    variance = 9.5, dist = "normal")
dx <- clusteredData(k = 30, m = 50, defC, defI2)

# Effect size and variation across all observations 
dx[rx == 1, mean(y)] - dx[rx == 0, mean(y)]
dx[, var(y)]

ggplot(data=dx, aes(site, y)) + 
  geom_jitter(aes(colour = rx), width = 0.22, size = 0.9) + 
  theme_minimal() + theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(), 
    legend.position = "none")


#### Randomization within Site
# Cluster randomization within site
withinData <- function(k, m, d1, d2) {
  dc <- genData(k, d1)
  di <- genCluster(dc, "site", m, "id")
  di <- trtAssign(di, strata="site", grpName = "rx")
  di <- addColumns(d2, di)
  di[]
}
dx <- withinData(30, 50, defC, defI2)
dx[rx == 1, mean(y)] - dx[rx == 0, mean(y)]
dx[, var(y)]

ggplot(data=dx, aes(site, y)) + 
  geom_jitter(aes(colour = rx), width = 0.22, size = 0.9) + 
  theme_minimal() + theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(), 
    legend.position = "none")
