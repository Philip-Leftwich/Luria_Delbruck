library(tidyverse)
library(ggbeeswarm)
library(aplot)
library(scales)
library(patchwork)
#library(gghighlight)
#library(gganimate)
#library(gifski)
#library(magick)

source("scripts/LD_function.R")

bgcolor <- "grey20"
textcolor <- "white"
my_theme <- theme(
  plot.background = element_rect(fill = bgcolor, colour = bgcolor),
  panel.background = element_rect(fill = NA),
  legend.background = element_rect(fill = NA),
  legend.position="none",
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  text = element_text(colour = textcolor, size=16),
  axis.text = element_text(colour = textcolor, size=12)
)

my_colour <- scale_colour_manual(values = c("#3D99CC", "#898710"))
my_fill <- scale_fill_manual(values = c("#3D99CC", "#898710"))


plot_LD <- function(data){
  plotly::ggplotly(
data %>% 
  mutate(`resistant` = n_resistant+n_mutants) %>% 
  mutate(`susceptible` = n_susceptible) %>% 
  pivot_longer(cols = `resistant`:`susceptible`,
               names_to = "antibiotic resistance",
               values_to = "numbers") %>% 
ggplot(aes(x=generation, 
                            y = numbers, 
                            colour = `antibiotic resistance` ))+
         geom_line(aes(group = culture), size = 0.8)+
  facet_wrap(~ `antibiotic resistance`, scales = "free_y")+
    my_theme + my_colour
)
}



plot_violinbox <- function(data) {
  data %>%
    filter(generation == 30) %>% 
    mutate(`Rifampicin & Ampicillin` = n_resistant+n_mutants) %>% 
    mutate(`Ampicillin only` = n_susceptible + `Rifampicin & Ampicillin`) %>% 
    pivot_longer(cols = `Rifampicin & Ampicillin`:`Ampicillin only`,
                 names_to = "LB agar plates",
                 values_to = "CFU (colony forming units)") %>% 
    mutate(`CFU (colony forming units)` = `CFU (colony forming units)`/1275) %>% 
    ggplot(aes(x = `LB agar plates`, y = 1+`CFU (colony forming units)`, fill = `LB agar plates`)) +
    geom_quasirandom(aes(fill = `LB agar plates`), shape = 21, colour = "white", width=0.2) +
    ylab("Colony counts (log scale)") +
    xlab("Antibiotic Plates") +
    scale_y_log10()+
    my_theme + my_fill
}


plot_violinbox <- function(data) {
  violin <- data %>%
    filter(generation == max(generation)) %>% 
    mutate(`Rifampicin` = n_resistant+n_mutants) %>% 
    mutate(`Non Selective` = n_susceptible + `Rifampicin`) %>% 
    pivot_longer(cols = `Rifampicin`:`Non Selective`,
                 names_to = "LB agar plates",
                 values_to = "CFU (colony forming units)") %>% 
    mutate(`CFU (colony forming units)` = `CFU (colony forming units)`/100) %>% 
    ggplot(aes(x = `LB agar plates`, y = 1+`CFU (colony forming units)`, fill = `LB agar plates`)) +
    geom_point(aes(fill = `LB agar plates`), shape = 21, colour = "white",
               size = 3,
               position = position_jitter(
                 width = 0.2,
                 height = 0.05,
                 seed = NA
               )) +
    geom_hline(yintercept = 0, linetype = 2, colour = "white", size = 0.5)+
    ylab("Colony forming units") +
    xlab("Antibiotic Plates") +
    my_theme + my_fill+
 # gghighlight(max(1+`CFU (colony forming units)`) > 1, use_direct_label = FALSE)+
    theme(panel.grid.major.y = element_line(color = "white",
                                                size = 0.2,
                                                linetype = 1))
  
  if(data$transformation){
   violin <- violin+scale_y_log10(breaks = breaks_log(n = 5, base = 10), limits = c(1.1, NA))+ annotation_logticks(sides="lr", colour = "white")

  } 
  else{
    violin <- violin+scale_y_continuous(breaks = scales::breaks_extended(n = 5), limits = c(1.1, NA))

  }
  violin
}

plot_LD <- function(data){
  
    data %>% 
    mutate(`resistant` = n_resistant+n_mutants) %>% 
    mutate(`susceptible` = n_susceptible) %>% 
    mutate(`total` = n_susceptible + `resistant`) %>% 
    pivot_longer(cols = `resistant`:`susceptible`,
                 names_to = "antibiotic resistance",
                 values_to = "numbers") -> data_1 
  
  plot_1 <- data_1 %>% 
    filter(`antibiotic resistance` == "resistant") %>% 
    ggplot(aes(x=generation, 
               y = 1+numbers))+
    geom_line(aes(group = culture), size = 0.8, colour = "#898710")+
    ylab("") +
#    transition_reveal(generation)+
    my_theme + my_colour+ggtitle("Mutants") 
  
  
  plot_2 <- data_1 %>% 
        ggplot(aes(x=generation, 
               y = 1+`total`))+
    geom_line(aes(group = culture), size = 0.8, colour = "#3D99CC")+
    ylab("") +
#    transition_reveal(generation)+
    my_theme + my_colour+ggtitle("Total") 

# plot_2 %>% insert_right(plot_1)
    
if(data$transformation){
  plot_1 <- plot_1+scale_y_log10(breaks = breaks_log(n = 5, base = 10))+ annotation_logticks(sides="lr", colour = "white")+coord_cartesian(ylim = c(1, 4000000000))
  plot_2 <- plot_2+scale_y_log10(breaks = breaks_log(n = 5, base = 10))+ annotation_logticks(sides="lr", colour = "white")+coord_cartesian(ylim = c(1, 4000000000))
  combined <- plot_1 + plot_2
} 
  else{
    plot_1 <- plot_1+scale_y_continuous(breaks = scales::breaks_extended(n = 5))
    plot_2 <- plot_2+scale_y_continuous(breaks = scales::breaks_extended(n = 5))
  
    combined <- plot_1 + plot_2
  }
  
  combined

# p_ranges_y <- c(ggplot_build(combined_plot[[1]])$layout$panel_scales_y[[1]]$range$range,
           #     ggplot_build(combined_plot[[2]])$layout$panel_scales_y[[1]]$range$range)

#  animate(plot_1, duration = 4, fps = 4,height = 800, width =800, renderer = gifski_renderer(loop = FALSE))
#  anim_save("outfile_1.gif")

#  animate(plot_2, duration = 4, fps = 4,height = 800, width =800, renderer = gifski_renderer(loop = FALSE))
#  anim_save("outfile_2.gif")
  
#  a_mgif <- image_read("outfile_1.gif")
 # b_mgif <- image_read("outfile_2.gif")
  
#  new_gif <- image_append(c(a_mgif[1], b_mgif[1]))
#  for(i in 2:length(a_mgif)){
# combined <- image_append(c(a_mgif[i], b_mgif[i]))
#    new_gif <- c(new_gif, combined)
#  }
  
#  anim_save("new.gif", animation = new_gif)

}
