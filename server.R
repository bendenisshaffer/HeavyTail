

library(shiny)
library(ggvis)
library(rmutil)
library(fExtremes)
library(networkD3)
library(plotly)
library(xts)
library(quantmod)
library(dygraphs)

get_returns = function(price_vec){
        ret_vec = diff(price_vec) / lag(price_vec)
        names(ret_vec) = paste(names(price_vec),"Returns")
        return(ret_vec)
}


# Define server logic required to draw a histogram
shinyServer(function(input, output){
        
        ########################################################################################
        ###################### Page 1: Relationships ###########################################
        ########################################################################################
        
        output$distRel = renderSimpleNetwork({
                src = c("Exponential", "Exponential", "Exponential", "Pareto")
                dest = c("Gamma", "Pareto","GPD", "GPD")
                distRel = data.frame(src, dest)
                simpleNetwork(distRel)
        })
        
        ########################################################################################
        ###################### Page 3: Stocks ##################################################
        ########################################################################################
        
        
        stock_df = reactive({
                input$stock_ticker
                apple_stock_price = getSymbols(input$stock_ticker, auto.assign = FALSE)
                price_vec = apple_stock_price[,6]
                df = cbind(price_vec, get_returns(price_vec))
                df
                
        })
        
        gdf = reactive({
                returns = stock_df()[-1,2]
                
                dist_fun = ""
                if(input$compare_dist == "Gaussian"){
                        dist_fun = "dnorm"
                }else if(input$compare_dist == "Laplace"){
                        dist_fun = "dlaplace"
                }else if(input$compare_dist == "Cauchy"){
                        dist_fun = "dcauchy"
                }
                
                ret_density = density(returns, kernel = input$kernel, bw = input$bw)
                mu = mean(returns)
                sd = sd(returns )
                pts = seq(min(returns), max(returns), length.out = length(ret_density$x))
                norm_denity = do.call(dist_fun, list(pts, mu, sd))
                gdf = data.frame(x = ret_density$x, y = ret_density$y, norm = norm_denity, pts)
                gdf
        })
        
        output$dygraph = renderDygraph({
                
                dygraph(stock_df()) %>% dySeries(paste0(input$stock_ticker,".Adjusted"), axis = "y2") %>% 
                        dyRangeSelector() %>% 
                        dyHighlight(highlightCircleSize = 5, 
                                    highlightSeriesBackgroundAlpha = 0.2,
                                    hideOnMouseOut = FALSE)
        })
        
        output$retrun_density = renderPlot({
                mu = mean(stock_df()[-1,2])
                sd = sd(stock_df()[-1,2])
                g1 = ggplot(gdf(), aes(x = x, y = y)) + geom_area(alpha = 0.7, fill = "blue", color = "blue") + 
                        geom_area(aes(x = pts, y = norm), alpha = 0.2, fill = "red") + 
                        geom_vline(xintercept = mu, color = "green", alpha = 0.7, linetype = 4) + 
                        geom_vline(xintercept = mu + sd, color = "green", alpha = 0.7, linetype = 4) + 
                        geom_vline(xintercept = mu - sd, color = "green", alpha = 0.7, linetype = 4) + theme_linedraw()
                g1
                #ggplotly(g1)
        })
        
        output$qqplot = renderPlot({
                returns = stock_df()[-1,2]
                
                dist_fun = ""
                if(input$compare_dist == "Gaussian"){
                        dist_fun = "qnorm"
                }else if(input$compare_dist == "Laplace"){
                        dist_fun = "qlaplace"
                }else if(input$compare_dist == "Cauchy"){
                        dist_fun = "qcauchy"
                }
                
                g2 = ggplot(returns, aes_string(sample = paste0(input$stock_ticker, ".Adjusted.Returns"))) + 
                        stat_qq(color = "blue", distribution = dist_fun) + theme_linedraw()
                g2
                #ggplotly(g2)
        })
        
        
        
        ########################################################################################
        ###################### Page 4: Distributions ###########################################
        ########################################################################################
        
        
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
        
        output$ggvis_gaussian_cdf_pdf = renderPlotly({
                p1 = plot_ly(dists(), x = ~gaussian_pts, y = ~gaussian_cdf, type = 'scatter', mode = 'lines', name = "CDF")
                p2 = plot_ly(dists(), x = ~gaussian_pts, y = ~gaussian_pdf, type = 'scatter', mode = 'lines', name = "PDF")
                subplot(p1, p2, nrows = 1)
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
        
        output$ggvis_exp_cdf_pdf = renderPlotly({
                p1 = plot_ly(dists(), x = ~exp_pts, y = ~exp_cdf, type = 'scatter', mode = 'lines', name = "CDF")
                p2 = plot_ly(dists(), x = ~exp_pts, y = ~exp_pdf, type = 'scatter', mode = 'lines', name = "PDF")
                subplot(p1, p2, nrows = 1)
        })
        
        
        ###### CAUCHY ######
        
        output$ggvis_cauchy_cdf = renderPlotly({
                plot_ly(dists(), x = ~cauchy_pts, y = ~cauchy_cdf, type = 'scatter', mode = 'lines', name = "Cauchy")  %>%
                        add_lines(y = ~gaussian_cdf, color = I("red"), name = "Normal")
        })
        
        output$ggvis_cauchy_pdf = renderPlotly({
                plot_ly(dists(), x = ~cauchy_pts, y = ~cauchy_pdf, type = 'scatter', mode = 'lines', name = "Cauchy")  %>%
                        add_lines(y = ~gaussian_pdf, color = I("red"), name = "Normal")
        })
        
        output$ggvis_cauchy_qf = renderPlotly({
                plot_ly(dists(), y = ~cauchy_pts, x = ~cauchy_cdf, type = 'scatter', mode = 'lines', name = "Cauchy")  %>%
                        add_lines(x = ~gaussian_cdf, color = I("red"), name = "Normal")
        })
        
        
        ###### PARETO ######
        
        output$ggvis_pareto_cdf_pdf = renderPlotly({
                p1 = plot_ly(dists(), x = ~pareto_pts, y = ~pareto_cdf, type = 'scatter', mode = 'lines', name = "Pareto")  %>%
                        add_lines(y = ~exp_cdf, color = I("red"), name = "Exponential")
                p2 = plot_ly(dists(), x = ~pareto_pts, y = ~pareto_pdf, type = 'scatter', mode = 'lines')  %>%
                        add_lines(y = ~exp_pdf, color = I("red"))
                subplot(p1, p2, nrows = 1)
        })
  
})
