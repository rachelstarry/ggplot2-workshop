# Install packages (only run these lines ONCE; erase the # to "uncomment" this line and run it)
# install.packages("tidyverse")
# install.packages("ggthemes")

# Intro to ggplot2 ----

# This code walks through the re-creation of a chart published by Gapminder Tools in 2016:
# https://github.com/rachelstarry/ggplot2-workshop/blob/master/GapminderWorld2015Poster.pdf 

# Load the required packages into our working environment
library(tidyverse)
library(ggthemes)

# Read in the dataset
gapdata <- read_csv("data/gap_data_clean.csv")

# Preview the dataset
View(gapdata)

# Geoms and Aesthetic Mapping ----

# In ggplot2, an *aesthetic* means "an aspect of a geometric object (geom) that you can see,"
# such as the position (of points) on the x and y axes, color ("outside" color), fill ("inside" color), 
# shape (of points), linetype, or size.

# Not all geoms allow all kinds of aesthetics. Example: geom_point (for a scatterplot) allows color,
# shape, fill, and size; but geom_bar (for a bar graph) allows color, fill, linetype, size, and weight.

# A ggplot requires, at minimum, two things: the data it should graph, and
ggplot(data = gapdata, aes(x = gapdata$income_per_capita_2011, y = gapdata$life_expectancy_2016))
