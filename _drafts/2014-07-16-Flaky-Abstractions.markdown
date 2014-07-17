---
layout: post
title: "Flaky Abstractions"
author: Lorenzo Gil Sanchez
author_avatar: http://www.redbeacon.com/media/about/images/Lorenzo.jpg
excerpt: "Abstractions are a very powerful tool but they can also be traps if you don't understand them."
---


Last week I got hit by a bug in my Django application due to a misunderstanding of how an API was working. In this post I'll talk about this particular case, but the big picture is about the need to understand the inner workings of the tools you use. Just because an abstraction saves you a lot of work does not mean you shouldn't make the effort to understand what that function is really doing under the hood. Otherwise you get bitten sooner or later.

So, let's talk about Django ORM and its query language.

Say we have this model in our app:

    class President(models.Model):
        first_name = models.CharField(max_length=255)
        middle_name = models.CharField(max_length=255, blank=True, null=False)
        last_name = models.CharField(max_length=255)

And let's say we are going to find us presidents by their first name:

    >>> query1 = President.objects.filter(first_name='John')
    >>> query1
    [<President: John  Adams>, <President: John Quincy Adams>, <President: John  Tyler>, <President: John F. Kennedy>]

It's easy to see how this gets translated into this SQL query:

    >>> print(query1.query)
    SELECT "presidents_president"."id", "presidents_president"."first_name", "presidents_president"."middle_name", "presidents_president"."last_name"
    FROM "presidents_president"
    WHERE "presidents_president"."first_name" = John

Now, let's say we want to find all the presidents whose first name is John and last name is Adams. Easy, right?

    >>> query2 = President.objects.filter(first_name='John', last_name='Adams')
    >>> query2
    [<President: John  Adams>, <President: John Quincy Adams>]

which gets translated into this SQL statement:

    >>> print(query2.query)
    SELECT "presidents_president"."id", "presidents_president"."first_name", "presidents_president"."middle_name", "presidents_president"."last_name"
    FROM "presidents_president"
    WHERE ("presidents_president"."first_name" = John  AND "presidents_president"."last_name" = Adams )

Ok, how about we write that query with a slightly different syntax:

    >>> query3 = President.objects.filter(first_name='John').filter(last_name='Adams')
    >>> query3
    [<President: John  Adams>, <President: John Quincy Adams>]

Django translates that query to the same SQL, which is probably what we want:

    >>> print(query3.query)
    SELECT "presidents_president"."id", "presidents_president"."first_name", "presidents_president"."middle_name", "presidents_president"."last_name"
    FROM "presidents_president"
    WHERE ("presidents_president"."first_name" = John  AND "presidents_president"."last_name" = Adams )

So, at this point you think you understand how the filter() method works and you think you can throw any attribute clause and it will just do the AND of all of them.

Well, think again. If you do a query that spawns relationships, the whole picture changes, and now chaining the filter calls may give you different results.

Let's add a few new models:

    class Party(models.Model):
        name = models.CharField(max_length=255)

    class State(models.Model):
        name = models.CharField(max_length=255)

    class Tenure(models.Model):
        president = models.ForeignKey(President)
        state = models.ForeignKey(State)
        party = models.ForeignKey(Party)
        start_year = models.PositiveSmallIntegerField()
        end_year = models.PositiveSmallIntegerField()

Now we want to know what states gave a Democratic president before 1900. My first query:

    >>> query4 = State.objects.filter(tenure__party__name='Democratic', tenure__start_year__lt=1900).distinct()
    [<State: Tennessee>, <State: New York>, <State: North Carolina>, <State: New Hampshire>, <State: Pennsylvania>]

is actually working but this one will give me different results:

    >>> query5 = State.objects.filter(tenure__party__name='Democratic').filter(tenure__start_year__lt=1900).distinct()
    [<State: Massachusetts>, <State: Tennessee>, <State: New York>, <State: North Carolina>, <State: New Hampshire>, <State: Pennsylvania>, <State: Illinois>]

