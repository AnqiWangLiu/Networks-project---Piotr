# BFT-style conditional randomization test on one Add Health network
#
# This script intentionally lives separately from the Aronow-Samii material.
# It uses the BicliqueRT generalized interface to build a conditional
# randomization test on a single Add Health school/community network.
#
# Conceptually, this adapts the Basse-Feller-Toulis idea as follows:
#   - Design: complete randomization with a fixed number treated.
#   - Exposure mapping: h_i(Z) = (own treatment, any treated friend).
#   - Null of interest: no spillover among untreated units,
#       Y_i(0, 0) = Y_i(0, 1).
#   - Test statistic: difference in mean outcomes between focal units with
#       exposure d01 versus d00.
#
# This is a simulation skeleton. It uses the Add Health network structure and
# simulates both treatment and outcomes on top of that structure.

ensure_github_package <- function(pkg, repo) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    return(invisible(TRUE))
  }

  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }

  remotes::install_github(repo)
  invisible(TRUE)
}

ensure_github_package("BicliqueRT", "dpuelz/BicliqueRT")
ensure_github_package("networkdata", "zalmquist/networkdata")

library(BicliqueRT)
library(networkdata)

data(addhealth, package = "networkdata")

prepare_addhealth_network <- function(addhealth,
                                      comm_name = "comm_1",
                                      symmetrize = TRUE,
                                      drop_isolates = TRUE) {
  A <- as.matrix(addhealth[[comm_name]])

  if (symmetrize) {
    # Treat a nomination in either direction as a social tie.
    A <- ((A + t(A)) > 0) * 1
  }

  diag(A) <- 0
  storage.mode(A) <- "numeric"

  keep <- rep(TRUE, nrow(A))
  if (drop_isolates) {
    keep <- rowSums(A) > 0
    A <- A[keep, keep, drop = FALSE]
  }

  list(
    A = A,
    keep = keep,
    comm_name = comm_name,
    N = nrow(A)
  )
}

draw_complete_randomization <- function(N, n_treated) {
  Z <- rep(0, N)
  treated_idx <- sample.int(N, size = n_treated, replace = FALSE)
  Z[treated_idx] <- 1
  Z
}

compute_exposures <- function(A, Z) {
  treated_friends <- as.numeric((A %*% Z) > 0)
  own_treat <- as.numeric(Z)

  label <- character(length(Z))
  label[own_treat == 0 & treated_friends == 0] <- "d00"
  label[own_treat == 0 & treated_friends == 1] <- "d01"
  label[own_treat == 1 & treated_friends == 0] <- "d10"
  label[own_treat == 1 & treated_friends == 1] <- "d11"

  data.frame(
    own_treat = own_treat,
    treated_friends = treated_friends,
    label = label,
    stringsAsFactors = FALSE
  )
}

simulate_observed_outcomes <- function(A,
                                       Z,
                                       baseline_mean = 0,
                                       baseline_sd = 1,
                                       direct_effect = 0.5,
                                       spillover_effect = 1.0,
                                       noise_sd = 1.0) {
  exposure_df <- compute_exposures(A, Z)
  baseline <- rnorm(length(Z), mean = baseline_mean, sd = baseline_sd)

  baseline +
    direct_effect * exposure_df$own_treat +
    spillover_effect * exposure_df$treated_friends +
    rnorm(length(Z), mean = 0, sd = noise_sd)
}

is_null_exposure <- function(exposure_vec) {
  identical(as.numeric(exposure_vec), c(0, 0)) ||
    identical(as.numeric(exposure_vec), c(0, 1))
}

build_bft_hypothesis <- function(A, n_treated) {
  list(
    design_fn = function() {
      draw_complete_randomization(nrow(A), n_treated)
    },
    exposure_i = function(z, i) {
      c(
        as.numeric(z[i]),
        as.numeric(sum(A[i, ] * z) > 0)
      )
    },
    null_equiv = function(e1, e2) {
      is_null_exposure(e1) && is_null_exposure(e2)
    }
  )
}

make_spillover_test_stat <- function(A) {
  force(A)

  function(y, z, is_focal) {
    exposure_df <- compute_exposures(A, z)
    focal <- as.logical(is_focal)

    control_no_peer <- focal & exposure_df$label == "d00"
    control_with_peer <- focal & exposure_df$label == "d01"

    if (sum(control_no_peer) == 0 || sum(control_with_peer) == 0) {
      # Some focal assignments are uninformative for the d00 vs d01 contrast.
      return(0)
    }

    abs(mean(y[control_with_peer]) - mean(y[control_no_peer]))
  }
}

