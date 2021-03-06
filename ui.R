#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#

library(shiny)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(navbarPage("HeavyTail", theme = shinytheme("flatly"),
                   
                   ### PAGE 1 ###
                   tabPanel("Relationships",
                            simpleNetworkOutput("distRel")
                            
                            ),
                   
                   ### PAGE 2 ###
                   tabPanel("Definitions",
                            tags$h1("Definitions"),
                            
                            tags$h2("Statistics"),
                            
                            tags$h3("Likelihood Function"),
                            
                            tags$h3("Log-Likelihood"),
                            
                            tags$h3("Maximum Likelihood Estimate"),
                            
                            tags$h2("Finance"),
                            
                            tags$h3("Net Returns"),
                            
                            tags$h3("Gross Returns"),
                            
                            tags$h3("Log Returns"),
                            
                            tags$h3("Risk Management"),
                            
                            tags$h3("MultiPeriod Returns"),
                            
                            tags$h3("Adjusted Returns"),
                            
                            tags$h3("Zero-Cupon Bond"),
                            
                            tags$h3("Cupon Bond"),
                            
                            tags$h3("Yield to Maturity"),
                            
                            tags$h3("Spot Rate"),
                            
                            tags$h3("Risk Premium"),
                            
                            tags$h2("Risk Management"),
                            
                            tags$h3("Value at Risk"),
                            
                            withMathJax(),
                            helpText("VaR - a function of two parameteres ( \\(\\alpha\\) ) a small probability and ( \\(T\\) ) a time horizon.
                                   VaR is the \\(\\alpha\\)th quantile of the loss distribution \\(L\\) over time \\(T\\)."),
                            withMathJax(),
                            helpText('$$ P\\bigg(L_{T} < \\text{VaR}_{T}(\\alpha)\\bigg) = \\alpha $$'),
                            helpText('$$ \\text{VaR}_{T}(\\alpha) = inf[x: P(L_{T} > x) < \\alpha ] $$'),
                            
                            tags$h3("Shortfall Distribution"),
                            
                            helpText("S - is the conditional distribution of loss \\(L\\), conditioning on the event that \\(L\\) > VaR,
                                     over the time horizon \\(T\\)."),
                            helpText('$$ S_T(x,\\alpha) = P\\bigg(L_T \\leq x | L_T > \\text{VaR}_T(\\alpha)\\bigg) $$'),
                            
                            tags$h3("Expected Shortfall"),
                            
                            tags$p("ES - ")
                            
                            
                            ),
                   
                   ### PAGE 3 ###
                   tabPanel("Stocks",
                            fluidPage(
                                    wellPanel(
                                            textInput("stock_ticker",label = "Stock Ticker"),
                                            selectInput("kernel", label = "Kernel", choices = c("gaussian", "epanechnikov",
                                                                              "rectangular","triangular",
                                                                              "biweight", "cosine", "optcosine")),
                                            sliderInput("bw", label = "Bandwidth", min = 0.0001, max = 0.008, 0.0025, step = 0.0001),
                                            selectInput("compare_dist", label = "Theoretical Distribution", choices = c("Gaussian",
                                                                                                                        "Laplace",
                                                                                                                        "Cauchy"))
                                    ),
                                    fluidRow(column(10, dygraphOutput("dygraph"), offset = 1)),
                                    fluidRow(column(5, plotOutput("retrun_density")),
                                             column(5, plotOutput("qqplot"))
                                             )
                                    )
                            ),
                   
                   ### PAGE 4 ###
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
                                                          plotlyOutput("ggvis_gaussian_cdf_pdf")
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
                                                       plotlyOutput("ggvis_exp_cdf_pdf")
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
                                                       plotlyOutput("ggvis_pareto_cdf_pdf")
                                               )
                                       )
                              )
                   )
))