So, let's take a look of what the SQL queries look in each case:

    >>> print(query4.query)
    SELECT DISTINCT "presidents_state"."id", "presidents_state"."name"
    FROM "presidents_state" INNER JOIN "presidents_tenure" ON ( "presidents_state"."id" = "presidents_tenure"."state_id" )
                            INNER JOIN "presidents_party" ON ( "presidents_tenure"."party_id" = "presidents_party"."id" )
    WHERE ("presidents_party"."name" = Democratic  AND "presidents_tenure"."start_year" < 1900 )

    >>> print(query5.query)
    SELECT DISTINCT "presidents_state"."id", "presidents_state"."name"
    FROM "presidents_state" INNER JOIN "presidents_tenure" ON ( "presidents_state"."id" = "presidents_tenure"."state_id" )
                            INNER JOIN "presidents_party" ON ( "presidents_tenure"."party_id" = "presidents_party"."id" )
                            INNER JOIN "presidents_tenure" T4 ON ( "presidents_state"."id" = T4."state_id" )
    WHERE ("presidents_party"."name" = Democratic  AND T4."start_year" < 1900 )

So you can see there is an extra INNER JOIN in query 5. Basically every time you chain a filter() call to your query that traverses a relationship, you are performing an extra INNER JOIN, which is not only bad for performance reasons but also is going to give you unexpected results.

Let's see what happens with real data. This is a table of all presidencies that started before 1900.

<table class="table table-stripped">
  <theader>
    <tr>
        <th>ID</th>
        <th>President</th>
        <th>State</th>
        <th>Party</th>
        <th>Start year</th>
        <th>End year</th>
    </tr>
  </theader>
  <tbody>
    <tr>
      <td>1</td>
      <td>George  Washington</td>
      <td>Virginia</td>
      <td>No party</td>
      <td>1789</td>
      <td>1797</td>
    </tr>
    <tr>
      <td>2</td>
      <td>John  Adams</td>
      <td>Massachusetts</td>
      <td>Federalist</td>
      <td>1797</td>
      <td>1801</td>
    </tr>
    <tr>
      <td>3</td>
      <td>Thomas  Jefferson</td>
      <td>Virginia</td>
      <td>Democratic-Republican</td>
      <td>1801</td>
      <td>1809</td>
    </tr>
    <tr>
      <td>4</td>
      <td>James  Madison</td>
      <td>Virginia</td>
      <td>Democratic-Republican</td>
      <td>1809</td>
      <td>1817</td>
    </tr>
    <tr>
      <td>5</td>
      <td>James  Monroe</td>
      <td>Virginia</td>
      <td>Democratic-Republican</td>
      <td>1817</td>
      <td>1825</td>
    </tr>
    <tr>
      <td>6</td>
      <td>John Quincy Adams</td>
      <td>Massachusetts</td>
      <td>Democratic-Republican</td>
      <td>1825</td>
      <td>1829</td>
    </tr>
    <tr>
      <td>7</td>
      <td>Andrew  Jackson</td>
      <td>Tennessee</td>
      <td>Democratic</td>
      <td>1829</td>
      <td>1837</td>
    </tr>
    <tr>
      <td>8</td>
      <td>Martin Van Buren</td>
      <td>New York</td>
      <td>Democratic</td>
      <td>1837</td>
      <td>1841</td>
    </tr>
    <tr>
      <td>9</td>
      <td>William Henry Harrison</td>
      <td>Virginia</td>
      <td>Whig</td>
      <td>1841</td>
      <td>1841</td>
    </tr>
    <tr>
      <td>10</td>
      <td>John  Tyler</td>
      <td>Virginia</td>
      <td>Whig</td>
      <td>1841</td>
      <td>1845</td>
    </tr>
    <tr>
      <td>11</td>
      <td>James K. Polk</td>
      <td>North Carolina</td>
      <td>Democratic</td>
      <td>1845</td>
      <td>1849</td>
    </tr>
    <tr>
      <td>12</td>
      <td>Zachary  Taylor</td>
      <td>Kentucky</td>
      <td>Whig</td>
      <td>1849</td>
      <td>1850</td>
    </tr>
    <tr>
      <td>13</td>
      <td>Millard  Fillmore</td>
      <td>New York</td>
      <td>Whig</td>
      <td>1850</td>
      <td>1853</td>
    </tr>
    <tr>
      <td>14</td>
      <td>Franklin  Pierce</td>
      <td>New Hampshire</td>
      <td>Democratic</td>
      <td>1853</td>
      <td>1857</td>
    </tr>
    <tr>
      <td>15</td>
      <td>James  Buchanan</td>
      <td>Pennsylvania</td>
      <td>Democratic</td>
      <td>1857</td>
      <td>1861</td>
    </tr>
    <tr>
      <td>16</td>
      <td>Abraham  Lincoln</td>
      <td>Illinois</td>
      <td>Republican</td>
      <td>1861</td>
      <td>1865</td>
    </tr>
    <tr>
      <td>17</td>
      <td>Andrew  Johnson</td>
      <td>Tennessee</td>
      <td>Democratic</td>
      <td>1865</td>
      <td>1869</td>
    </tr>
    <tr>
      <td>18</td>
      <td>Ulysses S. Grant</td>
      <td>Ohio</td>
      <td>Republican</td>
      <td>1869</td>
      <td>1877</td>
    </tr>
    <tr>
      <td>19</td>
      <td>Rutherford B. Hayes</td>
      <td>Ohio</td>
      <td>Republican</td>
      <td>1877</td>
      <td>1881</td>
    </tr>
    <tr>
      <td>20</td>
      <td>James  Garfield</td>
      <td>Ohio</td>
      <td>Republican</td>
      <td>1881</td>
      <td>1881</td>
    </tr>
    <tr>
      <td>21</td>
      <td>Chester  Arthur</td>
      <td>Vermont</td>
      <td>Republican</td>
      <td>1881</td>
      <td>1885</td>
    </tr>
    <tr>
      <td>22</td>
      <td>Grover  Cleveland</td>
      <td>New York</td>
      <td>Democratic</td>
      <td>1885</td>
      <td>1889</td>
    </tr>
    <tr>
      <td>23</td>
      <td>Benjamin  Harrison</td>
      <td>Ohio</td>
      <td>Republican</td>
      <td>1889</td>
      <td>1893</td>
    </tr>
    <tr>
      <td>24</td>
      <td>Grover  Cleveland</td>
      <td>New York</td>
      <td>Democratic</td>
      <td>1893</td>
      <td>1897</td>
    </tr>
    <tr>
      <td>25</td>
      <td>William  McKinley</td>
      <td>Ohio</td>
      <td>Republican</td>
      <td>1897</td>
      <td>1901</td>
    </tr>
  </tbody>
