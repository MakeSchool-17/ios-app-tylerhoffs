Planning: https://docs.google.com/spreadsheets/d/1-IO_4kZzq9tRX8e6ZM2k91JYdhKrvihPDY2oYWoJMZc/edit?usp=sharing

#App Design Document


##Objective
Create an app that makes it easy for users to find the nearest available public transport service which they can use to get from point A to point B. This will include Bus and Train services available.

##Audience
People in the South Africa who are currently not using public transport because it is too complicated or hard to use. And to those who only use the services they know how to. This can apply to people of all ages, but mostly from an upper middle class background who are not accustomed to using public transport.

##Experience
The user will open the app when they are looking for guidance on how to use public transport to get to some destination. They will be greeted by a splash screen and then a map with all the nearby bus/train station will be displayed. Upon searching/selecting a destination, a new screen will be displayed showing the available routes the user can take to get there.

##Technical

####External Services
•Google Maps Api
•Custom Flask Server
•REST API from https://rwt.to/
•Parse if users are implemented

####Screens
•Splash/Intro screen - automatically move to the next screen.
•Home/Map screen - map showing stations and their location - Clicking on or searching their destination will take them to the next screen
•Route screen - shows routes available from location to destination.


####Views / View Controllers/ Classes
•HomeViewController - map view with bus stations and your location
•StationViewController - show map with with routes, which pass through that station, marked out. User can click on route to see detailed description

####Data Models
Station: 
  -ID
  -GeoLocation
  -[Routes]

Route:
  -ID
  -Name
  -Intersection?
  
##MVP Milestones
####Week 1
•Wireframe Model
•Database structure
•All bus stops details

####Week 2
•UI Prototypes
•Begin server/database implementation
