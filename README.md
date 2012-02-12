# Running Bulldozer

1) Build the initial database.
	
	$ ruby db/migrations/create_tables.rb

2) The first will hit Koofers entire index and retrieve all urls that will provide us with the structure to then scrape all of the exams on a faster more productive server later on. This is a multi-threaded program and is fairly fast.

	$ ruby koofers.rb

3) Verify that all the correct data scrapped from Koofers is correct. Once all data is in the database, you can then use that initial seed data to now scrape all of the documents. This should be run on a fast server that you can leave alone while this process runs.

	$ ruby koofers_download.rb



[fratfolder-database]: https://fratfolder.s3.amazonaws.com/fratfolder_complete_database.zip