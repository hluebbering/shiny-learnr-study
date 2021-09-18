library(shiny)
shinyApp(ui = ui, server = server)

server <- function(input, output) { 
  output$random <- reactive({
    ifelse(runif(1) > 0.5, "A", "B") })
  
  outputOptions(output, "random", suspendWhenHidden = FALSE) }

ui <- shinyUI(
  conditionalPanel(
    condition = "output.random == 'A'", 
    actionButton(
      inputId = "yes",
      label = "Yes, I agree to this study",
      icon = icon("check"),
      onclick = "window.open('http://link-to-order-A.html')"
      )))

## or

ui <- shinyUI(
  conditionalPanel(
    condition = "output.random == 'B'", 
    actionButton(
      inputId = "yes",
      label = "Yes, I agree to this study",
      icon = icon("check"),
      onclick = "window.open('http://link-to-order-B.html')"
    )))


library(rdrop2)

token <- drop_auth()
saveRDS(token, "droptoken.rds")

library(rdrop2)

# inside the shiny app
drop_auth(rdstoken = "droptoken.rds")


event_recorder <- function(tutorial_id, tutorial_version, user_id, event, data) {
  t <- readRDS(glue("data_{user_id}.rds"))
  if (drop_exists(glue("teaching-r-study/data_{user_id}.rds"))) {
    drop_download(path = glue("teaching-r-study/data_{user_id}.rds"),
                  local_path = glue("data_{user_id}.rds"),
                  overwrite = TRUE)}
  else {t <- tibble(
    time = .POSIXct(numeric(0)),
    tutorial_id = character(),
    tutorial_version = character(),
    user_id = character(),
    event = character(),
    data = list())}
  
  t <- bind_rows(t, tibble(
    time = Sys.time(),
    tutorial_id = tutorial_id,
    tutorial_version = tutorial_version,
    user_id = user_id,
    event = event,
    data = list(data)))
  
  saveRDS(t, file = glue("data_{user_id}.rds"))
  drop_upload(file = glue("data_{user_id}.rds"),
              path = "teaching-r-study")
}

question_is_correct.always_correct <- function(question, value) {
  return(mark_as(TRUE, message = NULL))
}

question("This is your question?",
         answer("This is an answer.", correct = TRUE),
         type = c("always_correct", "radio_button"),
         correct = "Submitted")
  
  