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
    probs[[c]] <- counts[[c]] / R  # no smoothing for point estimates
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
                           R, n_reps) {
  
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
  R = 10000,
  n_reps = 10000
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






###

# --- Run simulation across all networks ---

run_simulation_all_networks <- function(addhealth, 
                                        frac     = 0.1,
                                        R        = 10000,
                                        n_reps   = 500,
                                        estimator = "hajek") {
  
  # Get all community names
  comm_names <- names(addhealth)
  n_networks <- length(comm_names)
  
  message(sprintf("Running simulation across %d networks...", n_networks))
  
  # Store results per network
  network_results <- vector("list", n_networks)
  names(network_results) <- comm_names
  
  # Store per-network summaries for aggregation
  summaries <- lapply(c("d01_d00", "d10_d00", "d11_d00"), function(e) {
    data.frame(
      network  = character(),
      N        = integer(),
      true_tau = numeric(),
      mean_est = numeric(),
      bias     = numeric(),
      sd       = numeric(),
      rmse     = numeric(),
      stringsAsFactors = FALSE
    )
  })
  names(summaries) <- c("d01_d00", "d10_d00", "d11_d00")
  
  skipped <- character()
  
  for (idx in seq_along(comm_names)) {
    
    comm <- comm_names[idx]
    message(sprintf("[%d/%d] Processing %s...", idx, n_networks, comm))
    
    # Get adjacency matrix
    A <- as.matrix(addhealth[[comm]])
    diag(A) <- 0
    N <- nrow(A)
    
    # Skip networks that are too small or too sparse
    if (N < 10) {
      message(sprintf("  Skipping %s: N=%d too small", comm, N))
      skipped <- c(skipped, comm)
      next
    }
    
    # Check network is not empty
    if (sum(A) == 0) {
      message(sprintf("  Skipping %s: no edges", comm))
      skipped <- c(skipped, comm)
      next
    }
    
    # Drop isolated nodes (degree = 0) as per paper p.1931
    degree  <- rowSums(A)
    keep    <- degree > 0
    if (sum(keep) < 10) {
      message(sprintf("  Skipping %s: too few connected nodes", comm))
      skipped <- c(skipped, comm)
      next
    }
    A <- A[keep, keep]
    N <- nrow(A)
    
    # Generate base outcomes from after-school activities variable if available
    # Otherwise simulate as in the paper (right-skewed)
    # Paper uses actual outcome data from Add Health for y_i(d00)
    base_Y <- rnorm(N, mean = 2.14, sd = 2.64)   # match paper's mean/sd
    base_Y <- pmax(base_Y, 0)                      # non-negative like count data
    
    # Run simulation for this network
    res <- tryCatch({
      run_simulation(
        A         = A,
        base_Y    = base_Y,
        frac      = frac,
        R         = R,
        n_reps    = n_reps,
        estimator = estimator
      )
    }, error = function(e) {
      message(sprintf("  Error in %s: %s", comm, e$message))
      NULL
    })
    
    if (is.null(res)) {
      skipped <- c(skipped, comm)
      next
    }
    
    network_results[[comm]] <- res
    
    # Store summary rows
    for (estimand in c("d01_d00", "d10_d00", "d11_d00")) {
      s <- res$summary[[estimand]]
      summaries[[estimand]] <- rbind(
        summaries[[estimand]],
        data.frame(
          network  = comm,
          N        = N,
          true_tau = s$true,
          mean_est = s$mean,
          bias     = s$bias,
          sd       = s$sd,
          rmse     = s$rmse,
          stringsAsFactors = FALSE
        )
      )
    }
  }
  
  if (length(skipped) > 0)
    message(sprintf("\nSkipped %d networks: %s",
                    length(skipped), paste(skipped, collapse = ", ")))
  
  # --- Aggregate across networks ---
  # Paper takes the average across schools
  aggregate_results <- lapply(summaries, function(df) {
    list(
      per_network    = df,
      mean_true_tau  = mean(df$true_tau),
      mean_bias      = mean(df$bias),
      mean_sd        = mean(df$sd),
      mean_rmse      = mean(df$rmse),
      # Weighted by N, as larger networks contribute more
      wtd_mean_bias  = weighted.mean(df$bias, df$N),
      wtd_mean_rmse  = weighted.mean(df$rmse, df$N),
      n_networks     = nrow(df)
    )
  })
  
  list(
    network_results    = network_results,
    summaries          = summaries,
    aggregate_results  = aggregate_results,
    skipped            = skipped,
    settings           = list(frac = frac, R = R,
                              n_reps = n_reps, estimator = estimator)
  )
}

print_aggregate_summary <- function(all_results) {
  
  cat("\n====================================================\n")
  cat(sprintf("Estimator: %s | Networks: %d | Reps per network: %d\n",
              all_results$settings$estimator,
              length(all_results$network_results) - length(all_results$skipped),
              all_results$settings$n_reps))
  cat("====================================================\n")
  
  cat(sprintf("\n%-12s | %-8s | %-8s | %-8s | %-8s | %-8s\n",
              "Estimand", "TrueTau", "MeanEst", "Bias", "SD", "RMSE"))
  cat(paste(rep("-", 65), collapse = ""), "\n")
  
  for (estimand in names(all_results$aggregate_results)) {
    agg <- all_results$aggregate_results[[estimand]]
    cat(sprintf("%-12s | %8.3f | %8.3f | %+8.4f | %8.3f | %8.3f\n",
                estimand,
                agg$mean_true_tau,
                agg$mean_true_tau + agg$mean_bias,
                agg$mean_bias,
                agg$mean_sd,
                agg$mean_rmse))
  }
  
  cat("\n--- Weighted by network size ---\n")
  for (estimand in names(all_results$aggregate_results)) {
    agg <- all_results$aggregate_results[[estimand]]
    cat(sprintf("%-12s | Wtd Bias: %+.4f | Wtd RMSE: %.3f\n",
                estimand,
                agg$wtd_mean_bias,
                agg$wtd_mean_rmse))
  }
}

plot_network_results <- function(all_results) {
  
  par(mfrow = c(3, 3), mar = c(4, 4, 3, 1))
  
  estimands  <- c("d01_d00", "d10_d00", "d11_d00")
  estimand_labels <- c("τ(d01, d00)", "τ(d10, d00)", "τ(d11, d00)")
  
  for (i in seq_along(estimands)) {
    
    est <- estimands[i]
    df  <- all_results$summaries[[est]]
    
    # Bias by network
    plot(df$N, df$bias,
         main = paste(estimand_labels[i], "- Bias by N"),
         xlab = "Network size (N)",
         ylab = "Bias",
         pch  = 19, col = adjustcolor("steelblue", 0.6))
    abline(h = 0, col = "red", lty = 2)
    lines(lowess(df$N, df$bias), col = "red", lwd = 2)
    
    # RMSE by network
    plot(df$N, df$rmse,
         main = paste(estimand_labels[i], "- RMSE by N"),
         xlab = "Network size (N)",
         ylab = "RMSE",
         pch  = 19, col = adjustcolor("darkorange", 0.6))
    lines(lowess(df$N, df$rmse), col = "darkorange", lwd = 2)
    
    # Distribution of biases across networks
    hist(df$bias, breaks = 20,
         main  = paste(estimand_labels[i], "- Bias distribution"),
         xlab  = "Bias",
         col   = "steelblue", border = "white")
    abline(v = 0,             col = "red",    lwd = 2, lty = 2)
    abline(v = mean(df$bias), col = "orange", lwd = 2, lty = 1)
  }
}

# --- Run ---
set.seed(123)

all_results <- run_simulation_all_networks(
  addhealth = addhealth,
  frac      = 0.1,
  R         = 10000,
  n_reps    = 500,
  estimator = "hajek"
)

print_aggregate_summary(all_results)
plot_network_results(all_results)

# --- Per-network detail if needed ---
for (estimand in c("d01_d00", "d10_d00", "d11_d00")) {
  cat(sprintf("\nPer-network results for %s:\n", estimand))
  df <- all_results$summaries[[estimand]]
  df <- df[order(df$N), ]
  print(df, row.names = FALSE)
}

## HT estimator
all_results_ht <- run_simulation_all_networks(
  addhealth = addhealth,
  frac      = 0.1,
  R         = 20000,
  n_reps    = 500,
  estimator = "ht"
)

print_aggregate_summary(all_results_ht)
plot_network_results(all_results_ht)


library(ggplot2)

# Extract per-network bias for HT
ht_bias_by_network <- all_results_ht$summaries$d11_d00

# Plot bias vs N
ggplot(ht_bias_by_network, aes(x = N, y = bias)) +
  geom_point(alpha = 0.6, color = "steelblue") +
  geom_smooth(method = "loess", color = "red", se = TRUE) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "HT Bias vs Network Size (d11_d00)",
       x = "Network size (N)", y = "Bias") +
  theme_minimal()

