# Load necessary libraries
library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(DT)
library(stringr)
library(shinyjs)

# Loading dataset
cohort_data <- read.csv("cohort_performance.csv",
                        stringsAsFactors = FALSE, check.names = FALSE)

# Cleaning column names
colnames(cohort_data) <- gsub("\\.+$", "", colnames(cohort_data))

# Converting relevant columns to numeric
cohort_data$Attendance <-
  as.numeric(gsub("[^0-9.]", "", cohort_data$Attendance))
cohort_data$Project_Completion <-
  as.numeric(gsub("[^0-9.]", "",
                  cohort_data$Project_Completion))
cohort_data$Test_Score <-
  as.numeric(gsub("[^0-9.]", "",
                  cohort_data$Test_Score))

# Converting Month to ordered factor
cohort_data$Month <-
  factor(cohort_data$Month, levels = month.name, ordered = TRUE)

# ----------------- UI -----------------
ui <- dashboardPage(
  dashboardHeader(title = "Cohort Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard Overview", 
               tabName = "overview", icon = icon("chart-line")),
      menuItem("Cohort Performance Trends",
               tabName = "cohort_trends", icon = icon("chart-bar")),
      menuItem("Detailed Student Reports",
               tabName = "reports", icon = icon("user-graduate")),
      menuItem("Export Filtered Data",
               tabName = "download", icon = icon("download"))
    ),
    selectInput("selected_cohort", "Choose Cohort:",
                choices = c("All", unique(cohort_data$Cohort))),
    selectInput("selected_month", "Choose Month:",
                choices = c("All", month.name))
  ),
  dashboardBody(
    tabItems(
      # Overview Page
      tabItem(tabName = "overview",
        fluidRow(
          valueBoxOutput("avg_attendance_box", width = 3),
          valueBoxOutput("avg_score_box", width = 3),
          valueBoxOutput("total_students_box", width = 3),
          valueBoxOutput("pass_rate_box", width = 3)
        ),
        fluidRow(
          box(title = "Overall Attendance Trends", 
              status = "primary", solidHeader = TRUE,
              plotlyOutput("attendance_plot"), width = 6),
          box(title = "Final Grade Distribution",
              status = "primary", solidHeader = TRUE, 
              plotlyOutput("grade_distribution"), width = 6)
        )
      ),
      # Cohort Trends Page
      tabItem(tabName = "cohort_trends",
        fluidRow(
          valueBoxOutput("avg_attendance_box_cohort", width = 3),
          valueBoxOutput("avg_score_box_cohort", width = 3),
          valueBoxOutput("total_students_box_cohort", width = 3),
          valueBoxOutput("pass_rate_box_cohort", width = 3)
        ),
        fluidRow(
          box(title = "Cohort Attendance Trends", 
              status = "info", solidHeader = TRUE, 
              plotlyOutput("cohort_attendance_plot"), width = 6),
          box(title = "Test Score Trends", 
              status = "info", solidHeader = TRUE, 
              plotlyOutput("cohort_test_plot"), width = 6)
        )
      ),
      # Student Reports
      tabItem(tabName = "reports",
        fluidRow(
          box(title = "Students Performance Record", 
              status = "primary", solidHeader = TRUE, 
              DTOutput("student_table"), width = 12)
        )
      ),
      # Download
      tabItem(tabName = "download",
        fluidRow(
          box(title = "Download Data", 
              status = "primary", solidHeader = TRUE, 
              downloadButton("download_data", "Download CSV"), width = 6)
        )
      )
    )
  )
)

