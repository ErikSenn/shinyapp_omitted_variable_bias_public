# app.R
# Shiny app with 3D plot functionality
# This can be adapted for visualizing omitted variable bias

### TODO: Deploy app successfully


library(shiny)
library(plotly)
library(dplyr)
library(markdown)

# UI definition
ui <- fluidPage(
  withMathJax(),
  titlePanel("Omitted Variable Bias Visualization in 3D"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3, # 3/12, default 4/14, 12 columns in total.
      # Input parameters for the 3D plot
      h3("Plot Controls"),
      
      # # X variable
      # selectInput("x_var", "X Variable:",
      #             choices = c("Treatment" = "treatment",
      #                         "Confounder" = "confounder"),
      #             selected = "treatment"),
      # 
      # # Y variable
      # selectInput("y_var", "Y Variable:",
      #             choices = c("Outcome" = "outcome",
      #                         "Confounder" = "confounder"),
      #             selected = "confounder"),
      # 
      # # Z variable
      # selectInput("z_var", "Z Variable:",
      #             choices = c("Outcome" = "outcome",
      #                         "Treatment" = "treatment",
      #                         "Confounder" = "confounder"),
      #             selected = "outcome"),
      
      # Function settings
      h4("Function Parameters"),
      numericInput("beta_0", "Intercept (β₀):", 0),
      numericInput("beta_1", "Treatment Effect (β₁):",1),
      numericInput("beta_2", "Confounder Effect (β₂):",0.5),
      numericInput("corr_xz", "Correlation (X,Z):", 0.7, min=-1, max=1, step=0.1),
      numericInput("sigma_u", "Error Standard Deviation (σᵤ):", 0.01, min=0, max=1, step=0.01),
      
      # Visual settings
      h4("Visual Settings"),
      checkboxInput("show_true_plane", "Show True Model Plane", TRUE),
      checkboxInput("show_biased_plane", "Show Underspecified Model Plane", TRUE),
      checkboxInput("show_data", "Show Data Points", TRUE),
      
      # Sample size slider
      sliderInput("n_points", "Number of Data Points:", 
                  min = 50, max = 500, value = 200, step = 50)
    ),
    
    mainPanel(
      plotlyOutput("plot_3d", height = "500px"),
      
      tabsetPanel(
        tabPanel("Explanation", 
                 includeMarkdown("explanation.md")),
        tabPanel("Estimated Models ", 
                 verbatimTextOutput("model_summary")),
        tabPanel("Notes", 
                 h4("Shiny app - omitted variable bias visualization in 3D"),
                 p(
                   "Created for Econometrics Teaching at University of St. Gallen ",
                   a("by Erik Senn", href = "https://eriksenn.github.io/", target = "_blank")
                 ),
                 tags$br(),
                 a("Original Source and Idea from: Wolfram Demonstration by Timur Gareev (2018)", 
                   href = "https://demonstrations.wolfram.com/OmittedVariableBiasIn3D/", target = "_blank"),
                 p("License: CC BY-NC-SA"),
                 p("Developed with the help of generative AI."),
                 p("If you have any difficulties in usage or ideas for improvement, please contact me under erik.senn[at]gmx[dot]de.")
        )
      )
    )
  )
)

