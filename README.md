# Relp

Relp is a Shiny application that imitates the `yelp.com`.
The application scrapes the `yelp` web page using the `rvest` package and reconstructs the scraped information via `leaflet`, `DT`, `ggmap`, and `tidyverse`.

# How to use the App?
### Front Page
![Front Page](/Report/relp_front.PNG)
First enter the values for the "Find" and "Near" variable and click the red search symbol.
When entering the "Near" variable, please provide the State information as well (e.g. IA).
The default value of the "Find" is "Restaurant" and "Ames, IA" for the "Near" variable.

### Main Page
![Front Page](/Report/relp_main.PNG)
Output of the initial search maybe modified using the widgets on the left column.  Simply update a new search query or apply filter, and click `refresh`. If there is a specific business of interest, click the table.  The location of the business will be highlighted and addtional information will be scraped from `yelp`. To view the detailed information, click on the `Reviews` or the `Images` tab. It may take a few seconds to load; Keep calm and wait for your potato.
