## Randomization Inference -----------------------------------------------------
## Kyle Butts, CU Boulder Economics

library(shiny)
library(shiny.tailwind)
library(ggplot2)
library(glue)

source("components.R")


person_card <- function(treated = FALSE, selected = FALSE, i = 0, y = 10) {
  svg_person <- tags$svg(xmlns = "http://www.w3.org/2000/svg", "aria-hidden" = "true", role = "img", class = "w-16 h-16", preserveAspectRatio = "xMidYMid meet", viewBox = "0 0 48 48", tags$path(fill = "currentColor", d = "M20.002 10.5a4 4 0 0 0 2.226 3.586l.492.179a3.75 3.75 0 0 0 2.566 0l.491-.179a4 4 0 1 0-5.775-3.586Zm-2.194 1.977A6.5 6.5 0 0 1 24.003 4a6.5 6.5 0 0 1 6.194 8.477l6.1-2.22a4.25 4.25 0 0 1 2.908 7.988l-8.201 2.985v4.796c0 .353.067.703.2 1.03L35.69 38.16a4.25 4.25 0 1 1-7.882 3.185l-3.807-9.422l-3.807 9.421a4.25 4.25 0 0 1-7.882-3.184l4.49-11.112c.132-.327.2-.677.2-1.03V21.23L8.8 18.245a4.25 4.25 0 1 1 2.907-7.987l6.1 2.22Zm3.444 3.914l-10.399-3.784a1.75 1.75 0 0 0-1.197 3.289l8.365 3.044a2.25 2.25 0 0 1 1.481 2.114v4.964c0 .674-.13 1.342-.382 1.967l-4.49 11.112a1.75 1.75 0 1 0 3.245 1.311l4.04-9.995c.758-1.877 3.414-1.877 4.172 0l4.04 9.995a1.75 1.75 0 0 0 3.245-1.311l-4.487-11.105a5.25 5.25 0 0 1-.382-1.966v-4.972c0-.945.592-1.79 1.481-2.114l8.365-3.044a1.75 1.75 0 1 0-1.197-3.29l-10.398 3.785a6.477 6.477 0 0 1-2.751.609a6.477 6.477 0 0 1-2.751-.609Z"))

  if (treated) {
    label <- p(class = "text-[#00b7ff] text-center text-sm", paste0("Treated"))
  } else {
    label <- p(class = "text-gray-600 text-center text-sm", i)
  }

  if (selected) {
    highlight <- "border-[#00b7ff]"
  } else {
    highlight <- "border-gray-200"
  }

  div(
		class = paste("p-2 bg-white rounded-lg border-2 flex flex-col items-center max-w-sm shadow-md hover:bg-gray-100", highlight),
    label,
    svg_person,
    p(class = "mt-2 text-italic", paste0("Y = ", y, ""))
  )
}

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
  	css = "style.css",
    tailwindConfig = "tailwind.config.js"
  ),
  withMathJax(),
  # Header
  gradient_header("Randomization Inference", from = "#67b26f", to = "#4ca2cd"),
  # Intro
  div(
    class = "mt-6 prose lg:prose-lg xl:prose-xl",
    p("Below, we see the 30 participants in our study. Among them, we select two individuals to treat (labeled treated below). We have generated the data to potentially have a treatment effect (depending on the checkbox below) and want to run randomization inference on our treatment effect."),
    uiOutput("estimate")
  ),

  # Cards
  uiOutput("cards"),

  # Input
  border_container(
    class = "w-full mt-12 grid grid-cols-1 md:grid-cols-2 gap-4",
    div(
      caps_header("Data Generating Process"),
      twCheckboxInput(
        "true_te",
        label = "If checked, ATT = 1. Otherwise, ATT = 0.", value = TRUE,
        container_class = "not-prose flex items-center mb-4",
        label_class = "ml-2 text-sm font-medium text-gray-900",
        input_class = "w-4 h-4 bg-gray-100 rounded border-gray-300 focus:ring-[#00b7ff] text-[#00b7ff] focus:ring-2",
        center = TRUE
      )
    ),


    div(
      caps_header("Randomization Inference"),
      # shiny::actionButton
      div(
        class = "flex flex-col gap-y-4",
        tags$button(id = "shuffle", type = "button", class = "action-button inline-block border-2 border-[#00b7ff] py-1 px-2 rounded-md bg-[#e6f8ff] text-[#006e99]", "1 Shuffle of Randomization Inference"),
        tags$button(id = "shuffle100", type = "button", class = "action-button inline-block border-2 border-[#00b7ff] py-1 px-2 rounded-md bg-[#e6f8ff] text-[#006e99]", "100 Shuffles of Randomization Inference")
      )
    )
  ),

  # Randomization Summary
  div(
    class = "mt-12 prose lg:prose-lg",
    p("Each time we click the reshuffle button, we will randomly assign the 'treated' label to two individuals. Then, we will calculate the estimated 'placebo treatment effect' for those two individuals. That estimate is going to be added to the histogram displayed below.")
  ),

  border_container(
  	class="mt-12",
    caps_header("Distribution of Estimated Treatment Effects"),
    uiOutput("pval"),
    plotOutput("ri_hist")
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  # People
  generate_data <- function() {
    df <- data.frame(
      i = 1:30,
      treated = c(TRUE, TRUE, rep(FALSE, 28)),
      selected = c(TRUE, TRUE, rep(FALSE, 28))
    )
    df$eps <- 10 + rnorm(nrow(df), 0, 0.3)
    df$y <- df$eps
    return(df)
  }

  temp <- generate_data()
  obs_te <- mean(temp[temp$treated == TRUE, ]$y) - mean(temp[temp$treated == FALSE, ]$y)

  df <- reactiveVal(temp)
  ri_data <- reactiveVal(data.frame(i = 0, te_hat = 0))
  obs_tehat <- reactiveVal(0)
  curr_tehat <- reactiveVal(0)
  pvalue <- reactiveVal(0)

  resetPlot <- function() {
    # update `df` based on `input$true_te`
    temp_df <- df()
    temp_df$y <- temp_df$eps + input$true_te * 1 * temp_df$treated
    temp_df$selected <- temp_df$treated
    df(temp_df)

    # Reset `obs_tehat`
    obs_te <- mean(temp_df[temp_df$treated == TRUE, ]$y) - mean(temp_df[temp_df$treated == FALSE, ]$y)
    obs_tehat(obs_te)

    # Reset `ri_data`
    temp <- ri_data()
    temp[temp$i == 0, ]$te_hat <- obs_te
    ri_data(temp[temp$i == 0, ])

    # reset `pval`
    calculate_pvalue()
  }

  # Reset everything when `true_te` checkbox toggled
  # Note: also runs at the start
  observeEvent(input$true_te, {
    resetPlot()
  })

  output$estimate <- renderUI({
    if (nrow(ri_data()) == 1) {
      curr_tehat_text <- ""
    } else {
      curr_tehat_text <- glue(" Currently, the estimated 'placebo effect' is {round(curr_tehat(), 2)}.")
    }
		list(
			p(glue("The estimated treatment effect is {round(obs_tehat(), 2)}. We want to test if this is significantly different from zero. To do so, we will reshuffle treatment labels to other units and estimate placebo treatment effects for them. Each time you click on 'Reshuffle', notice how the blue denoting treatment 'labels' is shuffled around.{curr_tehat_text}")),
			p("")
		)
  })

  output$cards <- renderUI({
    div(
      class = "flex flex-wrap mt-8 gap-4 justify-evenly",
      # Cards
      lapply(1:nrow(df()), \(i) {
        row <- df()[i, ]
        person_card(
          i = row$i,
          y = round(row$y, 2),
          treated = row$treated,
          selected = row$selected
        )
      })
    )
  })

  output$pval <- renderUI({
    pval <- pvalue()

    if (nrow(ri_data()) == 1) {
      return(
        p(class = "my-4", glue::glue("Our estimated treatment effect is {round(obs_tehat(), 2)}. Simulate random shuffles to estimate a p-value."))
      )
    } else {
      p(class = "my-4", glue::glue("Our estimated treatment effect is {round(obs_tehat(), 2)}. The estimated p-value is {round(pvalue(), 3)}."))
    }
  })

  output$ri_hist <- renderPlot({
    # Get data
    temp <- ri_data()

    obs_te <- temp[temp$i == 0, ]
    temp <- temp[temp$i != 0, ]

    ggplot() +
      geom_histogram(data = temp, aes(x = te_hat)) +
      geom_vline(xintercept = obs_te$te_hat, color = "#00b7ff", size = 1.6) +
    	labs(x = "Estimated Placebo Effects") +
      theme_bw(base_size = 16)
  })

  # 1 shuffle
  shuffle_treatment <- function() {
    temp <- df()
    temp$selected <- sample(temp$selected)
    df(temp)
  }
  estimate_te <- function() {
  	temp_df <- df()
    te_hat <- mean(temp_df[temp_df$selected == TRUE, ]$y) - mean(temp_df[temp_df$selected == FALSE, ]$y)

    curr_tehat(te_hat)

    # Store estimate
    temp <- rbind(
      ri_data(),
      data.frame(i = nrow(ri_data()) + 1, te_hat = te_hat)
    )
    ri_data(temp)
  }
  calculate_pvalue <- function() {
    temp <- ri_data()
    # observed te
    obs_te <- abs(temp[temp$i == 0, ]$te_hat)

    # ri distribution of te
    temp <- abs(temp[temp$i != 0, ]$te_hat)

    p_val <- sum(temp >= obs_te) / (length(temp))
    pvalue(p_val)
  }
  observeEvent(input$shuffle, {
    shuffle_treatment()
    estimate_te()
    calculate_pvalue()
  })
  # 100 shuffles
  observeEvent(input$shuffle100, {
    for (i in 1:100) {
      shuffle_treatment()
      estimate_te()
    }
    calculate_pvalue()
  })
}

# Run the application
shinyApp(ui = ui, server = server)
