
# 
# # ged_cdf = fGarch::pged()
# # ged_pdf = fGarch::dged()
# # ged_qf = fGarch::qged()
# 
# # pareto_cdf = fExtremes::pgpd()
# # pareto_pdf = fExtremes::dgpd()
# # pareto_qf = fExtremes::qgpd()
# 
# 
# dists = data.frame(laplace_cdf,
#                    laplace_pdf,
#                    gaussian_cdf,
#                    gaussian_pdf,
#                    t_cdf,
#                    t_pdf,
#                    pts)

library(shiny)
library(ggvis)
library(rmutil)
library(fExtremes)
library(networkD3)


# Define server logic required to draw a histogram
shinyServer(function(input, output){
        output$distRel = renderSimpleNetwork({
                src = c("Normal", "Normal", "Exponential", "t-distribution", "t-distribution")
                dest = c("t-distribution", "Gamma", "Gamma", "Laplace", "Gamma")
                distRel = data.frame(src, dest)
                simpleNetwork(distRel)
        })
        
        dists = reactive({
                
                gaussian_pts = seq(input$gaussian_xmin, input$gaussian_xmax, length.out = 2000)
                laplace_pts = seq(input$laplace_xmin, input$laplace_xmax, length.out = 2000)
                t_pts = seq(input$t_xmin, input$t_xmax, length.out = 2000)
                exp_pts = seq(0,input$exp_xmax, length.out = 2000)
                cauchy_pts = seq(input$cauchy_xmin, input$cauchy_xmax, length.out = 2000)
                pareto_pts = seq(input$pareto_xmin, input$pareto_xmax, length.out = 2000)
                
                laplace_cdf = rmutil::plaplace(laplace_pts, m = input$laplace_mu, s = input$laplace_lambda)
                laplace_pdf = rmutil::dlaplace(laplace_pts, m = input$laplace_mu, s = input$laplace_lambda)
                
                gaussian_cdf = pnorm(gaussian_pts, mean = input$gaussian_mu, sd = input$gaussian_sd)
                gaussian_pdf = dnorm(gaussian_pts, mean = input$gaussian_mu, sd = input$gaussian_sd)
                
                t_cdf = pt((t_pts - input$t_mu)/input$t_sd, df = input$t_nu)
                t_pdf = dt((t_pts - input$t_mu)/input$t_sd, df = input$t_nu)
                
                exp_cdf = pexp(exp_pts, rate = input$exp_lambda)
                exp_pdf = dexp(exp_pts, rate = input$exp_lambda)
                
                cauchy_cdf = pcauchy(cauchy_pts, location = input$cauchy_mu, scale = input$cauchy_sd)
                cauchy_pdf = dcauchy(cauchy_pts, location = input$cauchy_mu, scale = input$cauchy_sd)
                
                pareto_cdf = fExtremes::pgpd(pareto_pts, xi = input$pareto_shape, mu = input$pareto_mu, beta = input$pareto_scale)
                pareto_pdf = fExtremes::dgpd(pareto_pts, xi = input$pareto_shape, mu = input$pareto_mu, beta = input$pareto_scale)
                
                dists = data.frame(laplace_cdf,
                                   laplace_pdf,
                                   laplace_pts,
                                   gaussian_cdf,
                                   gaussian_pdf,
                                   gaussian_pts,
                                   t_cdf,
                                   t_pdf,
                                   t_pts,
                                   exp_cdf,
                                   exp_pdf,
                                   exp_pts,
                                   cauchy_cdf,
                                   cauchy_pdf,
                                   cauchy_pts,
                                   pareto_cdf,
                                   pareto_pdf,
                                   pareto_pts)
        })
        
        ####### plotly #######
        
        ###### GAUSSIAN ######
        
        output$ggvis_gaussian_cdf = renderPlotly({
                plot_ly(dists(), x = ~gaussian_pts, y = ~gaussian_cdf, type = 'scatter', mode = 'lines', name = "Gaussian")
        })
        
        
        output$ggvis_gaussian_pdf = renderPlotly({
                plot_ly(dists(), x = ~gaussian_pts, y = ~gaussian_pdf, type = 'scatter', mode = 'lines', name = "Gaussian")
        })
        
        
        output$ggvis_gaussian_qf = renderPlotly({
                plot_ly(dists(), y = ~gaussian_pts, x = ~gaussian_cdf, type = 'scatter', mode = 'lines', name = "Gaussian")
        })
        
        ###### LAPLACE ######
        output$ggvis_laplace_cdf = renderPlotly({
                plot_ly(dists(), x = ~laplace_pts, y = ~laplace_cdf, type = 'scatter', mode = 'lines', name = "Laplacian")  %>%
                        add_lines(y = ~gaussian_cdf, color = I("red"), name = "Normal")
        })
        
        output$ggvis_laplace_pdf = renderPlotly({
                plot_ly(dists(), x = ~laplace_pts, y = ~laplace_pdf, type = 'scatter', mode = 'lines', name = "Laplacian")  %>%
                        add_lines(y = ~gaussian_pdf, color = I("red"), name = "Normal")
        })
        
        
        output$ggvis_laplace_qf = renderPlotly({
                plot_ly(dists(), y = ~laplace_pts, x = ~laplace_cdf, type = 'scatter', mode = 'lines', name = "Laplacian")  %>%
                        add_lines(y = ~gaussian_cdf, color = I("red"), name = "Normal")
        })
        
        ###### t-dist ######
        output$ggvis_t_cdf = renderPlotly({
                plot_ly(dists(), x = ~t_pts, y = ~t_cdf, type = 'scatter', mode = 'lines', name = "t-distribution")  %>%
                        add_lines(y = ~gaussian_cdf, color = I("red"), name = "Normal")
        })
        
        output$ggvis_t_pdf = renderPlotly({
                plot_ly(dists(), x = ~t_pts, y = ~t_pdf, type = 'scatter', mode = 'lines', name = "t-distribution")  %>%
                        add_lines(y = ~gaussian_pdf, color = I("red"), name = "Normal")
        })
        
        output$ggvis_t_qf = renderPlotly({
                plot_ly(dists(), y = ~t_pts, x = ~t_cdf, type = 'scatter', mode = 'lines', name = "t-distribution")  %>%
                        add_lines(x = ~gaussian_cdf, color = I("red"), name = "Normal")
        })
        
        ###### Exponential ######
        dists %>% ggvis(~exp_pts, ~exp_cdf) %>%
                layer_lines(stroke := "blue",
                            strokeWidth := 3,
                            strokeDash := 4) %>% bind_shiny("ggvis_exp_cdf")

        dists %>% ggvis(~exp_pts, ~exp_pdf) %>%
                layer_lines(stroke := "blue",
                            strokeWidth := 3,
                            strokeDash := 4) %>% bind_shiny("ggvis_exp_pdf")

        dists %>% ggvis(~exp_cdf, ~exp_pts) %>%
                layer_lines(stroke := "blue",
                            strokeWidth := 3,
                            strokeDash := 4) %>% bind_shiny("ggvis_exp_qf")
        
        ###### CAUCHY ######
        dists %>% ggvis(~cauchy_pts, ~cauchy_cdf) %>%
                layer_lines(stroke := "blue",
                            strokeWidth := 3,
                            strokeDash := 4) %>% bind_shiny("ggvis_cauchy_cdf")
        
        dists %>% ggvis(~cauchy_pts, ~cauchy_pdf) %>%
                layer_lines(stroke := "blue",
                            strokeWidth := 3,
                            strokeDash := 4) %>% bind_shiny("ggvis_cauchy_pdf")
        
        dists %>% ggvis(~cauchy_cdf, ~cauchy_pts) %>%
                layer_lines(stroke := "blue",
                            strokeWidth := 3,
                            strokeDash := 4) %>% bind_shiny("ggvis_cauchy_qf")
        
        ###### PARETO ######
        dists %>% ggvis(~pareto_pts, ~pareto_cdf) %>%
                layer_lines(stroke := "blue",
                            strokeWidth := 3,
                            strokeDash := 4) %>% bind_shiny("ggvis_pareto_cdf")
        
        dists %>% ggvis(~pareto_pts, ~pareto_pdf) %>%
                layer_lines(stroke := "blue",
                            strokeWidth := 3,
                            strokeDash := 4) %>% bind_shiny("ggvis_pareto_pdf")
        
        output$ggvis_pareto_qf = renderPlotly({
                       plot_ly(dists(), y = ~pareto_pts, x = ~pareto_cdf, type = 'scatter', mode = 'lines')
                })
  
})
