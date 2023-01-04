# Bacteria plates
source("scripts/LD_function.R")
library(tidyverse)
library(ggbeeswarm)
library(aplot)
library(scales)
library(patchwork)
library(scattermore)
#data()

my_theme2 <- 
  theme_void()+
  theme(legend.position = "none",
        strip.text = element_blank())


plate_spread <- function(value) {
  data.frame(
    size = rnorm(value, mean = 1.2, sd= 0.4),
    x = runif(value, min = 0, max = 9),
    y = runif(value, min = 0, max = 9)
  )
 
}


plot_plate <- function(data){

  data %>% 
  filter(generation == max(generation)) %>% 
  mutate(`resistant` = n_resistant+n_mutants) %>% 
  mutate(`total` = n_susceptible + `resistant`) %>%
  mutate(subset = `total`/1000) %>% 
  mutate(subset = if_else(subset >250, 250, subset)) %>% 
  mutate(`resistant` = (`resistant`/1000)) -> new_data



####
  


my_list <- lapply((new_data$subset[1:5])+1, plate_spread)
total_colonies <- do.call(rbind, my_list)

total_colonies$id <- factor(rep(1:5, times = c(nrow(my_list[[1]]), 
                                        nrow(my_list[[2]]), 
                                        nrow(my_list[[3]]), 
                                        nrow(my_list[[4]]), 
                                        nrow(my_list[[5]]))))
total_colonies$colour <- if_else(sum(new_data$subset[1:5]) <= 5, "white", "#3D99CC")

# Create a ggplot object with the colonies data
  
plot1 <- ggplot(total_colonies, aes(x = x, y = y))+xlim(0,10)+ylim(0,10) + geom_point(aes(x=0, y=0), size = 90, shape = 21)+
    geom_point(size = total_colonies$size,color = total_colonies$colour) +coord_polar(theta = "x")+my_theme2 + facet_wrap( ~ id)




####################



my_list <- lapply((new_data$resistant[1:5])+1, plate_spread)
resistant_colonies <- do.call(rbind, my_list)

resistant_colonies$id <- factor(rep(1:5, times = c(nrow(my_list[[1]]), 
                                        nrow(my_list[[2]]), 
                                        nrow(my_list[[3]]), 
                                        nrow(my_list[[4]]), 
                                        nrow(my_list[[5]]))))
resistant_colonies$colour <- if_else(sum(new_data$resistant[1:5]) <= 5, "white", "#898710")
  
plot2 <- ggplot(resistant_colonies, aes(x = x, y = y))+xlim(0,10)+ylim(0,10) + geom_point(aes(x=0, y=0), size = 90, shape = 21)+
  geom_point(size = resistant_colonies$size, color = resistant_colonies$colour) +coord_polar(theta = "x")+my_theme2 + facet_wrap( ~ id)

plot2

plot1_2 <- plot2 | plot1

plot1_2

}


#
# Iterate over the first five elements of data$subset

#plot_list1 <- list()

#for (i in 1:5) {
 # total_colonies <- data.frame(
  #  x = runif(new_data$subset[i], min = 0, max = 10),
   # y = runif(new_data$subset[i], min = 0, max = 10),
    #size = rnorm(new_data$subset[i], mean = 4, sd = 2)
#  )
  #
  # Create a ggplot object with the colonies data
  
 # plot_list1[[i]] <- ggplot(total_colonies, aes(x = x, y = y, size = size))+xlim(0,10)+ylim(0,10) + geom_point(aes(x=0, y=0), size = 40, shape = 21)+
  #  geom_point(color = "#3D99CC") +coord_polar(theta = "x")+my_theme2
#}

#plot1 <-   plot_list1[[1]]/
 # plot_list1[[2]]/
  #plot_list1[[3]]/
  #plot_list1[[4]]/
  #plot_list1[[5]]
