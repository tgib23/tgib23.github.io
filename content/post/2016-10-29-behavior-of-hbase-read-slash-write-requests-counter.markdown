---
layout: post
title: "Behavior of Hbase Read/Write Requests Counter"
slug: behavior-of-hbase-read-slash-write-requests-counter
date: 2016-10-29 23:10:50 +0900
comments: true
tags: [hbase]
---

HBase has Read/Write Requests System Counter feature and we can monitor it from HBase Web UI or API.
Against my instincts, the numbers of those counters could DECREASE while running.
This article covers how we could see the decrease of those counters.



We can see read/write request counters of HBase from  
http://master-server-node:60010/master-status#requestStats   
or  
http://region-server-nodes:60010/jmx  

These numbers are calculated by summing each region’s counts.
Check the iteration part of the code.
https://github.com/apache/hbase/blob/947ea85b0c086a022d7b50868b8499a0560331ad/hbase-server/src/main/java/org/apache/hadoop/hbase/regionserver/MetricsRegionServerWrapperImpl.java#L495
```java
        for (Region r : regionServer.getOnlineRegionsLocalContext()) {
          tempNumMutationsWithoutWAL += r.getNumMutationsWithoutWAL();
          tempDataInMemoryWithoutWAL += r.getDataInMemoryWithoutWAL();
          tempReadRequestsCount += r.getReadRequestsCount();
          tempWriteRequestsCount += r.getWriteRequestsCount();
          tempCheckAndMutateChecksFailed += r.getCheckAndMutateChecksFailed();
          tempCheckAndMutateChecksPassed += r.getCheckAndMutateChecksPassed();
          tempBlockedRequestsCount += r.getBlockedRequestsCount();
```

So, every time regions get moved or deleted, the number of counters decreases.

Here is a sample check the behaviour.

1. check http://master-server-node:60010/master-status#requestStats
2. create table and put some record
```bash
 $ hbase shell   
 hbase> create 'weblog2', 'stats'
 hbase> put 'weblog2', 'row1', 'stats:weekly', 'test-weekly-value'
 hbase> put 'weblog2', 'row1', 'stats:weekly', 'test-weekly-value'
 hbase> put 'weblog2', 'row2', 'stats:daily', 'test-weekly-value'
 hbase> put 'weblog2', 'row3', 'stats:monthly', 'test-weekly-value'
 ```
3. reload the above web page and identify which node increases the write counter. That node has the region.
4. now, delete the table and compare how the value changed
    - check the counter
```bash
$ curl 'http://syamada-v4-dist0:60030/jmx' -s | grep RequestCount
   "totalRequestCount" : 12,
   "readRequestCount" : 8,
   "writeRequestCount" : 5,
```
- disable and drop the table
```bash
$ hbase shell
hbase> disable 'weblog2'
hbase> drop 'weblog2'
```
- check the counter again
```bash
$ curl 'http://syamada-v4-dist0:60030/jmx' -s | grep RequestCount
   "totalRequestCount" : 13,
   "readRequestCount" : 0,
   "writeRequestCount" : 0,
   "blockedRequestCount" : 0,
```

This happens when you move the Region, too.

```shell
hbase> move ‘ENCODED_REGIONNAME’, ‘SERVER_NAME’
```

The counter values are not migrated when region moved. All counters for the region reset to 0.


Notice in the example above, “totalRequestCount” is not reset to 0.
“totalRequestCount” is maintained by an instance variable managed by RegionServer, not Region.
Every time RegionServer accepts RPC call from clients, RegionServer increments the count.
Here's one example from the code.
Notice ```requestCount.increment()``` is called every time RPC call method is called.

https://github.com/apache/hbase/blob/dfb2a800c43b30c326dbdcec673387f7033f2092/hbase-server/src/main/java/org/apache/hadoop/hbase/regionserver/RSRpcServices.java#L1377
```java
  @Override
  @QosPriority(priority=HConstants.ADMIN_QOS)
  public CompactRegionResponse compactRegion(final RpcController controller,
      final CompactRegionRequest request) throws ServiceException {
    try {
      checkOpen();
      requestCount.increment();
      Region region = getRegion(request.getRegion());
```


When you restart the region server, not only read/write counters but also totalRequestCount are also reset to 0.

