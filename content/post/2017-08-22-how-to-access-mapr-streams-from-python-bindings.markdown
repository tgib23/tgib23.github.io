---
layout: post
title: "How to access MapR Streams from Python bindings"
slug: how-to-access-mapr-streams-from-python-bindings
date: 2017-08-22 15:38:09 +0900
comments: true
tags: [mapr, mapr streams, python]
---

From MEP 3.0, MapR offers Python binding for MapR Streams.
This article show how to use it with sample code.

# Step 0.

The environment is as follows.

* CentOS : 7.2
* MapR 5.2.2
* MEP 3.1
* python-2.7.5-48.el7.x86_64
* python-devel-2.7.5-48.el7.x86_64

# Step 1.

Create stream and topic as follows.
```bash
$ maprcli stream create -path  /streams/python-test-stream -produceperm p -consumeperm p -topicperm p
$ maprcli stream topic create -path /streams/python-test-stream -topic test-topic
```

# Step 2.
Install what you need.
```bash
# yum install python2-pip python-wheel -y
# pip install --upgrade pip
# yum install librdkafka mapr-librdkafka -y
# yum groupinstall 'Development Tools' -y
# pip install --global-option=build_ext --global-option="--library-dirs=/opt/mapr/lib" --global-option="--include-dirs=/opt/mapr/include/" http://package.mapr.com/releases/MEP/MEP-3.0/mac/mapr-streams-python-0.9.2.tar.gz
```

# Step 3.
Prepare code.
There is a sample code here http://maprdocs.mapr.com/home/MapR_Streams/MapRStreamsPythonExample.html .
Modify the stream and topic for this sample.

* producer.py

```python
from mapr_streams_python import Producer
p = Producer({'streams.producer.default.stream': '/streams/python-test-stream'})
some_data_source= ["msg1", "msg2", "msg3"]
for data in some_data_source:
    p.produce('test-topic', data.encode('utf-8'))
p.flush()
```

* consumer.py

```python
from mapr_streams_python import Consumer, KafkaError
c = Consumer({'group.id': 'mygroup',
              'default.topic.config': {'auto.offset.reset': 'earliest'}})
c.subscribe(['/streams/python-test-stream:test-topic'])
running = True
while running:
    msg = c.poll(timeout=1.0)
    if msg is None: continue
    if not msg.error():
        print('Received message: %s' % msg.value().decode('utf-8'))
    elif msg.error().code() != KafkaError._PARTITION_EOF:
        print(msg.error())
        running = False
c.close()
```

# Step 4.

Set LD_LIBRARY_PATH to /opt/mapr/lib and the directory containing libjvm.
Find the libjvm with find command as below.
```bash
# find / -name libjvm*
/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.141-1.b16.el7_3.x86_64/jre/lib/amd64/server/libjvm.so
```

Set the LD_LIBRARY_PATH with above.
```bash
$ export LD_LIBRARY_PATH=/opt/mapr/lib/:/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.141-1.b16.el7_3.x86_64/jre/lib/amd64/server
```

# Step 5.

Run the programs!
```bash
$ python producer.py
$ python consumer.py
Received message: msg1
Received message: msg2
Received message: msg3
```
