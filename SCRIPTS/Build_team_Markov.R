build_team_markov <- function(team_transitions_tbl, all_states, transient_states, absorbing_states) {
  
  # 1. Compter les transitions observées pour l'équipe
  transition_counts_tbl <- team_transitions_tbl %>%
    count(state_from, state_to, name = "n_transitions")
  
  # 2. Compléter la grille complète des états
  full_transition_grid_tbl <- tidyr::expand_grid(
    state_from = all_states,
    state_to = all_states
  )
  
  transition_counts_full_tbl <- full_transition_grid_tbl %>%
    left_join(transition_counts_tbl, by = c("state_from", "state_to")) %>%
    mutate(
      n_transitions = dplyr::coalesce(n_transitions, 0L)
    )
  
  # 3. Construire la matrice de comptes
  count_matrix <- transition_counts_full_tbl %>%
    tidyr::pivot_wider(
      names_from = state_to,
      values_from = n_transitions
    ) %>%
    as.data.frame()
  
  rownames(count_matrix) <- count_matrix$state_from
  count_matrix$state_from <- NULL
  
  count_matrix <- as.matrix(count_matrix)
  count_matrix <- count_matrix[all_states, all_states, drop = FALSE]
  
  # 4. Construire la matrice de probabilités
  prob_matrix <- matrix(0, nrow = length(all_states), ncol = length(all_states))
  rownames(prob_matrix) <- all_states
  colnames(prob_matrix) <- all_states
  
  # Lignes transitoires : normalisation si somme > 0
  transient_row_sums <- rowSums(count_matrix[transient_states, , drop = FALSE])
  
  for (s in transient_states) {
    if (transient_row_sums[s] > 0) {
      prob_matrix[s, ] <- count_matrix[s, ] / transient_row_sums[s]
    }
  }
  
  # États absorbants : self-loops
  prob_matrix[absorbing_states, ] <- 0
  diag(prob_matrix[absorbing_states, absorbing_states]) <- 1
  
  # 5. Extraire Q et R
  Q <- prob_matrix[transient_states, transient_states, drop = FALSE]
  R <- prob_matrix[transient_states, absorbing_states, drop = FALSE]
  
  # 6. Calculer N et B si possible
  B <- NULL
  B_tbl <- NULL
  invertible <- TRUE
  
  inv_attempt <- tryCatch(
    solve(diag(nrow(Q)) - Q),
    error = function(e) {
      invertible <<- FALSE
      NULL
    }
  )
  
  if (invertible) {
    N <- inv_attempt
    B <- N %*% R
    
    B_tbl <- as.data.frame(B)
    B_tbl$state_from <- rownames(B_tbl)
    B_tbl <- B_tbl %>%
      dplyr::select(state_from, Win, Draw, Loss)
  } else {
    N <- NULL
  }
  
  list(
    count_matrix = count_matrix,
    prob_matrix = prob_matrix,
    Q = Q,
    R = R,
    N = N,
    B = B,
    B_tbl = B_tbl,
    invertible = invertible
  )
}

mu_transitions_tbl <- transitions_final_tbl %>%
  filter(team_id == 33)

mu_markov <- build_team_markov(
  team_transitions_tbl = mu_transitions_tbl,
  all_states = all_states,
  transient_states = transient_states,
  absorbing_states = absorbing_states
)
mu_markov$B_tbl %>%
  filter(state_from %in% c("(-1,T2)", "(-1,T3)", "(-1,T4)", "(0,T4)", "(+1,T4)"))


team_transitions_list <- transitions_final_tbl %>%
  split(.$team_id)

team_markov_list <- lapply(
  team_transitions_list,
  build_team_markov,
  all_states = all_states,
  transient_states = transient_states,
  absorbing_states = absorbing_states
)
team_absorption_tbl <- lapply(names(team_markov_list), function(team_id_chr) {
  
  mk <- team_markov_list[[team_id_chr]]
  
  if (is.null(mk$B_tbl)) {
    return(NULL)
  }
  
  mk$B_tbl %>%
    mutate(team_id = as.integer(team_id_chr))
  
}) %>%
  bind_rows()

team_names_tbl <- team_match_mental_features %>%
  select(team_id, team_name) %>%
  distinct()

team_absorption_tbl <- team_absorption_tbl %>%
  left_join(team_names_tbl, by = "team_id") %>%
  select(team_id, team_name, state_from, Win, Draw, Loss)

team_absorption_tbl %>%
  filter(state_from == "(+1,T4)") %>%
  arrange(desc(Win))

