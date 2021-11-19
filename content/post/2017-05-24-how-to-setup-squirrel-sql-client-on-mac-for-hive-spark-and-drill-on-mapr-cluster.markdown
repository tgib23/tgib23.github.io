---
layout: post
title: "How to setup Squirrel SQL Client on Mac for Hive, Drill, and Impala on MapR cluster"
slug: how-to-setup-squirrel-sql-client-on-mac-for-hive-spark-and-drill-on-mapr-cluster
date: 2017-05-24 17:35:18 +0900
comments: true
tags: [drill, hive, impala, mapr, squirrel]
---

This post shows how to setup Squirrel SQL client for Hive, Drill, and Impala on Mac.
I assume Mac client is [already setup](http://maprdocs.mapr.com/home/AdvancedInstallation/SettingUptheClient-macosx.html) and this is the case with MapR 5.2.1 and MEP 3.0.
Change the version numbers if you set up with other MapR or MEP versions.

# Install Squirrel

Go to http://www.squirrelsql.org/#installation and follow the instruction.

Then, Launch Squirrel App from Application Directory.

# Use Hive from Squirrel

You have to follow three steps, bring jars, configuration, and run the query.
Let's see each detail.

## Bring jars

Bring jars from cluster node with hive installed.
You need to bring these jars below (assuming you use MR2).

```bash
/opt/mapr/hive/hive-2.1/lib/commons-logging-1.2.jar
/opt/mapr/hive/hive-2.1/lib/libfb303-0.9.3.jar
/opt/mapr/hive/hive-2.1/lib/libthrift-0.9.3.jar
/opt/mapr/hive/hive-2.1/lib/httpcore-4.4.jar
/opt/mapr/hive/hive-2.1/lib/httpclient-4.4.jar
/opt/mapr/hive/hive-2.1/lib/hive-shims-2.1.1-mapr-1703.jar
/opt/mapr/hive/hive-2.1/lib/hive-service-2.1.1-mapr-1703.jar
/opt/mapr/hive/hive-2.1/lib/hive-metastore-2.1.1-mapr-1703.jar
/opt/mapr/hive/hive-2.1/lib/hive-exec-2.1.1-mapr-1703.jar
/opt/mapr/hive/hive-2.1/lib/hive-jdbc-2.1.1-mapr-1703.jar
/opt/mapr/hive/hive-2.1/lib/guava-14.0.1.jar
/opt/mapr/hadoop/hadoop-2.7.0/share/hadoop/common/hadoop-common-2.7.0-mapr-1703.jar
/opt/mapr/lib/slf4j-*
```

Then, put those jars into some directory such as $HOME/squirrel/hive or something.

## Configuration

Create Drivers and Aliases with those jars brought from cluster nodes.

1. Click "Drivers" on the upper left side
2. Click Green Cross
3. On the window, put some Name like MapR Hive
4. Fill in Example URL with the hiveserver2 node and port on the cluster, such as jdbc:hive2://cent62:10000
5. Click "Extra Class Path"
6. Click "Add" and choose the jar folder we put the jars above, and select all the jars. !['octopress preview' 'octopress preview'](/images/20170524/blog0.png)
7. Fill in the "Class Name" with "org.apache.hive.jdbc.HiveDriver". Then, click OK.
8. Click on "Aliases" on the upper left side.
9. Click Green Cross.
10. Put some Name like "Hive on Cent6"
11. Choose the Drive we made on the step 7.
12. Confirm the URL for hiveserver2 is correct. Modify if wrong. !['octopress preview' 'octopress preview'](/images/20170524/blog1.png)
13. Fill in User and Password.
14. Click "Test"
15. Fill in User and Password, then click "Connect"
16. If succeeded, you are ready to go!
17. Click "OK"

## Run Hive Query

1. Click Aliases and double click the alias you just made.
2. On the popup window, click "Connect"
3. Click "SQL" on upper middle section to execute queries
4. Click yellow highlighted sections and enter some queries
5. Then, click the icon of running man on upper left side or press Control-Enter, which will run the query and give you the result !['octopress preview' 'octopress preview'](/images/20170524/blog3.png)

# Use Drill from Squirrel

Using Drill case is mostly described [here](http://maprdocs.mapr.com/home/Drill/Downloading-Configuring-Driver.html), but I'll show you the steps anyways.

## Bring jars

For Drill, you have to bring jars from [this URL](http://package.mapr.com/tools/MapR-JDBC/MapR_Drill/)

## Configuration

Basically follow the same step as shown in Hive case.
* Create Drivers as follows
    * Use jdbc:drill:zk=<zk quorum>/drill/<cluster id> to fill Example URL
        * cluster-id is "${cluster name}-drillbits" by default and specified at /opt/mapr/drill/drill-1.10.0/conf/drill-override.conf
    * add the jars above to Extra Class Path
    * Use "com.mapr.drill.jdbc41.Drive" for Class Name !['octopress preview' 'octopress preview'](/images/20170524/blog4.png)
* Create Aliases with the Drive above. If connection test is successful, you are ready to go!

## Run Drill Query

This is almost the same process as Hive.
If you haven't enabled Hive storage format, [enable it](http://maprdocs.mapr.com/home/Drill/configure_hive_storage_plugin.html) before connection to query Hive table.
After connection, Squirrel shows the enabled storages.
!['octopress preview' 'octopress preview'](/images/20170524/blog5.png)

Now you can query Hive table from Drill.

# Use Impala from Squirrel

The essence of using Impala from jdbc connection is also described [here](http://maprdocs.mapr.com/home/Impala/JDBCConnections-UsingtheJ.html), but I'll show the steps anyways.

## jars and Configurations

You can use the same jars and drivers as Hive case.
Make Aliases and specify Impala server URL and port as jdbc:hive2://<impala-server-host>:21050/;auth=noSasl
!['octopress preview' 'octopress preview'](/images/20170524/blog6.png)

## Run Impala Query

Running Impala Query is the same as running hive query.


