<!-- README.md is generated from README.Rmd. Please edit that file -->

ASX Implied Cash Rate
=====================

This repo automatically scrapes the ASX 30 Day Interbank Cash Rate
Futures Implied Yield Curve from
[here](https://www.asx.com.au/data/trt/ib_expectation_curve_graph.pdf)
and converts it into a simple csv.

Implied yield curve
-------------------

    all_data <- fread("combined-data/all_data.csv")

    plot_ly(all_data, x = ~date, y = ~cash_rate, color = ~scrape_date, name = ~scrape_date, type = "scatter", mode = "lines")

<div id="htmlwidget-016b6d75a60276c3caea" style="width:100%;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-016b6d75a60276c3caea">{"x":{"visdat":{"e4b21c00dfd":["function () ","plotlyVisDat"]},"cur_data":"e4b21c00dfd","attrs":{"e4b21c00dfd":{"x":{},"y":{},"mode":"lines","name":{},"color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"xaxis":{"domain":[0,1],"automargin":true,"title":"date"},"yaxis":{"domain":[0,1],"automargin":true,"title":"cash_rate"},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":["2022-06-01","2022-07-01","2022-08-01","2022-09-01","2022-10-01","2022-11-01","2022-12-01","2023-01-01","2023-02-01","2023-03-01","2023-04-01","2023-05-01","2023-06-01","2023-07-01","2023-08-01","2023-09-01","2023-10-01","2023-11-01"],"y":[0.695,1.2,1.695,2.045,2.45,2.9,3.24,3.315,3.605,3.79,3.83,3.86,3.895,3.935,3.94,3.94,3.92,3.895],"mode":"lines","name":"2022-06-24","type":"scatter","xaxis":"x","yaxis":"y","frame":null},{"x":["2022-06-01","2022-07-01","2022-08-01","2022-09-01","2022-10-01","2022-11-01","2022-12-01","2023-01-01","2023-02-01","2023-03-01","2023-04-01","2023-05-01","2023-06-01","2023-07-01","2023-08-01","2023-09-01","2023-10-01","2023-11-01"],"y":[0.695,1.18,1.675,2.005,2.395,2.815,3.11,3.19,3.48,3.665,3.705,3.735,3.77,3.81,3.815,3.815,3.795,3.77],"mode":"lines","name":"2022-06-25","type":"scatter","xaxis":"x","yaxis":"y","frame":null},{"x":["2022-06-01","2022-07-01","2022-08-01","2022-09-01","2022-10-01","2022-11-01","2022-12-01","2023-01-01","2023-02-01","2023-03-01","2023-04-01","2023-05-01","2023-06-01","2023-07-01","2023-08-01","2023-09-01","2023-10-01","2023-11-01"],"y":[0.695,1.18,1.675,2.005,2.395,2.815,3.11,3.19,3.48,3.665,3.705,3.735,3.77,3.81,3.815,3.815,3.795,3.77],"mode":"lines","name":"2022-06-26","type":"scatter","xaxis":"x","yaxis":"y","frame":null},{"x":["2022-06-01","2022-07-01","2022-08-01","2022-09-01","2022-10-01","2022-11-01","2022-12-01","2023-01-01","2023-02-01","2023-03-01","2023-04-01","2023-05-01","2023-06-01","2023-07-01","2023-08-01","2023-09-01","2023-10-01","2023-11-01"],"y":[0.695,1.18,1.675,2.005,2.395,2.815,3.11,3.19,3.48,3.665,3.705,3.735,3.77,3.81,3.815,3.815,3.795,3.77],"mode":"lines","name":"2022-06-27","type":"scatter","xaxis":"x","yaxis":"y","frame":null},{"x":["2022-06-01","2022-07-01","2022-08-01","2022-09-01","2022-10-01","2022-11-01","2022-12-01","2023-01-01","2023-02-01","2023-03-01","2023-04-01","2023-05-01","2023-06-01","2023-07-01","2023-08-01","2023-09-01","2023-10-01","2023-11-01"],"y":[0.69,1.195,1.685,2.02,2.445,2.865,3.2,3.28,3.555,3.735,3.775,3.805,3.84,3.88,3.885,3.885,3.865,3.84],"mode":"lines","name":"2022-06-28","type":"scatter","xaxis":"x","yaxis":"y","frame":null},{"x":["2022-06-01","2022-07-01","2022-08-01","2022-09-01","2022-10-01","2022-11-01","2022-12-01","2023-01-01","2023-02-01","2023-03-01","2023-04-01","2023-05-01","2023-06-01","2023-07-01","2023-08-01","2023-09-01","2023-10-01","2023-11-01"],"y":[0.69,1.2,1.695,2.035,2.445,2.87,3.19,3.27,3.53,3.7,3.74,3.77,3.805,3.845,3.845,3.845,3.815,3.785],"mode":"lines","name":"2022-06-29","type":"scatter","xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