# ----------------- SERVER -----------------
server <- function(input, output, session) {
  # Update dropdowns dynamically
  observe({
    updateSelectInput(session, "selected_cohort", 
                      choices = c("All", unique(cohort_data$Cohort)))
    updateSelectInput(session, "selected_month", 
                      choices = c("All", month.name))
  })
  # Filtered dataset
  filtered_data <- reactive({
    data <- cohort_data
    if (input$selected_cohort != "All") data <-
      data %>% filter(Cohort == input$selected_cohort)
    if (input$selected_month != "All") data <-
      data %>% filter(as.character(Month) == input$selected_month)
    return(data)
  })
  # Aggregated data for plots
  aggregated_data <- reactive({
    filtered_data() %>%
      group_by(Month, Cohort) %>%
      summarise(
        Avg_Attendance = mean(Attendance, na.rm = TRUE),
        Avg_Test_Score = mean(Test_Score, na.rm = TRUE),
        .groups = "drop"
      )
  })
  # ----------------- PLOTS -----------------
  output$attendance_plot <- renderPlotly({
    ggplotly(
      ggplot(aggregated_data(), aes(x = Month, 
                                    y = Avg_Attendance, 
                                    group = Cohort, color = Cohort)) +
        geom_line(size = 1.2) + geom_point(size = 3) +
        labs(title = "Average Monthly Attendance", 
             x = "Month", y = "Average Attendance (%)") +
        theme_minimal()
    )
  })
  output$grade_distribution <- renderPlotly({
    ggplotly(
      ggplot(filtered_data(), aes(x = Final_Grade, fill = Cohort)) +
        geom_bar() +
        labs(title = "Final Grade Distribution", 
             x = "Final Grade", y = "Count") +
        theme_minimal()
    )
  })
  output$cohort_attendance_plot <- renderPlotly({
    ggplotly(
      ggplot(aggregated_data(), aes(x = Month, y = Avg_Attendance, 
                                    group = Cohort, color = Cohort)) +
        geom_line(size = 1.2) + geom_point(size = 3) +
        labs(title = "Cohort Attendance Trends", 
             x = "Month", y = "Average Attendance (%)") +
        theme_minimal()
    )
  })
  output$cohort_test_plot <- renderPlotly({
    ggplotly(
      ggplot(aggregated_data(), aes(x = Month, y = Avg_Test_Score, 
                                    group = Cohort, color = Cohort)) +
        geom_line(size = 1.2) + geom_point(size = 3) +
        labs(title = "Cohort Test Score Trends", 
             x = "Month", y = "Average Test Score") +
        theme_minimal()
    )
  })
  # ----------------- STUDENT TABLE -----------------
  output$student_table <- renderDT({
    datatable(filtered_data(), 
              options = list(pageLength = 10, autoWidth = TRUE)) %>%
      formatStyle('Test_Score', 
              backgroundColor = styleInterval(c(50,70), c('red','yellow','green'))) %>%
      formatStyle('Final_Grade', 
              color = styleEqual(c('A','B','C','D','F'), c('green','green','yellow','orange','red')))
  })
  # ----------------- DOWNLOAD -----------------
  output$download_data <- downloadHandler(
    filename = function() { paste0("Cohort_Performance_", Sys.Date(), ".csv") },
    content = function(file) 
    { write.csv(filtered_data(), file, row.names = FALSE) }
  )
  # ----------------- VALUE BOXES OVERVIEW -----------------
  output$avg_attendance_box <- renderValueBox({
    valueBox(round(mean(filtered_data()$Attendance, na.rm = TRUE),1), 
             "Average Attendance (%)", icon = icon("users"), color = "blue")
  })
  output$avg_score_box <- renderValueBox({
    valueBox(round(mean(filtered_data()$Test_Score, na.rm = TRUE),1), 
             "Average Test Score", icon = icon("chart-line"), color = "green")
  })
  output$total_students_box <- renderValueBox({
    valueBox(nrow(filtered_data()), "Total Records", 
             icon = icon("database"), color = "yellow")
  })
  output$pass_rate_box <- renderValueBox({
    pass_rate <- mean(filtered_data()$Final_Grade %in% c("A","B","C"))*100
    valueBox(paste0(round(pass_rate,1), "%"), "Pass Rate", 
             icon = icon("check-circle"), color = "purple")
  })
  # ----------------- VALUE BOXES COHORT TRENDS -----------------
  output$avg_attendance_box_cohort <- renderValueBox({
    valueBox(round(mean(filtered_data()$Attendance, na.rm = TRUE),1), 
             "Average Attendance (%)", icon = icon("users"), color = "blue")
  })
  output$avg_score_box_cohort <- renderValueBox({
    valueBox(round(mean(filtered_data()$Test_Score, na.rm = TRUE),1), 
             "Average Test Score", icon = icon("chart-line"), color = "green")
  })
  output$total_students_box_cohort <- renderValueBox({
    valueBox(nrow(filtered_data()), "Total Records", 
             icon = icon("database"), color = "yellow")
  })
  output$pass_rate_box_cohort <- renderValueBox({
    pass_rate <- mean(filtered_data()$Final_Grade %in% c("A","B","C"))*100
    valueBox(paste0(round(pass_rate,1), "%"), "Pass Rate", 
             icon = icon("check-circle"), color = "purple")
  })
}

# ----------------- RUN APP -----------------
shinyApp(ui, server)