</table>

Now let's keep only the Democratic ones:

<table class="table table-stripped">
  <theader>
    <tr>
        <th>ID</th>
        <th>President</th>
        <th>State</th>
        <th>Party</th>
        <th>Start year</th>
        <th>End year</th>
    </tr>
  </theader>
  <tbody>
    <tr>
      <td>7</td>
      <td>Andrew  Jackson</td>
      <td>Tennessee</td>
      <td>Democratic</td>
      <td>1829</td>
      <td>1837</td>
    </tr>
    <tr>
      <td>8</td>
      <td>Martin Van Buren</td>
      <td>New York</td>
      <td>Democratic</td>
      <td>1837</td>
      <td>1841</td>
    </tr>
    <tr>
      <td>11</td>
      <td>James K. Polk</td>
      <td>North Carolina</td>
      <td>Democratic</td>
      <td>1845</td>
      <td>1849</td>
    </tr>
    <tr>
      <td>14</td>
      <td>Franklin  Pierce</td>
      <td>New Hampshire</td>
      <td>Democratic</td>
      <td>1853</td>
      <td>1857</td>
    </tr>
    <tr>
      <td>15</td>
      <td>James  Buchanan</td>
      <td>Pennsylvania</td>
      <td>Democratic</td>
      <td>1857</td>
      <td>1861</td>
    </tr>
    <tr>
      <td>17</td>
      <td>Andrew  Johnson</td>
      <td>Tennessee</td>
      <td>Democratic</td>
      <td>1865</td>
      <td>1869</td>
    </tr>
    <tr>
      <td>22</td>
      <td>Grover  Cleveland</td>
      <td>New York</td>
      <td>Democratic</td>
      <td>1885</td>
      <td>1889</td>
    </tr>
    <tr>
      <td>24</td>
      <td>Grover  Cleveland</td>
      <td>New York</td>
      <td>Democratic</td>
      <td>1893</td>
      <td>1897</td>
    </tr>
  </tbody>
