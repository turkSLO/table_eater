**Senior Project**

*Monday Jan 9, 2017 15:00-16:30*

Created the beginning structure of the program. It uses the native curl
package to open webpages and stream the content. Might swap it to just
full loading the page, but this will leave less recursions through the
full raw page at the time. It checks for if multiple tables exist on the
page and separates them.

URLs used:
[FBI](https://ucr.fbi.gov/crime-in-the-u.s/2014/crime-in-the-u.s.-2014/tables/expanded-homicide-data/expanded_homicide_data_table_8_murder_victims_by_weapon_2010-2014.xls)

Libraries added: curl

Planned next: splitting the tables by td/th and tr and finding more
example sites for testing table designs.

Current worries: tables where there’s multiple headings and tables with
headers and sidebar subsections

Example:

![](http://i.imgur.com/I7X9yBT.png)

*Wednesday Jan 11, 2017 16:00-18:30*

Using the same table as before, I have stripped out all excess html and
created the layouts of each file types. However, as I came to the point
of saving the files themselves, I found myself at a loss of words when I
remembered there was function to write directly into csv and txt using
R. I will have to rewrite the entire process to strip out the html and
re-arrange the data into a matrix or something to use these proper
functions. Hence, I am debating the merits of rewriting the function. I
can use sink() to create the files just as easily as I developed the
formatting already. The files created do work as intended, but I need to
expand my repertoire of tables to test how well it handles them. I have
to spend time optimizing this code, because there are many situations
where I’m substituting lines and the resubstituting the exact same lines
again. When I get to the rewrite, I will probably solve this problem.

Libraries added: tools

Planned next: Getting more tables and redesigning the way I handle the
table (turning it into a data.frame maybe?) in order to use the proper
write functions.

Current worries: same as previous, but now with extraneous html tags as
well and my current method of handling of data cleaning potentially
causing issues.

*Thursday Jan 26, 2017 16:30-17:00*

Spoke with Dr. Glanz about the destination of the code and decided on only
doing it as a Shiny App rather than the CRAN project and the Shiny App.
We tested the code on the sites he gave me and saw a few issues come to
light.

- [ ] Headers that are separated as their own ~~`<tbody>` or~~ `<table>`
- [x] `<a href=...>`tags
- [ ] # marks being neglected (?)
- [ ] Header value being skipped entirely
- [ ] Curl misbehaving and cutting off early

The reason for going fully to Shiny instead of CRAN is because of the idea of previewing the tables and selecting the ones you want (and potentially merge).

URLs used:
[NFL](http://www.nfl.com/stats/categorystats?tabSeq=1&statisticPositionCategory=QUARTERBACK&season=2016&seasonType=REG),
[Skyscraper Center](https://skyscrapercenter.com/compare-data/submit?type%5B%5D=building&status%5B%5D=COM&base_height_range=4&base_company=All&base_min_year=1885&base_max_year=9999&skip_comparison=on&output%5B%5D=list)

*Tuesday Fev 7, 2017 15:00-16:40*

I got the **NFL** link working properly. However, **Skyscraper Center** is quite the terrible piece of code, so I was not able to get that one working thus far. I cleaned up the code a bit. Reworked some of the regex substitutions to grab what I'm specifically looking for, rather than basing every section generically.

Honestly, working with the Skyscraper code is giving me headaches, so I'm looking to just treat this as an extreme example and leave it for last. I would like to get a few more links from more commonly used sites to gather data tables and put those as a priority.

After working with the code a bit more and testing on more sites, I plan on moving forward into designing it for Shiny. I need to talk to Dr. Glanz about how my code currently transforms the pages into the data tables, seeing if he'd prefer I use my current method of `sink -> cat -> sink` or if I should rewrite it to take in the data in a more complex way and turn it into a data frame, then use `write.table` or `write.csv` to turn it into a file.

The issue with that design is that, if the data frame is malformed, the code would just fail. When it's made in my current way, if the table is malformed, the user can just clean it up themselves to get it in working order.