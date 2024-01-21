# Finnish Vehicle Insights

By Daniel Moul

What can we learn from Finnish passenger vehicle data?

Finland, a small country of about 5.6M in 2023, offers a convenient window into larger trends in passenger vehicles. Using three data sets I downloaded from the Finnish Ministry of Transportation and Communications (FINCOM) I explore the following questions:

-   Looking at passenger vehicle inspection data from 2022: Which brands are most reliable? Least reliable? What are the most common reasons for inspection failure by vehicle brand, and how does this change as vehicles age? What is the relationship between driving distance and inspection failure? What are the brands' market share, and how has this changed over the years (since the mix of vehicles for a model year approximately indicate the purchase decisions in that year)?

-   Looking at a snapshot of passenger vehicles in traffic on 2023-09-30: What is the mix of power trains? By brand? How has this mix changed over the years? Which brands have been most successful in the transition to electrification, and has this transition opened a space for new market entrants? If so, which ones?

-   Looking at used car imports 2014-2023: How many vehicles imported? How old are most vehicles when they are imported? Which brands are most commonly imported. How do imports compare with the full set of passenger vehicles in Finland?

These data sets provide one set of answers--certainly not the last word--in answering these questions.

The rendered output from the scripts in this repo is available at ***TBD***

## Acknowledgements

Thanks to the Finnish Ministry of Transportation and Communications (FINCOM) for making the data available.

Photo on this page by John Lloyd[^readme-1]

[^readme-1]: Photo: <https://flickr.com/photos/hugo90/42693172685/> licensed CC BY 2.0 DEED

Hat tip to Jeremy Signer-Vine for [Data Is Plural](https://www.data-is-plural.com), where I learned about FINCOM open data.

## Replicating this analysis

1.  Clone this GitHub repo (dmoul/finnish-vehicle-insights)

2.  In the project root directory create ./data/processed so that when you run the qmd scripts, processed .rds files will be created in that directory.

3.  Install [quarto](https://quarto.org) if it's not already installed.

4.  In a terminal window in the project root directory, run: quarto render

5.  Quarto book-style output will be created in ./\_finnish-vehicles/
