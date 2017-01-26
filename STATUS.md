**Senior Project**

*Monday Jan 9, 2017 15:00-16:30*

Created the beginning structure of the program. It uses the native curl
package to open webpages and stream the content. Might swap it to just
full loading the page, but this will leave less recursions through the
full raw page at the time. It checks for if multiple tables exist on the
page and separates them.

URLs used:
<https://ucr.fbi.gov/crime-in-the-u.s/2014/crime-in-the-u.s.-2014/tables/expanded-homicide-data/expanded_homicide_data_table_8_murder_victims_by_weapon_2010-2014.xls>

Libraries added: curl

Planned next: splitting the tables by td/th and tr and finding more
example sites for testing table designs.

Current worries: tables where there’s multiple headings and tables with
headers and sidebar subsections

Example:

  2011   2012
  ------ ------ ------ ------
  Cats   Dogs
  \#     \#

                               2011   2012
  ----------------- ---------- ------ ------
  Total firearms:              \#     \#
                    Handguns   \#     \#
                    Rifles     \#     \#

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