</table>

Let's focus on the state and party columns and run a SQL query similar to query 5:

    sqlite> SELECT DISTINCT presidents_tenure.id, presidents_party.name, presidents_state.name FROM presidents_state INNER JOIN presidents_tenure ON ( presidents_state.id = presidents_tenure.state_id ) INNER JOIN presidents_party ON ( presidents_tenure.party_id = presidents_party.id ) WHERE (presidents_party.name = "Democratic" AND presidents_tenure.start_year < 1900 );
    7|Democratic|Tennessee
    8|Democratic|New York
    11|Democratic|North Carolina
    14|Democratic|New Hampshire
    15|Democratic|Pennsylvania
    17|Democratic|Tennessee
    22|Democratic|New York
    24|Democratic|New York

The states are correct, and they answer our question. But if we do it with a SQL query similar to query 6, we start to understand why that query was not right:

    sqlite> SELECT DISTINCT presidents_tenure.id, presidents_party.name, presidents_state.name, T4.id FROM presidents_state INNER JOIN presidents_tenure ON ( presidents_state.id = presidents_tenure.state_id ) INNER JOIN presidents_party ON ( presidents_tenure.party_id = presidents_party.id ) INNER JOIN presidents_tenure T4 ON ( presidents_state.id = T4.state_id ) WHERE (presidents_party.name = "Democratic"  AND T4.start_year < 1900 );
    7|Democratic|Tennessee|7
    7|Democratic|Tennessee|17
    8|Democratic|New York|8
    8|Democratic|New York|13
    8|Democratic|New York|22
    8|Democratic|New York|24
    11|Democratic|North Carolina|11
    14|Democratic|New Hampshire|14
    15|Democratic|Pennsylvania|15
    17|Democratic|Tennessee|7
    17|Democratic|Tennessee|17
    22|Democratic|New York|8
    22|Democratic|New York|13
    22|Democratic|New York|22
    22|Democratic|New York|24
    24|Democratic|New York|8
    24|Democratic|New York|13
    24|Democratic|New York|22
    24|Democratic|New York|24
    32|Democratic|New York|8
    32|Democratic|New York|13
    32|Democratic|New York|22
    32|Democratic|New York|24
    35|Democratic|Massachusetts|2
    35|Democratic|Massachusetts|6
    44|Democratic|Illinois|16

As you can see the extra inner join is duplicating a lot of rows.

There is actually a hack that you can do if you really need to chain your filter calls. There is an undocumented feature in Django ORM that allows you to avoid extra joins by making the filter calls 'sticky'. Use it at your own risk:

    >>> State.objects.all()._next_is_sticky().filter(tenure__party__name='Democratic').filter(tenure__start_year__lt=1900).distinct()
    [<State: Tennessee>, <State: New York>, <State: North Carolina>, <State: New Hampshire>, <State: Pennsylvania>]

Hopefully this will show how important is to know and understand what the ORM (the abstraction) is doing here. Sometimes you can put all your criteria in a single filter() call but sometimes your code does not allow you to do that easily and you need to understand that chaining filter calls is not going to be the same. For example, if you have a REST API and you decided to implement it using the great Django REST framework you may also want to use Django Filter which allows you to define the filters the users of your API are going to have available. So remember that if you are doing simple filters you should be fine but if you are doing filters that spawn relationships as in the previous example then this abstraction is going to be a leaky one.

Now it's time to understand what that piece of code that you copied from Stackoverflow actually does :-)
