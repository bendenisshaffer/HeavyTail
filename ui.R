#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(navbarPage("HeavyTail",
                   tabPanel("Relationships",
                            simpleNetworkOutput("distRel")),
                   tabPanel("Definitions"),
                   tabPanel("Stocks",
                            dygraphOutput("dygraph"),
                            plotlyOutput("retrun_density")
                            ),
                   navbarMenu("Distributions",
                              tabPanel("Gaussian",
                                  titlePanel("Gaussian Distribution"),
                                  fluidPage(
                                          fluidRow(column(4,
                                                          tags$h3("Plot Controls"),
                                                          wellPanel(
                                                                  sliderInput("gaussian_mu", label = "mu", value = 0, min = -20, max = 20, step = 0.1),
                                                                  sliderInput("gaussian_xmax", label = "xmax", value = 10, min = 5, max = 20, step = 0.5),
                                                                  sliderInput("gaussian_xmin", label = "xmin", value = -10, min = -20, max = -5, step = 0.5),
                                                                  sliderInput("gaussian_sd", label = "sd", value = 1, min = 0.01, max = 20, step = 0.01)
                                                                  )
                                                          ),
                                                   column(4,
                                                          tags$h3("Moments")
                                                   )
                                          ),
                                          fluidRow(column(12,
                                                          plotlyOutput("ggvis_gaussian_cdf")
                                                          )
                                                   )
                                          )
                                ),
                              
                              tabPanel("Exponential",
                                       # Application title
                                       titlePanel("Exponential Distribution"),
                                       
                                       sidebarLayout(
                                               sidebarPanel(
                                                       sliderInput("exp_lambda", label = "lambda", value = 1, min = 0.01, max = 5, step = 0.01),
                                                       sliderInput("exp_xmax", label = "xmax", value = 10, min = 2, max = 5, step = 0.5)
                                               ),
                                               
                                               mainPanel(
                                                       plotlyOutput("ggvis_exp_cdf"),
                                                       plotlyOutput("ggvis_exp_pdf"),
                                                       plotlyOutput("ggvis_exp_qf")
                                               )
                                       )
                              ),
                              tabPanel("Laplacian",
                                       # Application title
                                       titlePanel("Laplacian Distribution"),
                                       
                                       sidebarLayout(
                                               sidebarPanel(
                                                       sliderInput("laplace_mu", label = "mu", value = 0, min = -20, max = 20, step = 0.1),
                                                       sliderInput("laplace_xmax", label = "xmax", value = 10, min = 5, max = 20, step = 0.5),
                                                       sliderInput("laplace_xmin", label = "xmin", value = -10, min = -20, max = -5, step = 0.5),
                                                       sliderInput("laplace_lambda", label = "lambda", value = 1, min = 0.01, max = 20, step = 0.01)
                                                       
                                               ),
                                               
                                               mainPanel(
                                                       plotlyOutput("ggvis_laplace_cdf"),
                                                       plotlyOutput("ggvis_laplace_pdf"),
                                                       plotlyOutput("ggvis_laplace_qf")
                                               )
                                       )
                              ),
                              tabPanel("Cauchy",
                                       # Application title
                                       titlePanel("Cauchy Distribution"),
                                       
                                       sidebarLayout(
                                               sidebarPanel(
                                                       sliderInput("cauchy_mu", label = "mu", value = 0, min = -20, max = 20, step = 0.1),
                                                       sliderInput("cauchy_xmax", label = "xmax", value = 10, min = 5, max = 20, step = 0.5),
                                                       sliderInput("cauchy_xmin", label = "xmin", value = -10, min = -20, max = -5, step = 0.5),
                                                       sliderInput("cauchy_sd", label = "sd", value = 1, min = 0.01, max = 20, step = 0.01)
                                                       
                                               ),
                                               
                                               mainPanel(
                                                       plotlyOutput("ggvis_cauchy_cdf"),
                                                       plotlyOutput("ggvis_cauchy_pdf"),
                                                       plotlyOutput("ggvis_cauchy_qf")
                                               )
                                       )
                              ),
                              tabPanel("t-distribution",
                                       # Application title
                                       titlePanel("t-Distribution"),
                                       
                                       sidebarLayout(
                                               sidebarPanel(
                                                       sliderInput("t_mu", label = "mu", value = 0, min = -20, max = 20, step = 0.1),
                                                       sliderInput("t_xmax", label = "xmax", value = 10, min = 5, max = 20, step = 0.5),
                                                       sliderInput("t_xmin", label = "xmin", value = -10, min = -20, max = -5, step = 0.5),
                                                       sliderInput("t_sd", label = "sd", value = 1, min = 0.01, max = 20, step = 0.01),
                                                       sliderInput("t_nu", label = "nu", value = 6, min = 3, max = 30, step = 1)
                                                       
                                               ),
                                               
                                               mainPanel(
                                                       plotlyOutput("ggvis_t_cdf"),
                                                       plotlyOutput("ggvis_t_pdf"),
                                                       plotlyOutput("ggvis_t_qf")
                                               )
                                       )
                              ),
                              tabPanel("Pareto",
                                       # Application title
                                       titlePanel("Pareto Distribution"),
                                       
                                       sidebarLayout(
                                               sidebarPanel(
                                                       sliderInput("pareto_mu", label = "mu", value = 0, min = -20, max = 20, step = 0.1),
                                                       sliderInput("pareto_xmax", label = "xmax", value = 10, min = 5, max = 20, step = 0.5),
                                                       sliderInput("pareto_xmin", label = "xmin", value = -10, min = -20, max = -5, step = 0.5),
                                                       sliderInput("pareto_shape", label = "shape", value = 1, min = 0.01, max = 20, step = 0.01),
                                                       sliderInput("pareto_scale", label = "scale", value = 1, min = 0.01, max = 20, step = 0.01)
                                                       
                                               ),
                                               
                                               mainPanel(
                                                       plotlyOutput("ggvis_pareto_cdf"),
                                                       plotlyOutput("ggvis_pareto_pdf"),
                                                       plotlyOutput("ggvis_pareto_qf")
                                               )
                                       )
                              )
                   )
))
