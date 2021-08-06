import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:weatherapp/constants.dart';
import 'package:weatherapp/credentials.dart';
import 'package:weatherapp/utils/location.dart';
import 'package:weatherapp/utils/dailyweather.dart';

//Setting icon and background image
class WeatherDisplayData{
  Icon weatherIcon;
  AssetImage weatherImage;

  WeatherDisplayData({required this.weatherIcon, required this.weatherImage});
}

//Request weather from the API on lat/long
class WeatherData{
  WeatherData({required this.locationData});
  LocationHelper locationData;

  //List for daily/hourly cards
  List<DailyWeather> dailyWeatherCards = [];
  //List<HourlyWeather> hourlyWeathercards = [];

  //Current weather values
  double currentTemp = 0.0;
  double currentTempMin = 0.0;
  double currentTempMax = 0.0;
  double currentWindSpeed = 0.0;

  String currentDescription = "";
  String currentLocation = "";
  String currentCountry = "";

  int currentCon = 0;
  int currentHumidity = 0;

  //Daily weather values
  dynamic maxTemp;
  dynamic minTemp;

  //Future settings switch
  String appLang = "en";
  String appUnits = "metric";

  Future<void> getCurrentTemperature() async{
    Response response = await get(
      //One call API. Returns more data than the standard data
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=${locationData.latitude}&lon=${locationData.longitude}&exclude=&appid=${apiKey}&units=${appUnits}&lang=${appLang}'
        )
    );

    //Return the weather values
    if(response.statusCode == 200){
      String data = response.body;
      var currentWeather = jsonDecode(data);
      try{
        currentTemp = currentWeather['current']['temp'];
        currentTempMin = currentWeather['daily'][0]['temp']['min'];
        currentTempMax = currentWeather['daily'][0]['temp']['max'];
        currentWindSpeed = currentWeather['current']['wind_speed'];
        currentDescription = currentWeather['current']['weather'][0]['description'];
        currentCon = currentWeather['current']['weather']['id'];
        currentHumidity = currentWeather['current']['humidity'];
      }catch(e){
        print("Exception: $e");
      }
    }else{
      print('Error: Unable to fetch weather data');
    }
  }

  //Daily weather values - Check against inspiration later since changed function a lot
  void getDailyWeather(dynamic response){
    List<dynamic> jsonDays = response['daily'];
    jsonDays.forEach((day){
      dailyWeatherCards.add(
        DailyWeather(
          weekday: kWeekdays.toString()[
              DateTime.fromMillisecondsSinceEpoch(day['dt'] * 1000).weekday],
          conditionWeather: day['weather'][0]['id'],
          maxTemp: day['temp']['max'].round(),
          minTemp: day['temp']['min'].round(),
        ),
      );
    });
    print('Daily MaxTemp: $maxTemp - MinTemp: $minTemp');
  }

  //Icon changing based on weather
  //To Do: Maybe update into switch statement and take into account more conditions (Sun + Cloud, Snow, Fog)
  //Kinda crazy? How about splitting background. Making a dayscape and nightscape, then if cloudy we add more to sky? Madness
  WeatherDisplayData getWeatherDisplayData(){
    if(currentCon < 600){
      return WeatherDisplayData(
        weatherIcon: kCloudIcon,
        weatherImage: AssetImage('assets/backgroundnight.png'),
      );
    }else{
      var currentTime = new DateTime.now();
      if(currentTime.hour >= 19){
        return WeatherDisplayData(
          weatherIcon: kMoonIcon,
          weatherImage: AssetImage('assets/backgroundnight.png'),
          );
      }else{
        return WeatherDisplayData(
          weatherIcon: kSunIcon,
          weatherImage: AssetImage('assets/backgroundday.png'),
        );
      }
    }
  }

  /*
  New Switch case for changing the icons
  Removing moon icon from rotation, replacing with day/night wallpaper

  Idea for expansion is dynamic image creation for background
  This will work by checking ID and adjusting overlays, then building into an image
  _____________________________________________________________________________________

  WeatherDisplayData getWeatherDisplayData(){
    //On case of basic description matching string
    Switch(currentMain){
      case "Thunderstorm":
        weatherIcon: kRainIcon
        print("Thunderstorm");
        break;
      case "Drizzle":
        weatherIcon: kRainIcon
        print("Drizzle");
        break;
      case "Rain":
        weatherIcon: kRainIcon
        print("Rain");
        break;
      case "Snow":
        weatherIcon: kSnowIcon
        print("Snow");
        break;
      case "Atmosphere":
        weatherIcon: kSunIcon
        print("Atmosphere");
        break;
      case "Clear":
        weatherIcon: kSunIcon
        print("Clear");
        break;
      case "Clouds":
        weatherIcon: kCloudIcon
        print("Clouds");
        break;
      }

      var currentTime = DateTime.now;
      if(currentTime.now >= 19)
      {
        weatherImage: AssetImage('assets/backgroundnight.png')
      } else
      {
        weatherImage: AssetImage('assets/backgroundday.png')
      }
    }
    */
  
}