run_bft_addhealth <- function(comm_name = "comm_82",
                              treated_frac = 0.10,
                              num_randomizations = 2000,
                              mina = 10,
                              seed = 123,
                              direct_effect = 0.5,
                              spillover_effect = 1.0,
                              noise_sd = 1.0) {
  set.seed(seed)

  network <- prepare_addhealth_network(addhealth, comm_name = comm_name)
  A <- network$A
  N <- network$N

  n_treated <- max(1, floor(N * treated_frac))
  Z_obs <- draw_complete_randomization(N, n_treated)
  Y_obs <- simulate_observed_outcomes(
    A = A,
    Z = Z_obs,
    direct_effect = direct_effect,
    spillover_effect = spillover_effect,
    noise_sd = noise_sd
  )

  hypothesis <- build_bft_hypothesis(A, n_treated)
  controls <- list(
    method = "greedy",
    mina = mina,
    num_randomizations = num_randomizations
  )

  biclique_decomp <- biclique.decompose(
    Z = Z_obs,
    hypothesis = hypothesis,
    controls = controls
  )

  test_stat <- make_spillover_test_stat(A)
  test_out <- clique_test(
    Y = Y_obs,
    Z = Z_obs,
    teststat = test_stat,
    biclique_decom = biclique_decomp,
    one_sided = TRUE
  )

  exposure_obs <- compute_exposures(A, Z_obs)

  list(
    settings = list(
      comm_name = comm_name,
      N = N,
      n_treated = n_treated,
      treated_frac = treated_frac,
      mina = mina,
      num_randomizations = num_randomizations,
      direct_effect = direct_effect,
      spillover_effect = spillover_effect,
      noise_sd = noise_sd
    ),
    network = network,
    Z_obs = Z_obs,
    Y_obs = Y_obs,
    exposure_obs = exposure_obs,
    biclique_decomp = biclique_decomp,
    test_out = test_out
  )
}

summarize_bft_result <- function(result) {
  exposure_counts <- table(result$exposure_obs$label)

  summary_df <- data.frame(
    community = result$settings$comm_name,
    N = result$settings$N,
    n_treated = result$settings$n_treated,
    p_value = result$test_out$p.value,
    statistic = result$test_out$statistic,
    focal_assignments = length(result$test_out$statistic.dist),
    d00 = unname(exposure_counts["d00"]),
    d01 = unname(exposure_counts["d01"]),
    d10 = unname(exposure_counts["d10"]),
    d11 = unname(exposure_counts["d11"]),
    row.names = NULL
  )

  summary_df[is.na(summary_df)] <- 0
  summary_df
}

benchmark_bft_communities <- function(comm_names,
                                      treated_frac = 0.10,
                                      num_randomizations = 200,
                                      mina = 10,
                                      seed = 123,
                                      direct_effect = 0.5,
                                      spillover_effect = 1.0,
                                      noise_sd = 1.0,
                                      verbose = TRUE) {
  benchmark_rows <- vector("list", length(comm_names))
  benchmark_results <- vector("list", length(comm_names))
  names(benchmark_results) <- comm_names

  for (idx in seq_along(comm_names)) {
    comm_name <- comm_names[idx]
    sim_seed <- seed + idx - 1

    if (verbose) {
      message(
        sprintf(
          "[%d/%d] Benchmarking %s | seed=%d | R=%d",
          idx, length(comm_names), comm_name, sim_seed, num_randomizations
        )
      )
    }

    start_time <- Sys.time()
    run_out <- tryCatch(
      run_bft_addhealth(
        comm_name = comm_name,
        treated_frac = treated_frac,
        num_randomizations = num_randomizations,
        mina = mina,
        seed = sim_seed,
        direct_effect = direct_effect,
        spillover_effect = spillover_effect,
        noise_sd = noise_sd
      ),
      error = function(e) e
    )
    elapsed_sec <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

    if (inherits(run_out, "error")) {
      benchmark_rows[[idx]] <- data.frame(
        community = comm_name,
        N = NA_integer_,
        n_treated = NA_integer_,
        p_value = NA_real_,
        statistic = NA_real_,
        focal_assignments = NA_integer_,
        d00 = NA_integer_,
        d01 = NA_integer_,
        d10 = NA_integer_,
        d11 = NA_integer_,
        runtime_sec = elapsed_sec,
        valid_p_value = FALSE,
        status = paste("error:", conditionMessage(run_out)),
        row.names = NULL
      )
      next
    }

    benchmark_results[[comm_name]] <- run_out
    summary_row <- summarize_bft_result(run_out)
    summary_row$runtime_sec <- elapsed_sec
    summary_row$valid_p_value <- is.finite(summary_row$p_value)
    summary_row$status <- "ok"
    benchmark_rows[[idx]] <- summary_row
  }

  benchmark_table <- do.call(rbind, benchmark_rows)

  list(
    benchmark_table = benchmark_table,
    benchmark_results = benchmark_results
  )
}

