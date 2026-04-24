remotes::install_github("zalmquist/networkdata")
library(networkdata)
library(cograph)
data(addhealth)

## implementing the add health simulation 

## Convert network data to adjacency matrix
adjacency_matrix_class_1 = to_matrix(addhealth$comm_1)

## 

assign_treatment <- function(N, frac = 0.1) {
  Z <- rep(0, N)
  treated <- sample(1:N, size = as.integer(N * frac), replace = FALSE)
  Z[treated] <- 1
  return(Z)
}


exposure_mapping <- function(Z, A) {
  # Z: treatment vector (0/1)
  # A: adjacency matrix
  
  # counts treated peers for each unit
  peer_treated <- A %*% Z  
  
  # initialize exposure vector
  D <- character(length(Z))
  
  # assign exposure conditions
  D[(Z == 1) & (peer_treated > 0)] <- "d11"
  D[(Z == 1) & (peer_treated == 0)] <- "d10"
  D[(Z == 0) & (peer_treated > 0)] <- "d01"
  D[(Z == 0) & (peer_treated == 0)] <- "d00"
  
  return(D)
}

estimate_exposure_probs <- function(A, N, frac = 0.1, R = 10000) {
  # Exposure conditions
  conditions <- c("d11", "d10", "d01", "d00")
  
  # Initialize counts list
  counts <- list()
  for (c in conditions) {
    counts[[c]] <- rep(0, N)
  }
  
  # Monte Carlo simulation
  for (r in 1:R) {
    Z <- assign_treatment(N, frac)
    D <- exposure_mapping(Z, A)
    
    for (c in conditions) {
      counts[[c]] <- counts[[c]] + as.numeric(D == c)
    }
  }
  
  # Additive smoothing
  probs <- list()
  for (c in conditions) {
    probs[[c]] <- (counts[[c]] + 1) / (R + 1)
  }
  
  return(probs)
}

generate_potential_outcomes <- function(base_outcome) {
  # base_outcome = y_i(d00)
  
  list(
    d00 = base_outcome,
    d01 = 1.25 * base_outcome,
    d10 = 1.50 * base_outcome,
    d11 = 2.00 * base_outcome
  )
}

ht_estimator <- function(Y_obs, D, pi, N) {
  
  mu_hat <- list()
  
  for (c in names(pi)) {
    probs <- pi[[c]]
    
    mask <- (D == c)
    
    # Avoid division by zero
    weights <- ifelse(mask, 1 / probs, 0)
    
    mu_hat[[c]] <- sum(Y_obs * weights) / N
  }
  
  return(mu_hat)
}

estimate_joint_probs <- function(A, N, cond_k, cond_l,
                                 frac = 0.1, R = 10000) {
  
  joint <- matrix(0, nrow = N, ncol = N)
  
  for (r in 1:R) {
    
    Z <- assign_treatment(N, frac)
    D <- exposure_mapping(Z, A)
    
    in_k <- as.numeric(D == cond_k)
    in_l <- as.numeric(D == cond_l)
    
    joint <- joint + outer(in_k, in_l)
  }
  
  joint / R
}

run_simulation <- function(A, base_Y, frac = 0.1,
                           R, n_reps = 500) {
  
  N <- length(base_Y)
  
  PO <- generate_potential_outcomes(base_Y)
  
  pi <- estimate_exposure_probs(A, N, frac, R)
  
  estimates <- list(
    d01_d00 = numeric(),
    d10_d00 = numeric(),
    d11_d00 = numeric()
  )
  
  for (rep in 1:n_reps) {
    
    Z <- assign_treatment(N, frac)
    D <- exposure_mapping(Z, A)
    
    # Observed outcomes
    Y_obs <- numeric(N)
    
    for (i in 1:N) {
      Y_obs[i] <- PO[[D[i]]][i]
    }
    
    mu <- ht_estimator(Y_obs, D, pi, N)
    
    estimates$d01_d00 <- c(
      estimates$d01_d00,
      mu$d01 - mu$d00
    )
    
    estimates$d10_d00 <- c(
      estimates$d10_d00,
      mu$d10 - mu$d00
    )
    
    estimates$d11_d00 <- c(
      estimates$d11_d00,
      mu$d11 - mu$d00
    )
  }
  
  return(estimates)
}

set.seed(123)
A = to_matrix(addhealth$comm_1)
N = nrow(A)
base_Y <- rnorm(N, mean = 10, sd = 2)

# Step 2 — potential outcomes

estimates = run_simulation(
  A,
  base_Y,
  frac = 0.1,
  R = 100000,
  n_reps = 5000
)

true_tau <- list(
  d01_d00 = mean(PO$d01 - PO$d00),
  d10_d00 = mean(PO$d10 - PO$d00),
  d11_d00 = mean(PO$d11 - PO$d00)
)

bias <- mean(estimates$d01_d00) -
  true_tau$d01_d00

sd <- sd(estimates$d01_d00)

rmse <- sqrt(bias^2 + sd^2)







