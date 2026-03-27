team_transition_prob_tbl <- lapply(names(team_markov_list), function(team_id_chr) {
  
  mk <- team_markov_list[[team_id_chr]]
  
  prob_mat <- mk$prob_matrix
  
  prob_df <- as.data.frame(as.table(prob_mat), stringsAsFactors = FALSE)
  colnames(prob_df) <- c("state_from", "state_to", "prob")
  
  prob_df %>%
    mutate(team_id = as.integer(team_id_chr))
  
}) %>%
  bind_rows() %>%
  left_join(team_names_tbl, by = "team_id") %>%
  select(team_id, team_name, state_from, state_to, prob)
dim(team_transition_prob_tbl)
team_state_counts_tbl <- transitions_final_tbl %>%
  count(team_id, team_name, state_from, name = "n_from_state")
team_absorption_tbl <- team_absorption_tbl %>%
  left_join(
    team_state_counts_tbl,
    by = c("team_id", "team_name", "state_from")
  )
team_absorption_tbl %>%
  filter(state_from == "(+1,T4)") %>%
  arrange(desc(Win)) %>%
  select(team_name, state_from, n_from_state, Win, Draw, Loss)
team_absorption_tbl %>%
  filter(state_from == "(-1,T4)") %>%
  mutate(avoid_loss = Win + Draw) %>%
  arrange(desc(avoid_loss)) %>%
  select(team_name, state_from, n_from_state, Win, Draw, Loss, avoid_loss)