select_best_benchmark_communities <- function(benchmark_table, top_k = 3) {
  candidate_table <- benchmark_table
  candidate_table$valid_p_value[is.na(candidate_table$valid_p_value)] <- FALSE
  candidate_table$focal_assignments[is.na(candidate_table$focal_assignments)] <- -1
  candidate_table$N[is.na(candidate_table$N)] <- -1

  # Rank communities by inferential usefulness, not by runtime.
  candidate_table <- candidate_table[
    order(
      candidate_table$valid_p_value,
      candidate_table$focal_assignments,
      candidate_table$N,
      decreasing = TRUE
    ),
  ]

  head(candidate_table, top_k)
}

rerun_selected_benchmark_communities <- function(selected_table,
                                                 treated_frac = 0.10,
                                                 num_randomizations = 1000,
                                                 mina = 10,
                                                 seed = 10000,
                                                 direct_effect = 0.5,
                                                 spillover_effect = 1.0,
                                                 noise_sd = 1.0,
                                                 verbose = TRUE) {
  stopifnot("selected_table must contain a community column" =
              ("community" %in% names(selected_table)))

  benchmark_bft_communities(
    comm_names = selected_table$community,
    treated_frac = treated_frac,
    num_randomizations = num_randomizations,
    mina = mina,
    seed = seed,
    direct_effect = direct_effect,
    spillover_effect = spillover_effect,
    noise_sd = noise_sd,
    verbose = verbose
  )
}

run_bft_benchmark_workflow <- function(
    benchmark_comm_names = benchmark_comm_tiers,
    top_k = 3,
    treated_frac = 0.10,
    benchmark_num_randomizations = 200,
    rerun_num_randomizations = 1000,
    mina = 10,
    benchmark_seed = 123,
    rerun_seed = 10000,
    direct_effect = 0.5,
    spillover_effect = 1.0,
    noise_sd = 1.0,
    verbose = TRUE) {
  benchmark_out <- benchmark_bft_communities(
    comm_names = benchmark_comm_names,
    treated_frac = treated_frac,
    num_randomizations = benchmark_num_randomizations,
    mina = mina,
    seed = benchmark_seed,
    direct_effect = direct_effect,
    spillover_effect = spillover_effect,
    noise_sd = noise_sd,
    verbose = verbose
  )

  selected_table <- select_best_benchmark_communities(
    benchmark_out$benchmark_table,
    top_k = top_k
  )

  rerun_out <- rerun_selected_benchmark_communities(
    selected_table = selected_table,
    treated_frac = treated_frac,
    num_randomizations = rerun_num_randomizations,
    mina = mina,
    seed = rerun_seed,
    direct_effect = direct_effect,
    spillover_effect = spillover_effect,
    noise_sd = noise_sd,
    verbose = verbose
  )

  list(
    benchmark_table = benchmark_out$benchmark_table,
    benchmark_results = benchmark_out$benchmark_results,
    selected_table = selected_table,
    rerun_table = rerun_out$benchmark_table,
    rerun_results = rerun_out$benchmark_results,
    settings = list(
      benchmark_comm_names = benchmark_comm_names,
      top_k = top_k,
      treated_frac = treated_frac,
      benchmark_num_randomizations = benchmark_num_randomizations,
      rerun_num_randomizations = rerun_num_randomizations,
      mina = mina,
      benchmark_seed = benchmark_seed,
      rerun_seed = rerun_seed,
      direct_effect = direct_effect,
      spillover_effect = spillover_effect,
      noise_sd = noise_sd
    )
  )
}

benchmark_comm_tiers <- c(
  "comm_1",
  "comm_9",
  "comm_11",
  "comm_13",
  "comm_16",
  "comm_82",
  "comm_15",
  "comm_79",
  "comm_84",
  "comm_50"
)

# Example single run:
# bft_result <- run_bft_addhealth(
#   comm_name = "comm_82",
#   treated_frac = 0.10,
#   num_randomizations = 2000,
#   mina = 10,
#   seed = 123,
#   direct_effect = 0.5,
#   spillover_effect = 1.0,
#   noise_sd = 1.0
# )
# print(summarize_bft_result(bft_result))
#
# Example benchmark workflow:
# benchmark_out <- benchmark_bft_communities(
#   comm_names = benchmark_comm_tiers,
#   treated_frac = 0.10,
#   num_randomizations = 200,
#   mina = 10,
#   seed = 123,
#   direct_effect = 0.5,
#   spillover_effect = 1.0,
#   noise_sd = 1.0
# )
# benchmark_out$benchmark_table
# select_best_benchmark_communities(benchmark_out$benchmark_table, top_k = 3)
#
# Example full workflow:
# workflow_out <- run_bft_benchmark_workflow(
#   benchmark_comm_names = benchmark_comm_tiers,
#   top_k = 3,
#   treated_frac = 0.10,
#   benchmark_num_randomizations = 200,
#   rerun_num_randomizations = 1000,
#   mina = 10,
#   benchmark_seed = 123,
#   rerun_seed = 10000,
#   direct_effect = 0.5,
#   spillover_effect = 1.0,
#   noise_sd = 1.0
# )
# workflow_out$benchmark_table
# workflow_out$selected_table
# workflow_out$rerun_table