# Check distribution of network sizes
cat("Network size distribution:\n")
print(summary(ht_bias_by_network$N))

# Check minimum exposure probabilities per network
# to confirm this is the culprit
check_min_probs <- function(addhealth, frac = 0.1, R = 5000) {
  
  results <- lapply(names(addhealth), function(comm) {
    
    A <- as.matrix(addhealth[[comm]])
    diag(A) <- 0
    keep <- rowSums(A) > 0
    A    <- A[keep, keep]
    N    <- nrow(A)
    
    if (N < 10 || sum(A) == 0) return(NULL)
    
    pi <- estimate_exposure_probs(A, N, frac, R)
    
    data.frame(
      network    = comm,
      N          = N,
      min_pi_d01 = min(pi$d01),
      min_pi_d10 = min(pi$d10),
      min_pi_d11 = min(pi$d11),
      min_pi_d00 = min(pi$d00),
      pct_tiny_d11 = mean(pi$d11 < 0.01) * 100,
      pct_tiny_d01 = mean(pi$d01 < 0.01) * 100
    )
  })
  
  do.call(rbind, Filter(Negate(is.null), results))
}

set.seed(123)
prob_check <- check_min_probs(addhealth, frac = 0.1, R = 5000)

cat("\nExposure probability summary across networks:\n")
print(summary(prob_check[, c("N", "min_pi_d11", "min_pi_d01",
                             "pct_tiny_d11", "pct_tiny_d01")]))

# Show worst offenders
cat("\nNetworks with most tiny probabilities (d11):\n")
worst <- prob_check[order(-prob_check$pct_tiny_d11), ]
print(head(worst[, c("network", "N", "min_pi_d11", "pct_tiny_d11")], 10))

# Scatter: min pi vs bias
merged <- merge(prob_check, ht_bias_by_network, by = "network")

ggplot(merged, aes(x = min_pi_d11, y = bias, size = N)) +
  geom_point(alpha = 0.6, color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_x_log10() +
  labs(title = "HT Bias vs minimum π(d11) per network",
       x = "Min exposure probability (log scale)",
       y = "Bias for d11_d00") +
  theme_minimal()