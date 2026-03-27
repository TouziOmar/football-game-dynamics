transient_states <- c(
  "(-2,T1)", "(-1,T1)", "(0,T1)", "(+1,T1)", "(+2,T1)",
  "(-2,T2)", "(-1,T2)", "(0,T2)", "(+1,T2)", "(+2,T2)",
  "(-2,T3)", "(-1,T3)", "(0,T3)", "(+1,T3)", "(+2,T3)",
  "(-2,T4)", "(-1,T4)", "(0,T4)", "(+1,T4)", "(+2,T4)"
)

absorbing_states <- c("Win", "Draw", "Loss")

all_states <- c(transient_states, absorbing_states)

transition_counts_tbl <- transitions_final_tbl %>%
  count(state_from, state_to, name = "n_transitions")

full_transition_grid_tbl <- tidyr::expand_grid(
  state_from = all_states,
  state_to = all_states
)

transition_counts_full_tbl <- full_transition_grid_tbl %>%
  left_join(transition_counts_tbl, by = c("state_from", "state_to")) %>%
  mutate(
    n_transitions = dplyr::coalesce(n_transitions, 0L)
  )
transition_count_matrix <- transition_counts_full_tbl %>%
  tidyr::pivot_wider(
    names_from = state_to,
    values_from = n_transitions
  ) %>%
  as.data.frame()

rownames(transition_count_matrix) <- transition_count_matrix$state_from
transition_count_matrix$state_from <- NULL

transition_count_matrix <- as.matrix(transition_count_matrix)
transition_count_matrix <- transition_count_matrix[all_states, all_states]


transition_prob_matrix <- transition_count_matrix
transient_row_sums <- rowSums(transition_prob_matrix[transient_states, , drop = FALSE])

transition_prob_matrix[transient_states, ] <- transition_prob_matrix[transient_states, , drop = FALSE] / transient_row_sums
transition_prob_matrix[absorbing_states, ] <- 0
diag(transition_prob_matrix[absorbing_states, absorbing_states]) <- 1





Q_global <- transition_prob_matrix[transient_states, transient_states]
R_global <- transition_prob_matrix[transient_states, absorbing_states]

I20 <- diag(nrow(Q_global))
N_global <- solve(I20 - Q_global)
B_global <- N_global %*% R_global

B_global_tbl <- as.data.frame(B_global)
B_global_tbl$state_from <- rownames(B_global_tbl)

B_global_tbl <- B_global_tbl %>%
  dplyr::select(state_from, Win, Draw, Loss)


B_global_tbl %>%
  mutate(row_sum = Win + Draw + Loss) %>%
  summarise(
    min_sum = min(row_sum),
    max_sum = max(row_sum)
  )
B_global_tbl %>%
  filter(state_from %in% c("(-1,T2)", "(-1,T3)", "(-1,T4)", "(0,T4)", "(+1,T4)"))