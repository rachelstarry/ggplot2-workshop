# Install packages (only run these lines ONCE; erase the # to "uncomment" this line and run it)
# install.packages("tidyverse")
# install.packages("ggthemes")
# install.packages("ggrepel")

# Intro to ggplot2 ----

# This code walks through the re-creation of a chart published by Gapminder Tools in 2016:
# https://github.com/rachelstarry/ggplot2-workshop/blob/master/GapminderWorld2015Poster.pdf 

# Load the required packages into our working environment
library(tidyverse)
library(ggthemes)
library(ggrepel)

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

# Aesthetic mappings tell the ggplot function which variables to "map" to which aesthetics.

# A ggplot requires, at minimum, two things: the data to graph, and the aesthetic mappings. For most kinds
# of plots, position mappings (which variables to plot on which axes) are required while others are optional.
ggplot(data = gapdata, aes(x = gapdata$income_per_capita_2011, y = gapdata$life_expectancy_2016))

# That's not a very exciting graph, because it's missing any actual geometric objects to represent the data!
# To add geometric objects like points, lines, or bars to your graph, you have to create your ggplot and then
# add one or more geoms, such as geom_point() or geom_bar().
ggplot(data = gapdata, aes(x = gapdata$income_per_capita_2011, y = gapdata$life_expectancy_2016)) +
  geom_point()

# That graph doesn't look exactly like the original, because the Gapminder example uses a logarithmic
# scale for the x axis. It's easy to perform calculations on our data before graphing it - in this case,
# by calling log() on the variable "income_per_capita_2011" that we're mapping to the x axis.
ggplot(data = gapdata, aes(x = log(gapdata$income_per_capita_2011), y = gapdata$life_expectancy_2016)) +
  geom_point()

# We can also simplify our ggplot function call  and save our plot in a variable called p.
p <- ggplot(gapdata, aes(log(income_per_capita_2011), life_expectancy_2016)) + geom_point()
p

# Once we have a basic ggplot, it's easy to add additional geoms! When we add geoms to an existing 
# ggplot, the geoms will "inherit" the aesthetic mappings we already specified - in this case, the x and y
# positions.
p + geom_smooth(method = "lm")    # This adds a linear regression line to the plot
p + geom_rug()                    # This adds marginal lines, creating a rug plot
p + geom_text()                   # This adds text to the plot

# Adding geom_text() without specifying the aesthetics required by that geom will cause an error.
# This is because, while geom_smooth() and geom_rug() "inherit" the only mappings they need (x and y position)
# in order to display their geometric objects, geom_text() requires an additiona mapping we haven't specified,
# namely the variable we want to use for the text label.
p + geom_text(aes(label = country)) # This is messy. We'll make it look nicer in a minute.

# Aesthetic Mapping VS Aesthetic Assignment ----

# We can control all kinds of aesthetics in our ggplots. But it's important to note that if you want
# the values of a variable to control some aspect of how your geom appears - color, line, size, etc. - 
# you MUST map the variable in the aes() function call. 

# Fixed aesthetics - when you want to change the size or color of ALL your geometric objects - are set
# outside the aes() function call. This can be confusing.
p1 <- ggplot(gapdata, aes(log(income_per_capita_2011), life_expectancy_2016))

p1 + geom_point(aes(size = 2, color = "red"))     # This is incorrect! 2 and "red" are not variables
p1 + geom_point(aes(color = four_regions))        # This is correct. Now we've mapped color to "four_regions"
p1 + geom_point(aes(color = four_regions),        # This is also correct. But it changes the size of ALL points
                size = 3)

# In the original Gapminder chart, color represents world region; point size represents population;
# and the size of the text label is linked to point size and therefore also to population.
p2 <- ggplot(gapdata, aes(log(income_per_capita_2011), life_expectancy_2016)) +
  geom_point(aes(size = population_2015, color = four_regions)) +
  geom_text(aes(label = country, size = population_2015))
p2

# Scales: Controlling Aesthetic Mapping ----

# Aesthetic mapping tells ggplot which variables you want to map to certain aesthetics, but it
# doesn't say *how* that should happen. Mapping color to world region doesn't specify which colors
# to use, and mapping size to population doesn't specify the actual sizes of the points.

# Scales control the precise way aesthetic mapping happens. Scales are added as an additional "layer"
# to an existing ggplot, just like we added additional geoms!
p3 <- p2 + scale_size(range = c(2, 20))
p3

# This sets the scale for the aesthetic mapping "size." Note that we use the aes "size" in two different
# geoms, geom_point and geom_text, so the sizes of both the points and text labels are affected.

# There are lots of scales available. In RStudio, type scale_<tab> to view the options.

# Let's specify the exact color scale we want to use for the four world regions. 
p3 <- p3 + scale_color_manual(values = c("asia" = "red", "africa" = "light blue", "europe" = "yellow", 
                                         "americas" = "green"))
p3
