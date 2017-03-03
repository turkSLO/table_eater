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

*Tuesday Feb 7, 2017 15:00-16:40*

I got the **NFL** link working properly. However, **Skyscraper Center** is quite the terrible piece of code, so I was not able to get that one working thus far. I cleaned up the code a bit. Reworked some of the regex substitutions to grab what I'm specifically looking for, rather than basing every section generically.

Honestly, working with the Skyscraper code is giving me headaches, so I'm looking to just treat this as an extreme example and leave it for last. I would like to get a few more links from more commonly used sites to gather data tables and put those as a priority.

After working with the code a bit more and testing on more sites, I plan on moving forward into designing it for Shiny. I need to talk to Dr. Glanz about how my code currently transforms the pages into the data tables, seeing if he'd prefer I use my current method of `sink -> cat -> sink` or if I should rewrite it to take in the data in a more complex way and turn it into a data frame, then use `write.table` or `write.csv` to turn it into a file.

The issue with that design is that, if the data frame is malformed, the code would just fail. When it's made in my current way, if the table is malformed, the user can just clean it up themselves to get it in working order.

*Thursday Feb 9, 2017 17:00-17:15*

Spoke with Dr. Glanz and decided we should move the the project onto the next step. He mentioned [Shinyapps.io](shinyapps.io) for when we move onto that stage. It will be where I move my project to when I get to that stage.

We decided to try feeding back in the code to confirm that it comes out properly. If it doesn't, we can try catching the warnings and finding the problems and having the code automatically remove them problem lines. However, I would like to move to this stage after some more testing. More URLs were provided complimentary of both Dr. Glanz and Dr. Carlton, so I plan to make efforts on those.

*Tuesday Feb 14, 2017 21:00-23:40*

I tested the new URLs and found more big bugs, I have decided it's time to rewrite the way I handle the code. I plan on swapping to RCurl rather than base curl and rewriting sections of the code to split rather than take in the already split html and splice it back together. This should provide more accurate separation of tables and elements. I can split the sections I need, splice together using the proper separators, and place any needed special characters in simpler and more efficient code.

The rewrite appears to be successful and works on all previous pages, excluding the Skyscraper one. However, I determined that one cannot be handled at all unless I run a more advanced scrape. It uses XHR to populate the table, so unless I figure out a way to get curl to wait for the page to actually load as if done in a browser, it cannot be gathered. This will become a problem with the future of HTML, as more things are becoming handled through asynchronous grabbing of files through XHR.

I need to speak with Dr. Glanz about the links he sent me, specifically about the "metadata table" link. The other ones won't work for reasons of either being XHR or that they're not actually tables, just `<div>`s that look like tables.

Libraries removed: curl

Libraries added: RCurl

URLs used:
[Spotrac](http://www.spotrac.com/nfl/san-francisco-49ers/), 
[Wikipedia on US Senators](https://en.wikipedia.org/wiki/List_of_current_United_States_Senators)

*Wednesday Mar 1, 2017 19:00-21:00*

Took me a lot of time to come up with just a few lines, but I think I have "colspan" handled. If it turns out you can't have two headers by the same name, then I will split the code so it handles the `<th>` separately from `<td>` when it comes to "colspan".

I started using the stringr package so I can match with regex and get the actual strings back out so that I can duplicate them. However, while I have discovered a method to handle "colspan" using that method, "rowspan" still eludes me. I need to somehow inject into the next row a duplicate of the data.

Haven't tested the code as it's currently not workable. If I tested it, a lot of working sites would either break or be going through extraneous tasks that might break the rest of the code.

Libraries added: stringr

*Thursday Mar 2, 2017 11:00-12:00 & 14:00-17:40*

Ran through dozens of different ways to process the data and be able to rip out the "colspan" and the "rowspan". After hours of trying many different methods, I finally came up with a way to handle it perfectly. It took a lot of attacking the process from different angles, finding complications in my design for handling such methods, and then rearranged the order of operations in a way that allowed for "perfect" management of the data (as like before), adding management of the extra variables presented, and cleaning the excess junk off without issue.

"Sortkey" took a lot of hammering down, because it kept on grabbing entire elements and removing them, rather than just the small subset I wanted. It took a lot of regex management, but I got a way to do it; it's rather sloppy though. There is definitely a better way to handle it, but that is a very low priority.

It is almost time to move onto the next stage, the RShiny app. I just want to replace some of the code that using the base methods of string manipulation with stringr, consistency is king.

Tested on the US Senators again, works perfectly.

