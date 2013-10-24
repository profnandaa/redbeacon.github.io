---
layout: post
title: Dealing with Database Deadlocks
excerpt: "Today we'll be looking at a particular kind of database error: the deadlock. Before we define what a deadlock is, let's start on the ground with the following query"
author: Robert Miller
---

Today we'll be looking at a particular kind of database error: the deadlock. Before we define what a deadlock is, let's start on the ground with the following query:
<pre>select * from jobsdone_privatemessage where bid_id=15127683
</pre>

The table <code>jobsdone_privatemessage</code> stores messages sent between consumers and pros during a Redbeacon job. Since each pro working with a consumer has made a bid on that consumer's job, we associate messages with bids. The query above gets all the messages associated to the bid with ID 15127683. If you are more curious about what is happening on the database side when you run a query, you can use the <a href="http://dev.mysql.com/doc/refman/5.1/en/execution-plan-information.html" target="_blank">explain extended</a> command to get more details:
<pre>explain extended select * from jobsdone_privatemessage where bid_id=15127683</pre>
<font size=-2>
<table border="1" cellspacing="0" cellpadding="2">
<thead>
<tr>
<td>id</td>
<td>select_type</td>
<td>table</td>
<td>type</td>
<td>possible_keys</td>
<td>key</td>
<td>key_len</td>
<td>ref</td>
<td>rows</td>
<td>filtered</td>
<td>Extra</td>
</tr>
</thead>
<tbody>
<tr>
<td>1</td>
<td>SIMPLE</td>
<td>jobsdone_privatemessage</td>
<td>ref</td>
<td>jobsdone_privatemessage_bid_id</td>
<td>jobsdone_privatemessage_bid_id</td>
<td>4</td>
<td>const</td>
<td>2</td>
<td>100</td>
<td></td>
</tr>
</tbody>
</table>
</font>
This not only shows which indexes are used to execute the query, but also the order in which they are processed. In fact, sometimes the database can make pretty poor decisions about which index to use first, so you may find <a href="http://dev.mysql.com/doc/refman/5.1/en/index-hints.html" target="_blank">index hints</a> useful.

Let's take a closer look at the indexes:
<pre>show indexes from jobsdone_privatemessage</pre>
The following are a few columns selected from the result:
<font size=-2>
<table border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td>Non_unique</td>
<td>Key_name</td>
<td>Seq_in_index</td>
<td>Column_name</td>
<td>Collation</td>
<td>Sub_part</td>
<td>Packed</td>
<td>Null</td>
<td>Index_type</td>
<td>Comment</td>
</tr>
<tr>
<td>0</td>
<td>PRIMARY</td>
<td>1</td>
<td>id</td>
<td>A</td>
<td>NULL</td>
<td>NULL</td>
<td></td>
<td>BTREE</td>
<td></td>
</tr>
<tr>
<td>1</td>
<td>jobsdone_privatemessage_bid_id</td>
<td>1</td>
<td>bid_id</td>
<td>A</td>
<td>NULL</td>
<td>NULL</td>
<td></td>
<td>BTREE</td>
<td></td>
</tr>
<tr>
<td>1</td>
<td>jobsdone_privatemessage_sender_id</td>
<td>1</td>
<td>sender_id</td>
<td>A</td>
<td>NULL</td>
<td>NULL</td>
<td></td>
<td>BTREE</td>
<td></td>
</tr>
<tr>
<td>1</td>
<td>jobsdone_privatemessage_633a86fc</td>
<td>1</td>
<td>wiz_on_behalf_id</td>
<td>A</td>
<td>NULL</td>
<td>NULL</td>
<td>YES</td>
<td>BTREE</td>
<td></td>
</tr>
<tr>
<td>1</td>
<td>jobsdone_privatemessage_dc8eb65d</td>
<td>1</td>
<td>time_created</td>
<td>A</td>
<td>NULL</td>
<td>NULL</td>
<td></td>
<td>BTREE</td>
<td></td>
</tr>
</tbody>
</table>
</font>
We see that <code>jobsdone_privatemessage_bid_id</code> is a non-unique index implemented as a <a href="http://en.wikipedia.org/wiki/B-tree" target="_blank">B-tree</a>. Because this is a non-unique index, once the database server gets to the point on the tree where there are several entries with the same value, the B-tree structure can no longer distinguish the entries. What happens then depends on the database implementation. In particular, queries which access this set of entries are not guaranteed to run in the same order. The database engine may even randomize this for overall efficiency.

This is probably a good time to recall that a table in a database isn't necessarily stored as a table. It is a set of indexes: at the leaves of all those B-trees are pointers into a black box, which tell you where to get your entries one at a time.

