## Regression Discontinuity ----------------------------------------------------
## Kyle Butts, CU Boulder Economics

library(shiny)
library(shiny.tailwind)
library(tidyverse)
library(glue)

source("components.R")

twCheckboxInput <- function(inputId, label = NULL, value = FALSE, width = NULL,
                            disabled = FALSE,
                            container_class = NULL, label_class = NULL,
                            input_class = NULL, center = TURE) {
  container_class <- paste("form-check", container_class)
  input_class <- paste("form-check-input", input_class)
  label_class <- paste("form-check-label", label_class)

  res <- shiny::div(
    class = container_class,
    style = if (!is.null(width)) paste0("width:", width) else NULL,
    shiny::tags$input(
      type = "checkbox",
      id = inputId,
      style = if (center) "margin: 0px !important;" else NULL,
      checked = if (value) "" else NULL,
      disabled = if (disabled) "" else NULL,
      class = input_class
    ),
    shiny::tags$label(
      class = label_class, "for" = inputId,
      label
    )
  )

  return(res)
}

# Define UI for application that draws a histogram
ui <- wrapper(
  shiny.tailwind::use_tailwind(
    tailwindConfig = "tailwind.config.js",
    css = c("style.css")
  ),
  withMathJax(),
  # Header
  gradient_header("Regression Discontinuity", from = "#67b26f", to = "#4ca2cd"),
  # Intro
  div(
    class = "mt-6 prose lg:prose-lg xl:prose-xl",
    p("Much of the recent econometric literature on regression discontinuity is dedicated to how to properly estimate conditional expectation functions around the cutoff, e.g. Global vs. Local polynomials, bandwidth selection, and polynomial order. To build some intuition on these choices, play around with the RDD Estimator and take note how the estimated polynomial changes with your settings and what that implies for the estimated treatment effect.")
  ),


  # Input
  border_container(
    class = "w-full mt-12 grid grid-cols-1 md:grid-cols-3 gap-8",

		div(class="hide_grid",
			caps_header("Data Generation"),
			shiny::sliderInput(inputId = "sample_size", min=50, max=3500, value = 500, label="Sample Size"),
			shiny::sliderInput(inputId = "noise", min=0, max=0.25, value = 0.03, step = 0.01, label="Noise")
		),
    div(
      caps_header("Polynomial"),
      div(
      	tags$label("for" = "polynomial_order", class = "block mb-2 text-sm font-medium text-gray-900", "Polynomial Order"),
      	tags$input(type = "number", id = "polynomial_order", class = "bg-[#e6f8ff] border border-[#00b7ff]  text-sm rounded-lg  focus:ring-[#00b7ff] focus:ring-2 block ", min = 0, max = 5, value = 1, step = 1)
    	),
      div(
      	twCheckboxInput(
      		"global_polynomial",
      		label = "Use global polynomial", value = TRUE,
      		container_class = "flex items-center mt-4",
      		label_class = "ml-2 text-sm font-medium text-gray-900",
      		input_class = "w-4 h-4 bg-gray-100 rounded border-gray-300 focus:ring-[#00b7ff] text-[#00b7ff] focus:ring-2",
      		center = TRUE
      	)
      )
    ),

    div(
    	caps_header("Bandwidth Selection"),
    	div(class="slider-wrapper hide_grid",
    		shiny::sliderInput(inputId = "bw", min=0.05, max=1, value = 0.3, step=0.02, label="Bandwidth Selector")
    	)
    )
  ),

  # RD Estimate
  border_container(
  	class="mt-12",
    caps_header("RDD Estimator"),
    plotOutput("rd_estimate")
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  # RD Generation
  cond_expec <- function(R) {
		return(
			ifelse(R > 0,
						 # Wolfram Alpha: polynomial through points {(0, 0.3), (0.3, 0.4), (0.5, 0.1), (0.8, 0.2), (1, 0.3)}
						 0.3 + 4.47976*R - 22.0036*R^2 + 31.4524*R^3 - 13.9286*R^4,
						 # Wolfram Alpha: polynomial through points {(-1, 0.2), (-0.6, 0.4), (-0.3, 0), (0, 0.1)}
						 0.1 + 2.1381*R + 7.63492*R^2 + 5.39683*R^3
			)
		)
  }

  generate_data <- function(N, sd) {
    df <- tibble(
      i = 1:N,
      # Running variable
      R = runif(N, -1, 1),
      treat = (R > 0)
    )

    df = df |>
    	mutate(
				cond_exp = cond_expec(R),
				eps = rnorm(n(), 0, sd),
				y = cond_exp + eps
    	)
    return(df)
  }

  df <- reactiveVal(NULL)

  observeEvent(input$sample_size, {
  	df(generate_data(input$sample_size, input$noise))
  })
  observeEvent(input$noise, {
  	df(generate_data(input$sample_size, input$noise))
  })

  output$rd_estimate <- renderPlot({

  	# Estimate RD
  	temp_df <- df()


  	if(input$global_polynomial) {
			bw = 1
  	} else {
  		bw = input$bw
  	}

  	subset = temp_df |> filter(abs(R) <= bw)

  	if(input$polynomial_order == 0) {
  		est <- fixest::feols(
  			y ~ i(treat),
  			data = subset
			)
  	} else if(input$polynomial_order == 1) {
			est <- fixest::feols(
				y ~ i(treat) + i(treat, R),
				data = subset
			)
  	} else if(input$polynomial_order == 2) {
  		est <- fixest::feols(
  			y ~ i(treat) + i(treat, R) + i(treat, R^2),
  			data = subset
			)
  	} else if(input$polynomial_order == 3) {
  		est <- fixest::feols(
  			y ~ i(treat) + i(treat, R) + i(treat, R^2) + i(treat, R^3),
  			data = subset
			)
  	} else if(input$polynomial_order == 4) {
  		est <- fixest::feols(
  			y ~ i(treat) + i(treat, R) + i(treat, R^2) + i(treat, R^3) + i(treat, R^4) ,
  			data = subset
			)
  	} else {
  		est <- fixest::feols(
  			y ~ i(treat) + i(treat, R) + i(treat, R^2) + i(treat, R^3) + i(treat, R^4) + i(treat, R^5),
  			data = subset
			)
  	}

		predict_df <- tibble(
			R = seq(-1, 1, 0.01),
			treat = (R >= 0)
		)

		predict_df$yhat <- predict(est, newdata = predict_df)
		predict_df$ytrue <- cond_expec(predict_df$R)

  	# Plot
		ggplot() +
			geom_line(data = predict_df |> filter(R < 0), aes(x = R, y = ytrue), color = "#cccccc", size = 1.6) +
			geom_line(data = predict_df |> filter(R > 0), aes(x = R, y = ytrue), color = "#cccccc", size = 1.6) +
			geom_point(data = temp_df |> filter(abs(R) > bw), aes(x = R, y = y), color = "#e5e7eb") +
			geom_point(data = temp_df |> filter(abs(R) <= bw), aes(x = R, y = y), color = "#111827") +
			geom_line(data = predict_df |> filter(R < 0) |> filter(abs(R) <= bw), aes(x = R, y = yhat), color = "#00b7ff", size = 1.6) +
			geom_line(data = predict_df |> filter(R > 0) |> filter(abs(R) <= bw), aes(x = R, y = yhat), color = "#00b7ff", size = 1.6) +
  		# geom_vline(xintercept = 0, color = "#00b7ff", size = 1.2) +
  		labs(x = "Running Variable", y = "Conditional Expectation of Y") +
  		theme_bw(base_size = 16)
  })

}

# Run the application
shinyApp(ui = ui, server = server)
