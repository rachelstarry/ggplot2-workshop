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
p1 <- ggplot(gapdata, aes(log(income_per_capita_2011), life_expectancy_2016)) +
  geom_point(aes(size = population_2015, color = four_regions)) +
  geom_text(aes(label = country, size = population_2015))
p1

# Scales: Controlling Aesthetic Mapping ----

# Aesthetic mapping tells ggplot which variables you want to map to certain aesthetics, but it
# doesn't say *how* that should happen. Mapping color to world region doesn't specify which colors
# to use, and mapping size to population doesn't specify the actual sizes of the points.

# Scales control the precise way aesthetic mapping happens. Scales are added as an additional "layer"
# to an existing ggplot, just like we added additional geoms!
p2 <- p1 + scale_size(range = c(2, 20))
p2

# This sets the scale for the aesthetic mapping "size." Note that we use the aes "size" in two different
# geoms, geom_point and geom_text, so the sizes of both the points and text labels are affected.

# There are lots of scales available. In RStudio, type scale_<tab> to view the options.

# In particular, there are lots of color scales to choose from. But since our example uses four specific
# colors, let's specify the exact color scale we want to use for the four world regions. 
p2 <- p2 + scale_color_manual(values = c("asia" = "red", "africa" = "light blue", "europe" = "yellow", 
                                         "americas" = "green"))
p2

# Themes ----

# We can customize the overall appearance of our ggplot as well as particular plot annotations 
# by using built-in ggplot2 themes and themes from the ggthemes package.

# Themes are added on top of geoms in the same way as scales, using the + operator.
p2 + theme_minimal()
p2 + theme_economist_white()

# It's easy to create your own custom theme with the theme() function. Read all about theme elements at
# https://ggplot2.tidyverse.org/reference/theme.html 
# We will make some changes to the theme as we clean up our chart and make it look more like the original.

# All the Little Things ----

# To make our plot look like the Gapminder example, we still need to...
# [] add a stroke around the bubbles
# [] fix the chart legends
# [] change the axis titles
# [] add a chart title 
# [] format the chart axes
# [] change the font

# Let's start by copying and pasting all of our modifications from above.
p3 <- ggplot(gapdata, aes(log(income_per_capita_2011), life_expectancy_2016)) +
  geom_point(aes(size = population_2015, color = four_regions)) +
  geom_text(aes(label = country, size = population_2015)) +
  scale_size(range = c(2, 20)) +
  scale_color_manual(values = c("asia" = "red", "africa" = "light blue", "europe" = "yellow", 
                                "americas" = "green"))

# We'll need to make some changes to the aesthetic mapping and scales we used earlier to adjust things
# like adding a stroke around the bubbles and adjusting the chart legends, since those need to happen
# in the geom and scale function calls. Compare the code below to the code above to see where the
# changes described in the following lines are added.

# 1) We're using a different shape - an open circle that lets us use fill to color the inside, but note
# how the fixed aesthetics for shape and color are put *outside* the aes() call for geom_point().

# 2) In geom_text, we're using show.legend = F to remove the text legend, and in scale_size we're
# using guide = "none" to turn off the point size legend.


p4 <- ggplot(gapdata, aes(log(income_per_capita_2011), life_expectancy_2016)) +
  geom_point(aes(size = population_2015, fill = four_regions), shape = 21, color = "black") +
  geom_text(aes(label = country, size = population_2015), show.legend = F) +
  scale_size(range = c(2, 20), guide = "none") +
  scale_color_manual(name = "World Region", values = c("asia" = "red", "africa" = "light blue", 
                                                       "europe" = "yellow", "americas" = "green"),
                     labels = c("Africa", "Americas", "Asia", "Europe"))

# Let's then choose a theme that's pretty close to what we're looking for in terms of chart background.
p4 <- p4 + theme_minimal()

# We tweaked the legends a bit already, but we can also adjust the title