So what is a deadlock? Intuitively, a deadlock is the database equivalent of this passage, <a href="http://en.wikipedia.org/wiki/Deadlock" target="_blank">allegedly</a> passed by the Kansas legislature:
<blockquote>"When two trains approach each other at a crossing, both shall come to a full stop and neither shall start up again until the other has gone."</blockquote>
Interactions with a database are organized into transactions, which are a series of commands to be executed as a block. Queries which only retrieve information are harmless, but the database server needs to be more careful with queries which insert rows or change values. Since transactions are to be executed as a block, you can't have two different transactions writing to the same locations at the same time. This is implemented in our particular combination of technologies (a mysql server using innodb as the database engine) as <a href="http://dev.mysql.com/doc/refman/5.1/en/innodb-transaction-model.html" target="_blank">row locks</a>. A transaction requests a lock for a particular row when it is updating its values, or for a particular gap between rows when it is inserting a row. The database server then grants locks to one transaction at a time, while the other transactions wait.

A deadlock occurs when transactions are no longer able to proceed due to a cycle of lock dependency. The simplest example is with two transactions and two locks:
<ul>
    <li>Transaction 1 requests (and is granted) the lock on row A.</li>
    <li>Transaction 2 requests (and is granted) the lock on row B.</li>
    <li>Transaction 1 requests the lock on row B, but must wait for Transaction 2.</li>
    <li>Transaction 2 requests the lock on row A, but must wait for Transaction 1.</li>
</ul>
At this point neither transaction can proceed, and the database detects this situation. We can see the database's version of the story by executing the command:
<pre>show engine innodb status</pre>
The result includes: <font size=-2><pre>
------------------------
LATEST DETECTED DEADLOCK
------------------------
130917 21:11:14
*** (1) TRANSACTION:
TRANSACTION 20D26ECF, ACTIVE 1 sec, process no 651, OS thread id 139698613929728 fetching rows
mysql tables in use 1, locked 1
LOCK WAIT 4 lock struct(s), heap size 1248, 3 row lock(s), undo log entries 1
MySQL thread id 99844845, query id 7149615885 10.178.13.92 produser Updating
UPDATE `jobsdone_privatemessage` SET `time_read` = '2013-09-17 21:11:13', `reviewed` = 1 WHERE (`jobsdone_privatemessage`.`bid_id` = 14984853 AND `jobsdone_privatemessage`.`reviewed` = 0 )
*** (1) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 875 page no 3418 n bits 1200 index `jobsdone_privatemessage_bid_id` of table `dj_beautifulmind_produser`.`jobsdone_privatemessage` trx id 20D26ECF lock_mode X locks rec but not gap waiting
*** (2) TRANSACTION:
TRANSACTION 20D26ED2, ACTIVE 1 sec, process no 651, OS thread id 139698604611328 starting index read
mysql tables in use 1, locked 1
14 lock struct(s), heap size 3112, 8 row lock(s), undo log entries 3
MySQL thread id 99844847, query id 7149616199 10.178.20.222 produser Updating
UPDATE `jobsdone_privatemessage` SET `time_read` = '2013-09-17 21:11:14', `reviewed` = 1 WHERE (`jobsdone_privatemessage`.`bid_id` = 14984853 AND `jobsdone_privatemessage`.`reviewed` = 0 )
*** (2) HOLDS THE LOCK(S):
RECORD LOCKS space id 875 page no 3418 n bits 1200 index `jobsdone_privatemessage_bid_id` of table `dj_beautifulmind_produser`.`jobsdone_privatemessage` trx id 20D26ED2 lock_mode X locks rec but not gap
*** (2) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 875 page no 3418 n bits 1200 index `jobsdone_privatemessage_bid_id` of table `dj_beautifulmind_produser`.`jobsdone_privatemessage` trx id 20D26ED2 lock_mode X locks rec but not gap waiting
*** WE ROLL BACK TRANSACTION (1)
</pre></font>

This is the result of double-execution of the following django code:
<pre>messages = self.filter(bid=bid, reviewed=False)
messages.update(reviewed=True, time_read=datetime.utcnow())</pre>
Because django's query sets are lazy, this all gets translated into a single query:
<pre>UPDATE `jobsdone_privatemessage`
 SET `time_read` = '2013-09-17 21:11:14', `reviewed` = 1
 WHERE (`jobsdone_privatemessage`.`bid_id` = 14984853
  AND   `jobsdone_privatemessage`.`reviewed` = 0 )</pre>

One way to fix this deadlock (apart from fixing the original double-click that caused it) is to replace
<pre>
messages.update(reviewed=True, time_read=datetime.utcnow())
</pre>
with
<pre>
messages = list(messages.values_list('pk', flat=True))
messages.sort()
messages = PrivateMessage.objects.filter(pk__in=messages)
messages.update(reviewed=True, time_read=datetime.utcnow())
</pre>
This explicitly orders the rows that the query will access, giving the database no opportunity to develop lock dependency cycles.


