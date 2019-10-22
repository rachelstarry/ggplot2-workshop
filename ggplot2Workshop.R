# Install packages (only run these lines ONCE; erase the # to "uncomment" and run the following lines)
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
# in order to display their geometric objects, geom_text() requires an additional mapping we haven't specified,
# namely the variable we want to use for the text label.
p + geom_text(aes(label = country)) # This is messy. We'll make it look nicer in a minute.

# Aesthetic Mapping VS Aesthetic Assignment ----

# We can control all kinds of aesthetics in our ggplots. But it's important to note that if you want
# the values of a variable to control some aspect of how your geom appears - color, line, size, etc. - 
# you MUST map the variable in the aes() function call. 

# On the other hand: fixed aesthetics - when you want to change the size or color of ALL your geometric objects 
# - are set *outside* the aes() function call. This can be confusing.
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
# to use, and mapping size to population doesn't specify the actual size range of the points.

# Scales control the precise way aesthetic mapping happens. Scales are added as an additional "layer"
# to an existing ggplot, just like we added additional geoms!
p3 <- p2 + scale_size(range = c(2, 20))
p3

# This sets the scale for the aesthetic mapping "size." Note that we use the aes "size" in two different
# geoms, geom_point and geom_text, so the sizes of both the points and text labels are affected.

# There are lots of scales available. In RStudio, type scale_<tab> to view the options.

# In particular, there are lots of color scales to choose from. But since our example uses four specific
# colors, let's specify the exact color scale we want to use for the four world regions. 
p4 <- p3 + scale_color_manual(values = c("asia" = "red", "africa" = "light blue", "europe" = "yellow", 
                                         "americas" = "green"))
p4

# Themes ----

# We can customize the overall appearance of our ggplot as well as particular plot annotations 
# by using built-in ggplot2 themes and themes from the ggthemes package.

# Themes are added on top of geoms in the same way as scales, using the + operator.
p4 + theme_minimal()
p4 + theme_economist_white()

# Just like scales, there are many available themes. In RStudio, type theme_<tab> to view the options.

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
# [] customize the chart theme

# Let's start by copying and pasting all of our modifications from above.
p5 <- ggplot(gapdata, aes(log(income_per_capita_2011), life_expectancy_2016)) +
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
# To see all the available shapes for geom_point, type ?shape

# 2) In geom_text, we're using show.legend = F to remove the text legend, and in scale_size we're
# using guide = "none" to turn off the point size legend since that is not a very useful legend.
# A great tutorial for altering your ggplot2 legends is available at: 
# https://www.datanovia.com/en/blog/ggplot-legend-title-position-and-labels/ 

# 3) In scale_fill_manual, we're overriding the name and value labels for our fill scale legend.


p6 <- ggplot(gapdata, aes(log(income_per_capita_2011), life_expectancy_2016)) +
  geom_point(aes(size = population_2015, fill = four_regions), shape = 21, color = "black") +
  geom_text(aes(label = country, size = population_2015), show.legend = F) +
  scale_size(range = c(2, 20), guide = "none") +
  scale_fill_manual(values = c("asia" = "red", "africa" = "light blue", "europe" = "yellow", 
                               "americas" = "green"), name = "World Region", 
                    labels = c("Africa", "Americas", "Asia", "Europe"))

# Let's then choose a theme that's pretty close to what we're looking for in terms of chart background.
p6 <- p6 + theme_minimal()

# Now let's add additional annotations to our chart and correct our axis labels.
# A great tutorial for altering your ggplot2 annotations is available at: 
# https://www.datanovia.com/en/blog/how-to-change-ggplot-labels/ 
p7 <- p6 + labs(title = "Health and Income of Nations in 2015",
                subtitle = "This graph compares Life Expectency & GDP per capita for all 182 nations recognized by the UN",
                caption = "Data source: www.gapminder.org",
                x = "GDP per capita ($ adjusted for price differences, PPP 2011)",
                y = "Life expectancy (years)")

# Now that we've added some annotations, it appears that some text elements are too close to the margins.
# We can adjust the x axis limits so that no text or data is cropped out of the plot.
# A great tutorial for altering your ggplot2 axes is available at: 
# https://www.datanovia.com/en/blog/ggplot-axis-limits-and-scales/ 
p8 <- p7 + coord_cartesian(xlim = c(5.7, 12), ylim = c(45, 85)) # This sets the axis limits to particular values.

# We also still need to adjust the axis labels for the x axis, which we changed from the original
# GDP per capita values to the log values to spread out the data like the original graph does.
# To do this, we can manually set the x axis ticks and label text using scale_x_continuous.
p9 <- p8 + scale_x_continuous(breaks=c(5,6,7,8,9,10,11,12), 
                              labels=c(exp(5), exp(6), exp(7), exp(8), exp(9), exp(10), exp(11), exp(12)))

# With the paste() command, we can also add $ to each label.
p10 <- p8 + scale_x_continuous(breaks=c(5,6,7,8,9,10,11,12), 
                              labels=c(paste("$", exp(5)), paste("$", exp(6)), paste("$", exp(7)), 
                                       paste("$", exp(8)), paste("$", exp(9)), paste("$", exp(10)), 
                                       paste("$", exp(11)), paste("$", exp(12))))

# Going a step further, we can round the dollar amounts for each x axis label.
p11 <- p8 + scale_x_continuous(breaks=c(5,6,7,8,9,10,11,12), 
                               labels=c(paste0("$", round(exp(5))), paste0("$", round(exp(6))), 
                                        paste0("$", round(exp(7))), paste0("$", round(exp(8))),
                                        paste0("$", round(exp(9))), paste0("$", round(exp(10))), 
                                        paste0("$", round(exp(11))), paste0("$", round(exp(12)))))

# Finally, we can make some general changes to the appearance of our plot by adjusting the theme. 
# Again, to see all possible theme elements you can adjust, visit:
# https://ggplot2.tidyverse.org/reference/theme.html 
p12 <- p11 + theme(legend.box.background = element_rect(), # add a box border to the legend
                 legend.box.margin = margin(6, 6, 6, 6), # set the margins of the legend border
                 
                 plot.title = element_text(face = "bold") # make the plot title text bold
                 )
