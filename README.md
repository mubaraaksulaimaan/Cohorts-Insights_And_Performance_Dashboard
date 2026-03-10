# Cohort Insights and Performance Dashboard
An interactive **R Shiny dashboard** to monitor internship cohort performance, visualize trends, and generate insights for student attendance, test scores, project completion, and final grades.

📌 **Internship Cohort Dashboard**  
A web-based R Shiny application built to track and visualize performance trends across multiple cohorts and months. It simplifies monitoring, reporting, and analysis for internship programs, providing actionable insights with an interactive interface.

## 🚀 Features
✅ **Dynamic Value Boxes** – Average Attendance, Average Test Score, Total Students, Pass Rate  

✅ **Trend Visualizations** – Monthly attendance trends, Test score trends, Cohort comparisons  

✅ **Interactive Student Table** – Filterable and searchable, displays all records  

✅ **Dynamic Filtering** – Filter by Cohort and Month  

✅ **Download Data** – Export filtered dataset as CSV  

✅ **Responsive and Intuitive UI** – Built with ShinyDashboard  

## 🛠️ Tech Stack

| Technology | Description |
|------------|-------------|
| **R** | Core programming and data processing |
| **Shiny & ShinyDashboard** | Interactive UI and dashboard |
| **ggplot2** | Charts and visualizations |
| **dplyr / tidyr** | Data cleaning and manipulation |
| **DT** | Interactive tables |
| **openxlsx / writexl** | Data export to Excel |
| **shinyjs** | Enhanced interactivity |

## 📁 Project Structure
📁 cohort_insights_dashboard/
├── 📄 app.R → Main Shiny app
├── 📄 Cohort_Performance.csv → Dataset CSV File
├── 📄 README.md → Project documentation

## ⚙️ Setup Instructions

1. Clone or download the repository:
```bash
git clone https://github.com/your-username/cohort-insights-dashboard.git

2.
Install required R packages (if not already installed):

install.packages(c("shiny", "shinydashboard", "dplyr", "tidyr", "readr", 
                   "ggplot2", "plotly", "DT", "stringr", "openxlsx", "writexl", "shinyjs"))

3.

Place the dataset Cohort_Performance_.csv inside the main file

4.

Launch the dashboard:

shiny::runApp()

5.
Use the sidebar filters to select Cohort and Month to explore metrics and trends.

📊 Sample Insights

Average attendance and test scores per month per cohort

Pass rate per cohort

Cohort comparison trends over time

Filterable, searchable, and downloadable student records

📤 Export Data

Filtered datasets can be exported as CSV via the Download Data tab.

🔮 Future Improvements

Add heatmaps for monthly attendance

Enhanced cohort comparison charts

Real-time integration with SQL or Excel for larger datasets

Deployment on ShinyApps.io or internal server