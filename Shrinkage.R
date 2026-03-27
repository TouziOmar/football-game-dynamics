build_team_markov_shrunk_corrected <- function(team_transitions_tbl,
                                               transition_prob_matrix_global,
                                               all_states,
                                               transient_states,
                                               absorbing_states,
                                               k = 3) {
  
  # 1. Comptes observés de l'équipe
  transition_counts_tbl <- team_transitions_tbl %>%
    dplyr::count(state_from, state_to, name = "n_transitions")
  
  # 2. Compléter tous les couples d'états
  full_transition_grid_tbl <- tidyr::expand_grid(
    state_from = all_states,
    state_to = all_states
  )
  
  transition_counts_full_tbl <- full_transition_grid_tbl %>%
    dplyr::left_join(transition_counts_tbl, by = c("state_from", "state_to")) %>%
    dplyr::mutate(
      n_transitions = dplyr::coalesce(n_transitions, 0L)
    )
  
  # 3. Matrice de comptes équipe
  count_matrix_team <- transition_counts_full_tbl %>%
    tidyr::pivot_wider(
      names_from = state_to,
      values_from = n_transitions
    ) %>%
    as.data.frame()
  
  rownames(count_matrix_team) <- count_matrix_team$state_from
  count_matrix_team$state_from <- NULL
  
  count_matrix_team <- as.matrix(count_matrix_team)
  count_matrix_team <- count_matrix_team[all_states, all_states, drop = FALSE]
  
  # 4. Matrice de probabilités shrinkée
  prob_matrix <- matrix(0, nrow = length(all_states), ncol = length(all_states))
  rownames(prob_matrix) <- all_states
  colnames(prob_matrix) <- all_states
  
  # 5. Shrinkage uniquement sur les états transitoires
  team_row_sums <- rowSums(count_matrix_team[transient_states, , drop = FALSE])
  
  for (s in transient_states) {
    team_n <- team_row_sums[s]
    global_row <- transition_prob_matrix_global[s, ]
    
    prob_matrix[s, ] <- (count_matrix_team[s, ] + k * global_row) / (team_n + k)
  }
  
  # 6. États absorbants imposés
  prob_matrix[absorbing_states, ] <- 0
  diag(prob_matrix[absorbing_states, absorbing_states]) <- 1
  
  # 7. Extraire Q et R
  Q <- prob_matrix[transient_states, transient_states, drop = FALSE]
  R <- prob_matrix[transient_states, absorbing_states, drop = FALSE]
  
  # 8. Probabilités d'absorption
  N <- solve(diag(nrow(Q)) - Q)
  B <- N %*% R
  
  B_tbl <- as.data.frame(B)
  B_tbl$state_from <- rownames(B_tbl)
  B_tbl <- B_tbl %>%
    dplyr::select(state_from, Win, Draw, Loss)
  
  list(
    count_matrix_team = count_matrix_team,
    prob_matrix = prob_matrix,
    Q = Q,
    R = R,
    N = N,
    B = B,
    B_tbl = B_tbl
  )
}
k <- 3

team_markov_shrunk_corrected_list <- lapply(
  team_transitions_list,
  build_team_markov_shrunk_corrected,
  transition_prob_matrix_global = transition_prob_matrix,
  all_states = all_states,
  transient_states = transient_states,
  absorbing_states = absorbing_states,
  k = k
)
team_absorption_shrunk_corrected_tbl <- lapply(names(team_markov_shrunk_corrected_list), function(team_id_chr) {
  
  mk <- team_markov_shrunk_corrected_list[[team_id_chr]]
  
  mk$B_tbl %>%
    dplyr::mutate(team_id = as.integer(team_id_chr))
  
}) %>%
  dplyr::bind_rows() %>%
  dplyr::left_join(team_names_tbl, by = "team_id") %>%
  dplyr::select(team_id, team_name, state_from, Win, Draw, Loss)
team_absorption_shrunk_corrected_with_n_tbl <- team_absorption_shrunk_corrected_tbl %>%
  dplyr::left_join(
    team_state_counts_tbl,
    by = c("team_id", "team_name", "state_from")
  )
team_absorption_shrunk_corrected_wide_source_tbl <- team_absorption_shrunk_corrected_with_n_tbl %>%
  dplyr::mutate(
    state_clean = state_from,
    state_clean = gsub("\\(", "", state_clean),
    state_clean = gsub("\\)", "", state_clean),
    state_clean = gsub(",", "_", state_clean),
    state_clean = gsub("\\+1", "p1", state_clean),
    state_clean = gsub("\\+2", "p2", state_clean),
    state_clean = gsub("-1", "m1", state_clean),
    state_clean = gsub("-2", "m2", state_clean)
  )
markov_team_wide_shrunk_corrected_with_n_tbl <- team_absorption_shrunk_corrected_wide_source_tbl %>%
  dplyr::select(
    team_id,
    team_name,
    state_clean,
    Win,
    Draw,
    Loss,
    n_from_state
  ) %>%
  tidyr::pivot_wider(
    names_from = state_clean,
    values_from = c(Win, Draw, Loss, n_from_state),
    names_glue = "{.value}_{state_clean}"
  ) %>%
  dplyr::arrange(team_name)
compare_absorption_corrected_tbl <- team_absorption_tbl %>%
  dplyr::select(
    team_id,
    team_name,
    state_from,
    n_from_state,
    Win_raw = Win,
    Draw_raw = Draw,
    Loss_raw = Loss
  ) %>%
  dplyr::left_join(
    team_absorption_shrunk_corrected_with_n_tbl %>%
      dplyr::select(
        team_id,
        team_name,
        state_from,
        Win_shrunk = Win,
        Draw_shrunk = Draw,
        Loss_shrunk = Loss
      ),
    by = c("team_id", "team_name", "state_from")
  )
