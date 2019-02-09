# polytable-Mobile app for polytable.ru
Simple mobile app created with Dart 2.1 and Flutter.

## Table of contents
* [General info](#general-info)
  * [Main page](#main-page)
  * [Group page](#group-page)
  * [Access to Java method](#access-to-java-method)
* [Screensohts](#screenshots)
* [Getting Started](#getting-started)

## General info
At the moment, the application consists of two pages - the start (main) and group page with direct navigation between them.
On the main page, the user in the search bar can indicate the number of the group he needs, then an asynchronous request is sent to us to the server, the application receives a response in JSON format and displays the list of groups found by the request.

### Main page
#### Async request
Below is a function that forms and processes a request to the server API.
```dart
void _findGroups(String group) async {
  results.clear();
  final String url = "https://polytable.ru/search.php?query=";
  String query = url + group.trim();
  await http.get(query)
      .then((response) =>
          json.decode(utf8.decode(response.bodyBytes))
            .forEach((element) => results.add(new SearchResult(
              name: element['name'],
              faculty_abbr: element['faculty_abbr']))))
      .catchError((e) => print(e));

```
### Group page
The group page contains the schedule received by asynchronous request to the same server and the subsequent response from it, as well as a calendar for easy navigation between days. Navigation between days is available using both the calendar and right and left gestures.
Weeks are PageViews, which can be scrolled endlessly to the right and left.
Every day is a GridView, which can be scrolled down and up, if not all pairs fit in the screen. And also, depending on the orientation of the screen, the number of columns is either 1 or 2.
The display of each individual pair is implemented by the Lesson class, which inherits the StatefullWidget class, which stores the name, type, and other data about the lesson. This class contains only one method that builds a page directly from all available data.
#### Lesson class
```dart
class Lesson extends StatefulWidget {
  const Lesson(
      {this.title,
      this.type,
      this.time_start,
      this.time_end,
      this.teachers,
      this.places});

  final String title;
  final String type;
  final String time_start;
  final String time_end;
  final List<dynamic> teachers;
  final List<dynamic> places;

  @override
  _LessonState createState() => new _LessonState();
}
```

### Access to Java method
The peculiarity of the implementation of the Web application API, namely, the need to know an even or odd week to build its schedule for the two existing weeks, forced us to implement or use the method to obtain the week number of the year.
Since Flutter does not provide such a method, it was decided to use the so-called channel between Flutter and Java. In the MainActivity.java class, a method was written that returns the week number of the year.
#### getWeekNumber(Java method)
```java
private int getWeekNumber(String date) {
  SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
  try {
    Date d = format.parse(date);

    Calendar c = Calendar.getInstance();
    c.setTime(d);

    return c.get(Calendar.WEEK_OF_YEAR);
  } catch (Exception e) {
    return -1;
  }
}
```
#### Channel implementation(Java)
```java
new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
        new MethodCallHandler() {
          @Override
          public void onMethodCall(MethodCall call, Result result)  {
            if (call.method.equals("getWeekNumber")) {
              int weekNumber = getWeekNumber(call.argument("date").toString());
              System.out.println(weekNumber);
              if (weekNumber == -1)
                result.error("ERROR", "Wrong data format present", null);
              result.success(weekNumber);
            } else {
              result.notImplemented();
            }
          }
        }
);
```
#### Channel Access Function (Dart)
```dart
static Future<int> getWeek(String date) async {
  int weekday = -1;

  await _channel.invokeMethod("getWeekNumber", <String, String>{
    "date" : date
  }).then((v) => weekday = v);

  return weekday;
}
```
#### Usage of methods
```dart
bool isOdd =  (await getWeek(key) - staticStartWeek) % 2 == 0;
```

## Screenshots
### Main page
![image](https://user-images.githubusercontent.com/20505376/52518828-4fdfe080-2c62-11e9-882e-88889ce26737.png) ![image](https://user-images.githubusercontent.com/20505376/52518830-5e2dfc80-2c62-11e9-86cd-891b86f228a0.png) ![image](https://user-images.githubusercontent.com/20505376/52518840-89185080-2c62-11e9-8d80-618ac590783b.png) ![image](https://user-images.githubusercontent.com/20505376/52518841-8b7aaa80-2c62-11e9-9668-ade829792448.png) 
### Group page
![image](https://user-images.githubusercontent.com/20505376/52518844-8d446e00-2c62-11e9-83d7-ddf00c685bbe.png) ![image](https://user-images.githubusercontent.com/20505376/52518847-903f5e80-2c62-11e9-86a5-baf1cae5b066.png) ![image](https://user-images.githubusercontent.com/20505376/52518848-92092200-2c62-11e9-9e28-2312b114af7a.png) ![image](https://user-images.githubusercontent.com/20505376/52518851-946b7c00-2c62-11e9-815a-c395e2802631.png)
### Horisontal mode
![image](https://user-images.githubusercontent.com/20505376/52518853-96353f80-2c62-11e9-9f23-588bcc1bc348.png) ![image](https://user-images.githubusercontent.com/20505376/52518855-97ff0300-2c62-11e9-8087-9d10cb102d9c.png)

## Getting Started
For help getting started with Flutter, view our online
[documentation](https://flutter.io/).