# Server logic
server <- function(input, output, session) {
  
  # Generate data based on inputs
  generate_data <- reactive({
    # Set seed for reproducibility within the session
    set.seed(123)
    
    # Number of points
    n <- input$n_points
    
    # Generate confounder Z
    z <- rnorm(n, mean = 0, sd = 1)
    
    # Generate treatment X with correlation to Z
    x <- input$corr_xz * z + sqrt(1 - input$corr_xz^2) * rnorm(n)
    
    # Generate outcome Y based on true model
    y_true <- input$beta_0 + input$beta_1 * x + input$beta_2 * z + rnorm(n, sd = input$sigma_u)
    
    # Create dataframe
    data.frame(
      x = x,
      z = z,
      y = y_true
    )
  })
  
  # Compute models
  compute_models <- reactive({
    data <- generate_data()
    
    # True model (with confounder)
    true_model <- lm(y ~ x + z, data = data)
    
    # Biased model (without confounder)
    biased_model <- lm(y ~ x, data = data)
    
    list(
      true_model = true_model,
      biased_model = biased_model,
      data = data
    )
  })
  
  # 3D Plot
  output$plot_3d <- renderPlotly({
    models <- compute_models()
    data <- models$data
    
    # Create basic 3D scatter plot
    p <- plot_ly(type = 'scatter3d') %>%
      layout(
        scene = list(
          xaxis = list(title = "Treatment (X)"), # input$x_var
          yaxis = list(title = "Confounder (Z)"), # input$y_var
          zaxis = list(title = "Outcome (Y)") # input$z_var
          # Set the camera position
          # camera = current_camera
        ),
        title = "" #Comparison of True vs. Biased Models"
      )
    
    # Add data points if selected
    if (input$show_data) {
      p <- p %>% add_trace(
        data = data,
        x = ~x, y = ~z, z = ~y,
        mode = 'markers',
        marker = list(size = 3, opacity = 0.6),
        name = 'Data Points'
      )
    }
    p
    
    # Create grid for planes
    grid_size <- 20
    x_range <- range(data$x)
    z_range <- range(data$z)
    x_grid <- seq(x_range[1], x_range[2], length.out = grid_size)
    z_grid <- seq(z_range[1], z_range[2], length.out = grid_size)
    grid <- expand.grid(x = x_grid, z = z_grid)
    
    # True model plane
    if (input$show_true_plane) {
      grid$y_true <- predict(models$true_model, newdata = grid)
      # grid$y_true <- with(grid, input$beta_0 + input$beta_1 * z + input$beta_2 * x)
      
      # p <- p %>% add_surface(
      #   x = x_grid,
      #   z = z_grid,
      #   y = matrix(grid$y_true, nrow = grid_size, ncol = grid_size),
      #   opacity = 0.7,
      #   colorscale = list(c(0, 1), c("blue", "lightblue")),
      #   name = "True Model"
      # )
      # Ensure grid$y_true is reshaped into a matrix
      grid_matrix <- t(matrix(grid$y_true, nrow = grid_size, ncol = grid_size))
      
      p <- p %>% add_surface(
         x = x_grid,  # X remains the same (treatment)
         y = z_grid,  # Y remains the same (confounder)
         z = grid_matrix,  # Correct: Y (Outcome) should be the matrix for surface plotting
        opacity = 0.7,
        colorscale = list(c(0, 1), c("blue", "lightblue")),
        name = "True Model",
        colorbar = list(title = "Y - true model")  
      )
      
    }
    
    # Biased model plane
    if (input$show_biased_plane) {
      grid <- expand.grid(x = x_grid, z = z_grid)
      grid$y_biased <- predict(models$biased_model, newdata = grid[, "x", drop = FALSE])
      grid_matrix <- t(matrix(grid$y_biased, nrow = grid_size, ncol = grid_size))
      
      p <- p %>% add_surface(
         x = x_grid,
         y = z_grid,
         z = grid_matrix,
        opacity = 0.7,
        colorscale = list(c(0, 1), c("red", "pink")),
        name = "Biased Model",
        colorbar = list(title = "Y - underspecified model")  
      )
    }
    

    
    p
    
    # Add an event to capture camera changes
    # p <- p %>% onRender("
    #   function(el, x) {
    #     var gd = document.getElementById(el.id);
    #     gd.on('plotly_relayout', function(d) {
    #       if (d['scene.camera']) {
    #         Shiny.setInputValue('camera_change', {
    #           eye: d['scene.camera'].eye,
    #           center: d['scene.camera'].center,
    #           up: d['scene.camera'].up
    #         });
    #       }
    #     });
    #   }
    # ")
    
  })
  
  # Model summary output
  output$model_summary <- renderPrint({
    models <- compute_models()
    
    cat("True Model (includes confounder):\n")
    print(summary(models$true_model))
    
    cat("\nUnderspecified Model (omits confounder):\n")
    print(summary(models$biased_model))
    
    cat("\nBias Analysis:\n")
    cat("True model: X coefficient:", round(coef(models$true_model)["x"], 4), "\n")
    cat("Underspecified model: X coefficient:", round(coef(models$biased_model)["x"], 4), "\n")
    cat("Difference (Bias 'in sample'):", round(coef(models$biased_model)["x"] - coef(models$true_model)["x"], 4), "\n")
  })
}



# Run the application
shinyApp(ui = ui, server = server)

# deploy to shinyapps.io
# library(rsconnect)
# rsconnect::deployApp() # or button 'publish' on running app.
