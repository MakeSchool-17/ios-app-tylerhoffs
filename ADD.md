#App Design Document


##Objective
Create an app that makes it easy for users to find the nearest bust stop. The app will also show where they can go from this bus stop or which routes to use to get to their desination.

##Audience
People in the South Africa who are currently not using public transport because it is too complicated or hard to use. This can apply to people of all ages, but mostly from an upper middle class background who are not accustomed to using public transport.

##Experience
The user will open the app when they are looking for directions to the nearest bus station. They will be greated by a splash screen and then a map with all the nearby bus stops will be displayed. Upon selecting a bus stop, a new screen will be shown with details about the routes that use that bus stop. The user can select a route to display it on a map and determine if it is suitable for them.

##Technical

####External Services
•Google Maps Api
•Custom Flask Server

####Screens
•Splash/Intro screen - automatically move to the next screen.
•Home/Map screen - map showing bus stations and their location - clicking on a bus station will move them to the next screen.
•Bus station screen - shows routes from bus station on a map.


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
