
# https://www.r-bloggers.com/2016/02/toying-with-models-the-luria-delbruck-fluctuation-test/

culture <- function(generations, mu) {
  
# populate empty vectors for length of generations  
  n_susceptible <- numeric(generations)
  n_resistant <- numeric(generations)
  n_mutants <- numeric(generations)
  generations <- generations

# set first generation number of clones to 1  
  n_susceptible[1] <- 1

  #  set a random growth rate for each culture
  
  
#   
  if(generations <= 30){

  for (i in 1:(generations - 1)) {
    x1 <- runif(1, 1.95, 2.05)
    n_mutants[i] <- rbinom(n = 1, size = n_susceptible[i], prob = 1.13475e-07*mu)
    n_susceptible[i + 1] <- ceiling(x1 * (n_susceptible[i] - n_mutants[i]))
    n_resistant[i + 1] <- ceiling(x1 * (n_resistant[i] + n_mutants[i]))
  }
  data.frame(generation = 1:generations,
             n_susceptible,
             n_resistant,
             n_mutants)
    } 
  else{
    if(generations <= 35){
      for (i in 1:29) {
        x1 <- runif(1, 1.95, 2.05)
        n_mutants[i] <- rbinom(n = 1, size = n_susceptible[i], prob = 1.13475e-07*mu)
        n_susceptible[i + 1] <- ceiling(x1 * (n_susceptible[i] - n_mutants[i]))
        n_resistant[i + 1] <- ceiling(x1 * (n_resistant[i] + n_mutants[i]))
      }
      for (i in 30:(generations - 1)){
        x1 <- runif(1, 1, 1.6)
        n_mutants[i] <- rbinom(n = 1, size = n_susceptible[i], prob = 1.13475e-07*mu)
        n_susceptible[i + 1] <- ceiling(x1 * (n_susceptible[i] - n_mutants[i]))
        n_resistant[i + 1] <- ceiling(x1 * (n_resistant[i] + n_mutants[i]))
      }
    }
    else{
    for (i in 1:29) {
      x1 <- runif(1, 1.95, 2.05)
      n_mutants[i] <- rbinom(n = 1, size = n_susceptible[i], prob = 1.13475e-07*mu)
      n_susceptible[i + 1] <- ceiling(x1 * (n_susceptible[i] - n_mutants[i]))
      n_resistant[i + 1] <- ceiling(x1 * (n_resistant[i] + n_mutants[i]))
    }
    for (i in 30:34){
      x1 <- runif(1, 1, 1.6)
      n_mutants[i] <- rbinom(n = 1, size = n_susceptible[i], prob = 1.13475e-07*mu)
      n_susceptible[i + 1] <- ceiling(x1 * (n_susceptible[i] - n_mutants[i]))
      n_resistant[i + 1] <- ceiling(x1 * (n_resistant[i] + n_mutants[i]))
    }
    for (i in 35:(generations - 1)){
      x1 <- runif(1, 0.9, 1.2)
      n_mutants[i] <- rbinom(n = 1, size = n_susceptible[i], prob = 1.13475e-07*mu)
      n_susceptible[i + 1] <- ceiling(x1 * (n_susceptible[i] - n_mutants[i]))
      n_resistant[i + 1] <- ceiling(x1 * (n_resistant[i] + n_mutants[i]))
    }
    }
  }

    data.frame(generation = 1:generations,
               n_susceptible,
               n_resistant,
               n_mutants)
  
}
  


total_cultures <- function(iteration=30, generations, mu, log = FALSE){
  cultures <- replicate(iteration, culture(generations, mu), simplify = FALSE)
  combined <- Reduce(function (x, y) rbind(x, y), cultures)
  combined$culture <- rep(1:iteration, each = generations)
  combined$transformation <- log
  print(combined)
}

