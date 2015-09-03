# Pre deployment - trunk and tagging #

Note for the release number, just choose the next available number ie 0028 below

Example for trunking:

```
svn copy  https://brewtoolz.googlecode.com/svn/trunk  https://brewtoolz.googlecode.com/svn/branches/release_0028 -m "Replace buggy tag loading with jQuery tabs and other fixes"
```

Example for tagging:

```
svn copy  https://brewtoolz.googlecode.com/svn/trunk  https://brewtoolz.googlecode.com/svn/tags/release_0028_2010_10_22 -m "Replace buggy tag loading with jQuery tabs and other fixes - release tag"
```

# Deploying #

Note deployment needs to take place from the directory where the source code has been checked out to.

You also need to copy the "deploy.rb" file into the config directory.



You will also need the password for btadmin

```
cap deploy
```


The config/mongrel\_cluster.yml also needs to have the corrent user and group configured

And the config/database.yml needs to be set up with the production database credentials accordingly



After doing this the mongrel process need to be restarted on the server for changes to take affect.

These instructions don't cover schema changes and db migrations as yet.